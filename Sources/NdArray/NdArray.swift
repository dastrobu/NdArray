import Darwin
import Accelerate

public enum Contiguous {
    case C
    case F
}

open class NdArray<T>: CustomDebugStringConvertible,
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
    private var owner: NdArray<T>?

    /// dimension of the array, i.e. the length of the shape
    /// - SeeAlso: effectiveNdim
    public var ndim: Int {
        shape.count
    }

    /// the effective ndim is the number of dimensions, the array actually has, if any size is 0, the element
    /// has an element ndim of 0 since it has no elements.
    public var effectiveNdim: Int {
        if shape.isEmpty || shape.reduce(1, *) == 0 {
            return 0
        }
        return ndim
    }

    /// an array is considered empty if it has no items, i.e. if the effectiveNdim is 0.
    public var isEmpty: Bool {
        effectiveNdim == 0
    }

    /// flag indicating if this ndarray owns its data
    public var ownsData: Bool {
        owner == nil
    }

    /// create a new array without initializing any memory
    public required init(empty count: Int = 0) {
        self.count = count
        data = UnsafeMutablePointer<T>.allocate(capacity: count)
        if count == 0 {
            shape = [0]
        } else {
            shape = [count]
        }
        strides = [1]
    }

    internal convenience init(empty shape: [Int], order: Contiguous = .C) {
        let n = shape.isEmpty ? 0 : shape.reduce(1, *)
        self.init(empty: n)
        var success = reshape([n])
        precondition(success, "could not reshape from [\(self.shape)] to \(n)")
        success = reshape(shape, order: order)
        precondition(success, "could not reshape form [\(self.shape)] to \(shape)")
    }

    internal func stealOwnership() {
        guard let owner = owner else {
            fatalError(
                """
                Cannot steal ownership if array is already owning data.
                Assertion failed while trying stealing ownership from owner of \(debugDescription).
                """)
        }
        precondition(owner.ownsData,
            """
            Cannot steal from array not owning its data
            Assertion failed while trying to init stealing from \(owner.debugDescription).
            """)
        owner.owner = self
        self.owner = nil
    }

    /// creates a view on another array without copying any data
    public required init(_ a: NdArray<T>) {
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
        self.init(empty: a.shape, order: a.isFContiguous ? .F : .C)
        a.copyTo(self)
    }

    /// create a view or copy of the array with specified order. Only if a copy is required to get an array in the
    /// specific order, a copy is made.
    public convenience init(_ a: NdArray<T>, order: Contiguous) {
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
        switch order {
        case .C:
            if a.isCContiguous {
                self.init(copy: a)
                return
            }
        case .F:
            if a.isFContiguous {
                self.init(copy: a)
                return
            }
        }
        self.init(empty: a.shape, order: order)
        a.copyTo(self)
    }

    /// create an 1D NdArray from a plain array
    public convenience init(_ a: [T]) {
        self.init(empty: a.count)
        data.initialize(from: a, count: a.count)
    }

    /// create an 2D NdArray from a plain array
    public convenience init(_ a: [[T]], order: Contiguous = .C) {
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
                precondition(row.count == colCount, "\(row.count) == \(colCount) at row \(i)")
                memcpy(data + i * strides[0], row, colCount * MemoryLayout<T>.stride)
            }
        case .F:
            for i in 0..<rowCount {
                let row = a[i]
                precondition(row.count == colCount, "\(row.count) == \(colCount) at row \(i)")
                // manual memcopy for strided data
                for j in 0..<colCount {
                    data[i * strides[0] + j * strides[1]] = row[j]
                }
            }
        }
    }

    /// create an 3D NdArray from a plain array
    public convenience init(_ a: [[[T]]], order: Contiguous = .C) {
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
                precondition(ai.count == jCount, "\(ai.count) == \(jCount) at index \(i)")
                for j in 0..<jCount {
                    let aij = ai[j]
                    precondition(aij.count == kCount, "\(aij.count) == \(kCount) at index \(i), \(j)")
                    memcpy(data + i * strides[0] + j * strides[1], aij, kCount * MemoryLayout<T>.stride)
                }
            }
        case .F:
            for i in 0..<iCount {
                let ai = a[i]
                precondition(ai.count == jCount, "\(ai.count) == \(jCount) at index \(i)")
                for j in 0..<jCount {
                    let aij = ai[j]
                    precondition(aij.count == kCount, "\(aij.count) == \(kCount) at index \(i), \(j)")
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
        "\(self, style: .multiLine)"
    }

    /**
     element access
     */
    public subscript(index: [Int]) -> T {
        get {
            data[flatIndex(index)]
        }
        set {
            data[flatIndex(index)] = newValue
        }
    }

    /// full slice access
    @available(*, deprecated, message: "prefer new slicing syntax a[0..., 0..., 0...] over old one a[...][...][...]")
    public subscript(r: UnboundedRange) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    @available(*, deprecated, message: "prefer new slicing syntax a[0...42, 0...42, 0...42] over old one a[0...42][0...42][0...42]")
    public subscript(r: ClosedRange<Int>) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    @available(*, deprecated, message: "prefer new slicing syntax a[...42, ...42, ...42] over old one a[...42][...42][...42]")
    public subscript(r: PartialRangeThrough<Int>) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    @available(*, deprecated, message: "prefer new slicing syntax a[..<42, ..<42, ..<42] over old one a[..<42][..<42][..<42]")
    public subscript(r: PartialRangeUpTo<Int>) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// partial range slice access
    @available(*, deprecated, message: "prefer new slicing syntax a[42..., 42.., 42..] over old one a[42...][42...][42...]")
    public subscript(r: PartialRangeFrom<Int>) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// range slice access
    @available(*, deprecated, message: "prefer new slicing syntax a[1..<42, 1..<42, 1..<42] over old one a[1..<42][1..<42][1..<42]")
    public subscript(r: Range<Int>) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r]
        }
        set {
            newValue.copyTo(self[r])
        }
    }

    /// range with stride
    @available(*, deprecated, message: "prefer new slicing syntax a[1..<42 ~ 3, 1..<42 ~ 3, 1..<42 ~ 3] over old one a[1..<42, 3][1..<42, 3][1..<42, 3]")
    public subscript(r: Range<Int>, stride: Int) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// closed range with stride
    @available(*, deprecated, message: "prefer new slicing syntax a[0...42 ~ 3, 0...42 ~ 3, 0...42 ~ 3] over old one a[0...42, 3][0...42, 3][0...42, 3]")
    public subscript(r: ClosedRange<Int>, stride: Int) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// partial range with stride
    @available(*, deprecated, message: "prefer new slicing syntax a[42... ~ 3, 42.. ~ 3, 42.. ~ 3] over old one a[42..., 3][42..., 3][42..., 3]")
    public subscript(r: PartialRangeFrom<Int>, stride: Int) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// partial range with stride
    @available(*, deprecated, message: "prefer new slicing syntax a[...42 ~ 3, ...42 ~ 3, ...42 ~ 3] over old one a[...42, 3][...42, 3][...42, 3]")
    public subscript(r: PartialRangeThrough<Int>, stride: Int) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// partial range with stride
    @available(*, deprecated, message: "prefer new slicing syntax a[..<42 ~ 3, ..<42 ~ 3, ..<42 ~ 3] over old one a[..<42, 3][..<42, 3][..<42, 3]")
    public subscript(r: PartialRangeUpTo<Int>, stride: Int) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// full range with stride
    @available(*, deprecated, message: "prefer new slicing syntax a[0... ~ 3, 0... ~ 3, 0... ~ 3] over old one a[..., 3][..., 3][..., 3]")
    public subscript(r: UnboundedRange, stride: Int) -> NdArray<T> {
        get {
            NdArraySlice(self, sliced: 0)[r, stride]
        }
        set {
            newValue.copyTo(self[r, stride])
        }
    }

    /// single slice access
    @available(*, deprecated, message: "prefer new slicing syntax a[42, 42, 42] over old one a[42][42][42]")
    public subscript(i: Int) -> NdArray<T> {
        get {
            precondition(!isEmpty)
            var startIndex = [Int](repeating: 0, count: ndim)
            startIndex[0] = i
            // here we reduce the shape, hence slice = 0
            let slice = NdArraySlice(self, startIndex: startIndex, sliced: 0)
            // drop leading shape 1
            let shape = [Int](slice.shape[1...])
            if shape.isEmpty {
                slice.shape = [1]
                slice.strides = [1]
                slice.count = 1
            } else {
                slice.shape = shape
                slice.strides = Array(slice.strides[1...])
                slice.count = slice.len
            }
            return slice
        }
        set {
            newValue.copyTo(self[i])
        }
    }

    /**
     slice access
     */
    public subscript(slices: [Slice]) -> NdArray<T> {
        get {
            var a = NdArraySlice(self, sliced: 0)
            for (i, s) in slices.enumerated() {
                switch s.sliceKind {
                case .range(lowerBound: let lowerBound, upperBound: let upperBound, stride: let stride):
                    let stride = stride ?? 1
                    let lowerBound = lowerBound ?? 0
                    let upperBound = upperBound ?? shape[i]
                    a = a.subscr(lowerBound: lowerBound, upperBound: upperBound, stride: stride)
                case .index(let i):
                    a = a.subscr(i)
                    if a.shape.isEmpty {
                        a.shape = [1]
                        a.strides = [1]
                        a.count = 1
                    }
                }
            }
            return NdArray(a)
        }
        set {
            newValue.copyTo(self[slices])
        }
    }

    /**
     slice access
     */
    public subscript(slices: Slice...) -> NdArray<T> {
        get {
            self[slices]
        }
        set {
            self[slices] = newValue
        }
    }
}

// extension helping to handle different memory alignments
extension NdArray {
    /// flag indicating if the array is C contiguous, i.e. is stored contiguously in memory and has C order
    /// (row major)
    public var isCContiguous: Bool {
        // compare C contiguous strides to actual strides
        strides == strides(order: .C)
    }

    /// flag indicating if the array is F contiguous, i.e. is stored contiguously in memory and has Fortran order
    /// (column major)
    public var isFContiguous: Bool {
        // compare F contiguous strides to actual strides
        strides == strides(order: .F)
    }

    /// flag indicating if the array is contiguous, i.e. is stored contiguously in memory and has either C or Fortran
    /// order.
    public var isContiguous: Bool {
        isCContiguous || isFContiguous
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
        var strides = [Int](repeating: 1, count: ndim)
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
        precondition(index.count == ndim, "\(index.count) != \(ndim)")
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
        if shape.first(where: {
            $0 == 0
        }) != nil {
            return 0
        }
        let lastIndex = shape.map {
            $0 - 1
        }
        return flatIndex(lastIndex) + 1
    }
}
