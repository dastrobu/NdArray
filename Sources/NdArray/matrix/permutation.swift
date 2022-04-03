//
// Created by Daniel Strobusch on 03.04.22.
//

import Darwin
import Accelerate

/**
 convert BLAS style ipiv to a pure permutation vector
 */
internal func permutationVector(n: Int, ipiv: Vector<__CLPK_integer>) -> Vector<__CLPK_integer> {
    let p = Vector<__CLPK_integer>.empty(shape: [n])
    for i in 0..<n {
        p[[i]] = __CLPK_integer(i)
    }
    ipiv.enumerated().forEach { (i, j) in
        let pi = p[[Int(i)]]
        let pj = p[[Int(j - 1)]]
        p[i] = pj
        p[Int(j) - 1] = pi
    }
    return p
}

/**
 [On the meaning of the permutation pivot indices, ipiv](http://icl.cs.utk.edu/lapack-forum/viewtopic.php?f=2&t=1747)
 */
internal func permutationMatrix<T: FloatingPoint>(n: Int, ipiv: Vector<__CLPK_integer>) -> Matrix<T> {
    let p = permutationVector(n: n, ipiv: ipiv)
    let P = Matrix<T>.zeros([n, n])

    p.enumerated().forEach { (i: Int, j: __CLPK_integer) in
        P[[i, Int(j)]] = T(1)
    }
    return P
}
