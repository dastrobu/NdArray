//
// Created by Daniel Strobusch on 2019-05-07.
//

import XCTest
import NdArray

class VectorTestsFloatDouble: XCTestCase {
    func testInit1dShouldCreateContiguousArray() {
        let a = Vector<Double>([1, 2, 3])
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [1, 2, 3])
        XCTAssertEqual(a.shape, [3])
        XCTAssertEqual(a.strides, [1])
        XCTAssert(a.isCContiguous)
        XCTAssert(a.isFContiguous)
    }

    func testInit1dShouldCreateEmptyArray() {
        let a = Vector<Double>([])
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [])
        XCTAssertEqual(a.shape, [0])
        XCTAssertEqual(a.strides, [1])
        XCTAssert(a.isCContiguous)
        XCTAssert(a.isFContiguous)
    }

    func testSort() {
        // 0d
        do {
            let a = Vector<Double>.zeros(0)
            a.sort()
            XCTAssertEqual(a.shape, [0])
        }
        // 1d contiguous
        do {
            let a = Vector<Double>.range(to: 6)
            a.sort(order: .descending)
            XCTAssertEqual(a.dataArray, Vector<Double>.range(to: 6).dataArray.reversed())
            a.sort(order: .ascending)
            XCTAssertEqual(a.dataArray, Vector<Double>.range(to: 6).dataArray)
        }
        // 1d not aligned
        do {
            let a = Vector<Double>(Vector<Double>.range(to: 6)[..., 2])
            a.sort(order: .descending)
            XCTAssertEqual(a.dataArray, [4, 1, 2, 3, 0, 5])
            a.sort(order: .ascending)
            XCTAssertEqual(a.dataArray, Vector<Double>.range(to: 6).dataArray)
        }
    }

    func testReverse() {
        // 0d
        do {
            let a = Vector<Double>.zeros(0)
            a.reverse()
            XCTAssertEqual(a.shape, [0])
        }
        // 1d contiguous
        do {
            let a = Vector<Double>.range(to: 6)
            a.reverse()
            XCTAssertEqual(a.dataArray, Vector<Double>.range(to: 6).dataArray.reversed())
        }
        // 1d not aligned
        do {
            let a = Vector<Double>(Vector<Double>.range(to: 6)[..., 2])
            a.reverse()
            XCTAssertEqual(a.dataArray, [4, 1, 2, 3, 0, 5])
        }
    }

    func testNrm2() {
        // 0d
        do {
            let a = Vector<Double>.zeros(0)
            XCTAssertEqual(a.norm2(), 0, accuracy: 1e-15)
        }
        // 1d contiguous
        do {
            let a = Vector<Double>.range(to: 6)
            XCTAssertEqual(a.norm2(), 7.416198487095663, accuracy: 1e-15)
        }
        // 1d not aligned
        do {
            let a = Vector<Double>(Vector<Double>.range(to: 6)[..., 2])
            XCTAssertEqual(a.norm2(), 4.47213595499958, accuracy: 1e-15)
        }
    }

    func testDot() {
        // 0d
        do {
            let a = Vector<Double>.zeros(0)
            XCTAssertEqual(a.dot(a), 0, accuracy: 1e-15)
        }
        // 1d contiguous
        do {
            let a = Vector<Double>.range(to: 6)
            XCTAssertEqual(a.dot(a), 55)
        }
        // 1d not aligned
        do {
            let a = Vector<Double>(Vector<Double>.range(to: 6)[..., 2])
            XCTAssertEqual(a.dot(a), 20)
        }
        // 1d not aligned
        do {
            let a = Vector<Double>(Vector<Double>.range(to: 6)[..., 2])
            let b = Vector<Double>(Vector<Double>.range(to: 6)[1..., 2])
            XCTAssertEqual(a.dot(b), 26)
        }
    }

    func testMul() {
        // 0d
        do {
            let a = Vector<Double>.zeros(0)
            XCTAssertEqual(a * a, 0, accuracy: 1e-15)
        }
        // 1d contiguous
        do {
            let a = Vector<Double>.range(to: 6)
            XCTAssertEqual(a.dot(a), a * a)
        }
        // 1d not aligned
        do {
            let a = Vector<Double>(Vector<Double>.range(to: 6)[..., 2])
            XCTAssertEqual(a.dot(a), a * a)
        }
        // 1d not aligned
        do {
            let a = Vector<Double>(Vector<Double>.range(to: 6)[..., 2])
            let b = Vector<Double>(Vector<Double>.range(to: 6)[1..., 2])
            XCTAssertEqual(a.dot(b), b * a)
        }
    }
}

