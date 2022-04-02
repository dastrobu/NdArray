//
// Created by Daniel Strobusch on 2019-05-04.
//

import Darwin

internal class NdArraySlice<T>: NdArray<T> {
    /// number of dimensions that have been sliced
    private var sliced: Int

    /// array of slices that have been applied to the original array, used for debugDescription
    private var sliceDescription: [String] = []

    /// creates a view on another array without copying any data
    internal init(_ a: NdArray<T>, sliced: Int) {
        self.sliced = sliced
        super.init(a)
        precondition(sliced <= ndim,
            """
            Cannot slice array with ndim \(ndim) more than \(ndim) times.
            Precondition failed while trying to create slice \(debugDescription).
            """)
    }

    /// construct an array slice from starting at index start
    internal init(_ a: NdArray<T>, startIndex: [Int], sliced: Int = 1) {
        self.sliced = sliced
        super.init(a)

        let start = a.flatIndex(startIndex)
        dataStart = a.dataStart + start
        count = a.len
    }

    internal required init(empty count: Int) {
        sliced = 0
        super.init(empty: count)
    }

    /// creates a view on another array without copying any data
    internal required convenience init(_ a: NdArray<T>) {
        self.init(a, sliced: 0)
    }

    /// creates a copy of the array and defines a full slice of the copied array
    internal required convenience init(copy a: NdArray<T>) {
        self.init(NdArray(copy: a), sliced: 0)
    }

    private func subscr(_ r: UnboundedRange) -> NdArraySlice {
        let slice = NdArraySlice(self, sliced: sliced + 1)
        slice.sliceDescription = sliceDescription
        slice.sliceDescription.append("[0...]")
        return slice
    }

    private func subscr(_ r: ClosedRange<Int>) -> NdArraySlice {
        let slice = self.subscr(r.lowerBound..<r.upperBound + 1)
        slice.sliceDescription.removeLast()
        slice.sliceDescription.append("[\(r.lowerBound)...\(r.upperBound)]")
        return slice
    }

    private func subscr(_ r: PartialRangeThrough<Int>) -> NdArraySlice {
        let slice = self.subscr(0...r.upperBound)
        slice.sliceDescription.removeLast()
        slice.sliceDescription.append("[...\(r.upperBound)]")
        return slice
    }

    private func subscr(_ r: PartialRangeUpTo<Int>) -> NdArraySlice {
        let slice = self.subscr(0..<r.upperBound)
        slice.sliceDescription.removeLast()
        slice.sliceDescription.append("[..<\(r.upperBound)]")
        return slice
    }

    private func subscr(_ r: PartialRangeFrom<Int>) -> NdArraySlice {
        let slice = self.subscr(r.lowerBound..<shape[sliced])
        slice.sliceDescription.removeLast()
        slice.sliceDescription.append("[\(r.lowerBound)...]")
        return slice
    }

    private func subscr(_ r: Range<Int>) -> NdArraySlice {
        precondition(!isEmpty)
        precondition(r.lowerBound >= 0, "\(r.lowerBound) >= 0")

        // check for empty range
        if r.lowerBound >= r.upperBound {
            let slice = NdArraySlice(self, startIndex: [Int](repeating: 0, count: ndim), sliced: sliced + 1)
            slice.shape[sliced] = 0
            slice.count = slice.len
            slice.sliceDescription = sliceDescription
            slice.sliceDescription.append("[\(r.lowerBound)..<\(r.upperBound)]")
            return slice
        }

        let upperBound = Swift.min(r.upperBound, shape[sliced])
        var startIndex = [Int](repeating: 0, count: ndim)
        startIndex[sliced] = r.lowerBound
        let slice = NdArraySlice(self, startIndex: startIndex, sliced: sliced + 1)
        slice.shape[sliced] = upperBound - r.lowerBound
        slice.count = slice.len
        slice.sliceDescription = sliceDescription
        slice.sliceDescription.append("[\(r.lowerBound)..<\(r.upperBound)]")
        return slice
    }

    internal func subscr(lowerBound: Int, upperBound: Int, stride: Int) -> NdArraySlice<T> {
        precondition(stride > 0, "\(stride) > 0")

        let slice = self.subscr(lowerBound..<upperBound)
        slice.sliceDescription.removeLast()
        slice.sliceDescription.append("[\(lowerBound)..<\(upperBound), \(stride)]")
        slice.strideBy(stride, axis: sliced)
        return slice
    }

    internal func subscr(_ i: Int) -> NdArraySlice<T> {
        precondition(!isEmpty)

        // set the index on the sliced dimension
        var startIndex = [Int](repeating: 0, count: ndim)
        startIndex[sliced] = i

        // here we reduce the shape, hence sliced stays the same
        let slice = NdArraySlice(self, startIndex: startIndex, sliced: sliced)
        slice.sliceDescription = sliceDescription
        slice.sliceDescription.append("[\(i)]")
        // drop shape and stride
        slice.shape = Array(slice.shape[0..<sliced] + slice.shape[(sliced + 1)...])
        slice.strides = Array(slice.strides[0..<sliced] + slice.strides[(sliced + 1)...])
        slice.count = slice.len
        return slice
    }

    /// adjust strides and shape, if the array is strided
    private func strideBy(_ stride: Int, axis: Int) {
        strides[axis] *= stride
        // integer ceiling division
        shape[axis] = (shape[axis] - 1 + stride) / stride
    }
}
