//
// Created by Daniel Strobusch on 2019-05-11.
//

import Accelerate

// SignedNumeric and Comparable

public func abs<K: SignedNumeric, T: NdArray<K>>(_ a: T) -> T where K: Comparable {
    let b = T(copy: a)
    b.apply(Swift.abs)
    return b
}

// Double

public func abs<T: NdArray<Double>>(_ a: T, out b: T) {
    let n = vDSP_Length(a.shape.reduce(1, *))
    if n == 0 {
        return
    }
    switch a.ndim {
    case 0:
        return
    case 1:
        vDSP_vabsD(a.data, a.strides[0], b.data, b.strides[0], vDSP_Length(a.shape[0]))
    default:
        if (a.isCContiguous && b.isCContiguous) || (a.isFContiguous && b.isFContiguous) {
            vDSP_vabsD(a.data, 1, b.data, 1, n)
        } else {
            // make sure the array is not sliced
            let a = NdArray(a)
            for i in 0..<a.shape[0] {
                abs(a[i], out: b[i])
            }
        }
    }
}

public func abs<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    abs(a, out: b)
    return b
}

// Float

public func abs<T: NdArray<Float>>(_ a: T, out b: T) {
    let n = vDSP_Length(a.shape.reduce(1, *))
    if n == 0 {
        return
    }
    switch a.ndim {
    case 0:
        return
    case 1:
        vDSP_vabs(a.data, a.strides[0], b.data, b.strides[0], vDSP_Length(a.shape[0]))
    default:
        if (a.isCContiguous && b.isCContiguous) || (a.isFContiguous && b.isFContiguous) {
            vDSP_vabs(a.data, 1, b.data, 1, n)
        } else {
            // make sure the array is not sliced
            let a = NdArray(a)
            for i in 0..<a.shape[0] {
                abs(a[i], out: b[i])
            }
        }
    }
}

public func abs<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    abs(a, out: b)
    return b
}

