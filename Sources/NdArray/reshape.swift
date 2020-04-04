//
// Created by Daniel Strobusch on 2019-05-03.
//

/// Extension for reshaping arrays
public extension NdArray {

    /// Perform a no-copy (in place) reshape of the array. That means the existing data is interpreted as a different
    /// NdArray with a new shape (and new strides).
    /// The new shape must be compatible with the old shape.
    ///
    /// Code is a port of numpys reshape algorithm in numpy/core/src/multiarray/shape.c
    @discardableResult
    internal func reshape(_ shape: [Int], order: Contiguous = .C) -> Bool {
        assert((shape.isEmpty ? 0 : shape.reduce(1, *)) == count, "data with \(count) elements cannot be reshaped to new shape \(shape)")

        if count == 0 {
            self.shape = shape
            self.strides = Array(repeating: 1, count: shape.count)
            return true
        }

        let oldShape = self.shape
        let newShape = shape

        let oldDim = oldShape.count
        let newDim = newShape.count

        let oldStrides = self.strides
        var newStrides = [Int](repeating: 0, count: newDim)

        /* oi to oj and ni to nj give the axis ranges currently worked with */
        var oi = 0
        var oj = 1
        var ni = 0
        var nj = 1
        while ni < newDim && oi < oldDim {
            // new and old dim on axis i
            do {
                var osi = oldShape[oi]
                var nsi = newShape[ni]

                while nsi != osi {
                    if nsi < osi {
                        /* Misses trailing 1s, these are handled later */
                        nsi *= newShape[nj]
                        nj += 1
                    } else {
                        osi *= oldShape[oj]
                        oj += 1
                    }
                }
            }

            /* Check whether the original axes can be combined */
            do {
                for ok in oi..<oj - 1 {
                    switch order {
                    case .F:
                        if oldStrides[ok + 1] != oldShape[ok] * oldStrides[ok] {
                            /* not contiguous enough */
                            return false
                        }
                    case .C:
                        if oldStrides[ok] != oldShape[ok + 1] * oldStrides[ok + 1] {
                            /* not contiguous enough */
                            return false
                        }
                    }
                }
            }

            /* Calculate new strides for all axes currently worked with */
            switch order {
            case .F:
                newStrides[ni] = oldStrides[oi]
                for nk in ni + 1..<nj {
                    newStrides[nk] = newStrides[nk - 1] * newShape[nk - 1]
                }
            case .C:
                newStrides[nj - 1] = oldStrides[oj - 1]
                var nk = nj - 1
                while nk > ni {
                    newStrides[nk - 1] = newStrides[nk] * newShape[nk]
                    nk -= 1
                }
            }
            ni = nj
            nj += 1
            oi = oj
            oj += 1
        }

        // Set strides corresponding to trailing 1s of the new shape.
        do {
            var last_stride: Int
            if ni >= 1 {
                last_stride = newStrides[ni - 1]
            } else {
                last_stride = 1
            }
            if order == .F {
                last_stride *= newShape[ni - 1]
            }

            for nk in ni..<newDim {
                newStrides[nk] = last_stride
            }
        }

        self.shape = newShape
        self.strides = newStrides
        return true
    }

    /// - Parameters:
    ///   - shape: shape of the reshaped array
    ///
    /// - Returns: A reshaped array view or copy if the array could not be reshaped in place
    func reshaped(_ shape: [Int]) -> NdArray<T> {
        var a = NdArray(self)
        // only reshape in F order it array is not 1D and is F contiguous
        if a.reshape(shape, order: isFContiguous && ndim != 1 ? .F : .C) {
            return a
        }
        a = NdArray(copy: self)
        a.reshape(shape)
        return a
    }

    /// - Parameters:
    ///   - shape: shape of the reshaped array
    ///   - order: alignment of the reshaped array
    ///
    /// - Returns: A reshaped array view or copy if the array could not be reshaped in place
    func reshaped(_ shape: [Int], order: Contiguous) -> NdArray<T> {
        var a = NdArray(self)
        if a.reshape(shape, order: order) {
            return a
        }
        a = NdArray(copy: self)
        a.reshape(shape)
        return a
    }

    /// - Returns: A flattened array view or copy if the array could not be reshaped to a flattened array
    func flattened() -> NdArray<T> {
        var a = NdArray(self)
        let n = a.shape.reduce(1, *)
        if n == a.count && a.reshape([n]) {
            return a
        }
        a = NdArray(copy: self)
        a.reshape([n])
        return a
    }
}
