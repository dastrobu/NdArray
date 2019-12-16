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
    a.apply1d(other: b, f1d: { n in
        vDSP_vabsD(a.data, a.strides[0], b.data, b.strides[0], vDSP_Length(a.shape[0]))
    }, fContiguous: { n in
        vDSP_vabsD(a.data, 1, b.data, 1, vDSP_Length(n))
    }, fSlice: { ai, bi in
        abs(ai, out: bi)
    })
}

public func abs<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    abs(a, out: b)
    return b
}

// Float

public func abs<T: NdArray<Float>>(_ a: T, out b: T) {
    a.apply1d(other: b, f1d: { n in
        vDSP_vabs(a.data, a.strides[0], b.data, b.strides[0], vDSP_Length(a.shape[0]))
    }, fContiguous: { n in
        vDSP_vabs(a.data, 1, b.data, 1, vDSP_Length(n))
    }, fSlice: { ai, bi in
        abs(ai, out: bi)
    })
}

public func abs<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    abs(a, out: b)
    return b
}
