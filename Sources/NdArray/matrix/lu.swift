//
// Created by Daniel Strobusch on 02.04.22.
//

import Darwin
import Accelerate

public extension Matrix where T == Double {

    /// Compute the LU factorization.
    ///
    /// Factorization is computed by LAPACKs DGETRF method, which computes an LU factorization of a general
    /// M-by-N matrix A using partial pivoting with row interchanges.
    ///
    /// The factorization has the form
    ///
    ///    A = P * L * U
    ///
    /// where P is a permutation matrix, L is lower triangular with unit
    /// diagonal elements (lower trapezoidal if m > n), and U is upper
    /// triangular (upper trapezoidal if m < n).
    ///
    /// See also ``luInPlace()`` for more fine grained control.
    ///
    /// - Returns: a tuple of the matrices (P, L, U)
    func lu() throws -> (Matrix<T>, Matrix<T>, Matrix<T>) {
        let A = Matrix(copy: self, order: .F)

        let ipiv = try A.luInPlace()

        let n = A.shape[0]
        let m = A.shape[1]
        let P: Matrix<T> = permutationMatrix(n: n, ipiv: ipiv)

        let L = Matrix(copy: A[[0..., 0..<Swift.min(n, m)]])
        let U = Matrix(copy: A[[0..., 0...]])

        for i in 0..<n {
            U[[Slice(i), ..<Swift.min(i, m)]].set(0)
            L[[i, i]] = 1
            L[[Slice(i), i + 1..<m]].set(0)
        }
        return (P, L, U)
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
    ///
    /// See also ``lu()`` which generates the full matrices instead of computing results in place.
    func luInPlace() throws -> Vector<__CLPK_integer> {
        precondition(isFContiguous,
            """
            Cannot compute LU factorization if not f contiguous
            Given array is \(debugDescription).
            """)
        let ipiv = Vector<__CLPK_integer>.empty(shape: [Swift.min(shape[0], shape[1])])
        var m = __CLPK_integer(shape[0])
        var n = __CLPK_integer(shape[1])
        // leading dimension is the number of rows in column major order
        var lda = __CLPK_integer(m)
        var info: __CLPK_integer = 0
        dgetrf_(&m, &n, dataStart, &lda, ipiv.dataStart, &info)
        if info != 0 {
            throw LapackError.getrf(info)
        }
        return ipiv
    }
}

public extension Matrix where T == Float {

    /// Compute the LU factorization.
    ///
    /// Factorization is computed by LAPACKs SGETRF method, which computes an LU factorization of a general
    /// M-by-N matrix A using partial pivoting with row interchanges.
    ///
    /// The factorization has the form
    ///
    ///    A = P * L * U
    ///
    /// where P is a permutation matrix, L is lower triangular with unit
    /// diagonal elements (lower trapezoidal if m > n), and U is upper
    /// triangular (upper trapezoidal if m < n).
    ///
    /// See also ``luInPlace()`` for more fine grained control.
    ///
    /// - Returns: a tuple of the matrices (P, L, U)
    func lu() throws -> (Matrix<T>, Matrix<T>, Matrix<T>) {
        let A = Matrix(copy: self, order: .F)

        let ipiv = try A.luInPlace()

        let n = A.shape[0]
        let m = A.shape[1]
        let P: Matrix<T> = permutationMatrix(n: n, ipiv: ipiv)

        let L = Matrix(copy: A[[0..., 0..<Swift.min(n, m)]])
        let U = Matrix(copy: A[[0..., 0...]])

        for i in 0..<n {
            U[[Slice(i), ..<Swift.min(i, m)]].set(0)
            L[[i, i]] = 1
            L[[Slice(i), i + 1..<m]].set(0)
        }
        return (P, L, U)
    }

    /// Compute the LU factorization (in place) and return the pivot vector
    ///
    /// Factorization is computed by LAPACKs SGETRF method, which computes an LU factorization of a general
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
    ///
    /// See also ``lu()`` which generates the full matrices instead of computing results in place.
    func luInPlace() throws -> Vector<__CLPK_integer> {
        precondition(isFContiguous,
            """
            Cannot compute LU factorization if not f contiguous
            Given array is \(debugDescription).
            """)
        let ipiv = Vector<__CLPK_integer>.empty(shape: [Swift.min(shape[0], shape[1])])
        var m = __CLPK_integer(shape[0])
        var n = __CLPK_integer(shape[1])
        // leading dimension is the number of rows in column major order
        var lda = __CLPK_integer(m)
        var info: __CLPK_integer = 0
        sgetrf_(&m, &n, dataStart, &lda, ipiv.dataStart, &info)
        if info != 0 {
            throw LapackError.getrf(info)
        }
        return ipiv
    }
}
