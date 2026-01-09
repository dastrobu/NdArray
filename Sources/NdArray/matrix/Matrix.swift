//
// Created by Daniel Strobusch on 2019-05-07.
//

import Darwin
import Accelerate

/// Special NdArray subtype for two dimensional data.
open class Matrix<T>: NdArray<T>, Sequence {

    /// flag to indicate if this matrix is a square matrix
    var isSquare: Bool {
        shape[0] == shape[1]
    }

    public convenience init(_ a: [[T]]) {
        self.init(a, order: .C)
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
                precondition(row.count == colCount, "\(row.count) == \(colCount) at row \(i)")
                row.withUnsafeBufferPointer { p in
                    if let base = p.baseAddress {
                        memcpy(dataStart + i * strides[0], base, colCount * MemoryLayout<T>.stride)
                    }
                }
            }
        case .F:
            for i in 0..<rowCount {
                let row = a[i]
                precondition(row.count == colCount, "\(row.count) == \(colCount) at row \(i)")
                // manual memcopy for strided data
                for j in 0..<colCount {
                    dataStart[i * strides[0] + j * strides[1]] = row[j]
                }
            }
        }
    }

    public init(empty shape: [Int], order: Contiguous = .C) {
        precondition(shape.count == 2,
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
        precondition(a.shape.count == 2,
            """
            Cannot create matrix with shape \(a.shape). Matrix must have two dimensions.
            Precondition failed while trying to init matrix from \(a.debugDescription).
            """)
        super.init(a)
    }

    public required init(empty count: Int) {
        super.init(empty: count)
        // make pseudo 2d
        reshape([1] + shape)
    }

    public required convenience init(copy a: NdArray<T>) {
        precondition(a.shape.count == 2,
            """
            Cannot create matrix with shape \(a.shape). Matrix must have two dimensions.
            Precondition failed while trying to copy \(a.debugDescription).
            """)
        self.init(empty: a.shape, order: a.isFContiguous ? .F : .C)
        a.copyTo(self)
    }

    /// returns a transposed array view.
    /// Note: if the matrix has an effective dimension of 0, transposition has no effect.
    public func transposed() -> Matrix<T> {
        let a = Matrix<T>(self)
        if effectiveNdim > 0 {
            a.shape = shape.reversed()
            a.strides = strides.reversed()
        }
        return a
    }

    /// transposes the array into another array.
    /// Note: if the matrix has an effective dimension of 0, transposition has no effect.
    public func transposed(out: Matrix<T>) {
        if effectiveNdim > 0 {
            precondition(shape == out.shape.reversed(),
                """
                Cannot transpose matrix with shape \(shape) to matrix with shape \(out.shape).
                Precondition failed while trying to transpose \(debugDescription) to \(out.debugDescription).
                """)
            out[[0..., 0...]] = self.transposed()[[0..., 0...]]
        }
    }
}

public extension Matrix where T == Double {
    /// short hand form for `transposed()`
    var T: Matrix<T> {
        transposed()
    }

    /// solve a system of linear equations
    /// - SeeAlso:
    ///   - `solve(x: Matrix<T>, out: Matrix<T>? = nil) throws -> Matrix<T>`
    @discardableResult
    func solve(_ rhs: Vector<T>, out: Vector<T>? = nil) throws -> Vector<T> {
        let n: Int = rhs.shape[0]
        let b = out ?? Vector(empty: n)
        try solve(Matrix(rhs.reshaped([n, 1], order: .F)), out: Matrix(b.reshaped([n, 1], order: .F), order: .F))
        return b
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
        var n = __CLPK_integer(shape[0])
        precondition(isSquare,
            """
            Cannot solve for non square matrix with shape \(shape).
            Precondition failed while trying to solve \(debugDescription).
            """)

        let B = out ?? Matrix(empty: rhs.shape, order: .F)
        precondition(B.isFContiguous,
            """
            Cannot use out array if not f contiguous.
            Given out array is \(B.debugDescription).
            """)
        precondition(!rhs.overlaps(B),
            """
            Cannot use out array if it overlaps with x.
            x is \(rhs.debugDescription) and out is \(B.debugDescription).
            """)
        precondition(rhs.shape[0] == n,
            """
            Cannot use x with shape \(rhs.shape) to solve with matrix \(debugDescription).
            """)

        if B.isEmpty {
            return B
        }
        // copy rhs to work space (thereby also making sure it is F contiguous)
        B[[0...]] = rhs[[0...]]

        // copy self to A, since it is modified (thereby also making sure it is F contiguous)
        let A = Matrix<T>(empty: shape, order: .F)
        A[[0...]] = self[[0...]]
        var nrhs = __CLPK_integer(B.shape[1])
        var ipiv: [__CLPK_integer] = [__CLPK_integer].init(repeating: 0, count: Int(n))
        var lda: __CLPK_integer = __CLPK_integer(n)
        var ldb = __CLPK_integer(B.shape[0])
        var info: __CLPK_integer = 0
        dgesv_(&n, &nrhs, A.dataStart, &lda, &ipiv, B.dataStart, &ldb, &info)
        if info != 0 {
            throw LapackError.dgesv(info)
        }
        return B
    }

    /// Invert the matrix
    ///
    /// Inverse of the matrix is computed by LAPACKs DGETRI method which computes the inverse of a matrix using the
    /// LU factorization computed by DGETRF.
    ///
    /// This method inverts U and then computes inv(A) by solving the system
    /// inv(A)*L = inv(U) for inv(A).
    ///
    /// If an error occurred, the data in `out` may have been changed to any data.
    @discardableResult
    func inverted(out: Matrix<T>? = nil) throws -> Matrix<T> {
        var n = __CLPK_integer(shape[0])
        precondition(isSquare,
            """
            Cannot invert non square matrix with shape \(shape).
            Precondition failed while trying to solve \(debugDescription).
            """)
        let A = out ?? Matrix(empty: shape, order: .F)
        A[[0...]] = self[[0...]]

        let ipiv = try A.luInPlace()

        var lda = __CLPK_integer(n)
        var info: __CLPK_integer = 0

        // do optimal workspace query
        var lwork: __CLPK_integer = -1
        var work = [__CLPK_doublereal](repeating: 0.0, count: 1)
        dgetri_(&n, A.dataStart, &lda, ipiv.dataStart, &work, &lwork, &info)
        if info != 0 {
            throw LapackError.getri(info)
        }

        // retrieve optimal workspace
        lwork = __CLPK_integer(work[0])
        work = [__CLPK_doublereal](repeating: 0.0, count: Int(lwork))

        // do the inversion
        dgetri_(&n, A.dataStart, &lda, ipiv.dataStart, &work, &lwork, &info)
        if info != 0 {
            throw LapackError.getri(info)
        }
        return A
    }

}

public extension Matrix where T == Float {
    /// short hand form for `transposed()`
    var T: Matrix<T> {
        transposed()
    }

    /// solve a system of linear equations
    /// - SeeAlso:
    ///   - `solve(x: Matrix<T>, out: Matrix<T>? = nil) throws -> Matrix<T>`
    @discardableResult
    func solve(_ rhs: Vector<T>, out: Vector<T>? = nil) throws -> Vector<T> {
        let n: Int = rhs.shape[0]
        let b = out ?? Vector(empty: n)
        try solve(Matrix(rhs.reshaped([n, 1], order: .F)), out: Matrix(b.reshaped([n, 1], order: .F), order: .F))
        return b
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
        var n = __CLPK_integer(shape[0])
        precondition(isSquare,
            """
            Cannot solve for non square matrix with shape \(shape).
            Precondition failed while trying to solve \(debugDescription).
            """)

        let B = out ?? Matrix(empty: rhs.shape, order: .F)
        precondition(B.isFContiguous,
            """
            Cannot use out array if not f contiguous.
            Given out array is \(B.debugDescription).
            """)
        precondition(!rhs.overlaps(B),
            """
            Cannot use out array if it overlaps with x.
            x is \(rhs.debugDescription) and out is \(B.debugDescription).
            """)
        precondition(rhs.shape[0] == n,
            """
            Cannot use x with shape \(rhs.shape) to solve with matrix \(debugDescription).
            """)

        if B.isEmpty {
            return B
        }
        // copy rhs to work space (thereby also making sure it is F contiguous)
        B[[0...]] = rhs[[0...]]

        // copy self to A, since it is modified (thereby also making sure it is F contiguous)
        let A = Matrix<T>(empty: shape, order: .F)
        A[[0...]] = self[[0...]]
        var nrhs = __CLPK_integer(B.shape[1])
        var ipiv: [__CLPK_integer] = [__CLPK_integer].init(repeating: 0, count: Int(n))
        var lda: __CLPK_integer = __CLPK_integer(n)
        var ldb = __CLPK_integer(B.shape[0])
        var info: __CLPK_integer = 0
        sgesv_(&n, &nrhs, A.dataStart, &lda, &ipiv, B.dataStart, &ldb, &info)
        if info != 0 {
            throw LapackError.dgesv(info)
        }
        return B
    }

    /// Invert the matrix
    ///
    /// Inverse of the matrix is computed by LAPACKs SGETRI method which computes the inverse of a matrix using the
    /// LU factorization computed by SGETRF.
    ///
    /// This method inverts U and then computes inv(A) by solving the system
    /// inv(A)*L = inv(U) for inv(A).
    ///
    /// If an error occurred, the data in `out` may have been changed to any data.
    @discardableResult
    func inverted(out: Matrix<T>? = nil) throws -> Matrix<T> {
        var n = __CLPK_integer(shape[0])
        precondition(isSquare,
            """
            Cannot invert non square matrix with shape \(shape).
            Precondition failed while trying to solve \(debugDescription).
            """)
        let A = out ?? Matrix(empty: shape, order: .F)
        A[[0...]] = self[[0...]]

        let ipiv = try A.luInPlace()

        var lda = __CLPK_integer(n)
        var info: __CLPK_integer = 0

        // do optimal workspace query
        var lwork: __CLPK_integer = -1
        var work = [__CLPK_real](repeating: 0.0, count: 1)
        sgetri_(&n, A.dataStart, &lda, ipiv.dataStart, &work, &lwork, &info)
        if info != 0 {
            throw LapackError.getri(info)
        }

        // retrieve optimal workspace
        lwork = __CLPK_integer(work[0])
        work = [__CLPK_real](repeating: 0.0, count: Int(lwork))

        // do the inversion
        sgetri_(&n, A.dataStart, &lda, ipiv.dataStart, &work, &lwork, &info)
        if info != 0 {
            throw LapackError.getri(info)
        }
        return A
    }
}

public func * (A: Matrix<Double>, x: Vector<Double>) -> Vector<Double> {
    precondition(A.shape[1] == x.shape[0],
        """
        Cannot multiply Matrix with shape \(A.shape) with Vector with shape \(x.shape).
        Precondition failed while trying to multiply \(A.debugDescription) with \(x.debugDescription).
        """)

    let y = Vector<Double>(empty: x.shape[0])
    let lda: Int32

    let a: Matrix<Double>
    let order: CBLAS_ORDER
    if A.isFContiguous {
        order = CblasColMajor
        a = Matrix(A, order: .F)
        lda = Int32(a.strides[1])
    } else {
        order = CblasRowMajor
        a = Matrix(A, order: .C)
        lda = Int32(a.strides[0])
    }

    let m: Int32 = Int32(a.shape[0])
    let n: Int32 = Int32(a.shape[1])
    let incX: Int32 = Int32(x.strides[0])
    let incY: Int32 = Int32(y.strides[0])
    cblas_dgemv(order, CblasNoTrans, m, n, 1, a.dataStart, lda, x.dataStart, incX, 0, y.dataStart, incY)

    return y
}

public func * (A: Matrix<Double>, B: Matrix<Double>) -> Matrix<Double> {
    // see https://www.intel.com/content/www/us/en/develop/documentation/mkl-tutorial-c/top/multiplying-matrices-using-dgemm.html
    precondition(A.shape[1] == B.shape[0],
        """
        Cannot multiply Matrix with shape \(A.shape) with Matrix with shape \(B.shape).
        Precondition failed while trying to multiply \(A.debugDescription) with \(B.debugDescription).
        """)

    // multiply matrix shapes (m x k) * (k x n) = (m x n)
    let m: Int32 = Int32(A.shape[0])
    let k: Int32 = Int32(A.shape[1])
    let n: Int32 = Int32(B.shape[1])

    // Leading dimension of array A, or the number of elements between successive rows (for row major storage) in memory.
    let lda: Int32
    // Leading dimension of array B, or the number of elements between successive rows (for row major storage)
    let ldb: Int32
    // Leading dimension of array C, or the number of elements between successive rows (for row major storage) in memory.
    let ldc: Int32

    let a: Matrix<Double>
    let b: Matrix<Double>
    let c: Matrix<Double>
    let order: CBLAS_ORDER
    if A.isFContiguous {
        order = CblasColMajor
        a = Matrix(A, order: .F)
        b = Matrix(B, order: .F)
        c = Matrix<Double>(empty: [Int(m), Int(n)], order: .F)
        lda = Int32(a.strides[1])
        ldb = Int32(b.strides[1])
        ldc = Int32(c.strides[1])
    } else {
        order = CblasRowMajor
        a = Matrix(A, order: .C)
        b = Matrix(B, order: .C)
        c = Matrix<Double>(empty: [Int(m), Int(n)], order: .C)
        lda = Int32(a.strides[0])
        ldb = Int32(b.strides[0])
        ldc = Int32(c.strides[0])
    }

    cblas_dgemm(order, CblasNoTrans, CblasNoTrans, m, n, k, 1, a.dataStart, lda, b.dataStart, ldb, 0, c.dataStart, ldc)
    return c
}

// TODO override for band/tridiag matrix

public func * (A: Matrix<Float>, x: Vector<Float>) -> Vector<Float> {
    precondition(A.shape[1] == x.shape[0],
        """
        Cannot multiply Matrix with shape \(A.shape) with Vector with shape \(x.shape).
        Precondition failed while trying to multiply \(A.debugDescription) with \(x.debugDescription).
        """)
    let y = Vector<Float>(empty: x.shape[0])

    let lda: Int32

    let a: Matrix<Float>
    let order: CBLAS_ORDER
    if A.isFContiguous {
        order = CblasColMajor
        a = Matrix(A, order: .F)
        lda = Int32(a.strides[1])
    } else {
        order = CblasRowMajor
        a = Matrix(A, order: .C)
        lda = Int32(a.strides[0])
    }

    let m: Int32 = Int32(a.shape[0])
    let n: Int32 = Int32(a.shape[1])
    let incX: Int32 = Int32(x.strides[0])
    let incY: Int32 = Int32(y.strides[0])
    cblas_sgemv(order, CblasNoTrans, m, n, 1, a.dataStart, lda, x.dataStart, incX, 0, y.dataStart, incY)

    return y
}

public func * (A: Matrix<Float>, B: Matrix<Float>) -> Matrix<Float> {
    // see https://www.intel.com/content/www/us/en/develop/documentation/mkl-tutorial-c/top/multiplying-matrices-using-dgemm.html
    precondition(A.shape[1] == B.shape[0],
        """
        Cannot multiply Matrix with shape \(A.shape) with Matrix with shape \(B.shape).
        Precondition failed while trying to multiply \(A.debugDescription) with \(B.debugDescription).
        """)

    // multiply matrix shapes (m x k) * (k x n) = (m x n)
    let m: Int32 = Int32(A.shape[0])
    let k: Int32 = Int32(A.shape[1])
    let n: Int32 = Int32(B.shape[1])

    // Leading dimension of array A, or the number of elements between successive rows (for row major storage) in memory.
    let lda: Int32
    // Leading dimension of array B, or the number of elements between successive rows (for row major storage)
    let ldb: Int32
    // Leading dimension of array C, or the number of elements between successive rows (for row major storage) in memory.
    let ldc: Int32

    let a: Matrix<Float>
    let b: Matrix<Float>
    let c: Matrix<Float>
    let order: CBLAS_ORDER
    if A.isFContiguous {
        order = CblasColMajor
        a = Matrix(A, order: .F)
        b = Matrix(B, order: .F)
        c = Matrix<Float>(empty: [Int(m), Int(n)], order: .F)
        lda = Int32(a.strides[1])
        ldb = Int32(b.strides[1])
        ldc = Int32(c.strides[1])
    } else {
        order = CblasRowMajor
        a = Matrix(A, order: .C)
        b = Matrix(B, order: .C)
        c = Matrix<Float>(empty: [Int(m), Int(n)], order: .C)
        lda = Int32(a.strides[0])
        ldb = Int32(b.strides[0])
        ldc = Int32(c.strides[0])
    }

    cblas_sgemm(order, CblasNoTrans, CblasNoTrans, m, n, k, 1, a.dataStart, lda, b.dataStart, ldb, 0, c.dataStart, ldc)
    return c
}

public extension Matrix where T: AdditiveArithmetic {
    convenience init(diag: Vector<T>, order: Contiguous = .C) {
        let shape = [diag.shape[0], diag.shape[0]]
        self.init(empty: shape)
        let z = Vector<T>.zeros(diag.shape[0])
        for (i, x) in diag.enumerated() {
            self[Slice(i)] = z
            self[i, i] = x
        }
    }
}
