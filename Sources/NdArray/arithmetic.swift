//
// Created by Daniel Strobusch on 2019-05-07.
//

import Accelerate

public extension NdArray where T: Comparable {
    /// - Returns: maximum element, nil for empty arrays
    func max() -> T? {
        if isEmpty {
            return nil
        }
        return reduce(data[0], { Swift.max($0, $1) })
    }

    /// - Returns: maximum element, nil for empty arrays
    func min() -> T? {
        if isEmpty {
            return nil
        }
        return reduce(data[0], { Swift.min($0, $1) })
    }
}

public extension NdArray where T: AdditiveArithmetic {
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

    /// - Returns: 0 if array is empty, the sum of all elements otherwise
    func sum() -> T {
        return reduce(T.zero, +)
    }
}

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

    /// - Returns: 0 if array is empty, the product of all elements otherwise
    func product() -> T {
        if isEmpty {
            return 0
        }
        return reduce(1, *)
    }
}

/// Extension for NdArray<Double> arithmetic
/// The logic is always implemented in the extension, operators are defined for convenience.
public extension NdArray where T == Double {
    /// - Returns: maximum element, nil for empty arrays
    func max() -> T? {
        let n = vDSP_Length(shape.reduce(1, *))
        if n == 0 {
            return nil
        }
        var r = data[0]
        switch ndim {
        case 0:
            return nil
        case 1:
            vDSP_maxvD(data, strides[0], &r, vDSP_Length(shape[0]))
        default:
            if isContiguous {
                vDSP_maxvD(data, 1, &r, n)
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                r = a.data[0]
                for i in 0..<shape[0] {
                    r = Swift.max(r, a[i].max()!)
                }
            }
        }
        return r
    }

    /// - Returns: maximum element, nil for empty arrays
    func min() -> T? {
        let n = vDSP_Length(shape.reduce(1, *))
        if n == 0 {
            return nil
        }
        var r = data[0]
        switch ndim {
        case 0:
            return nil
        case 1:
            vDSP_minvD(data, strides[0], &r, vDSP_Length(shape[0]))
        default:
            if isContiguous {
                vDSP_minvD(data, 1, &r, n)
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                r = a.data[0]
                for i in 0..<shape[0] {
                    r = Swift.min(r, a[i].max()!)
                }
            }
        }
        return r
    }

    // TODO amax
    // TODO cblas_daxpy
    // TODO catlas_daxpby
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

    /// - Returns: 0 if array is empty, the sum of all elements otherwise
    func sum() -> T {
        let n = vDSP_Length(shape.reduce(1, *))
        if n == 0 {
            return 0
        }
        var r = T.zero
        switch ndim {
        case 0:
            return 0
        case 1:
            vDSP_sveD(data, strides[0], &r, vDSP_Length(shape[0]))
        default:
            if isContiguous {
                vDSP_sveD(data, 1, &r, n)
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                for i in 0..<shape[0] {
                    r += a[i].sum()
                }
            }
        }
        return r
    }
}

/// Extension for NdArray<Float> arithmetic
/// The logic is always implemented in the extension, operators are defined for convenience.
public extension NdArray where T == Float {
    // TODO amax
    // TODO cblas_saxpy
    // TODO catlas_saxpby

    /// - Returns: maximum element, nil for empty arrays
    func max() -> T? {
        let n = vDSP_Length(shape.reduce(1, *))
        if n == 0 {
            return nil
        }
        var r = data[0]
        switch ndim {
        case 0:
            return nil
        case 1:
            vDSP_maxv(data, strides[0], &r, vDSP_Length(shape[0]))
        default:
            if isContiguous {
                vDSP_maxv(data, 1, &r, n)
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                r = a.data[0]
                for i in 0..<shape[0] {
                    r = Swift.max(r, a[i].max()!)
                }
            }
        }
        return r
    }

    /// - Returns: maximum element, nil for empty arrays
    func min() -> T? {
        let n = vDSP_Length(shape.reduce(1, *))
        if n == 0 {
            return nil
        }
        var r = data[0]
        switch ndim {
        case 0:
            return nil
        case 1:
            vDSP_minv(data, strides[0], &r, vDSP_Length(shape[0]))
        default:
            if isContiguous {
                vDSP_minv(data, 1, &r, n)
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                r = a.data[0]
                for i in 0..<shape[0] {
                    r = Swift.min(r, a[i].max()!)
                }
            }
        }
        return r
    }

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

    /// - Returns: 0 if array is empty, the sum of all elements otherwise
    func sum() -> T {
        let n = vDSP_Length(shape.reduce(1, *))
        if n == 0 {
            return 0
        }
        var r = T.zero
        switch ndim {
        case 0:
            return 0
        case 1:
            vDSP_sve(data, strides[0], &r, vDSP_Length(shape[0]))
        default:
            if isContiguous {
                vDSP_sve(data, 1, &r, n)
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                for i in 0..<shape[0] {
                    r += a[i].sum()
                }
            }
        }
        return r
    }
}

// AdditiveArithmetic operators

public func +<K: AdditiveArithmetic, T: NdArray<K>>(a: T, x: K) -> T {
    let b = T(copy: a)
    b += x
    return b
}

public func -<K: AdditiveArithmetic, T: NdArray<K>>(a: T, x: K) -> T {
    let b = T(copy: a)
    b -= x
    return b
}

public func +=<K: AdditiveArithmetic, T: NdArray<K>>(a: T, x: K) {
    a.add(x)
}

public func -=<K: AdditiveArithmetic, T: NdArray<K>>(a: T, x: K) {
    a.subtract(x)
}

// Numeric operators

public func *<K: Numeric, T: NdArray<K>>(a: T, x: K) -> T {
    let b = T(copy: a)
    b *= x
    return b
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


