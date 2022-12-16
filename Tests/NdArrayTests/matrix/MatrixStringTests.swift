//
// Created by Daniel Strobusch on 2019-05-07.
//

import XCTest
@testable import NdArray

class MatrixStringTests: XCTestCase {
    func testStringInterpolationWhenFormatIsMultiLine() {
        XCTAssertEqual("\(Matrix<Int>([[]]), style: .multiLine)",
            "[]")
        XCTAssertEqual("\(Matrix<Int>([[0, 1], [1, 2]]), style: .multiLine)",
            "[[0, 1],\n [1, 2]]")
    }

    func testStringInterpolationWhenFormatIsSingleLine() {
        XCTAssertEqual("\(Matrix<Int>([[]]), style: .singleLine)",
            "[]")
        XCTAssertEqual("\(Matrix<Int>([[0, 1], [1, 2]]), style: .singleLine)",
            "[[0, 1], [1, 2]]")
    }

}
