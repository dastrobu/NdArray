//
// Created by Daniel Strobusch on 2019-05-06.
//

import Accelerate

public extension NdArray where T == Double {
    convenience init(ones count: Int) {
        self.init(repeating: 1, count: count)
    }

    convenience init(ones shape: [Int], order: Contiguous = .C) {
        self.init(repeating: 1, shape: shape, order: order)
    }

    convenience init(zeros count: Int) {
        self.init(repeating: 0, count: count)
    }

    convenience init(zeros shape: [Int], order: Contiguous = .C) {
        self.init(repeating: 0, shape: shape, order: order)
    }

    convenience init(repeating x: T, shape: [Int], order: Contiguous = .C) {
        self.init(repeating: x, count: shape.reduce(1, *))
        self.reshape(shape, order: order)
    }

    convenience init(repeating x: T, count: Int) {
        self.init(empty: count)
        catlas_dset(Int32(count), x, data, 1)
    }
}

public extension NdArray where T == Float {
    convenience init(ones count: Int) {
        self.init(repeating: 1, count: count)
    }

    convenience init(ones shape: [Int], order: Contiguous = .C) {
        self.init(repeating: 1, shape: shape, order: order)
    }

    convenience init(zeros count: Int) {
        self.init(repeating: 0, count: count)
    }

    convenience init(zeros shape: [Int], order: Contiguous = .C) {
        self.init(repeating: 0, shape: shape, order: order)
    }

    convenience init(repeating x: T, shape: [Int], order: Contiguous = .C) {
        self.init(repeating: x, count: shape.reduce(1, *))
        self.reshape(shape, order: order)
    }

    convenience init(repeating x: T, count: Int) {
        self.init(empty: count)
        catlas_sset(Int32(count), x, data, 1)
    }
}
