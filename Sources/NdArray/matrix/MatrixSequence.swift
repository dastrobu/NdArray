/// simple matrix iterator
public struct MatrixIterator<T>: IteratorProtocol {

    fileprivate init(_ mat: Matrix<T>) {
        self.mat = mat
    }

    private let mat: Matrix<T>
    private var index: Int = 0

    /// - Returns: next element or nil if there is no next element
    public mutating func next() -> Vector<T>? {
        if index >= mat.shape[0] || mat.isEmpty {
            return nil
        }
        let element = Vector<T>(mat[Slice(index)])
        index += 1
        return element
    }
}

/// make vector conform to sequence protocol
public extension Matrix {

    func makeIterator() -> MatrixIterator<T> {
        MatrixIterator(self)
    }

    /// - Returns: shape[0] or 0 if matrix is empty
    var underestimatedCount: Int {
        isEmpty ? 0 : shape[0]
    }
}
