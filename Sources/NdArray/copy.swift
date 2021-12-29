import Darwin

public extension NdArray {

    /// Copy the values from the array into another array. The destination array must have the same shape as the source
    /// array.
    func copyTo(_ out: NdArray<T>) {
        precondition(shape == out.shape,
            """
            Cannot copy array with shape \(shape) to array with shape \(out.shape).
            Precondition failed while trying to copy \(debugDescription) to \(out.debugDescription).
            """)
        if count == 0 {
            // if there is nothing to copy, return
            return
        }
        precondition(ndim > 0, "\(ndim) > 0")
        // check if both arrays are aligned and have the same alignment. In this case do a simple memcpy
        if (isCContiguous && out.isCContiguous) ||
               (isFContiguous && out.isFContiguous) {
            // since buffers may overlap, use memmove instead of memcpy
            memmove(out.data, data, count * MemoryLayout<T>.stride)
        } else if overlaps(out) {
            // if memory overlaps and is not 1d aligned make an intermediate copy
            if out.isFContiguous {
                // if out is an F contiguous array, make sure the copy of self is as well, so we can fallback to
                // memcopy later
                NdArray(copy: self, order: .F).copyTo(out)
            } else {
                // if the out array is C contiguous or not aligned just make a C contiguous copy of self
                NdArray(copy: self, order: .C).copyTo(out)
            }
        } else {
            // make sure we get rid of any subclassing
            // array not aligned or not with same alignment
            if ndim == 1 {
                // handle 1d strided data explicitly
                let k = out.strides[0]
                let l = strides[0]
                for i in 0..<shape[0] {
                    out.data[i * k] = data[i * l]
                }
            } else {
                // iterate first dimension and do recursion.
                // If contiguous memory is found in inner dimensions, this will fall back to memcpy calls
                let dst = NdArray(out) // make a NdArray view to get rid of sliced when doing subscripts
                let src = NdArray(self)
                for i in 0..<shape[0] {
                    dst[i] = src[i]
                }
            }
        }
    }
}
