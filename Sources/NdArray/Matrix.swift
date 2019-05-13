//
// Created by Daniel Strobusch on 2019-05-07.
//

import Darwin

public class Matrix<T>: NdArray<T> {
    /// create an 2D NdArray from a plain array
    public init(_ a: [[T]], order: Contiguous = .C) {
        super.init(empty: 0)
    }

    public init(empty shape: [Int], order: Contiguous = .C) {
        super.init(empty: shape.reduce(1, *))
        reshape(shape, order: order)
    }

    /// creates a view on another array without copying any data
    public init(_ a: Matrix<T>) {
        super.init(a)
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

}

public extension Matrix where T == Double {
    var T: Matrix<T> {
        get {
            return transposed()
        }
    }

    func transposed() -> Matrix<T> {
        // TODO
        return self
    }

    func solve(_ x: Vector<T>, out: Vector<T>? = nil) throws -> Vector<T> {
        let B = out ?? Vector(empty: x.shape[0])
        // TODO
        return B
    }

    func solve(_ x: Matrix<T>, out: Matrix<T>? = nil) throws -> Matrix<T> {
        let B = out ?? Matrix(empty: x.shape)
        // TODO
        return B
    }

    func inverted(out: Matrix<T>? = nil) throws -> Matrix<T> {
        let B = out ?? Matrix(empty: self.shape)
        // TODO
        return B
    }

}


public func *(A: Matrix<Double>, x: Vector<Double>) -> Vector<Double> {
    // TODO
    let y = Vector<Double>(empty: x.shape[0])
    return y
}

public func *(A: Matrix<Double>, B: Matrix<Double>) -> Matrix<Double> {
    // TODO
    let y = Matrix<Double>(empty: B.shape)
    return y
}

public func +(A: Matrix<Double>, B: Matrix<Double>) -> Matrix<Double> {
    // TODO
    let y = Matrix<Double>(empty: B.shape)
    return y
}

public func -(A: Matrix<Double>, B: Matrix<Double>) -> Matrix<Double> {
    // TODO
    let y = Matrix<Double>(empty: B.shape)
    return y

}

// TODO override for band/tridiag matrix

