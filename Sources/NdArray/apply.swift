//
// Created by Daniel Strobusch on 2019-05-11.
//

public extension NdArray {
    /// apply a function to all elements in place
    /// - Parameters:
    ///   - f: closure to apply to each array element
    func apply(_ f: (T) throws -> T) rethrows {
        let n = shape.reduce(1, *)
        if n == 0 {
            return
        }
        switch ndim {
        case 0:
            return
        case 1:
            let s = strides[0]
            var p = data
            for _ in 0..<n {
                p.initialize(to: try f(p.pointee))
                p += s
            }
        default:
            if isContiguous {
                var p = data
                for _ in 0..<n {
                    p.initialize(to: try f(p.pointee))
                    p += 1
                }
            } else {
                // make sure the array is not sliced
                let a = NdArray(self)
                for i in 0..<shape[0] {
                    try a[i].apply(f)
                }
            }
        }
    }
}

