//
// Created by Daniel Strobusch on 2019-05-11.
//

import Foundation

/// Extension defining the reduce operation
extension NdArray {
    /// reduce all elements of the array
    /// if the array is empty, the initial result is returned
    public func reduce<Result>(_ initialResult: Result,
                               _ nextPartialResult: (Result, T) throws -> Result) rethrows -> Result {

        var r = initialResult;
        let n = shape.reduce(1, *)
        if n == 0 {
            return r
        }
        switch ndim {
        case 0:
            return r
        case 1:
            let s = strides[0]
            var p = data
            for _ in 0..<n {
                r = try nextPartialResult(r, p.pointee)
                p += s
            }
        default:
            if isContiguous {
                var p = data
                for _ in 0..<n {
                    r = try nextPartialResult(r, p.pointee)
                    p += 1
                }
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                for i in 0..<shape[0] {
                    r = try a[i].reduce(r, nextPartialResult)
                }
            }
        }
        return r
    }
}