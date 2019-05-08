//
// Created by Daniel Strobusch on 2019-05-04.
//

import Darwin

public class NdArraySlice<T>: NdArray<T> {
    // number of dimensions that have been sliced
    private var sliced: Int

    /// creates a copy of the array and defines a full slice of the copied array
    public required convenience init(copy a: NdArray<T>) {
        self.init(NdArray(copy: a), sliced: 0)
    }

    /// creates a view on another array without copying any data
    internal init(_ a: NdArray<T>, sliced: Int) {
        self.sliced = sliced
        super.init(a)
    }

    /// construct an array slice from a starting at index start
    internal init(_ a: NdArray<T>, startIndex: [Int], sliced: Int = 1) {
        self.sliced = sliced
        super.init(a)

        let start = a.flatIndex(startIndex)
        self.data = a.data + start
        self.count = a.len
    }

    /// full slice access
    public override subscript(r: UnboundedRange) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: sliced + 1)
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    public override subscript(r: ClosedRange<Int>) -> NdArraySlice<T> {
        get {
            return self[r.lowerBound..<r.upperBound + 1]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    public override subscript(r: PartialRangeThrough<Int>) -> NdArraySlice<T> {
        get {
            return self[0...r.upperBound]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    public override subscript(r: PartialRangeUpTo<Int>) -> NdArraySlice<T> {
        get {
            return self[0..<r.upperBound]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    public override subscript(r: PartialRangeFrom<Int>) -> NdArraySlice<T> {
        get {
            return self[r.lowerBound..<shape[sliced]]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// range slice access
    public override subscript(r: Range<Int>) -> NdArraySlice<T> {
        get {
            assert(!isEmpty)
            assert(r.lowerBound >= 0, "\(r.lowerBound) >= 0")

            // check for empty range
            if r.lowerBound >= r.upperBound {
                let slice = NdArraySlice(self, startIndex: Array<Int>(repeating: 0, count: ndim), sliced: sliced + 1)
                slice.shape[sliced] = 0
                slice.count = slice.len
                return slice
            }

            let upperBound = min(r.upperBound, shape[sliced])
            var startIndex = Array<Int>(repeating: 0, count: ndim)
            startIndex[sliced] = r.lowerBound
            let slice = NdArraySlice(self, startIndex: startIndex, sliced: sliced + 1)
            slice.shape[sliced] = upperBound - r.lowerBound
            slice.count = slice.len
            return slice
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// closed range with stride
    public override subscript(r: ClosedRange<Int>, stride: Int) -> NdArraySlice<T> {
        get {
            assert(stride > 0, "\(stride) > 0")

            let slice = self[r]
            slice.multiplyBy(stride: stride, axis: sliced)
            return slice
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// range with stride
    public override subscript(r: Range<Int>, stride: Int) -> NdArraySlice<T> {
        get {
            assert(stride > 0, "\(stride) > 0")

            let slice = self[r]
            slice.multiplyBy(stride: stride, axis: sliced)
            return slice
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range with stride
    public override subscript(r: PartialRangeFrom<Int>, stride: Int) -> NdArraySlice<T> {
        get {
            assert(stride > 0, "\(stride) > 0")

            let slice = self[r]
            slice.multiplyBy(stride: stride, axis: sliced)
            return slice
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range with stride
    public override subscript(r: PartialRangeThrough<Int>, stride: Int) -> NdArraySlice<T> {
        get {
            assert(stride > 0, "\(stride) > 0")

            let slice = self[r]
            slice.multiplyBy(stride: stride, axis: sliced)
            return slice
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range with stride
    public override subscript(r: PartialRangeUpTo<Int>, stride: Int) -> NdArraySlice<T> {
        get {
            assert(stride > 0, "\(stride) > 0")

            let slice = self[r]
            slice.multiplyBy(stride: stride, axis: sliced)
            return slice
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// full range with stride
    public override subscript(r: UnboundedRange, stride: Int) -> NdArraySlice<T> {
        get {
            assert(stride > 0, "\(stride) > 0")

            let slice = self[r]
            slice.multiplyBy(stride: stride, axis: sliced)
            return slice
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// single slice access
    public override subscript(i: Int) -> NdArraySlice<T> {
        get {
            assert(!isEmpty)

            // set the index on the sliced dimension
            var startIndex = Array<Int>(repeating: 0, count: ndim)
            startIndex[sliced] = i

            // here we reduce the shape, hence sliced stays the same
            let slice = NdArraySlice(self, startIndex: startIndex, sliced: sliced)
            // drop shape and stride
            slice.shape = Array(slice.shape[0..<sliced] + slice.shape[(sliced + 1)...])
            slice.strides = Array(slice.strides[0..<sliced] + slice.strides[(sliced + 1)...])
            slice.count = slice.len
            return slice
        }
        set {
            newValue.copyTo(self[i])
        }
    }
}
