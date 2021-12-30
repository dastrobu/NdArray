//
// Created by Daniel Strobusch on 07.04.20.
//

import XCTest
import NdArray

class VectorSequenceTests: XCTestCase {

    func testIteratorShouldIterateWhenEmpty() {
        let a = Vector<Int>([])
        var v: [Int] = []
        for ai in a {
            v.append(ai)
        }
        XCTAssertEqual(NdArray(a, order: .C).dataArray, v)
        XCTAssertTrue(a.isContiguous)
    }

    func testIteratorShouldIterateWhenArrayIsContiguous() {
        let a = Vector<Int>([1, 2, 3])
        var v: [Int] = []
        for ai in a {
            v.append(ai)
        }
        XCTAssertEqual(NdArray(a, order: .C).dataArray, v)
        XCTAssertTrue(a.isContiguous)
    }

    func testIteratorShouldIterateWhenArrayIsNotContiguous() {
        let a = Vector(Vector<Int>([1, 1, 2, 2, 3, 3])[0... ~ 2])
        var v: [Int] = []
        for ai in a {
            v.append(ai)
        }
        XCTAssertEqual(NdArray(a, order: .C).dataArray, v)
        XCTAssertFalse(a.isContiguous)
    }

    func testUnderestimatedCountShouldBeZeroWhenEmpty() {
        let a = Vector<Int>([])
        XCTAssertEqual(a.underestimatedCount, 0)
    }

    func testUnderestimatedCountShouldBeShape0WhenContiguous() {
        let a = Vector<Int>([1, 2, 3])
        XCTAssertEqual(a.underestimatedCount, a.shape[0])
        XCTAssertTrue(a.isContiguous)
    }

    func testUnderestimatedCountShouldBeShape0WhenNotContiguous() {
        let a = Vector(Vector<Int>([1, 1, 2, 2, 3, 3])[0... ~ 2])
        XCTAssertEqual(a.underestimatedCount, a.shape[0])
        XCTAssertEqual(a.underestimatedCount, 3)
        XCTAssertFalse(a.isContiguous)
    }

    func testWithContiguousStorageIfAvailableShouldCallBodyWhenContiguous() {
        let a = Vector<Int>([1, 2, 3])
        XCTAssertTrue(a.isContiguous)
        let r: Int? = a.withContiguousStorageIfAvailable {
            XCTAssertEqual($0.baseAddress!, a.data)
            XCTAssertEqual($0.count, a.shape[0])
            return 42
        }
        XCTAssertEqual(r, 42)
    }

    func testWithContiguousStorageIfAvailableShouldNotCallBodyWhenNotContiguous() {
        let a = Vector(Vector<Int>([1, 1, 2, 2, 3, 3])[0... ~ 2])
        XCTAssertFalse(a.isContiguous)
        let r: Int? = a.withContiguousStorageIfAvailable { _ in
            // should not be called for non contiguous array
            42
        }
        XCTAssertNil(r)
    }
}
