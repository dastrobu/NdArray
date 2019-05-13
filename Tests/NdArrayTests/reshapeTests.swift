//
// Created by Daniel Strobusch on 2019-05-03.
//

@testable import NdArray
import XCTest

class reshapeTests: XCTestCase {

    func testReshapeShouldComputeStridesWhen_6_ReshapedTo_2_3() {
        let a = NdArray<Double>.range(to: 6)
        XCTAssertEqual(a.shape, [6])
        XCTAssertEqual(a.strides, [1])
        a.reshape([2, 3])
        XCTAssertEqual(a.shape, [2, 3])
        XCTAssertEqual(a.strides, [3, 1])

        XCTAssertEqual(a[[1, 1]], 4)
    }

    func testReshapeShouldComputeStridesWhen_6_ReshapedTo_3_2() {
        let a = NdArray<Double>.range(to: 6)
        XCTAssertEqual(a.shape, [6])
        XCTAssertEqual(a.strides, [1])
        a.reshape([3, 2])
        XCTAssertEqual(a.shape, [3, 2])
        XCTAssertEqual(a.strides, [2, 1])

        XCTAssertEqual(a[[1, 1]], 3)
    }

    func testReshapeShouldComputeStridesWhen_6_ReshapedTo_3_2_1() {
        let a = NdArray<Double>.range(to: 6)
        XCTAssertEqual(a.shape, [6])
        XCTAssertEqual(a.strides, [1])
        a.reshape([3, 2, 1])
        XCTAssertEqual(a.shape, [3, 2, 1])
        XCTAssertEqual(a.strides, [2, 1, 1])

        XCTAssertEqual(a[[1, 1, 0]], 3)
    }

    func testReshapeShouldComputeStridesWhen_9_ReshapedTo_3_3_3() {
        let a = NdArray<Double>.range(to: 3 * 3 * 3)
        XCTAssertEqual(a.shape, [3 * 3 * 3])
        XCTAssertEqual(a.strides, [1])
        a.reshape([3, 3, 3])
        XCTAssert(a.isCContiguous)
        XCTAssertEqual(a.shape, [3, 3, 3])
        XCTAssertEqual(a.strides, [9, 3, 1])

        XCTAssertEqual(a[[1, 1, 1]], 13)
    }

    func testFlattenedShouldFlattenArray() {
        let a = NdArray<Double>.range(to: 3 * 3 * 3)
        a.reshape([3, 3, 3])
        let b = a.flattened()
        XCTAssertEqual(a.shape, [3, 3, 3])
        XCTAssertEqual(a.strides, [9, 3, 1])
        XCTAssertEqual(b.shape, [3 * 3 * 3])
        XCTAssertEqual(b.strides, [1])
    }
}
