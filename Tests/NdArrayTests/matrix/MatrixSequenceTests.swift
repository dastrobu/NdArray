//
// Created by Daniel Strobusch on 07.04.20.
//

import XCTest
import NdArray

class MatrixSequenceTests: XCTestCase {

    func testIteratorShouldIterateWhenEmpty() {
        let a = Matrix<Int>([[]])
        var v: [[Int]] = []
        for ai in a {
            v.append(Array(ai))
        }
        XCTAssertEqual(NdArray(a, order: .C).dataArray, Matrix(v).dataArray)
        XCTAssertTrue(a.isContiguous)
    }

    func testIteratorShouldIterateWhenArrayIsContiguous() {
        let a = Matrix<Int>([1, 2, 3])
        var v: [[Int]] = []
        for ai in a {
            v.append(Array(ai))
        }
        XCTAssertEqual(NdArray(a, order: .C).dataArray, Matrix(v).dataArray)
        XCTAssertTrue(a.isContiguous)
    }

    func testIteratorShouldIterateWhenArrayIsNotContiguous() {
        let a = Matrix(Matrix<Int>([1, 1, 2, 2, 3, 3])[[0... ~ 2]])
        var v: [[Int]] = []
        for ai in a {
            v.append(Array(ai))
        }
        XCTAssertEqual(NdArray(a, order: .C).dataArray, Matrix(v).dataArray)
        XCTAssertFalse(a.isContiguous)
    }

    func testUnderestimatedCountShouldBeZeroWhenEmpty() {
        let a = Matrix<Int>([[]])
        XCTAssertEqual(a.underestimatedCount, 0)
    }

    func testUnderestimatedCountShouldBeShape0WhenContiguous() {
        let a = Matrix<Int>([[1, 2, 3]]).transposed()
        XCTAssertEqual(a.underestimatedCount, a.shape[0])
        XCTAssertTrue(a.isContiguous)
    }

    func testUnderestimatedCountShouldBeShape0WhenNotContiguous() {
        let a = Matrix(Matrix<Int>([[1, 1, 2, 2, 3, 3]]).transposed()[0... ~ 2])
        XCTAssertEqual(a.underestimatedCount, a.shape[0])
        XCTAssertEqual(a.underestimatedCount, 3)
        XCTAssertFalse(a.isContiguous)
    }
}
