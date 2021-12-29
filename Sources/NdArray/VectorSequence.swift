//
// Created by Daniel Strobusch on 07.04.20.
//

/// simple vector iterator
public struct VectorIterator<T>: IteratorProtocol {

    fileprivate init(baseAddress: UnsafePointer<T>, stride: Int, count: Int) {
        self.baseAddress = baseAddress
        self.stride = stride
        self.count = count
    }

    private let baseAddress: UnsafePointer<T>
    private let stride: Int
    private let count: Int
    private var index: Int = 0

    /// - Returns: next element or nil if there is no next element
    public mutating func next() -> T? {
        if index >= count {
            return nil
        }
        let element = baseAddress[index * stride]
        index += 1
        return element
    }
}

/// make vector conform to sequence protocol
public extension Vector {

    func makeIterator() -> VectorIterator<T> {
        if isEmpty {
            return VectorIterator(baseAddress: data, stride: 0, count: 0)
        }
        return VectorIterator(baseAddress: data, stride: strides[0], count: shape[0])
    }

    /// - Returns: shape[0] or 0 if vector is empty
    var underestimatedCount: Int {
        return isEmpty ? 0 : shape[0]
    }

    /// Calls body(p), where p is a pointer to the vector's contiguous storage.
    /// If the vector is not contiguous, body is not called and nil is returned.
    func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R? {
        if isContiguous {
            return try body(UnsafeBufferPointer(start: data, count: count))
        } else {
            return nil
        }
    }
}
