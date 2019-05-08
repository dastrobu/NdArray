//
// Created by Daniel Strobusch on 2019-05-03.
//

@testable import NdArray
import XCTest

class rangeTests: XCTestCase {
    func testInitShouldCreateHalfOpenIntervalWhenTypeIsDouble() {
        XCTAssertEqual(NdArray<Double>(rangeTo: 3).dataArray, [0, 1, 2])
        XCTAssertEqual(NdArray<Double>(rangeFrom: 1, to: 3).dataArray, [1, 2])
        XCTAssertEqual(NdArray<Double>(rangeFrom: 1, to: 3, by: 2).dataArray, [1])

        XCTAssertEqual(NdArray<Double>(rangeTo: 3, by: 0.7).dataArray, [0.0, 0.7, 1.4, 2.1, 2.8], accuracy: 1e-15)
        XCTAssertEqual(NdArray<Double>(rangeTo: 3, by: 1.1).dataArray, [0.0, 1.1, 2.2], accuracy: 1e-15)

        XCTAssertEqual(NdArray<Double>(rangeTo: 3, by: -1).dataArray, [])
        XCTAssertEqual(NdArray<Double>(rangeFrom: 3, to: 0, by: 1).dataArray, [])

        XCTAssertEqual(NdArray<Double>(rangeFrom: 3, to: 0, by: -1).dataArray, [3, 2, 1])
        XCTAssertEqual(NdArray<Double>(rangeFrom: 3, to: 0, by: -1.1).dataArray, [3.0, 1.9, 0.8], accuracy: 1e-15)
        XCTAssertEqual(NdArray<Double>(rangeFrom: 3, to: 0, by: -0.7).dataArray, [3.0, 2.3, 1.6, 0.9, 0.2], accuracy: 1e-15)
    }

    func testInitShouldCreateHalfOpenIntervalWhenTypeIsFloat() {
        XCTAssertEqual(NdArray<Float>(rangeTo: 3).dataArray, [0, 1, 2])
        XCTAssertEqual(NdArray<Float>(rangeFrom: 1, to: 3).dataArray, [1, 2])
        XCTAssertEqual(NdArray<Float>(rangeFrom: 1, to: 3, by: 2).dataArray, [1])

        XCTAssertEqual(NdArray<Float>(rangeTo: 3, by: 0.7).dataArray, [0.0, 0.7, 1.4, 2.1, 2.8], accuracy: 1e-6)
        XCTAssertEqual(NdArray<Float>(rangeTo: 3, by: 1.1).dataArray, [0.0, 1.1, 2.2], accuracy: 1e-6)

        XCTAssertEqual(NdArray<Float>(rangeTo: 3, by: -1).dataArray, [])
        XCTAssertEqual(NdArray<Float>(rangeFrom: 3, to: 0, by: 1).dataArray, [])

        XCTAssertEqual(NdArray<Float>(rangeFrom: 3, to: 0, by: -1).dataArray, [3, 2, 1])
        XCTAssertEqual(NdArray<Float>(rangeFrom: 3, to: 0, by: -1.1).dataArray, [3.0, 1.9, 0.8], accuracy: 1e-6)
        XCTAssertEqual(NdArray<Float>(rangeFrom: 3, to: 0, by: -0.7).dataArray, [3.0, 2.3, 1.6, 0.9, 0.2], accuracy: 1e-6)
    }
}
