//
// Created by Daniel Strobusch on 2019-05-07.
//

import XCTest
@testable import NdArray

// swiftlint:disable:next type_name
class stringTests: XCTestCase {
    func testStringInterpolationWhenFormatIsMultiLine() {
        XCTAssertEqual("\(NdArray<Int>.zeros(0), style: .multiLine)",
            "[]")
        XCTAssertEqual("\(NdArray<Int>.zeros(1), style: .multiLine)",
            "[0]")
        XCTAssertEqual("\(NdArray<Int>.zeros(2), style: .multiLine)",
            "[0, 0]")
        XCTAssertEqual("\(NdArray<Int>.zeros([1, 0]), style: .multiLine)",
            "[]")
        XCTAssertEqual("\(NdArray<Int>.zeros([0, 1]), style: .multiLine)",
            "[]")
        XCTAssertEqual("\(NdArray<Int>.zeros([1, 0, 1]), style: .multiLine)",
            "[]")
        XCTAssertEqual("\(NdArray<Int>.zeros([1, 1]), style: .multiLine)",
            "[[0]]")
        XCTAssertEqual("\(NdArray<Int>.zeros([1, 1, 1]), style: .multiLine)",
            "[[[0]]]")
        XCTAssertEqual("\(NdArray<Int>.range(to: 2 * 2).reshaped([2, 2]), style: .multiLine)",
            "[[0, 1],\n [2, 3]]")
        XCTAssertEqual("\(NdArray<Int>.range(to: 3 * 2).reshaped([2, 3]), style: .multiLine)",
            "[[0, 1, 2],\n [3, 4, 5]]")
        XCTAssertEqual("\(NdArray<Int>.range(to: 2 * 2 * 2).reshaped([2, 2, 2]), style: .multiLine)",
            "[[[0, 1],\n  [2, 3]],\n\n [[4, 5],\n  [6, 7]]]")
        XCTAssertEqual("\(NdArray<Int>.range(to: 2 * 3 * 2).reshaped([2, 3, 2]), style: .multiLine)",
            "[[[ 0,  1],\n  [ 2,  3],\n  [ 4,  5]],\n\n [[ 6,  7],\n  [ 8,  9],\n  [10, 11]]]")
        XCTAssertEqual("\(NdArray<Int>.range(to: 2 * 2 * 3).reshaped([2, 2, 3]), style: .multiLine)",
            "[[[ 0,  1,  2],\n  [ 3,  4,  5]],\n\n [[ 6,  7,  8],\n  [ 9, 10, 11]]]")
    }

    func testStringInterpolationWhenFormatIsSingleLine() {
        XCTAssertEqual("\(NdArray<Int>.zeros(0), style: .singleLine)",
            "[]")
        XCTAssertEqual("\(NdArray<Int>.zeros(1), style: .singleLine)",
            "[0]")
        XCTAssertEqual("\(NdArray<Int>.zeros(2), style: .singleLine)",
            "[0, 0]")
        XCTAssertEqual("\(NdArray<Int>.zeros([1, 0]), style: .singleLine)",
            "[]")
        XCTAssertEqual("\(NdArray<Int>.zeros([0, 1]), style: .singleLine)",
            "[]")
        XCTAssertEqual("\(NdArray<Int>.zeros([1, 0, 1]), style: .singleLine)",
            "[]")
        XCTAssertEqual("\(NdArray<Int>.zeros([1, 1]), style: .singleLine)",
            "[[0]]")
        XCTAssertEqual("\(NdArray<Int>.zeros([1, 1, 1]), style: .singleLine)",
            "[[[0]]]")
        XCTAssertEqual("\(NdArray<Int>.range(to: 2 * 2).reshaped([2, 2]), style: .singleLine)",
            "[[0, 1], [2, 3]]")
        XCTAssertEqual("\(NdArray<Int>.range(to: 3 * 2).reshaped([2, 3]), style: .singleLine)",
            "[[0, 1, 2], [3, 4, 5]]")
        XCTAssertEqual("\(NdArray<Int>.range(to: 2 * 2 * 2).reshaped([2, 2, 2]), style: .singleLine)",
            "[[[0, 1], [2, 3]],  [[4, 5], [6, 7]]]")
        XCTAssertEqual("\(NdArray<Int>.range(to: 2 * 3 * 2).reshaped([2, 3, 2]), style: .singleLine)",
            "[[[0, 1], [2, 3], [4, 5]],  [[6, 7], [8, 9], [10, 11]]]")
        XCTAssertEqual("\(NdArray<Int>.range(to: 2 * 2 * 3).reshaped([2, 2, 3]), style: .singleLine)",
            "[[[0, 1, 2], [3, 4, 5]],  [[6, 7, 8], [9, 10, 11]]]")
    }

}
