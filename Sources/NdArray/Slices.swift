/**
 A slice can either be a range
 
     a[...]
     a[..<2]
 
 or an index slice
 
     a[1]
 
 */
internal enum SliceKind {
    case range(lowerBound: Int?, upperBound: Int?, stride: Int? = nil)
    case index(Int)
}

/**
 Type encapsulating a slice.

 The following notations are equivalent:

     a[1] ≡ a[Slice(1)]
     a[0...] ≡ a[Slice()]
     a[1...] ≡ a[Slice(lowerBound: 1)]
     a[..<42] ≡ a[Slice(upperBound: 42)]
     a[...42] ≡ a[Slice(upperBound: 43)]
     a[1..<42] ≡ a[Slice(lowerBound: 1, upperBound: 42)]
     a[1... ~ 2] ≡ a[Slice(lowerBound: 1, upperBound, stride: 2)]
     a[..<42 ~ 3] ≡ a[Slice(upperBound: 42, stride: 3)]
     a[1..<42 ~ 3] ≡ a[Slice(lowerBound: 1, upperBound: 42, stride: 3)]
 */
public struct Slice: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = Int

    internal let sliceKind: SliceKind

    public init(integerLiteral value: Int) {
        self.init(value)
    }

    public init(_ i: Int) {
        sliceKind = .index(i)
    }

    public init(
        lowerBound: Int? = nil,
        upperBound: Int? = nil,
        stride: Int? = nil
    ) {
        sliceKind = .range(lowerBound: lowerBound, upperBound: upperBound, stride: stride)
    }
}

public func ... (lowerBound: Int, upperBound: Int) -> Slice {
    Slice(lowerBound: lowerBound, upperBound: upperBound + 1)
}

public func ..< (lowerBound: Int, upperBound: Int) -> Slice {
    Slice(lowerBound: lowerBound, upperBound: upperBound)
}

public prefix func ..< (upperBound: Int) -> Slice {
    Slice(upperBound: upperBound)
}

public prefix func ... (upperBound: Int) -> Slice {
    Slice(upperBound: upperBound + 1)
}

public postfix func ... (lowerBound: Int) -> Slice {
    Slice(lowerBound: lowerBound)
}

precedencegroup StridePrecedence {
    lowerThan: RangeFormationPrecedence
}

/**
 Operator to define strided slices
 */
infix operator ~: StridePrecedence

/**
 generate the strided slice from unstrided slice and stride
 */
public func ~ (s: Slice, stride: Int) -> Slice {
    switch s.sliceKind {
    case .range(lowerBound: let lowerBound, upperBound: let upperBound, stride: _):
        return Slice(lowerBound: lowerBound, upperBound: upperBound, stride: stride)
    case .index:
        return s
    }
}
