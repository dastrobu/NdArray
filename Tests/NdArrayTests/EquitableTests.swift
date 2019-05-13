//
// Created by Daniel Strobusch on 2019-05-13.
//

import XCTest
@testable import NdArray

class EquitableTests: XCTestCase {
    func testEquals() {
        // empty
        do{
            let a = NdArray<Double>(zeros: [])
            let b = NdArray<Double>(zeros: [1, 0])
            let c = NdArray<Double>(zeros: [0, 1])
            XCTAssertEqual(a, a)
            XCTAssertNotEqual(a, b)
            XCTAssertNotEqual(a, c)
            XCTAssertNotEqual(b, c)
        }
        // 1d contiguous
        do{
            let a = NdArray<Double>(zeros: [2])
            let b = NdArray<Double>(zeros: [2])
            let c = NdArray<Double>(ones: [2])
            XCTAssertEqual(a, a)
            XCTAssertEqual(a, b)
            XCTAssertEqual(a, a)
            XCTAssertNotEqual(a, c)
            XCTAssertNotEqual(b, c)
        }
        // 1d not contiguous
        do{
            let a = NdArray<Double>(zeros: [3])
            let b = NdArray<Double>(NdArray<Double>(zeros: [6])[...,2])
            let c = NdArray<Double>(NdArray<Double>(ones: [6])[...,2])
            XCTAssertEqual(a, a)
            XCTAssertEqual(a, b)
            XCTAssertNotEqual(a, c)
            XCTAssertNotEqual(b, c)
        }
        // 2d contiguous
        do{
            let a = NdArray<Double>(zeros: [2, 3])
            let b = NdArray<Double>(zeros: [2, 3])
            let c = NdArray<Double>(ones: [2, 3])
            XCTAssertEqual(a, a)
            XCTAssertEqual(a, b)
            XCTAssertEqual(a, a)
            XCTAssertNotEqual(a, c)
            XCTAssertNotEqual(b, c)
        }
        // 2d not contiguous
        do{
            let a = NdArray<Double>(zeros: [2, 3])
            let b = NdArray<Double>(NdArray<Double>(zeros: [2, 6])[...][...,2])
            let c = NdArray<Double>(NdArray<Double>(ones: [2, 6])[...][...,2])
            XCTAssertEqual(a, a)
            XCTAssertEqual(a, b)
            XCTAssertNotEqual(a, c)
            XCTAssertNotEqual(b, c)
        }
        // different types
        do {
            let a = NdArray<Double>(zeros: [2, 3])
            let b = NdArray<Double>(zeros: [2, 3])
            XCTAssertEqual(a, b)
            XCTAssertNotEqual(a, b[...])
            XCTAssertEqual(a[...], b[...])
        }
    }
}
