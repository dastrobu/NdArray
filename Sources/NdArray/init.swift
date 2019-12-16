//
// Created by Daniel Strobusch on 2019-05-06.
//

import Accelerate

private func vramp<T>(start: T, step: T, data: UnsafeMutablePointer<T>, n: Int,
                      vramp: (UnsafePointer<T>, UnsafePointer<T>, UnsafeMutablePointer<T>, vDSP_Stride, vDSP_Length) -> Void) {
    if n > 0 {
        var a = start
        var b = step
        vramp(&a, &b, data, 1, vDSP_Length(n))
    }
}

private func arange<T>(start: T, stop: T, step: T) -> Int where T: BinaryFloatingPoint {
    let n: Int
    if start <= stop {
        if step > 0 {
            n = Int(ceil((stop - start) / step))
        } else {
            n = 0
        }
    } else {
        if step < 0 {
            n = Int(ceil((start - stop) / -step))
        } else {
            n = 0
        }
    }
    assert(n >= 0)
    return n
}

public extension NdArray {
    static func empty(shape: [Int], order: Contiguous = .C) -> Self {
        let a = NdArray(empty: shape.isEmpty ? 0 : shape.reduce(1, *))
        a.reshape(shape, order: order)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    /// init with constant value
    static func repeating(_ x: T, count: Int) -> Self {
        let a = NdArray(empty: count)
        for i in 0..<count {
            a.data[i] = x
        }
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    /// init with constant value
    static func repeating(_ x: T, shape: [Int], order: Contiguous = .C) -> Self {
        let a = NdArray.repeating(x, count: shape.isEmpty ? 0 : shape.reduce(1, *))
        a.reshape(shape, order: order)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }
}

public extension NdArray where T: AdditiveArithmetic {
    /// init with constant value
    static func zeros(_ count: Int) -> Self {
        let a = NdArray.repeating(T.zero, count: count)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    /// init with zeros
    static func zeros(_ shape: [Int], order: Contiguous = .C) -> Self {
        let a = NdArray.repeating(T.zero, shape: shape, order: order)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

}

public extension NdArray where T == Double {
    /// Generate values within an half-open interval [0, rangeTo)
    static func range(to stop: T, by step: T = 1) -> Self {
        let a = NdArray.range(from: 0, to: stop, by: step)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    /// Generate values within an half-open interval [rangeFrom, rangeTo) with step size by
    static func range(from start: T, to stop: T, by step: T = 1) -> Self {
        let n = arange(start: start, stop: stop, step: step)
        let a = NdArray(empty: n)
        vramp(start: start, step: step, data: a.data, n: n, vramp: vDSP_vrampD)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func ones(_ count: Int) -> Self {
        let a = NdArray.repeating(1, count: count)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func ones(_ shape: [Int], order: Contiguous = .C) -> Self {
        let a = NdArray.repeating(1, shape: shape, order: order)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func zeros(_ count: Int) -> Self {
        let a = NdArray.repeating(0, count: count)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func zeros(_ shape: [Int], order: Contiguous = .C) -> Self {
        let a = NdArray.repeating(0, shape: shape, order: order)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func repeating(_  x: T, shape: [Int], order: Contiguous = .C) -> Self {
        let a = NdArray.repeating(x, count: shape.isEmpty ? 0 : shape.reduce(1, *))
        a.reshape(shape, order: order)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func repeating(_ x: T, count: Int) -> Self {
        let a = NdArray(empty: count)
        catlas_dset(Int32(count), x, a.data, 1)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }
}

public extension NdArray where T == Float {
    /// Generate values within an half-open interval [0, rangeTo)
    static func range(to stop: T, by step: T = 1) -> Self {
        let a = NdArray.range(from: 0, to: stop, by: step)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    /// Generate values within an half-open interval [rangeFrom, rangeTo) with step size by
    static func range(from start: T, to stop: T, by step: T = 1) -> Self {
        let n = arange(start: start, stop: stop, step: step)
        let a = NdArray(empty: n)
        vramp(start: start, step: step, data: a.data, n: n, vramp: vDSP_vramp)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func ones(_ count: Int) -> Self {
        let a = NdArray.repeating(1, count: count)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func ones(_ shape: [Int], order: Contiguous = .C) -> Self {
        let a = NdArray.repeating(1, shape: shape, order: order)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func zeros(_ count: Int) -> Self {
        let a = NdArray.repeating(0, count: count)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func zeros(_ shape: [Int], order: Contiguous = .C) -> Self {
        let a = NdArray.repeating(0, shape: shape, order: order)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func repeating(_  x: T, shape: [Int], order: Contiguous = .C) -> Self {
        let a = NdArray.repeating(x, count: shape.isEmpty ? 0 : shape.reduce(1, *))
        a.reshape(shape, order: order)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func repeating(_ x: T, count: Int) -> Self {
        let a = NdArray(empty: count)
        catlas_sset(Int32(count), x, a.data, 1)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }
}

/// Generate values within an half-open interval [start, stop)
public extension NdArray where T == Int {
    /// initializer an array with a range of number starting from 0 upto (but excluding) rangeTo.
    static func range(to stop: T, by step: T = 1) -> Self {
        let a = NdArray.range(from: 0, to: stop, by: step)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    /// Generate values within an half-open interval [rangeFrom, rangeTo) with step size by
    static func range(from start: T, to stop: T, by step: T = 1) -> Self {
        let n = arange(start: Double(start), stop: Double(stop), step: Double(step))
        let a = self.init(empty: n)
        var p = a.data
        for i in stride(from: start, to: stop, by: step) {
            p.initialize(to: i)
            p += 1
        }
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func zeros(_ count: Int) -> Self {
        let a = self.init(empty: count)
        memset(a.data, 0, count * MemoryLayout<Int>.stride)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }

    static func zeros(_ shape: [Int], order: Contiguous = .C) -> Self {
        let a = self.zeros(shape.isEmpty ? 0 : shape.reduce(1, *))
        a.reshape(shape, order: order)
        let r = self.init(a)
        r.stealOwnership()
        return r
    }
}
