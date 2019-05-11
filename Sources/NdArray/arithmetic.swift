//
// Created by Daniel Strobusch on 2019-05-07.
//

import Accelerate

/// Extension for NdArray<T> where T: Numeric arithmetic
/// The logic is always implemented in the extension, operators are defined for convenience.
public extension NdArray where T: Numeric {
    /// in place multiplication by a scalar
    func multiplyBy(_ x: T) {
        let n = Int32(shape.reduce(1, *))
        if n == 0 {
            return
        }
        switch ndim {
        case 0:
            return
        case 1:
            let s = strides[0]
            var p = data
            for _ in 0..<n {
                p.initialize(to: p.pointee * x)
                p += s
            }
        default:
            if isContiguous {
                var p = data
                for _ in 0..<n {
                    p.initialize(to: p.pointee * x)
                    p += 1
                }
                return
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                for i in 0..<shape[0] {
                    a[i] *= x
                }
            }
        }
    }

    /// in addition of a scalar
    func add(_ x: T) {
        let n = Int32(shape.reduce(1, *))
        if n == 0 {
            return
        }
        switch ndim {
        case 0:
            return
        case 1:
            let s = strides[0]
            var p = data
            for _ in 0..<n {
                p.initialize(to: p.pointee + x)
                p += s
            }
        default:
            if isContiguous {
                var p = data
                for _ in 0..<n {
                    p.initialize(to: p.pointee + x)
                    p += 1
                }
                return
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                for i in 0..<shape[0] {
                    a[i] += x
                }
            }
        }
    }

    /// in subtraction of a scalar
    func subtract(_ x: T) {
        add(T.zero - x)
    }
}

/// Extension for NdArray<Double> arithmetic
/// The logic is always implemented in the extension, operators are defined for convenience.
public extension NdArray where T == Double {
    /// in place multiplication by a scalar
    func multiplyBy(_ x: T) {
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
                // make sure the array is not sliced
                let a = NdArray(self)
                for i in 0..<shape[0] {
                    a[i] *= x
                }
            }
        }
    }

    func divideBy(_ x: T) {
        multiplyBy(1 / x)
    }
}

/// Extension for NdArray<Float> arithmetic
/// The logic is always implemented in the extension, operators are defined for convenience.
public extension NdArray where T == Float {
    /// in place multiplication by a scalar
    func multiplyBy(_ x: T) {
        let n = Int32(shape.reduce(1, *))
        if n == 0 {
            return
        }
        switch ndim {
        case 0:
            return
        case 1:
            cblas_sscal(n, x, data, Int32(strides[0]))
        default:
            if isContiguous {
                cblas_sscal(n, x, data, 1)
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                for i in 0..<shape[0] {
                    a[i] *= x
                }
            }
        }
    }

    func divideBy(_ x: T) {
        multiplyBy(1 / x)
    }
}

// Numeric operators

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

public func +=<K: Numeric, T: NdArray<K>>(a: T, x: K) {
    a.add(x)
}

public func -=<K: Numeric, T: NdArray<K>>(a: T, x: K) {
    a.subtract(x)
}

public func *=<K: Numeric, T: NdArray<K>>(a: T, x: K) {
    a.multiplyBy(x)
}

// Double operators

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

public func *=<T: NdArray<Double>>(a: T, x: Double) {
    a.multiplyBy(x)
}


public func /=<T: NdArray<Double>>(a: T, x: Double) {
    a.divideBy(x)
}


// Float operators

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

public func *=<T: NdArray<Float>>(a: T, x: Float) {
    a.multiplyBy(x)
}


public func /=<T: NdArray<Float>>(a: T, x: Float) {
    a.divideBy(x)
}

