//
// Created by Daniel Strobusch on 2019-05-11.
//

import Foundation

/// Extension defining the reduce operation
public extension NdArray {
    /// reduce all elements of the array
    /// if the array is empty, the initial result is returned
    func reduce<Result>(_ initialResult: Result,
                        _ nextPartialResult: (Result, T) throws -> Result) rethrows -> Result {
        var r = initialResult
        try apply1d(f1d: { n in
            let s = strides[0]
            var p = data
            for _ in 0..<n {
                r = try nextPartialResult(r, p.pointee)
                p += s
            }
        }, fContiguous: { n in
            var p = data
            for _ in 0..<n {
                r = try nextPartialResult(r, p.pointee)
                p += 1
            }
        }, fSlice: { s in
            r = try s.reduce(r, nextPartialResult)
        })
        return r
    }
}
