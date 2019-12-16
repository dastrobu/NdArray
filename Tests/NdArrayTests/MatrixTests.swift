import XCTest
import Foundation
@testable import NdArray

class MatrixTests: XCTestCase {
    func testInit2dShouldCreateContiguousArray() {
        let a = Matrix<Double>([[1, 2, 3], [4, 5, 6]])
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(a.shape, [2, 3])
        XCTAssertEqual(a.strides, [3, 1])
        XCTAssert(a.isCContiguous)
        XCTAssertFalse(a.isFContiguous)
    }

    func testInit2dShouldCreateEmptyArray() {
        let a = Matrix<Double>([[Double]]())
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [])
        XCTAssertEqual(a.shape, [1, 0])
        XCTAssertEqual(a.strides, [1, 1])
        XCTAssert(a.isCContiguous)
        XCTAssert(a.isFContiguous)
    }

    func testReshape() {
        let a = Matrix<Double>(empty: 3 * 2)
        XCTAssertEqual(a.shape, [1, 6])
        XCTAssertEqual(a.reshaped([2, 3]).shape, [2, 3])
    }

    func testTransposedView() {
        // 2d effective 0d
        do {
            let a = Matrix<Double>.zeros([1, 0])
            XCTAssertEqual(a.transposed().shape, [1, 0])
        }
        // 2d C contiguous
        do {
            let a = Matrix<Double>(Matrix<Double>.range(to: 6).reshaped([2, 3], order: .C))
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [3, 1])
            XCTAssertEqual(a.transposed().strides, [1, 3])
            XCTAssertEqual(a.transposed().dataArray, Matrix<Double>.range(to: 6).dataArray)
        }
        // 2d F contiguous
        do {
            let a = Matrix<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3], order: .F))
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [1, 2])
            XCTAssertEqual(a.transposed().strides, [2, 1])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>(Matrix<Double>.range(to: 6), order: .F).dataArray)
        }
        // 2d not aligned
        do {
            let a = Matrix(Matrix<Double>.range(to: 4 * 3).reshaped([4, 3], order: .C)[..., 2])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [6, 1])
            XCTAssertEqual(a.transposed().strides, [1, 6])
            XCTAssertEqual(a.transposed().dataArray, Matrix<Double>.range(to: 4 * 3).dataArray)
        }
    }

    func testTransposedCopy() {
        // 2d effective 0d
        do {
            let a = Matrix<Double>.zeros([1, 0])
            let at = Matrix<Double>.empty(shape: a.shape)
            a.transposed(out: at)
            XCTAssertEqual(at.shape, [1, 0])
        }
        // 2d C contiguous -> C contiguous
        do {
            let a = Matrix<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3], order: .C))
            let at = Matrix<Double>.empty(shape: a.shape.reversed())
            a.transposed(out: at)
            XCTAssertEqual(at.shape, [3, 2])
            XCTAssertEqual(a.strides, [3, 1])
            XCTAssertEqual(at.strides, [1, 3])
            XCTAssertEqual(at.dataArray, Matrix<Double>.range(to: 6).dataArray)
        }
        // 2d C contiguous -> F contiguous
        do {
            let a = Matrix<Double>(Matrix<Double>.range(to: 6).reshaped([2, 3], order: .C))
            let at = Matrix<Double>.empty(shape: a.shape.reversed(), order: .F)
            a.transposed(out: at)
            XCTAssertEqual(at.shape, [3, 2])
            XCTAssertEqual(a.strides, [3, 1])
            XCTAssertEqual(at.strides, [3, 1])
            XCTAssertEqual(at.dataArray, Matrix<Double>.range(to: 6).dataArray)
        }
        // 2d F contiguous -> C contiguous
        do {
            let a = Matrix<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3], order: .F))
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [1, 2])
            XCTAssertEqual(a.transposed().strides, [2, 1])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>(Matrix<Double>.range(to: 6), order: .F).dataArray)
        }
        // 2d F contiguous -> F contiguous
        do {
            let a = Matrix<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3], order: .F))
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [1, 2])
            XCTAssertEqual(a.transposed().strides, [2, 1])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>(Matrix<Double>.range(to: 6), order: .F).dataArray)
        }
        // 2d not aligned -> C contiguous
        do {
            let a = Matrix(Matrix<Double>.range(to: 4 * 3).reshaped([4, 3], order: .C)[..., 2])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [6, 1])
            XCTAssertEqual(a.transposed().strides, [1, 6])
            XCTAssertEqual(a.transposed().dataArray, Matrix<Double>.range(to: 4 * 3).dataArray)
        }
        // 2d not aligned -> F contiguous
        do {
            let a = Matrix(Matrix<Double>.range(to: 4 * 3).reshaped([4, 3], order: .C)[..., 2])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [6, 1])
            XCTAssertEqual(a.transposed().strides, [1, 6])
            XCTAssertEqual(a.transposed().dataArray, Matrix<Double>.range(to: 4 * 3).dataArray)
        }
        // 2d not aligned -> not aligned
        do {
            let a = Matrix(Matrix<Double>.range(to: 4 * 3).reshaped([4, 3], order: .C)[..., 2])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [6, 1])
            XCTAssertEqual(a.transposed().strides, [1, 6])
            XCTAssertEqual(a.transposed().dataArray, Matrix<Double>.range(to: 4 * 3).dataArray)
        }
    }
}
