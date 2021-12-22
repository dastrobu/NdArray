//
// Created by Daniel Strobusch on 2019-05-11.
//

import Accelerate
import Darwin

// SignedNumeric and Comparable

public func abs<K: SignedNumeric, T: NdArray<K>>(_ a: T) -> T where K: Comparable {
    let b = T(copy: a)
    b.apply(Swift.abs)
    return b
}

// Double

/// see ``vDSP_vabsD``.
public func abs<T: NdArray<Double>>(_ a: T, out b: T) {
    a.apply1d(other: b, f1d: { _ in
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

/// see ``Darwin/asin``.
public func asin<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.asin)
    return b
}

/// see ``Darwin/acos``.
public func acos<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.acos)
    return b
}

/// see ``Darwin/atan``.
public func atan<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.atan)
    return b
}

/// see ``Darwin/cos``.
public func cos<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.cos)
    return b
}

/// see ``Darwin/sin``.
public func sin<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.sin)
    return b
}

/// see ``Darwin/tan``.
public func tan<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.tan)
    return b
}

/// see ``Darwin/cosh``.
public func cosh<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.cosh)
    return b
}

/// see ``Darwin/sinh``.
public func sinh<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.sinh)
    return b
}

/// see ``Darwin/tanh``.
public func tanh<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.tanh)
    return b
}

/// see ``Darwin/exp``.
public func exp<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.exp)
    return b
}

/// see ``Darwin/exp2``.
public func exp2<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.exp2)
    return b
}

/// see ``Darwin/log``.
public func log<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.log)
    return b
}

/// see ``Darwin/log10``.
public func log10<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.log10)
    return b
}

/// see ``Darwin/log1p``.
public func log1p<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.log1p)
    return b
}

/// see ``Darwin/log2``.
public func log2<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.log2)
    return b
}

/// see ``Darwin/logb``.
public func logb<T: NdArray<Double>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.logb)
    return b
}

// Float


/// see ``vDSP_vabsD``.
public func abs<T: NdArray<Float>>(_ a: T, out b: T) {
    a.apply1d(other: b, f1d: { _ in
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

/// see ``Darwin/asinf``.
public func asin<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.asinf)
    return b
}

/// see ``Darwin/acosf``.
public func acos<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.acosf)
    return b
}

/// see ``Darwin/atanf``.
public func atan<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.atanf)
    return b
}

/// see ``Darwin/cosf``.
public func cos<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.cosf)
    return b
}

/// see ``Darwin/sinf``.
public func sin<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.sinf)
    return b
}

/// see ``Darwin/tanf``.
public func tan<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.tanf)
    return b
}

/// see ``Darwin/coshf``.
public func cosh<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.coshf)
    return b
}

/// see ``Darwin/sinhf``.
public func sinh<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.sinhf)
    return b
}

/// see ``Darwin/tanhf``.
public func tanh<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.tanhf)
    return b
}

/// see ``Darwin/expf``.
public func exp<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.expf)
    return b
}

/// see ``Darwin/exp2f``.
public func exp2<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.exp2f)
    return b
}

/// see ``Darwin/logf``.
public func log<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.logf)
    return b
}

/// see ``Darwin/log10f``.
public func log10<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.log10f)
    return b
}

/// see ``Darwin/log1pf``.
public func log1p<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.log1pf)
    return b
}

/// see ``Darwin/log2f``.
public func log2<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.log2f)
    return b
}

/// see ``Darwin/logbf``.
public func logb<T: NdArray<Float>>(_ a: T) -> T {
    let b = T(copy: a)
    b.apply(Darwin.logbf)
    return b
}
