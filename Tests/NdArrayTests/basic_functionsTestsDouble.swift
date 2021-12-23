//
// Created by Daniel Strobusch on 2019-05-11.
//

import XCTest
@testable import NdArray

// swiftlint:disable:next type_name
class basic_functionsTestsDouble: XCTestCase {
    func testAbs() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(abs(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.zeros([1, 0])
            XCTAssertEqual(abs(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: -3, to: 3)
            XCTAssertEqual(abs(a).dataArray, a.dataArray.map(abs))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>.range(from: -3, to: 3)[..., 2]
            XCTAssertEqual(abs(a).dataArray, [3, 1, 1])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: -3, to: 3).reshaped([2, 3], order: .C)
            XCTAssertEqual(abs(a).dataArray, [3, 2, 1, 0, 1, 2])
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: -3, to: 3).reshaped([2, 3], order: .F)
            XCTAssertEqual(abs(a).dataArray, [3, 2, 1, 0, 1, 2])
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>.range(from: -5, to: 4 * 3 - 5).reshaped([4, 3], order: .C)[1..., 2]
            XCTAssertEqual(abs(a).dataArray, [2, 1, 0, 4, 5, 6])
        }
    }
    func testAcos() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(acos(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(acos(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7) / 10
            XCTAssertEqual(acos(a).dataArray, a.dataArray.map(acos))
        }
        // 1d not aligned
        do {
            let a = (NdArray<Double>.range(from: 1, to: 7) / 10)[..., 2]
            XCTAssertEqual(acos(a).dataArray, NdArray(a, order: .C).dataArray.map(acos))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C) / 10
            XCTAssertEqual(acos(a).dataArray, NdArray(a, order: .C).dataArray.map(acos))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F) / 10
            XCTAssertEqual(acos(a).dataArray, NdArray(a, order: .F).dataArray.map(acos))
        }
        // 2d not aligned
        do {
            let a = (NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C) / 100)[1..., 2]
            XCTAssertEqual(acos(a).dataArray, NdArray(a, order: .C).dataArray.map(acos))
        }
    }
    func testAsin() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(asin(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(asin(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7) / 10
            XCTAssertEqual(asin(a).dataArray, a.dataArray.map(asin))
        }
        // 1d not aligned
        do {
            let a = (NdArray<Double>.range(from: 1, to: 7) / 10)[..., 2]
            XCTAssertEqual(asin(a).dataArray, NdArray(a, order: .C).dataArray.map(asin))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C) / 10
            XCTAssertEqual(asin(a).dataArray, NdArray(a, order: .C).dataArray.map(asin))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F) / 10
            XCTAssertEqual(asin(a).dataArray, NdArray(a, order: .F).dataArray.map(asin))
        }
        // 2d not aligned
        do {
            let a = (NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C) / 100)[1..., 2]
            XCTAssertEqual(asin(a).dataArray, NdArray(a, order: .C).dataArray.map(asin))
        }
    }
    func testAtan() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(atan(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(atan(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7) / 10
            XCTAssertEqual(atan(a).dataArray, a.dataArray.map(atan))
        }
        // 1d not aligned
        do {
            let a = (NdArray<Double>.range(from: 1, to: 7) / 10)[..., 2]
            XCTAssertEqual(atan(a).dataArray, NdArray(a, order: .C).dataArray.map(atan))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C) / 10
            XCTAssertEqual(atan(a).dataArray, NdArray(a, order: .C).dataArray.map(atan))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F) / 10
            XCTAssertEqual(atan(a).dataArray, NdArray(a, order: .F).dataArray.map(atan))
        }
        // 2d not aligned
        do {
            let a = (NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C) / 100)[1..., 2]
            XCTAssertEqual(atan(a).dataArray, NdArray(a, order: .C).dataArray.map(atan))
        }
    }
    func testCos() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(cos(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(cos(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7) / 10
            XCTAssertEqual(cos(a).dataArray, a.dataArray.map(cos))
        }
        // 1d not aligned
        do {
            let a = (NdArray<Double>.range(from: 1, to: 7) / 10)[..., 2]
            XCTAssertEqual(cos(a).dataArray, NdArray(a, order: .C).dataArray.map(cos))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C) / 10
            XCTAssertEqual(cos(a).dataArray, NdArray(a, order: .C).dataArray.map(cos))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F) / 10
            XCTAssertEqual(cos(a).dataArray, NdArray(a, order: .F).dataArray.map(cos))
        }
        // 2d not aligned
        do {
            let a = (NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C) / 100)[1..., 2]
            XCTAssertEqual(cos(a).dataArray, NdArray(a, order: .C).dataArray.map(cos))
        }
    }
    func testSin() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(sin(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(sin(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7) / 10
            XCTAssertEqual(sin(a).dataArray, a.dataArray.map(sin))
        }
        // 1d not aligned
        do {
            let a = (NdArray<Double>.range(from: 1, to: 7) / 10)[..., 2]
            XCTAssertEqual(sin(a).dataArray, NdArray(a, order: .C).dataArray.map(sin))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C) / 10
            XCTAssertEqual(sin(a).dataArray, NdArray(a, order: .C).dataArray.map(sin))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F) / 10
            XCTAssertEqual(sin(a).dataArray, NdArray(a, order: .F).dataArray.map(sin))
        }
        // 2d not aligned
        do {
            let a = (NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C) / 100)[1..., 2]
            XCTAssertEqual(sin(a).dataArray, NdArray(a, order: .C).dataArray.map(sin))
        }
    }
    func testTan() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(tan(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(tan(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7) / 10
            XCTAssertEqual(tan(a).dataArray, a.dataArray.map(tan))
        }
        // 1d not aligned
        do {
            let a = (NdArray<Double>.range(from: 1, to: 7) / 10)[..., 2]
            XCTAssertEqual(tan(a).dataArray, NdArray(a, order: .C).dataArray.map(tan))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C) / 10
            XCTAssertEqual(tan(a).dataArray, NdArray(a, order: .C).dataArray.map(tan))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F) / 10
            XCTAssertEqual(tan(a).dataArray, NdArray(a, order: .F).dataArray.map(tan))
        }
        // 2d not aligned
        do {
            let a = (NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C) / 100)[1..., 2]
            XCTAssertEqual(tan(a).dataArray, NdArray(a, order: .C).dataArray.map(tan))
        }
    }
    func testCosh() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(cosh(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(cosh(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7) / 10
            XCTAssertEqual(cosh(a).dataArray, a.dataArray.map(cosh))
        }
        // 1d not aligned
        do {
            let a = (NdArray<Double>.range(from: 1, to: 7) / 10)[..., 2]
            XCTAssertEqual(cosh(a).dataArray, NdArray(a, order: .C).dataArray.map(cosh))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C) / 10
            XCTAssertEqual(cosh(a).dataArray, NdArray(a, order: .C).dataArray.map(cosh))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F) / 10
            XCTAssertEqual(cosh(a).dataArray, NdArray(a, order: .F).dataArray.map(cosh))
        }
        // 2d not aligned
        do {
            let a = (NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C) / 100)[1..., 2]
            XCTAssertEqual(cosh(a).dataArray, NdArray(a, order: .C).dataArray.map(cosh))
        }
    }
    func testSinh() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(sinh(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(sinh(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7) / 10
            XCTAssertEqual(sinh(a).dataArray, a.dataArray.map(sinh))
        }
        // 1d not aligned
        do {
            let a = (NdArray<Double>.range(from: 1, to: 7) / 10)[..., 2]
            XCTAssertEqual(sinh(a).dataArray, NdArray(a, order: .C).dataArray.map(sinh))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C) / 10
            XCTAssertEqual(sinh(a).dataArray, NdArray(a, order: .C).dataArray.map(sinh))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F) / 10
            XCTAssertEqual(sinh(a).dataArray, NdArray(a, order: .F).dataArray.map(sinh))
        }
        // 2d not aligned
        do {
            let a = (NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C) / 100)[1..., 2]
            XCTAssertEqual(sinh(a).dataArray, NdArray(a, order: .C).dataArray.map(sinh))
        }
    }
    func testTanh() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(tanh(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(tanh(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7) / 10
            XCTAssertEqual(tanh(a).dataArray, a.dataArray.map(tanh))
        }
        // 1d not aligned
        do {
            let a = (NdArray<Double>.range(from: 1, to: 7) / 10)[..., 2]
            XCTAssertEqual(tanh(a).dataArray, NdArray(a, order: .C).dataArray.map(tanh))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C) / 10
            XCTAssertEqual(tanh(a).dataArray, NdArray(a, order: .C).dataArray.map(tanh))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F) / 10
            XCTAssertEqual(tanh(a).dataArray, NdArray(a, order: .F).dataArray.map(tanh))
        }
        // 2d not aligned
        do {
            let a = (NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C) / 100)[1..., 2]
            XCTAssertEqual(tanh(a).dataArray, NdArray(a, order: .C).dataArray.map(tanh))
        }
    }
    func testLog() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(log(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(log(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7)
            XCTAssertEqual(log(a).dataArray, a.dataArray.map(log))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>.range(from: 1, to: 7)[..., 2]
            XCTAssertEqual(log(a).dataArray, NdArray(a, order: .C).dataArray.map(log))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(log(a).dataArray, NdArray(a, order: .C).dataArray.map(log))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(log(a).dataArray, NdArray(a, order: .F).dataArray.map(log))
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C)[1..., 2]
            XCTAssertEqual(log(a).dataArray, NdArray(a, order: .C).dataArray.map(log))
        }
    }
    func testLog10() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(log10(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(log10(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7)
            XCTAssertEqual(log10(a).dataArray, a.dataArray.map(log10))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>.range(from: 1, to: 7)[..., 2]
            XCTAssertEqual(log10(a).dataArray, NdArray(a, order: .C).dataArray.map(log10))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(log10(a).dataArray, NdArray(a, order: .C).dataArray.map(log10))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(log10(a).dataArray, NdArray(a, order: .F).dataArray.map(log10))
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C)[1..., 2]
            XCTAssertEqual(log10(a).dataArray, NdArray(a, order: .C).dataArray.map(log10))
        }
    }
    func testLog1p() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(log1p(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(log1p(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7)
            XCTAssertEqual(log1p(a).dataArray, a.dataArray.map(log1p))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>.range(from: 1, to: 7)[..., 2]
            XCTAssertEqual(log1p(a).dataArray, NdArray(a, order: .C).dataArray.map(log1p))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(log1p(a).dataArray, NdArray(a, order: .C).dataArray.map(log1p))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(log1p(a).dataArray, NdArray(a, order: .F).dataArray.map(log1p))
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C)[1..., 2]
            XCTAssertEqual(log1p(a).dataArray, NdArray(a, order: .C).dataArray.map(log1p))
        }
    }
    func testLog2() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(log2(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(log2(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7)
            XCTAssertEqual(log2(a).dataArray, a.dataArray.map(log2))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>.range(from: 1, to: 7)[..., 2]
            XCTAssertEqual(log2(a).dataArray, NdArray(a, order: .C).dataArray.map(log2))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(log2(a).dataArray, NdArray(a, order: .C).dataArray.map(log2))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(log2(a).dataArray, NdArray(a, order: .F).dataArray.map(log2))
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C)[1..., 2]
            XCTAssertEqual(log2(a).dataArray, NdArray(a, order: .C).dataArray.map(log2))
        }
    }
    func testLogb() {
        // 0d
        do {
            let a = NdArray<Double>.zeros([])
            XCTAssertEqual(logb(a).shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>.ones([1, 0])
            XCTAssertEqual(logb(a).shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>.range(from: 1, to: 7)
            XCTAssertEqual(logb(a).dataArray, a.dataArray.map(logb))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>.range(from: 1, to: 7)[..., 2]
            XCTAssertEqual(logb(a).dataArray, NdArray(a, order: .C).dataArray.map(logb))
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(logb(a).dataArray, NdArray(a, order: .C).dataArray.map(logb))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>.range(from: 0, to: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(logb(a).dataArray, NdArray(a, order: .F).dataArray.map(logb))
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>.range(from: 0, to: 4 * 3).reshaped([4, 3], order: .C)[1..., 2]
            XCTAssertEqual(logb(a).dataArray, NdArray(a, order: .C).dataArray.map(logb))
        }
    }
}
