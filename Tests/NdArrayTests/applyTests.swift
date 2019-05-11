//
// Created by Daniel Strobusch on 2019-05-11.
//

import XCTest
@testable import NdArray

class applyTests: XCTestCase{

    func testApply() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            let b = NdArray<Double>(copy: a)
            a.apply { $0 * 2}
            b *= 2
            XCTAssertEqual(a.dataArray, b.dataArray)
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            let b = NdArray<Double>(copy: a)
            a.apply { $0 * 2}
            b *= 2
            XCTAssertEqual(a.dataArray, b.dataArray)
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeFrom: -3, to: 3)
            let b = NdArray<Double>(copy: a)
            a.apply { $0 * 2}
            b *= 2
            XCTAssertEqual(a.dataArray, b.dataArray)
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeFrom: -3, to: 3)
            let b = NdArray<Double>(rangeFrom: -3, to: 3)
            a[..., 2].apply { $0 * 2}
            b[..., 2] *= 2
            XCTAssertEqual(a.dataArray, b.dataArray)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeFrom: -3, to: 3).reshaped([2, 3], order: .C)
            let b = NdArray<Double>(copy: a)
            a.apply { $0 * 2}
            b *= 2
            XCTAssertEqual(a.dataArray, b.dataArray)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeFrom: -3, to: 3).reshaped([2, 3], order: .F)
            let b = NdArray<Double>(copy: a)
            a.apply { $0 * 2}
            b *= 2
            XCTAssertEqual(a.dataArray, b.dataArray)
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeFrom: -5, to: 4 * 3 - 5).reshaped([4, 3], order: .C)
            let b = NdArray<Double>(rangeFrom: -5, to: 4 * 3 - 5).reshaped([4, 3], order: .C)
            a[1..., 2].apply { $0 * 2}
            b[1..., 2] *= 2
            XCTAssertEqual(a.dataArray, b.dataArray)
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeFrom: -5, to: 4 * 3 - 5).reshaped([4, 3], order: .C)
            let b = NdArray<Double>(rangeFrom: -5, to: 4 * 3 - 5).reshaped([4, 3], order: .C)
            a[...][1..., 2].apply { $0 * 2}
            b[...][1..., 2] *= 2
            XCTAssertEqual(a.dataArray, b.dataArray)
        }
    }
}
