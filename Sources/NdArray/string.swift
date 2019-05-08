import Foundation

fileprivate extension NdArray {

    func string(separator: String, depth: Int = 0) -> String {
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
                s += "\(data[i * k]), "
            }
            if shape[0] > 0 {
                // remove trailing ", "
                s.removeLast(2)
            }
        default:
            let depthSeperator: String = String(repeating: separator, count: ndim - 1)
            let a = NdArray(self)
            for i in 0..<shape[0] {
                s += a[i].string(separator: separator, depth: depth + 1)
                s += ","
                s += depthSeperator
            }
            if shape[0] > 0 {
                // remove trailing "," + "separators"
                s.removeLast(depthSeperator.count + 1)
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
    mutating func appendInterpolation<T>(_ value: NdArray<T>, format: StringFormat = .multiLine) {
        switch format {
        case .singleLine:
            appendLiteral(value.string(separator: " "))
        case .multiLine:
            appendLiteral(value.string(separator: "\n"))
        }
    }
}