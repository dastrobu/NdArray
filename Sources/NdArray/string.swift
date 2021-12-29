import Foundation

fileprivate extension RangeReplaceableCollection where Self: StringProtocol {
    func paddingToLeft(toLength n: Int, withPad pad: Element = " ") -> String {
        String(repeatElement(pad, count: Swift.max(0, n - count)) + suffix(Swift.max(count, count - n)))
    }
}

fileprivate extension NdArray {
    func string(separator: String, indent: Int = 1, depth: Int = 0, formatter: (T) -> String) -> String {
        // check if any shape is zero
        if isEmpty {
            return "[]"
        }
        var s = "["
        switch ndim {
        case 0:
            break
        case 1:
            let k = strides[0]
            for i in 0..<shape[0] {
                s += formatter(data[i * k])
                s += ", "
            }
            if shape[0] > 0 {
                // remove trailing ", "
                s.removeLast(2)
            }
        default:
            let depthSeperator: String = String(repeating: separator, count: ndim - 1)
            let a = NdArray(self)
            for i in 0..<shape[0] {
                s += a[i].string(separator: separator, indent: indent, depth: depth + 1, formatter: formatter)
                s += ","
                s += depthSeperator
                s += String(repeating: " ", count: indent * (depth + 1))
            }
            if shape[0] > 0 {
                // remove trailing "," + "separators" + <whitespace>
                s.removeLast(depthSeperator.count + 1 + indent * (depth + 1))
            }
        }
        s += "]"
        return s
    }
}

public enum StringFormat {
    case singleLine
    case multiLine
}

public extension String.StringInterpolation {
    /// support for string interpolation
    /// - Parameters:
    ///   - value: Array to interpolate
    ///   - style: Enum to indicate if the array should be printed in single or multiline style
    ///   - formatter: A closure which can be used to format individual elements.
    ///               The closure is applied to each element to create the string representing the element.
    mutating func appendInterpolation<T>(_ value: NdArray<T>,
                                         style: StringFormat = .multiLine,
                                         formatter: @escaping (T) -> String = {
                                             "\($0)"
                                         }) {

        switch style {
        case .singleLine:
            appendLiteral(value.string(separator: " ", indent: 0, formatter: formatter))
        case .multiLine:
            // first find the maximal field length for the items
            let n = value.reduce(1, { n, element in
                Swift.max(n, formatter(element).count)
            })
            let wrapperFormatter: (T) -> String = { element in
                formatter(element).paddingToLeft(toLength: n, withPad: " ")
            }
            appendLiteral(value.string(separator: "\n", indent: 1, formatter: wrapperFormatter))
        }
    }
}
