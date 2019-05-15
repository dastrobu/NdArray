//
// Created by Daniel Strobusch on 2019-05-07.
//

import Darwin
import Accelerate

public enum SortOrder {
    case ascending
    case descending
}

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
    func dot(_ y: Vector<T>) -> T {
        let n = Int32(shape[0])
        return cblas_ddot(n, data, Int32(strides[0]), y.data, Int32(y.strides[0]))
    }

    func norm2(_ y: Vector<T>) -> T {
        let n = Int32(shape[0])
        return cblas_dnrm2(n, data, Int32(strides[0]))
    }

    func sort(order: SortOrder = .ascending) {
        let n = vDSP_Length(shape[0])
        let sortOrder: Int32
        switch order {
        case .ascending:
            sortOrder = 1
        case .descending:
            sortOrder = 2
        }

        if isContiguous {
            vDSP_vsortD(data, n, sortOrder)
        } else {
            // make a copy sort it and copy back if array is not contiguous
            let cpy = Vector(copy: self)
            vDSP_vsortD(cpy.data, n, sortOrder)
            self[...] = cpy[...]
        }
    }

    func revert() {
        let n = vDSP_Length(shape[0])
        vDSP_vrvrsD(data, strides[0], n)
    }
}

public extension Vector where T == Float {
    func dot(_ y: Vector<T>) -> T {
        let n = Int32(shape[0])
        return cblas_sdot(n, data, Int32(strides[0]), y.data, Int32(y.strides[0]))
    }

    func norm2(_ y: Vector<T>) -> T {
        let n = Int32(shape[0])
        return cblas_snrm2(n, data, Int32(strides[0]))
    }

    func sort(order: SortOrder = .ascending) {
        let n = vDSP_Length(shape[0])
        let sortOrder: Int32
        switch order {
        case .ascending:
            sortOrder = 1
        case .descending:
            sortOrder = 2
        }

        if isContiguous {
            vDSP_vsort(data, n, sortOrder)
        } else {
            // make a copy sort it and copy back if array is not contiguous
            let cpy = Vector(copy: self)
            vDSP_vsort(cpy.data, n, sortOrder)
            self[...] = cpy[...]
        }
    }

    func revert() {
        let n = vDSP_Length(shape[0])
        vDSP_vrvrs(data, strides[0], n)
    }
}

public func *(a: Vector<Double>, b: Vector<Double>) -> Double {
    return a.dot(b)
}

public func *(a: Vector<Float>, b: Vector<Float>) -> Float {
    return a.dot(b)
}

