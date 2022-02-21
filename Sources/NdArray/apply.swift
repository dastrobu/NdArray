//
// Created by Daniel Strobusch on 2019-05-11.
//

public extension NdArray {
    /// helper to apply a function to an array
    /// - Parameters:
    ///   - f1d: Function to apply, if the array is a 1d array
    ///   - fContiguous: Function to apply, if the array is contiguous
    ///   - fSlice: Function to apply to each slice, if the array is neither 1d nor contiguous
    internal func apply1d(f1d: (Int) throws -> Void,
                          fContiguous: (Int) throws -> Void,
                          fSlice: (NdArray<T>) throws -> Void) rethrows {
        let n = shape.reduce(1, *)
        if n == 0 {
            return
        }
        switch ndim {
        case 0:
            return
        case 1:
            try f1d(n)
        default:
            if isContiguous {
                try fContiguous(n)
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                for i in 0..<shape[0] {
                    try fSlice(a[[Slice(i)]])
                }
            }
        }
    }

    /// helper to apply a function to two arrays
    /// - Parameters:
    ///   - other: the other array
    ///   - f1d: Function to apply, if the array is a 1d array
    ///   - fContiguous: Function to apply, if the array and the other array is contiguous
    ///   - fSlice: Function to apply to each slice, if the array is neither 1d nor contiguous
    internal func apply1d(other: NdArray<T>, f1d: (Int) throws -> Void,
                          fContiguous: (Int) throws -> Void,
                          fSlice: (NdArray<T>, NdArray<T>) throws -> Void) rethrows {
        let n = shape.reduce(1, *)
        if n == 0 {
            return
        }
        switch ndim {
        case 0:
            return
        case 1:
            try f1d(n)
        default:
            if (isCContiguous && other.isCContiguous) || (isFContiguous && other.isFContiguous) {
                try fContiguous(n)
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                let b = NdArray(other)
                for i in 0..<shape[0] {
                    try fSlice(a[[Slice(i)]], b[[Slice(i)]])
                }
            }
        }
    }

    /// apply a function to all elements in place
    /// - Parameters:
    ///   - f: closure to apply to each array element
    func apply(_ f: (T) throws -> T) rethrows {
        try apply1d(f1d: { n in
            let s = strides[0]
            var p = data
            for _ in 0..<n {
                p.initialize(to: try f(p.pointee))
                p += s
            }
        }, fContiguous: { n in
            var p = data
            for _ in 0..<n {
                p.initialize(to: try f(p.pointee))
                p += 1
            }
        }, fSlice: { s in
            try s.apply(f)
        })
    }
}
