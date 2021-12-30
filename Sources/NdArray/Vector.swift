//
// Created by Daniel Strobusch on 2019-05-07.
//

import Darwin
import Accelerate

public enum SortOrder {
    case ascending
    case descending
}

open class Vector<T>: NdArray<T>, Sequence {
    public required init(empty count: Int) {
        super.init(empty: count)
    }

    /// create an 1D NdArray from a plain array
    public convenience init(_ a: [T]) {
        self.init(empty: a.count)
        data.initialize(from: a, count: a.count)
    }

    public required convenience init(copy a: NdArray<T>) {
        precondition(a.shape.count == 1,
            """
            Cannot create vector with shape \(a.shape). Vector must have one dimension.
            Precondition failed while trying to copy \(a.debugDescription).
            """)
        self.init(empty: a.shape, order: a.isFContiguous ? .F : .C)
        a.copyTo(self)
    }

    /// element access
    public subscript(i: Int) -> T {
        get {
            let k = i * strides[0]
            precondition(k < strides[0] * shape[0])
            return data[k]
        }
        set {
            let k = i * strides[0]
            precondition(k < strides[0] * shape[0])
            return data[k] = newValue
        }
    }

    /// creates a view on another array without copying any data
    public required init(_ a: NdArray<T>) {
        precondition(a.shape.count == 1,
            """
            Cannot create vector with shape \(a.shape). Vector must have one dimension.
            Precondition failed while trying to create vector from \(a.debugDescription).
            """)
        super.init(a)
    }
}

public extension Vector where T == Double {
    func dot(_ y: Vector<T>) -> T {
        precondition(shape == y.shape,
            """
            Cannot compute dot product of vectors with shape \(shape) and \(y.shape).
            Precondition failed while trying to compute dot product for vectors from \(debugDescription) and \(y.debugDescription).
            """)
        let n = Int32(shape[0])
        return cblas_ddot(n, data, Int32(strides[0]), y.data, Int32(y.strides[0]))
    }

    func norm2() -> T {
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
            sortOrder = -1
        }

        if isContiguous {
            vDSP_vsortD(data, n, sortOrder)
        } else {
            // make a copy sort it and copy back if array is not contiguous
            let cpy = Vector(copy: self)
            vDSP_vsortD(cpy.data, n, sortOrder)
            self[0...] = cpy[0...]
        }
    }

    func reverse() {
        let n = vDSP_Length(shape[0])
        vDSP_vrvrsD(data, strides[0], n)
    }
}

public extension Vector where T == Float {
    func dot(_ y: Vector<T>) -> T {
        precondition(shape == y.shape,
            """
            Cannot compute dot product of vectors with shape \(shape) and \(y.shape).
            Precondition failed while trying to compute dot product for vectors from \(debugDescription) and \(y.debugDescription).
            """)
        let n = Int32(shape[0])
        return cblas_sdot(n, data, Int32(strides[0]), y.data, Int32(y.strides[0]))
    }

    func norm2() -> T {
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
            sortOrder = -1
        }

        if isContiguous {
            vDSP_vsort(data, n, sortOrder)
        } else {
            // make a copy sort it and copy back if array is not contiguous
            let cpy = Vector(copy: self)
            vDSP_vsort(cpy.data, n, sortOrder)
            self[0...] = cpy[0...]
        }
    }

    func reverse() {
        let n = vDSP_Length(shape[0])
        vDSP_vrvrs(data, strides[0], n)
    }
}

public func * (a: Vector<Double>, b: Vector<Double>) -> Double {
    a.dot(b)
}

public func * (a: Vector<Float>, b: Vector<Float>) -> Float {
    a.dot(b)
}
