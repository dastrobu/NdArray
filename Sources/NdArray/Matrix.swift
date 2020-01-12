//
// Created by Daniel Strobusch on 2019-05-07.
//

import Darwin
import Accelerate

public class Matrix<T>: NdArray<T> {

    /// flag to indicate if this matrix is a square matrix
    var isSquare: Bool {
        return shape[0] == shape[1]
    }

    /// create an 2D NdArray from a plain array
    public convenience init(_ a: [[T]], order: Contiguous = .C) {
        guard let first = a.first else {
            self.init(empty: [1, 0], order: order)
            return
        }

        let rowCount = a.count
        let colCount = first.count
        self.init(empty: [rowCount, colCount], order: order)

        switch order {
        case .C:
            for i in 0..<rowCount {
                let row = a[i]
                assert(row.count == colCount, "\(row.count) == \(colCount) at row \(i)")
                memcpy(data + i * strides[0], row, colCount * MemoryLayout<T>.stride)
            }
        case .F:
            for i in 0..<rowCount {
                let row = a[i]
                assert(row.count == colCount, "\(row.count) == \(colCount) at row \(i)")
                // manual memcopy for strided data
                for j in 0..<colCount {
                    data[i * strides[0] + j * strides[1]] = row[j]
                }
            }
        }
    }

    public init(empty shape: [Int], order: Contiguous = .C) {
        assert(shape.count == 2,
            """
            Cannot create matrix with shape \(shape). Matrix must have two dimensions.
            """)
        super.init(empty: shape.isEmpty ? 0 : shape.reduce(1, *))
        reshape(shape, order: order)
    }

    /// creates a view on another array without copying any data
    public init(_ a: Matrix<T>) {
        super.init(a)
    }

    /// creates a view on another array without copying any data
    public required init(_ a: NdArray<T>) {
        assert(a.shape.count == 2,
            """
            Cannot create matrix with shape \(a.shape). Matrix must have two dimensions.
            Assertion failed while trying to init matrix from \(a.debugDescription).
            """)
        super.init(a)
    }

    internal required init(empty count: Int) {
        super.init(empty: count)
        // make pseudo 2d
        self.reshape([1] + shape)
    }

    public required convenience init(copy a: NdArray<T>) {
        assert(a.shape.count == 2,
            """
            Cannot create matrix with shape \(a.shape). Matrix must have two dimensions.
            Assertion failed while trying to copy \(a.debugDescription).
            """)
        self.init(empty: a.shape, order: a.isFContiguous ? .F : .C)
        a.copyTo(self)
    }

    /// returns a transposed array view.
    /// Note: if the matrix has an effective dimension of 0, transposition has no effect.
    public func transposed() -> Matrix<T> {
        let a = Matrix<T>(self)
        if effectiveNdim > 0 {
            a.shape = self.shape.reversed()
            a.strides = self.strides.reversed()
        }
        return a
    }

    /// transposes the array into another array.
    /// Note: if the matrix has an effective dimension of 0, transposition has no effect.
    public func transposed(out: Matrix<T>) {
        if effectiveNdim > 0 {
            assert(shape == out.shape.reversed(),
                """
                Cannot transpose matrix with shape \(shape) to matrix with shape \(out.shape).
                Assertion failed while trying to transpose \(self.debugDescription) to \(out.debugDescription).
                """)
            out[...][...] = self.transposed()[...][...]
        }
    }
}

public extension Matrix where T == Double {
    /// short hand form for `transposed()`
    var T: Matrix<T> {
        return transposed()
    }

    /// solve a system of linear equations
    /// - SeeAlso:
    ///   - `solve(x: Matrix<T>, out: Matrix<T>? = nil) throws -> Matrix<T>`
    @discardableResult
    func solve(_ rhs: Vector<T>, out: Vector<T>? = nil) throws -> Vector<T> {
        let n: Int = rhs.shape[0]
        let b = out ?? Vector(empty: n)
        try solve(Matrix(rhs.reshaped([n, 1], order: .F)), out: Matrix(b.reshaped([n, 1], order: .F), order: .F))
        return b;
    }

    /// solve a system of linear equations
    ///
    /// Solution is computed by LAPACKs DGESV methos which computes the solution to a real system of linear equations
    ///    A * X = B,
    /// where A is an N-by-N matrix and X and B are N-by-NRHS matrices.
    ///
    /// The LU decomposition with partial pivoting and row interchanges is
    /// used to factor A as
    ///    A = P * L * U,
    /// where P is a permutation matrix, L is unit lower triangular, and U is
    /// upper triangular.  The factored form of A is then used to solve the
    /// system of equations A * X = B.
    ///
    /// This array must be in column major storage.
    @discardableResult
    func solve(_ rhs: Matrix<T>, out: Matrix<T>? = nil) throws -> Matrix<T> {
        var n = Int32(shape[0])
        assert(isSquare,
            """
            Cannot solve for non square matrix with shape \(shape).
            Assertion failed while trying to solve \(self.debugDescription).
            """)

        let B = out ?? Matrix(empty: rhs.shape, order: .F)
        assert(B.isFContiguous,
            """
            Cannot use out array if not f contiguous.
            Given out array is \(B.debugDescription).
            """)
        assert(!rhs.overlaps(B),
            """
            Cannot use out array if it overlaps with x.
            x is \(rhs.debugDescription) and out is \(B.debugDescription).
            """)
        assert(rhs.shape[0] == n,
            """
            Cannot use x with shape \(rhs.shape) to solve with matrix \(debugDescription).
            """)

        if B.isEmpty {
            return B
        }
        // copy rhs to work space (thereby also making sure it is F contiguous)
        B[...] = rhs[...]

        // copy self to A, since it is modified (thereby also making sure it is F contiguous)
        let A = Matrix<T>(empty: self.shape, order: .F)
        A[...] = self[...]
        var nrhs = Int32(B.shape[1])
        var ipiv: [Int32] = [Int32].init(repeating: 0, count: Int(n))
        var lda: Int32 = Int32(n)
        var ldb = Int32(B.shape[0])
        var info: Int32 = 0
        dgesv_(&n, &nrhs, A.data, &lda, &ipiv, B.data, &ldb, &info)
        if info != 0 {
            throw LapackError.dgesv(info)
        }
        return B
    }

    /// Invert the matrix
    ///
    /// Inverse of the matrix is computed by LAPACKs SGETRI method which computes the inverse of a matrix using the
    /// LU factorization computed by DGETRF.
    ///
    /// This method inverts U and then computes inv(A) by solving the system
    /// inv(A)*L = inv(U) for inv(A).
    ///
    /// If an error occurred, the data in out may have been changed to any data.
    @discardableResult
    func inverted(out: Matrix<T>? = nil) throws -> Matrix<T> {
        var n = Int32(shape[0])
        assert(isSquare,
            """
            Cannot invert non square matrix with shape \(shape).
            Assertion failed while trying to solve \(self.debugDescription).
            """)
        let A = out ?? Matrix(empty: self.shape, order: .F)
        A[...] = self[...]

        var ipiv = try A.luFactor()

        var lda = Int32(n)
        var info: Int32 = 0

        // do optimal workspace query
        var lwork: Int32 = -1
        var work = [__CLPK_doublereal](repeating: 0.0, count: 1)
        dgetri_(&n, A.data, &lda, &ipiv, &work, &lwork, &info)
        if info != 0 {
            throw LapackError.getri(info)
        }

        // retrieve optimal workspace
        lwork = Int32(work[0])
        work = [__CLPK_doublereal](repeating: 0.0, count: Int(lwork))

        // do the inversion
        dgetri_(&n, A.data, &lda, &ipiv, &work, &lwork, &info)
        if info != 0 {
            throw LapackError.getri(info)
        }
        return A
    }

    /// Compute the LU factorization (in place) and return the pivot vector
    ///
    /// Factorization is computed by LAPACKs DGETRF method, which computes an LU factorization of a general
    /// M-by-N matrix A using partial pivoting with row interchanges.
    ///
    /// The factorization has the form
    ///    A = P * L * U
    /// where P is a permutation matrix, L is lower triangular with unit
    /// diagonal elements (lower trapezoidal if m > n), and U is upper
    /// triangular (upper trapezoidal if m < n).
    ///
    /// This is the right-looking Level 3 BLAS version of the algorithm.
    ///
    /// This array must be in column major storage.
    private func luFactor() throws -> [Int32] {
        // TODO: this is currently just a helper method for inverted, hence its private. Later a proper
        // LU factorization may be implemented, yielding P, L and U explicitly.
        assert(isFContiguous,
            """
            Cannot compute LU factorization if not f contiguous
            Given out array is \(self.debugDescription).
            """)
        var ipiv = [Int32](repeating: 0, count: Swift.min(shape[0], shape[1]))
        var m = Int32(shape[0])
        var n = Int32(shape[1])
        // leading dimension is the number of rows in column major order
        var lda = Int32(m)
        var info: Int32 = 0
        dgetrf_(&m, &n, data, &lda, &ipiv, &info)
        if info != 0 {
            throw LapackError.getrf(info)
        }
        return ipiv
    }

}

public extension Matrix where T == Float {
    /// short hand form for `transposed()`
    var T: Matrix<T> {
        return transposed()
    }

    /// solve a system of linear equations
    /// - SeeAlso:
    ///   - `solve(x: Matrix<T>, out: Matrix<T>? = nil) throws -> Matrix<T>`
    @discardableResult
    func solve(_ rhs: Vector<T>, out: Vector<T>? = nil) throws -> Vector<T> {
        let n: Int = rhs.shape[0]
        let b = out ?? Vector(empty: n)
        try solve(Matrix(rhs.reshaped([n, 1], order: .F)), out: Matrix(b.reshaped([n, 1], order: .F), order: .F))
        return b;
    }

    /// solve a system of linear equations
    ///
    /// Solution is computed by LAPACKs DGESV methos which computes the solution to a real system of linear equations
    ///    A * X = B,
    /// where A is an N-by-N matrix and X and B are N-by-NRHS matrices.
    ///
    /// The LU decomposition with partial pivoting and row interchanges is
    /// used to factor A as
    ///    A = P * L * U,
    /// where P is a permutation matrix, L is unit lower triangular, and U is
    /// upper triangular.  The factored form of A is then used to solve the
    /// system of equations A * X = B.
    ///
    /// This array must be in column major storage.
    @discardableResult
    func solve(_ rhs: Matrix<T>, out: Matrix<T>? = nil) throws -> Matrix<T> {
        var n = Int32(shape[0])
        assert(isSquare,
            """
            Cannot solve for non square matrix with shape \(shape).
            Assertion failed while trying to solve \(self.debugDescription).
            """)

        let B = out ?? Matrix(empty: rhs.shape, order: .F)
        assert(B.isFContiguous,
            """
            Cannot use out array if not f contiguous.
            Given out array is \(B.debugDescription).
            """)
        assert(!rhs.overlaps(B),
            """
            Cannot use out array if it overlaps with x.
            x is \(rhs.debugDescription) and out is \(B.debugDescription).
            """)
        assert(rhs.shape[0] == n,
            """
            Cannot use x with shape \(rhs.shape) to solve with matrix \(debugDescription).
            """)

        if B.isEmpty {
            return B
        }
        // copy rhs to work space (thereby also making sure it is F contiguous)
        B[...] = rhs[...]

        // copy self to A, since it is modified (thereby also making sure it is F contiguous)
        let A = Matrix<T>(empty: self.shape, order: .F)
        A[...] = self[...]
        var nrhs = Int32(B.shape[1])
        var ipiv: [Int32] = [Int32].init(repeating: 0, count: Int(n))
        var lda: Int32 = Int32(n)
        var ldb = Int32(B.shape[0])
        var info: Int32 = 0
        sgesv_(&n, &nrhs, A.data, &lda, &ipiv, B.data, &ldb, &info)
        if info != 0 {
            throw LapackError.dgesv(info)
        }
        return B
    }

    /// Invert the matrix
    ///
    /// Inverse of the matrix is computed by LAPACKs SGETRI method which computes the inverse of a matrix using the
    /// LU factorization computed by DGETRF.
    ///
    /// This method inverts U and then computes inv(A) by solving the system
    /// inv(A)*L = inv(U) for inv(A).
    ///
    /// If an error occurred, the data in out may have been changed to any data.
    @discardableResult
    func inverted(out: Matrix<T>? = nil) throws -> Matrix<T> {
        var n = Int32(shape[0])
        assert(isSquare,
            """
            Cannot invert non square matrix with shape \(shape).
            Assertion failed while trying to solve \(self.debugDescription).
            """)
        let A = out ?? Matrix(empty: self.shape, order: .F)
        A[...] = self[...]

        var ipiv = try A.luFactor()

        var lda = Int32(n)
        var info: Int32 = 0

        // do optimal workspace query
        var lwork: Int32 = -1
        var work = [__CLPK_real](repeating: 0.0, count: 1)
        sgetri_(&n, A.data, &lda, &ipiv, &work, &lwork, &info)
        if info != 0 {
            throw LapackError.getri(info)
        }

        // retrieve optimal workspace
        lwork = Int32(work[0])
        work = [__CLPK_real](repeating: 0.0, count: Int(lwork))

        // do the inversion
        sgetri_(&n, A.data, &lda, &ipiv, &work, &lwork, &info)
        if info != 0 {
            throw LapackError.getri(info)
        }
        return A
    }

    /// Compute the LU factorization (in place) and return the pivot vector
    ///
    /// Factorization is computed by LAPACKs DGETRF method, which computes an LU factorization of a general
    /// M-by-N matrix A using partial pivoting with row interchanges.
    ///
    /// The factorization has the form
    ///    A = P * L * U
    /// where P is a permutation matrix, L is lower triangular with unit
    /// diagonal elements (lower trapezoidal if m > n), and U is upper
    /// triangular (upper trapezoidal if m < n).
    ///
    /// This is the right-looking Level 3 BLAS version of the algorithm.
    ///
    /// This array must be in column major storage.
    private func luFactor() throws -> [Int32] {
        // TODO: this is currently just a helper method for inverted, hence its private. Later a proper
        // LU factorization may be implemented, yielding P, L and U explicitly.
        assert(isFContiguous,
            """
            Cannot compute LU factorization if not f contiguous
            Given out array is \(self.debugDescription).
            """)
        var ipiv = [Int32](repeating: 0, count: Swift.min(shape[0], shape[1]))
        var m = Int32(shape[0])
        var n = Int32(shape[1])
        // leading dimension is the number of rows in column major order
        var lda = Int32(m)
        var info: Int32 = 0
        sgetrf_(&m, &n, data, &lda, &ipiv, &info)
        if info != 0 {
            throw LapackError.getrf(info)
        }
        return ipiv
    }

}

// swiftlint:disable:next operator_whitespace
public func *(A: Matrix<Double>, x: Vector<Double>) -> Vector<Double> {
    let y = Vector<Double>(empty: x.shape[0])

    let a: Matrix<Double>
    let order: CBLAS_ORDER
    if A.isFContiguous {
        order = CblasColMajor
        a = Matrix(A, order: .F)
    } else {
        order = CblasRowMajor
        a = Matrix(A, order: .C)
    }

    let m: Int32 = Int32(a.shape[0])
    let n: Int32 = Int32(a.shape[1])
    let lda: Int32 = Int32(a.strides[1])
    let incX: Int32 = Int32(x.strides[0])
    let incY: Int32 = Int32(y.strides[0])
    cblas_dgemv(order, CblasNoTrans, m, n, 1, a.data, lda, x.data, incX, 0, y.data, incY)

    return y
}

// swiftlint:disable:next operator_whitespace
public func *(A: Matrix<Double>, B: Matrix<Double>) -> Matrix<Double> {
    let a: Matrix<Double>
    let b: Matrix<Double>
    let c: Matrix<Double>
    let order: CBLAS_ORDER
    if A.isFContiguous {
        order = CblasColMajor
        a = Matrix(A, order: .F)
        b = Matrix(B, order: .F)
        c = Matrix<Double>(empty: [A.shape[0], B.shape[1]], order: .F)
    } else {
        order = CblasRowMajor
        a = Matrix(A, order: .C)
        b = Matrix(B, order: .C)
        c = Matrix<Double>(empty: [A.shape[0], B.shape[1]], order: .C)
    }

    let m: Int32 = Int32(a.shape[0])
    let n: Int32 = Int32(b.shape[1])
    let k: Int32 = Int32(a.shape[1])
    let lda: Int32 = Int32(a.shape[0])
    let ldb: Int32 = Int32(b.shape[0])
    let ldc: Int32 = Int32(c.shape[0])
    cblas_dgemm(order, CblasNoTrans, CblasNoTrans, m, n, k, 1, a.data, lda, b.data, ldb, 0, c.data, ldc)
    return c
}

// TODO override for band/tridiag matrix

// swiftlint:disable:next operator_whitespace
public func *(A: Matrix<Float>, x: Vector<Float>) -> Vector<Float> {
    let y = Vector<Float>(empty: x.shape[0])

    let a: Matrix<Float>
    let order: CBLAS_ORDER
    if A.isFContiguous {
        order = CblasColMajor
        a = Matrix(A, order: .F)
    } else {
        order = CblasRowMajor
        a = Matrix(A, order: .C)
    }

    let m: Int32 = Int32(a.shape[0])
    let n: Int32 = Int32(a.shape[1])
    let lda: Int32 = Int32(a.strides[1])
    let incX: Int32 = Int32(x.strides[0])
    let incY: Int32 = Int32(y.strides[0])
    cblas_sgemv(order, CblasNoTrans, m, n, 1, a.data, lda, x.data, incX, 0, y.data, incY)

    return y
}

// swiftlint:disable:next operator_whitespace
public func *(A: Matrix<Float>, B: Matrix<Float>) -> Matrix<Float> {
    let a: Matrix<Float>
    let b: Matrix<Float>
    let c: Matrix<Float>
    let order: CBLAS_ORDER
    if A.isFContiguous {
        order = CblasColMajor
        a = Matrix(A, order: .F)
        b = Matrix(B, order: .F)
        c = Matrix<Float>(empty: [A.shape[0], B.shape[1]], order: .F)
    } else {
        order = CblasRowMajor
        a = Matrix(A, order: .C)
        b = Matrix(B, order: .C)
        c = Matrix<Float>(empty: [A.shape[0], B.shape[1]], order: .C)
    }

    let m: Int32 = Int32(a.shape[0])
    let n: Int32 = Int32(b.shape[1])
    let k: Int32 = Int32(a.shape[1])
    let lda: Int32 = Int32(a.shape[0])
    let ldb: Int32 = Int32(b.shape[0])
    let ldc: Int32 = Int32(c.shape[0])
    cblas_sgemm(order, CblasNoTrans, CblasNoTrans, m, n, k, 1, a.data, lda, b.data, ldb, 0, c.data, ldc)
    return c
}
