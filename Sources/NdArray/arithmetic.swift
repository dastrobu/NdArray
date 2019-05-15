//
// Created by Daniel Strobusch on 2019-05-07.
//

import Accelerate

/// Extension for arrays with elements that conform to the Comparable protocol.
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

/// Extension for arrays with elements that conform to the AdditiveArithmetic protocol.
public extension NdArray where T: AdditiveArithmetic {
    /// in place addition of a scalar
    func add(_ x: T) {
        apply1d(f1d: {
            n in
            let s = strides[0]
            var p = data
            for _ in 0..<n {
                p.initialize(to: p.pointee + x)
                p += s
            }
        }, fContiguous: {
            n in
            var p = data
            for _ in 0..<n {
                p.initialize(to: p.pointee + x)
                p += 1
            }
        }, fSlice: { s in
            s += x
        })
    }

    /// in place addition of a vector,
    func add(_ x: NdArray<T>) {
        assert(shape == x.shape,
            """
            Cannot add arrays with shape \(x.shape) and \(shape).
            Assertion failed while trying to add \(x.debugDescription) to \(debugDescription).
            """)
        apply1d(other: x, f1d: {
            n in
            var p = data
            var px = x.data
            let s = strides[0]
            let sx = x.strides[0]
            for _ in 0..<n {
                p.initialize(to: p.pointee + px.pointee)
                p += s
                px += sx
            }
        }, fContiguous: {
            n in
            var p = data
            var px = x.data
            for _ in 0..<n {
                p.initialize(to: p.pointee + px.pointee)
                p += 1
                px += 1
            }
        }, fSlice: { ai, bi in
            ai.add(bi)
        })
    }

    /// in place subtraction of a vector,
    func subtract(_ x: NdArray<T>) {
        assert(shape == x.shape,
            """
            Cannot subtract arrays with shape \(x.shape) and \(shape).
            Assertion failed while trying to add \(x.debugDescription) to \(debugDescription).
            """)
        apply1d(other: x, f1d: {
            n in
            var p = data
            var px = x.data
            let s = strides[0]
            let sx = x.strides[0]
            for _ in 0..<n {
                p.initialize(to: p.pointee - px.pointee)
                p += s
                px += sx
            }
        }, fContiguous: {
            n in
            var p = data
            var px = x.data
            for _ in 0..<n {
                p.initialize(to: p.pointee - px.pointee)
                p += 1
                px += 1
            }
        }, fSlice: { ai, bi in
            ai.subtract(bi)
        })
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

/// Extension for arrays with elements that conform to the Numeric protocol.
public extension NdArray where T: Numeric {
    /// in place multiplication by a scalar
    func multiply(by x: T) {
        apply1d(f1d: {
            n in
            let s = strides[0]
            var p = data
            for _ in 0..<n {
                p.initialize(to: p.pointee * x)
                p += s
            }
        }, fContiguous: {
            n in
            var p = data
            for _ in 0..<n {
                p.initialize(to: p.pointee * x)
                p += 1
            }
        }, fSlice: { s in
            s *= x
        })
    }

    /// - Returns: 0 if array is empty, the product of all elements otherwise
    func product() -> T {
        if isEmpty {
            return 0
        }
        return reduce(1, *)
    }
}

/// Extension for arrays with Double elements.
public extension NdArray where T == Double {
    /// - Returns: maximum element, nil for empty arrays
    func max() -> T? {
        if isEmpty {
            return nil
        }
        var r = data[0]
        apply1d(f1d: {
            n in
            vDSP_maxvD(data, strides[0], &r, vDSP_Length(n))
        }, fContiguous: {
            n in
            vDSP_maxvD(data, 1, &r, vDSP_Length(n))
        }, fSlice: { s in
            r = Swift.max(r, s.max()!)
        })
        return r
    }

    /// - Returns: maximum element, nil for empty arrays
    func min() -> T? {
        if isEmpty {
            return nil
        }
        var r = data[0]
        apply1d(f1d: {
            n in
            vDSP_minvD(data, strides[0], &r, vDSP_Length(n))
        }, fContiguous: {
            n in
            vDSP_minvD(data, 1, &r, vDSP_Length(n))
        }, fSlice: { s in
            r = Swift.min(r, s.min()!)
        })
        return r
    }

    /// in place addition of a scaled vector,
    /// uses BLAS daxpy operation: self = alpha * x + self
    func add(_ alpha: T, _ x: NdArray<T>) {
        assert(shape == x.shape,
            """
            Cannot add arrays with shape \(x.shape) and \(shape).
            Assertion failed while trying to add \(x.debugDescription) to \(debugDescription).
            """)
        apply1d(other: x, f1d: {
            n in
            cblas_daxpy(Int32(n), alpha, x.data, Int32(x.strides[0]), data, Int32(strides[0]))
        }, fContiguous: {
            n in
            cblas_daxpy(Int32(n), alpha, x.data, 1, data, 1)
        }, fSlice: { s, o in
            s.add(alpha, o)
        })
    }

    /// in place addition of a scaled vector,
    /// uses ATLAS daxpyb operation: self = alpha * x + beta * self
    func add(_ alpha: T, _ x: NdArray<T>, _ beta: T) {
        assert(shape == x.shape,
            """
            Cannot add arrays with shape \(x.shape) and \(shape).
            Assertion failed while trying to add \(x.debugDescription) to \(debugDescription).
            """)
        apply1d(other: x, f1d: {
            n in
            catlas_daxpby(Int32(n), alpha, x.data, Int32(x.strides[0]), beta, data, Int32(strides[0]))
        }, fContiguous: {
            n in
            catlas_daxpby(Int32(n), alpha, x.data, 1, beta, data, 1)
        }, fSlice: { s, o in
            s.add(alpha, o, beta)
        })
    }

    /// in place multiplication by a scalar
    func multiply(by x: T) {
        apply1d(f1d: {
            n in
            cblas_dscal(Int32(n), x, data, Int32(strides[0]))
        }, fContiguous: {
            n in
            cblas_dscal(Int32(n), x, data, 1)
        }, fSlice: { s in
            s *= x
        })
    }

    func divide(by x: T) {
        multiply(by: 1 / x)
    }

    /// - Returns: 0 if array is empty, the sum of all elements otherwise
    func sum() -> T {
        var r = T.zero
        apply1d(f1d: {
            n in
            vDSP_sveD(data, strides[0], &r, vDSP_Length(n))
        }, fContiguous: {
            n in
            vDSP_sveD(data, 1, &r, vDSP_Length(n))
        }, fSlice: { s in
            r += s.sum()
        })
        return r
    }
}

/// Extension for arrays with Float elements.
public extension NdArray where T == Float {
    /// - Returns: maximum element, nil for empty arrays
    func max() -> T? {
        if isEmpty {
            return nil
        }
        var r = data[0]
        apply1d(f1d: {
            n in
            vDSP_maxv(data, strides[0], &r, vDSP_Length(n))
        }, fContiguous: {
            n in
            vDSP_maxv(data, 1, &r, vDSP_Length(n))
        }, fSlice: { s in
            r = Swift.max(r, s.max()!)
        })
        return r
    }

    /// - Returns: maximum element, nil for empty arrays
    func min() -> T? {
        if isEmpty {
            return nil
        }
        var r = data[0]
        apply1d(f1d: {
            n in
            vDSP_minv(data, strides[0], &r, vDSP_Length(n))
        }, fContiguous: {
            n in
            vDSP_minv(data, 1, &r, vDSP_Length(n))
        }, fSlice: { s in
            r = Swift.min(r, s.min()!)
        })
        return r
    }

    /// in place addition of a scaled vector,
    /// uses BLAS saxpy operation: self = alpha * x + self
    func add(_ alpha: T, _ x: NdArray<T>) {
        assert(shape == x.shape,
            """
            Cannot add arrays with shape \(x.shape) and \(shape).
            Assertion failed while trying to add \(x.debugDescription) to \(debugDescription).
            """)
        apply1d(other: x, f1d: {
            n in
            cblas_saxpy(Int32(n), alpha, x.data, Int32(x.strides[0]), data, Int32(strides[0]))
        }, fContiguous: {
            n in
            cblas_saxpy(Int32(n), alpha, x.data, 1, data, 1)
        }, fSlice: { s, o in
            s.add(alpha, o)
        })
    }

    /// in place addition of a scaled vector,
    /// uses ATLAS saxpyb operation: self = alpha * x + beta * self
    func add(_ alpha: T, _ x: NdArray<T>, _ beta: T) {
        assert(shape == x.shape,
            """
            Cannot add arrays with shape \(x.shape) and \(shape).
            Assertion failed while trying to add \(x.debugDescription) to \(debugDescription).
            """)
        apply1d(other: x, f1d: {
            n in
            catlas_saxpby(Int32(n), alpha, x.data, Int32(x.strides[0]), beta, data, Int32(strides[0]))
        }, fContiguous: {
            n in
            catlas_saxpby(Int32(n), alpha, x.data, 1, beta, data, 1)
        }, fSlice: { s, o in
            s.add(alpha, o, beta)
        })
    }

    /// in place multiplication by a scalar
    func multiply(by x: T) {
        apply1d(f1d: {
            n in
            cblas_sscal(Int32(n), x, data, Int32(strides[0]))
        }, fContiguous: {
            n in
            cblas_sscal(Int32(n), x, data, 1)
        }, fSlice: { s in
            s *= x
        })
    }

    func divide(by x: T) {
        multiply(by: 1 / x)
    }

    /// - Returns: 0 if array is empty, the sum of all elements otherwise
    func sum() -> T {
        var r = T.zero
        apply1d(f1d: {
            n in
            vDSP_sve(data, strides[0], &r, vDSP_Length(n))
        }, fContiguous: {
            n in
            vDSP_sve(data, 1, &r, vDSP_Length(n))
        }, fSlice: { s in
            r += s.sum()
        })
        return r
    }
}

// AdditiveArithmetic operators

public func +<K: AdditiveArithmetic, T: NdArray<K>>(a: T, x: K) -> T {
    let b = T(copy: a)
    b += x
    return b
}

public func +<K: AdditiveArithmetic, T: NdArray<K>>(x: K, a: T) -> T {
    return a + x
}

public func +<K: AdditiveArithmetic, T: NdArray<K>>(a: T, b: T) -> T {
    let c = T(copy: a)
    c += b
    return c
}

public func +=<K: AdditiveArithmetic, T: NdArray<K>>(a: T, b: T) {
    a.add(b)
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

public func -<K: AdditiveArithmetic, T: NdArray<K>>(a: T, b: T) -> T {
    let c = T(copy: a)
    c -= b
    return c
}

public func -=<K: AdditiveArithmetic, T: NdArray<K>>(a: T, b: T) {
    a.subtract(b)
}

// Numeric operators
public prefix func -<K: Numeric, T: NdArray<K>>(a: T) -> T {
    let b = T(copy: a)
    b *= -1
    return b
}

public func *<K: Numeric, T: NdArray<K>>(a: T, x: K) -> T {
    let b = T(copy: a)
    b *= x
    return b
}

public func *=<K: Numeric, T: NdArray<K>>(a: T, x: K) {
    a.multiply(by: x)
}

public func *<K: Numeric, T: NdArray<K>>(x: K, a: T) -> T {
    return a * x
}

// Double operators
public prefix func -<T: NdArray<Double>>(a: T) -> T {
    let b = T(copy: a)
    b *= -1
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

public func *=<T: NdArray<Double>>(a: T, x: Double) {
    a.multiply(by: x)
}

public func *<T: NdArray<Double>>(x: Double, a: T) -> T {
    return a * x
}

public func /=<T: NdArray<Double>>(a: T, x: Double) {
    a.divide(by: x)
}

public func +<T: NdArray<Double>>(a: T, b: T) -> T {
    let c = T(copy: a)
    c += b
    return c
}

public func +=<T: NdArray<Double>>(a: T, b: T) {
    a.add(1, b)
}

public func +<T: NdArray<Double>>(x: Double, a: T) -> T {
    return a + x
}

public func -<T: NdArray<Double>>(a: T, b: T) -> T {
    let c = T(copy: a)
    c -= b
    return c
}

public func -=<T: NdArray<Double>>(a: T, b: T) {
    a.add(-1, b)
}


// Float operators
public prefix func -<T: NdArray<Float>>(a: T) -> T {
    let b = T(copy: a)
    b *= -1
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

public func *=<T: NdArray<Float>>(a: T, x: Float) {
    a.multiply(by: x)
}

public func *<T: NdArray<Float>>(x: Float, a: T) -> T {
    return a * x
}

public func /=<T: NdArray<Float>>(a: T, x: Float) {
    a.divide(by: x)
}

public func +<T: NdArray<Float>>(a: T, b: T) -> T {
    let c = T(copy: a)
    c += b
    return c
}

public func +=<T: NdArray<Float>>(a: T, b: T) {
    a.add(1, b)
}

public func +<T: NdArray<Float>>(x: Float, a: T) -> T {
    return a + x
}

public func -<T: NdArray<Float>>(a: T, b: T) -> T {
    let c = T(copy: a)
    c -= b
    return c
}

public func -=<T: NdArray<Float>>(a: T, b: T) {
    a.add(-1, b)
}

