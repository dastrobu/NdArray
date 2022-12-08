//
// Created by Daniel Strobusch on 08.12.22.
//

import Darwin
import Accelerate

public extension Matrix where T == Double {

    /// Compute the SVD
    ///
    /// Factorization is computed by LAPACKs DGESDD method, which computes a SVD of a general
    /// M-by-N matrix, optionally computing the left and right singular
    ///  vectors.  If singular vectors are desired, it uses a
    ///  divide-and-conquer algorithm.
    ///
    ///  The SVD is written
    ///
    ///       A = U * SIGMA * transpose(V)
    ///
    ///  where SIGMA is an M-by-N matrix which is zero except for its
    ///  min(m,n) diagonal elements, U is an M-by-M orthogonal matrix, and
    ///  V is an N-by-N orthogonal matrix.  The diagonal elements of SIGMA
    ///  are the singular values of A; they are real and non-negative, and
    ///  are returned in descending order.  The first min(m,n) columns of
    ///  U and V are the left and right singular vectors of A.
    ///
    /// - Returns: a tuple of the matrices (U, SIGMA, transpose(V))
    func svd() throws -> (Matrix<T>, Vector<T>, Matrix<T>) {
        // A is destroyed if jobz != O
        let A = Matrix(copy: self, order: .F)

        var m = __CLPK_integer(shape[0])
        var n = __CLPK_integer(shape[1])

        // see
        var jobz: CChar = "A".utf8CString[0]

        // leading dimension is the number of rows in column major order
        var lda = __CLPK_integer(A.shape[0])
        var info: __CLPK_integer = 0

        let U: Matrix<T> = Matrix.empty(shape: [Int(m), Int(m)], order: .F)
        var ldu = __CLPK_integer(U.shape[0])
        let s: Vector<T> = Vector.empty(shape: [Int(Swift.min(m, n))], order: .F)
        let Vt: Matrix<T> = Matrix.empty(shape: [Int(n), Int(n)], order: .F)
        var ldvt = __CLPK_integer(Vt.shape[0])

        let iwork: Vector<__CLPK_integer> = Vector.empty(shape: [8 * Int(Swift.min(m, n))], order: .F)

        // do optimal workspace query
        var lwork: __CLPK_integer = -1
        var work: Vector<__CLPK_doublereal> = Vector.empty(shape: [1], order: .F)
        dgesdd_(&jobz, &m, &n, A.dataStart, &lda, s.dataStart, U.dataStart, &ldu, Vt.dataStart, &ldvt, work.dataStart, &lwork, iwork.dataStart, &info)
        if info != 0 {
            throw LapackError.getri(info)
        }

        // retrieve optimal workspace
        lwork = __CLPK_integer(work[0])
        work = Vector.empty(shape: [Int(lwork)], order: .F)
        dgesdd_(&jobz, &m, &n, A.dataStart, &lda, s.dataStart, U.dataStart, &ldu, Vt.dataStart, &ldvt, work.dataStart, &lwork, iwork.dataStart, &info)

        if info != 0 {
            throw LapackError.gesdd(info)
        }
        return (U, s, Vt)
    }

}

public extension Matrix where T == Float {

    /// Compute the SVD
    ///
    /// Factorization is computed by LAPACKs SGESDD method, which computes a SVD of a general
    /// M-by-N matrix, optionally computing the left and right singular
    ///  vectors.  If singular vectors are desired, it uses a
    ///  divide-and-conquer algorithm.
    ///
    ///  The SVD is written
    ///
    ///       A = U * SIGMA * transpose(V)
    ///
    ///  where SIGMA is an M-by-N matrix which is zero except for its
    ///  min(m,n) diagonal elements, U is an M-by-M orthogonal matrix, and
    ///  V is an N-by-N orthogonal matrix.  The diagonal elements of SIGMA
    ///  are the singular values of A; they are real and non-negative, and
    ///  are returned in descending order.  The first min(m,n) columns of
    ///  U and V are the left and right singular vectors of A.
    ///
    /// - Returns: a tuple of the matrices (U, SIGMA, transpose(V))
    func svd() throws -> (Matrix<T>, Vector<T>, Matrix<T>) {
        // A is destroyed if jobz != O
        let A = Matrix(copy: self, order: .F)

        var m = __CLPK_integer(shape[0])
        var n = __CLPK_integer(shape[1])

        // see
        var jobz: CChar = "A".utf8CString[0]

        // leading dimension is the number of rows in column major order
        var lda = __CLPK_integer(A.shape[0])
        var info: __CLPK_integer = 0

        let U: Matrix<T> = Matrix.empty(shape: [Int(m), Int(m)], order: .F)
        var ldu = __CLPK_integer(U.shape[0])
        let s: Vector<T> = Vector.empty(shape: [Int(Swift.min(m, n))], order: .F)
        let Vt: Matrix<T> = Matrix.empty(shape: [Int(n), Int(n)], order: .F)
        var ldvt = __CLPK_integer(Vt.shape[0])

        let iwork: Vector<__CLPK_integer> = Vector.empty(shape: [8 * Int(Swift.min(m, n))], order: .F)

        // do optimal workspace query
        var lwork: __CLPK_integer = -1
        var work: Vector<__CLPK_real> = Vector.empty(shape: [1], order: .F)
        sgesdd_(&jobz, &m, &n, A.dataStart, &lda, s.dataStart, U.dataStart, &ldu, Vt.dataStart, &ldvt, work.dataStart, &lwork, iwork.dataStart, &info)
        if info != 0 {
            throw LapackError.getri(info)
        }

        // retrieve optimal workspace
        lwork = __CLPK_integer(work[0])
        work = Vector.empty(shape: [Int(lwork)], order: .F)
        sgesdd_(&jobz, &m, &n, A.dataStart, &lda, s.dataStart, U.dataStart, &ldu, Vt.dataStart, &ldvt, work.dataStart, &lwork, iwork.dataStart, &info)

        if info != 0 {
            throw LapackError.gesdd(info)
        }
        return (U, s, Vt)
    }

}
