//
// Created by Daniel Strobusch on 2019-05-03.
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

/// Generate values within an half-open interval [start, stop)
public extension NdArray where T == Int {
    /// initializer an array with a range of number starting from 0 upto (but excluding) rangeTo.
    convenience init(rangeTo stop: T, by step: T = 1) {
        self.init(rangeFrom: 0, to: stop, by: step)
    }

    /// Generate values within an half-open interval [rangeFrom, rangeTo) with step size by
    convenience init(rangeFrom start: T, to stop: T, by step: T = 1) {
        let n = arange(start: Double(start), stop: Double(stop), step: Double(step))
        self.init(empty: n)
        var p = data
        for i in stride(from: start, to: stop, by: step) {
            p.initialize(to: i)
            p += 1
        }
    }
}

public extension NdArray where T == Double {

    /// Generate values within an half-open interval [0, rangeTo)
    convenience init(rangeTo stop: T, by step: T = 1) {
        self.init(rangeFrom: 0, to: stop, by: step)
    }

    /// Generate values within an half-open interval [rangeFrom, rangeTo) with step size by
    convenience init(rangeFrom start: T, to stop: T, by step: T = 1) {
        let n = arange(start: start, stop: stop, step: step)
        self.init(empty: n)
        vramp(start: start, step: step, data: data, n: n, vramp: vDSP_vrampD)
    }
}

public extension NdArray where T == Float {

    /// Generate values within an half-open interval [0, rangeTo)
    convenience init(rangeTo stop: T, by step: T = 1) {
        self.init(rangeFrom: 0, to: stop, by: step)
    }

    /// Generate values within an half-open interval [rangeFrom, rangeTo) with step size by
    convenience init(rangeFrom start: T, to stop: T, by step: T = 1) {
        let n = arange(start: start, stop: stop, step: step)
        self.init(empty: n)
        vramp(start: start, step: step, data: data, n: n, vramp: vDSP_vramp)
    }
}

