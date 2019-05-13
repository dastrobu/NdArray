//
// Created by Daniel Strobusch on 2019-05-07.
//

import Darwin
import Accelerate

// TODO sort, norm2, dot
public class Vector<T>: NdArray<T> {
    internal override init(empty count: Int) {
        super.init(empty: count)
    }

    /// create an 1D NdArray from a plain array
    public convenience init(_ a: [T]) {
        self.init(empty: a.count)
        data.initialize(from: a, count: a.count)
    }

    public required init(copy a: NdArray<T>) {
        let n = a.shape.reduce(1, *)
        super.init(empty: n)

        // check if the entire data buffer can be simply copied
        if a.isContiguous {
            memcpy(data, a.data, a.count * MemoryLayout<T>.stride)
            self.shape = a.shape
            self.strides = a.strides
            return
        }

        // reshape the new array
        self.reshape(a.shape)
        a.copyTo(self)
    }

    /// creates a view on another array without copying any data
    public init(_ a: Vector<T>) {
        super.init(a)
    }
}

public extension Vector where T == Double {

    func plus(_ alpha: T, times x: Vector<T>) {
        let n = Int32(shape[0])
        cblas_daxpy(n, alpha, x.data, Int32(x.strides[0]), data, Int32(strides[0]))
    }

    func dot(_ y: Vector<T>) -> T {
        let n = Int32(shape[0])
        return cblas_ddot(n, data, Int32(strides[0]), y.data, Int32(y.strides[0]))
    }

    func norm2(_ y: Vector<T>) -> T {
        let n = Int32(shape[0])
        return cblas_dnrm2(n, data, Int32(strides[0]))
    }
}

public extension Vector where T == Float {
    func plus(_ alpha: T, times x: Vector<T>) {
        let n = Int32(shape[0])
        cblas_saxpy(n, alpha, x.data, Int32(x.strides[0]), data, Int32(strides[0]))
    }

    func dot(_ y: Vector<T>) -> T {
        let n = Int32(shape[0])
        return cblas_sdot(n, data, Int32(strides[0]), y.data, Int32(y.strides[0]))
    }

    func norm2(_ y: Vector<T>) -> T {
        let n = Int32(shape[0])
        return cblas_snrm2(n, data, Int32(strides[0]))
    }
}

// TODO refactor this to work on all arrays

// TODO test
fileprivate func binaryVectorOperation<T: Numeric>(_ a: Vector<T>, _ b: Vector<T>, _ op: (T, T) -> T) -> Vector<T> {
    assert(a.shape == b.shape, "\(a.shape) == \(b.shape)")
    let n = a.shape[0]
    let c = Vector<T>(empty: n)
    let sa = a.strides[0]
    let sb = b.strides[0]
    var pa = a.data
    var pb = b.data
    var pc = c.data
    for _ in 0..<n {
        pa.initialize(to: op(pa.pointee, pb.pointee))

        pa += sa
        pb += sb
        pc += 1
    }
    return c
}

public func +<T: Numeric>(a: Vector<T>, b: Vector<T>) -> Vector<T> {
    return binaryVectorOperation(a, b, +)
}

public func -<T: Numeric>(a: Vector<T>, b: Vector<T>) -> Vector<T> {
    return binaryVectorOperation(a, b, -)
}

public func *<T: Numeric>(a: Vector<T>, b: Vector<T>) -> Vector<T> {
    return binaryVectorOperation(a, b, *)
}

public func /<T: FloatingPoint>(a: Vector<T>, b: Vector<T>) -> Vector<T> {
    return binaryVectorOperation(a, b, /)
}

public func +=(a: Vector<Double>, b: Vector<Double>) {
    a.plus(1, times: b)
}

public func -=(a: Vector<Double>, b: Vector<Double>) {
    a.plus(-1, times: b)
}

public func *=(a: Vector<Double>, b: Vector<Double>) {
    // TODO
}


// TODO cblas_daxpy
// TODO catlas_daxpby
// TODO cblas_saxpy
// TODO catlas_saxpby
