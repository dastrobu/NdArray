//
// Created by Daniel Strobusch on 2019-05-07.
//

import Accelerate

// logic is always implemented in the extension, operators for convenience
public extension NdArray where T == Double {
    func multiplyBy(_ x: Double) {
        let n = Int32(shape.reduce(1, *))
        if n == 0 {
            return
        }
        switch ndim {
        case 0:
            return
        case 1:
            cblas_dscal(n, x, data, Int32(strides[0]))
        default:
            if isContiguous {
                cblas_dscal(n, x, data, 1)
            } else {
                for i in 0..<shape[0] {
                    self[i] *= x
                }
            }
        }
    }
}

// TODO test all
public func +<K: Numeric, T: NdArray<K>>(a: T, x: K) -> T {
    let b = T(copy: a)
    b += x
    return b
}

public func -<K: Numeric, T: NdArray<K>>(a: T, x: K) -> T {
    let b = T(copy: a)
    b -= x
    return b
}

public func *<K: Numeric, T: NdArray<K>>(a: T, x: K) -> T {
    let b = T(copy: a)
    b *= x
    return b
}

public func *<T: NdArray<Double>>(a: T, x: Double) -> T {
    let b = T(copy: a)
    b *= x
    return b
}

public func /<T: NdArray<Double>>(a: T, x: Double) -> T {
    let b = T(copy: a)
    b /= x
    return b
}

public func *<T: NdArray<Float>>(a: T, x: Float) -> T {
    let b = T(copy: a)
    b *= x
    return b
}

public func /<T: NdArray<Float>>(a: T, x: Float) -> T {
    let b = T(copy: a)
    b /= x
    return b
}

public func +=<K: Numeric, T: NdArray<K>>(a: T, x: K) {
    let n = a.shape.reduce(1, *)
    if n == 0 || a.ndim == 0 {
        return
    }
    if a.ndim == 1 {
        let s = a.strides[0]
        var p = a.data
        for _ in 0..<n {
            p.initialize(to: p.pointee + x)
            p += s
        }
        return
    }
    if a.isContiguous {
        var p = a.data
        for _ in 0..<n {
            p.initialize(to: p.pointee + x)
            p += 1
        }
        return
    }
    for i in 0..<a.shape[0] {
        a[i] += x
    }
}

public func -=<K: Numeric, T: NdArray<K>>(a: T, x: K) {
    let n = a.shape.reduce(1, *)
    if n == 0 || a.ndim == 0 {
        return
    }
    if a.ndim == 1 {
        let s = a.strides[0]
        var p = a.data
        for _ in 0..<n {
            p.initialize(to: p.pointee - x)
            p += s
        }
        return
    }
    if a.isContiguous {
        var p = a.data
        for _ in 0..<n {
            p.initialize(to: p.pointee - x)
            p += 1
        }
        return
    }
    for i in 0..<a.shape[0] {
        a[i] -= x
    }
}

public func *=<K: Numeric, T: NdArray<K>>(a: T, x: K) {
    let n = a.shape.reduce(1, *)
    if n == 0 || a.ndim == 0 {
        return
    }
    if a.ndim == 1 {
        let s = a.strides[0]
        var p = a.data
        for _ in 0..<n {
            p.initialize(to: p.pointee * x)
            p += s
        }
        return
    }
    if a.isContiguous {
        var p = a.data
        for _ in 0..<n {
            p.initialize(to: p.pointee * x)
            p += 1
        }
        return
    }
    for i in 0..<a.shape[0] {
        a[i] *= x
    }
}

public func *=<T: NdArray<Double>>(a: T, x: Double) {
    a.multiplyBy(x)
}


public func /=<T: NdArray<Double>>(a: T, x: Double) {
    a *= 1 / x
}

public func *=<T: NdArray<Float>>(a: T, x: Float) {
    let n = Int32(a.shape.reduce(1, *))
    if n == 0 {
        return
    }
    switch a.ndim {
    case 0:
        return
    case 1:
        cblas_sscal(n, x, a.data, Int32(a.strides[0]))
    default:
        if a.isContiguous {
            cblas_sscal(n, x, a.data, 1)
        } else {
            for i in 0..<a.shape[0] {
                a[i] *= x
            }
        }
    }
}


public func /=<T: NdArray<Float>>(a: T, x: Float) {
    a *= 1 / x
}
