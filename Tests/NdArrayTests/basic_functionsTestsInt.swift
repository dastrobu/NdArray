//
// Created by Daniel Strobusch on 2019-05-11.
//

import XCTest
@testable import NdArray

class basic_functionsTestsInt: XCTestCase{

    func testAbs() {
        // 0d
        do {
            let a = NdArray<Int>(zeros: [])
            XCTAssertEqual(abs(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>(zeros: [1, 0])
            XCTAssertEqual(abs(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>(rangeFrom: -3, to: 3)
            XCTAssertEqual(abs(a).dataArray, a.dataArray.map(abs))
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>(rangeFrom: -3, to: 3)[..., 2]
            XCTAssertEqual(abs(a).dataArray, [3, 1, 1])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>(rangeFrom: -3, to: 3).reshaped([2, 3], order: .C)
            XCTAssertEqual(abs(a).dataArray, [3, 2, 1, 0, 1, 2])
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>(rangeFrom: -3, to: 3).reshaped([2, 3], order: .F)
            XCTAssertEqual(abs(a).dataArray, [3, 2, 1, 0, 1, 2])
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>(rangeFrom: -5, to: 4 * 3 - 5).reshaped([4, 3], order: .C)[1..., 2]
            XCTAssertEqual(abs(a).dataArray, [2, 1, 0, 4, 5, 6])
        }
    }
}

