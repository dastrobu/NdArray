import Darwin
import Accelerate

public enum Contiguous {
    case C
    case F
}

open class NdArray<T>:
    CustomDebugStringConvertible,
    CustomStringConvertible {

    /// data buffer
    internal(set) public var data: UnsafeMutablePointer<T>

    /// length of the buffer
    internal var count: Int

    /// shape of the array
    internal(set) public var shape: [Int]

    /// strides of the dimensions
    internal(set) public var strides: [Int]

    /// owner of the data, if nil self is the owner and must deallocate the data buffer on destruction
    /// if self is just a view on a buffer, this reference to the owner prevents the data from being deallocated
    private var owner: NdArray<T>? = nil

    /// dimension of the array, i.e. the length of the shape
    /// - SeeAlso: effectiveNdim
    var ndim: Int {
        get {
            return shape.count
        }
    }

    /// the effective ndim is the number of dimensions, the array actually has, if any size is 0, the elemnent
    /// has an element ndim of 0 since it has no elements.
    var effectiveNdim: Int {
        get {
            if shape.isEmpty || shape.reduce(1, *) == 0 {
                return 0
            }
            return ndim
        }
    }

    /// an array is considered empty if it has no items, i.e. if the effectiveNdim is 0.
    var isEmpty: Bool {
        get {
            return effectiveNdim == 0
        }
    }

    /// flag indicating if this ndarray owns its data
    public var ownsData: Bool {
        return owner == nil
    }

    /// create a new array without initializing any memory
    public init(empty count: Int = 0) {
        self.count = count
        data = UnsafeMutablePointer<T>.allocate(capacity: count)
        if count == 0 {
            shape = [0]
        } else {
            shape = [count]
        }
        strides = [1]
    }

    /// creates a view on another array without copying any data
    public init(_ a: NdArray<T>) {
        if a.ownsData {
            self.owner = a
        } else {
            self.owner = a.owner
        }
        self.data = a.data
        self.count = a.count
        self.shape = a.shape
        self.strides = a.strides
        assert(self !== owner)
    }

    deinit {
        if ownsData {
            data.deallocate()
        }
    }

    /// creates a copy of an array (not sharing data) and aligning it in memory
    /// if the array to copy is contiguous, the order (F or C) will be kept for the copied array
    /// if the array is not contiguous, a C ordered array will be created.
    ///
    /// - SeeAlso: init(copy: NdArray<T>, order: Contiguous)
    public required convenience init(copy a: NdArray<T>) {

        let n = a.shape.reduce(1, *)
        self.init(empty: n)

        // check if the entire data buffer can be simply copied
        if a.isContiguous {
            memcpy(data, a.data, a.count * MemoryLayout<T>.stride)
            self.shape = a.shape
            self.strides = a.strides
            return
        }

        // reshape the new array
        self.reshape(a.shape)
        a.copyTo(self)
    }

    convenience init(empty shape: [Int], order: Contiguous = .C) {
        self.init(empty: shape.reduce(1, *))
        reshape(shape, order: order)
    }

    /// init with constant value
    convenience init(zeros count: Int) {
        self.init(empty: count)
        memset(data, 0, count * MemoryLayout<T>.stride)
    }

    /// init with zeros
    convenience init(zeros shape: [Int], order: Contiguous = .C) {
        self.init(zeros: shape.reduce(1, *))
        self.reshape(shape, order: order)
    }

    /// init with constant value
    convenience init(repeating x: T, count: Int) {
        self.init(empty: count)
        for i in 0..<count {
            self.data[i] = x
        }
    }

    /// init with constant value
    convenience init(repeating x: T, shape: [Int], order: Contiguous = .C) {
        self.init(repeating: x, count: shape.reduce(1, *))
        self.reshape(shape, order: order)
    }

    /// create a view or copy of the array with specified order. Only if a copy is required to get an array in the
    /// specific order, a copy is made.
    convenience init(_ a: NdArray<T>, order: Contiguous) {
        switch order {
        case .C:
            if a.isCContiguous {
                self.init(a)
            } else {
                self.init(copy: a, order: .C)
            }
        case .F:
            if a.isFContiguous {
                self.init(a)
            } else {
                self.init(copy: a, order: .F)
            }
        }
    }

    /// creates a copy of an array (not sharing data) and aligning it in memory according to the specified order.
    ///
    /// - SeeAlso: init(copy: NdArray<T>, order: Contiguous)
    public convenience init(copy a: NdArray<T>, order: Contiguous = .C) {
        let n = a.shape.reduce(1, *)
        switch order {
        case .C:
            if a.isCContiguous {
                self.init(copy: a)
            }
        case .F:
            if a.isFContiguous {
                self.init(copy: a)
            }
        }
        self.init(empty: n)
        self.reshape(a.shape, order: order)
        a.copyTo(self)
    }

    /// create an 1D NdArray from a plain array
    convenience init(_ a: [T]) {
        self.init(empty: a.count)
        data.initialize(from: a, count: a.count)
    }

    /// create an 2D NdArray from a plain array
    convenience init(_ a: [[T]], order: Contiguous = .C) {
        guard let first = a.first else {
            self.init(empty: [1, 0], order: order)
            return
        }

        let rowCount = a.count
        let colCount = first.count
        self.init(empty: [rowCount, colCount], order: order)

        switch order {
        case .C:
            for i in 0..<rowCount {
                let row = a[i]
                assert(row.count == colCount, "\(row.count) == \(colCount) at row \(i)")
                memcpy(data + i * strides[0], row, colCount * MemoryLayout<T>.stride)
            }
        case .F:
            for i in 0..<rowCount {
                let row = a[i]
                assert(row.count == colCount, "\(row.count) == \(colCount) at row \(i)")
                // manual memcopy for strided data
                for j in 0..<colCount {
                    data[i * strides[0] + j * strides[1]] = row[j]
                }
            }
        }
    }

    /// create an 3D NdArray from a plain array
    convenience init(_ a: [[[T]]], order: Contiguous = .C) {
        guard let first = a.first, let firstFirst = first.first else {
            self.init(empty: [1, 1, 0], order: order)
            return
        }
        let iCount = a.count
        let jCount = first.count
        let kCount = firstFirst.count
        self.init(empty: [iCount, jCount, kCount], order: order)

        switch order {
        case .C:
            for i in 0..<iCount {
                let ai = a[i]
                assert(ai.count == jCount, "\(ai.count) == \(jCount) at index \(i)")
                for j in 0..<jCount {
                    let aij = ai[j]
                    assert(aij.count == kCount, "\(aij.count) == \(kCount) at index \(i), \(j)")
                    memcpy(data + i * strides[0] + j * strides[1], aij, kCount * MemoryLayout<T>.stride)
                }
            }
        case .F:
            for i in 0..<iCount {
                let ai = a[i]
                assert(ai.count == jCount, "\(ai.count) == \(jCount) at index \(i)")
                for j in 0..<jCount {
                    let aij = ai[j]
                    assert(aij.count == kCount, "\(aij.count) == \(kCount) at index \(i), \(j)")
                    for k in 0..<kCount {
                        data[i * strides[0] + j * strides[1] + k * strides[2]] = aij[k]
                    }
                }
            }
        }
    }

    /// copies the data to an array (note, copy on write does not work)
    public var dataArray: [T] {
        if isEmpty {
            return []
        }
        return Array(UnsafeBufferPointer(start: data, count: count))
    }

    public var debugDescription: String {
        let address = String(format: "%p", Int(bitPattern: data))
        return "NdArray(shape: \(shape), strides: \(strides), data: \(address))"
    }

    public var description: String {
        return "\(self, style: .multiLine)"
    }

    /// element access
    public subscript(index: [Int]) -> T {
        get {
            return data[flatIndex(index)]
        }
        set {
            self.data[flatIndex(index)] = newValue
        }
    }

    /// full slice access
    public subscript(r: UnboundedRange) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    public subscript(r: ClosedRange<Int>) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    public subscript(r: PartialRangeThrough<Int>) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    public subscript(r: PartialRangeUpTo<Int>) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    public subscript(r: PartialRangeFrom<Int>) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// range slice access
    public subscript(r: Range<Int>) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// range with stride
    public subscript(r: Range<Int>, stride: Int) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// closed range with stride
    public subscript(r: ClosedRange<Int>, stride: Int) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// partial range with stride
    public subscript(r: PartialRangeFrom<Int>, stride: Int) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// partial range with stride
    public subscript(r: PartialRangeThrough<Int>, stride: Int) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// partial range with stride
    public subscript(r: PartialRangeUpTo<Int>, stride: Int) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// full range with stride
    public subscript(r: UnboundedRange, stride: Int) -> NdArraySlice<T> {
        get {
            return NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// single slice access
    public subscript(i: Int) -> NdArraySlice<T> {
        get {
            assert(!isEmpty)
            var startIndex = Array<Int>(repeating: 0, count: ndim)
            startIndex[0] = i
            // here we reduce the shape, hence slice = 0
            let slice = NdArraySlice(self, startIndex: startIndex, sliced: 0)
            // drop leading shape 1
            slice.shape = Array(slice.shape[1...])
            slice.strides = Array(slice.strides[1...])
            slice.count = slice.len
            return slice
        }
        set {
            newValue.copyTo(self[i])
        }
    }
}

// extension helping to handle different memory alignments
extension NdArray {
    /// flag indicating if the array is C contiguous, i.e. is stored contiguously in memory and has C order
    /// (row major)
    public var isCContiguous: Bool {
        // compare C contiguous strides to actual strides
        return strides == strides(order: .C)
    }

    /// flag indicating if the array is F contiguous, i.e. is stored contiguously in memory and has Fortran order
    /// (column major)
    public var isFContiguous: Bool {
        // compare F contiguous strides to actual strides
        return strides == strides(order: .F)
    }

    /// flag indicating if the array is contiguous, i.e. is stored contiguously in memory and has either C or Fortran
    /// order.
    public var isContiguous: Bool {
        return isCContiguous || isFContiguous
    }

    /// - Returns: true if data regions of this array overlap with data region of the other array
    public func overlaps(_ other: NdArray<T>) -> Bool {
        // check if other starts within our memory
        if other.data >= self.data && other.data < self.data + self.count {
            return true
        }
        // check if our memory starts within other memory
        if self.data >= other.data && self.data < other.data + other.count {
            return true
        }
        return false
    }

    /// compute the strides that a C or F contiguously aligned array would have
    private func strides(order: Contiguous) -> [Int] {
        if shape.count == 0 {
            return []
        }
        if ndim == 1 {
            return [1]
        }
        var strides = Array<Int>(repeating: 1, count: ndim)
        switch order {
        case .C:
            for i in (0..<ndim - 1).reversed() {
                for j in 0...i {
                    // zero shapes have stride 1
                    strides[j] *= Swift.max(1, shape[i + 1])
                }
            }
        case .F:
            for i in 1..<ndim {
                for j in i..<ndim {
                    // zero shapes have stride 1
                    strides[j] *= Swift.max(1, shape[i - 1])
                }
            }
        }
        return strides
    }
}

// internal extension
internal extension NdArray {

    /// compute the flat index from strides and an index array of size ndim
    func flatIndex(_ index: [Int]) -> Int {
        let ndim = self.ndim
        assert(index.count == ndim, "\(index.count) != \(ndim)")
        var flatIndex: Int = 0
        for i in 0..<ndim {
            flatIndex += index[i] * strides[i]
        }
        return flatIndex
    }

    /// compute the length of the array
    /// the length can be less than count, if the data array is larger than the referenced elements
    /// basically the length is the last valid flat index of the array + 1
    var len: Int {
        // check if there is any shape set to 0
        if let _ = shape.first(where: {
            $0 == 0
        }) {
            return 0
        }
        let lastIndex = shape.map {
            $0 - 1
        }
        return flatIndex(lastIndex) + 1
    }
}
