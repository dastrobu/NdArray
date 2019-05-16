//
// Created by Daniel Strobusch on 2019-05-06.
//

import Accelerate

fileprivate func vramp<T>(start: T, step: T, data: UnsafeMutablePointer<T>, n: Int,
                          vramp: (UnsafePointer<T>, UnsafePointer<T>, UnsafeMutablePointer<T>, vDSP_Stride, vDSP_Length) -> Void) {
    if n > 0 {
        var a = start
        var b = step
        vramp(&a, &b, data, 1, vDSP_Length(n))
    }
}

fileprivate func arange<T>(start: T, stop: T, step: T) -> Int where T: BinaryFloatingPoint {
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
        let a = self.init(empty: shape.isEmpty ? 0 : shape.reduce(1, *))
        a.reshape(shape, order: order)
        return a
    }

    /// init with constant value
    static func repeating(_ x: T, count: Int) -> Self {
        let a = self.init(empty: count)
        for i in 0..<count {
            a.data[i] = x
        }
        return a
    }

    /// init with constant value
    static func repeating(_ x: T, shape: [Int], order: Contiguous = .C) -> Self {
        let a = repeating(x, count: shape.isEmpty ? 0 : shape.reduce(1, *))
        a.reshape(shape, order: order)
        return a
    }
}

public extension NdArray where T: AdditiveArithmetic {
    /// init with constant value
    static func zeros(_ count: Int) -> Self {
        return repeating(T.zero, count: count)
    }

    /// init with zeros
    static func zeros(_ shape: [Int], order: Contiguous = .C) -> Self {
        return repeating(T.zero, shape: shape, order: order)
    }

}

public extension NdArray where T == Double {
    /// Generate values within an half-open interval [0, rangeTo)
    static func range(to stop: T, by step: T = 1) -> Self {
        return self.range(from: 0, to: stop, by: step)
    }

    /// Generate values within an half-open interval [rangeFrom, rangeTo) with step size by
    static func range(from start: T, to stop: T, by step: T = 1) -> Self {
        let n = arange(start: start, stop: stop, step: step)
        let a = self.init(empty: n)
        vramp(start: start, step: step, data: a.data, n: n, vramp: vDSP_vrampD)
        return a
    }

    static func ones(_ count: Int) -> Self {
        return repeating(1, count: count)
    }

    static func ones(_ shape: [Int], order: Contiguous = .C) -> Self {
        return repeating(1, shape: shape, order: order)
    }

    static func zeros(_ count: Int) -> Self {
        return repeating(0, count: count)
    }

    static func zeros(_ shape: [Int], order: Contiguous = .C) -> Self {
        return repeating(0, shape: shape, order: order)
    }

    static func repeating(_  x: T, shape: [Int], order: Contiguous = .C) -> Self {
        let a = repeating(x, count: shape.isEmpty ? 0 : shape.reduce(1, *))
        a.reshape(shape, order: order)
        return a
    }

    static func repeating(_ x: T, count: Int) -> Self {
        let a = self.init(empty: count)
        catlas_dset(Int32(count), x, a.data, 1)
        return a
    }
}

public extension NdArray where T == Float {
    /// Generate values within an half-open interval [0, rangeTo)
    static func range(to stop: T, by step: T = 1) -> Self {
        return self.range(from: 0, to: stop, by: step)
    }

    /// Generate values within an half-open interval [rangeFrom, rangeTo) with step size by
    static func range(from start: T, to stop: T, by step: T = 1) -> Self {
        let n = arange(start: start, stop: stop, step: step)
        let a = self.init(empty: n)
        vramp(start: start, step: step, data: a.data, n: n, vramp: vDSP_vramp)
        return a
    }

    static func ones(_ count: Int) -> Self {
        return repeating(1, count: count)
    }

    static func ones(_ shape: [Int], order: Contiguous = .C) -> Self {
        return repeating(1, shape: shape, order: order)
    }

    static func zeros(_ count: Int) -> Self {
        return repeating(0, count: count)
    }

    static func zeros(_ shape: [Int], order: Contiguous = .C) -> Self {
        return repeating(0, shape: shape, order: order)
    }

    static func repeating(_  x: T, shape: [Int], order: Contiguous = .C) -> Self {
        let a = repeating(x, count: shape.isEmpty ? 0 : shape.reduce(1, *))
        a.reshape(shape, order: order)
        return a
    }

    static func repeating(_ x: T, count: Int) -> Self {
        let a = self.init(empty: count)
        catlas_sset(Int32(count), x, a.data, 1)
        return a
    }
}

/// Generate values within an half-open interval [start, stop)
public extension NdArray where T == Int {
    /// initializer an array with a range of number starting from 0 upto (but excluding) rangeTo.
    static func range(to stop: T, by step: T = 1) -> Self {
        return range(from: 0, to: stop, by: step)
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
        return a
    }

    static func zeros(_ count: Int) -> Self {
        let a = self.init(empty: count)
        memset(a.data, 0, count * MemoryLayout<Int>.stride)
        return a
    }

    static func zeros(_ shape: [Int], order: Contiguous = .C) -> Self {
        let a = self.zeros(shape.isEmpty ? 0 : shape.reduce(1, *))
        a.reshape(shape, order: order)
        return a
    }
}

