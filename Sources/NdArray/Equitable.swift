//
// Created by Daniel Strobusch on 2019-05-11.
//

extension NdArray: Equatable where T: Equatable {

    /// arrays are considered equal if they have the same type, the same shape and the same elements
    /// (not necessarily the same strides).
    public static func ==(lhs: NdArray<T>, rhs: NdArray<T>) -> Bool {
        if type(of: lhs) !== type(of: rhs) {
            return false
        }

        if lhs.shape != rhs.shape {
            return false
        }

        let n = lhs.shape.reduce(1, *)
        if n == 0 {
            return true
        }
        switch lhs.ndim {
        case 0:
            return true
        case 1:
            var l = lhs.data
            var r = rhs.data
            let ls = lhs.strides[0]
            let rs = rhs.strides[0]
            for _ in 0..<lhs.count {
                if l.pointee != r.pointee {
                    return false
                }
                l += ls
                r += rs
            }
        default:
            if (lhs.isCContiguous && rhs.isCContiguous) || (lhs.isFContiguous && rhs.isFContiguous) {
                var l = lhs.data
                var r = rhs.data
                for _ in 0..<lhs.count {
                    if l.pointee != r.pointee {
                        return false
                    }
                    l += 1
                    r += 1
                }
            } else {
                // make sure the array is not sliced
                let a = NdArray(lhs)
                let b = NdArray(rhs)
                for i in 0..<a.shape[0] {
                    if a[i] != b[i] {
                        return false
                    }
                }
            }
        }
        return true
    }
}