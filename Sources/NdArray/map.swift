//
// Created by Daniel Strobusch on 2019-05-11.
//

import Darwin

/// extension implementing map
public extension NdArray {

    /// map a scalar function to all array elements
    func map(_ f: (T) throws -> T) rethrows -> Self {
        // copy and apply
        let r = type(of: self).init(copy: self)
        try r.apply(f)
        return r
    }
}
