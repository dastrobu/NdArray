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
}

