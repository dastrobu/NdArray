//
// Created by Daniel Strobusch on 2019-05-08.
//

import XCTest
@testable import NdArray

class arithmeticTestsDouble: XCTestCase {
    func testMulNdArrayScalarDouble() {
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            let b = a * 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 * 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)[..., 2]
            let b = a * 2
            XCTAssertEqual(NdArray(copy: a).dataArray, NdArray<Double>(rangeFrom: 0, to: 6, by: 2).dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 * 2 }))
            XCTAssertEqual(a.shape, b.shape)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            let b = a * 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 * 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isCContiguous)
            XCTAssert(b.isCContiguous)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            let b = a * 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 * 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isFContiguous)
            XCTAssert(b.isFContiguous)
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[..., 2]
            let b = a * 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[..., 2].dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 * 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(b.isCContiguous)
        }
    }
}

