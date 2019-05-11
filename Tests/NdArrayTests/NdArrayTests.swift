import XCTest
import Foundation
@testable import NdArray

fileprivate func address<T>(_ p: UnsafeBufferPointer<T>) -> String {
    return String(format: "%x", Int(bitPattern: p.baseAddress))
}

fileprivate func address<T>(_ p: UnsafePointer<T>) -> String {
    return String(format: "%x", Int(bitPattern: p))
}


final class NdArrayTests: XCTestCase {
    func testInitEmptyShouldCreateEmptyArrayWhenEmptyElementsIsZero() {
        let a = NdArray<Double>(empty: 0)
        XCTAssertEqual(a.count, 0)
        XCTAssertEqual(a.dataArray, [])
        XCTAssertEqual(a.strides, [1])
        XCTAssertEqual(a.shape, [0])
        XCTAssertEqual(a.ndim, 1)
    }

    func testNdArrayShouldNotOwnDataWhenIsView() {
        let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]])
        let b = NdArray<Double>(a)
        XCTAssert(a.ownsData)
        XCTAssert(!b.ownsData)
    }

    func testNdArrayShouldOwnDataWhenCopied() {
        let a = NdArray<Double>([1, 2, 3])
        let b = NdArray<Double>(copy: a)
        XCTAssert(a.ownsData)
        XCTAssert(b.ownsData)
        XCTAssertEqual(b.dataArray, [1, 2, 3])
    }

    func testNdArrayShouldCopyCorrectlyWhenStrideIsNotSizeOfT() {
        struct S: Equatable {
            let i: Int
            let b: Bool
        }

        XCTAssertNotEqual(MemoryLayout<S>.size, MemoryLayout<S>.stride)
        let a = NdArray<S>([S(i: 0, b: true), S(i: 1, b: false)])
        let b = NdArray<S>(copy: a)
        XCTAssertEqual(b.dataArray, [S(i: 0, b: true), S(i: 1, b: false)])
    }

    func testDescription() {
        XCTAssertEqual(NdArray<Double>([]).description, "[]")
        XCTAssertEqual(NdArray<Double>([1, 2, 3]).description, "[1.0, 2.0, 3.0]")
        XCTAssertEqual(NdArray<Double>([[1, 2, 3], [4, 5, 6]]).description, "[[1.0, 2.0, 3.0],\n [4.0, 5.0, 6.0]]")
        XCTAssert(NdArray<Double>([Double]()).description.hasPrefix("[]"))
        XCTAssert(NdArray<Double>([[Double]]()).description.hasPrefix("[]"))
    }

    func testDebugDescription() {
        XCTAssert(NdArray<Double>([]).debugDescription.hasPrefix("NdArray("))
        XCTAssert(NdArray<Double>([1, 2, 3]).debugDescription.contains("shape"))
        XCTAssert(NdArray<Double>([1, 2, 3]).debugDescription.contains("strides"))
        XCTAssert(NdArray<Double>([1, 2, 3]).debugDescription.contains("data"))
    }

    func testDataArrayShouldReturnEmptyArrayWhenArrayIsEmpty() {
        XCTAssertEqual(NdArray<Double>(zeros: []).dataArray, [])
        XCTAssertEqual(NdArray<Double>(zeros: [1, 0]).dataArray, [])
    }

    func testOverlaps() {
        let a = NdArray<Double>(rangeTo: 11)
        let b = a[...5]
        let c = a[5...]
        XCTAssert(a.overlaps(b))
        XCTAssert(b.overlaps(a))
        XCTAssert(b.overlaps(c))
        XCTAssert(c.overlaps(b))
        XCTAssert(a.overlaps(c))
        XCTAssert(c.overlaps(a))
    }

    func testEmptyArrayShouldBeCAndFContiguous() {
        let a = NdArray<Double>(zeros: [])
        XCTAssert(a.isCContiguous)
        XCTAssert(a.isFContiguous)
        XCTAssert(a.isContiguous)
    }
}
