import XCTest
@testable import NdArray

// swiftlint:disable:next type_name
class copyTests: XCTestCase {

    func testInitCopyShouldCopyContiguousArray() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            let cpy = NdArray(copy: a)
            XCTAssert(a.ownsData)
            XCTAssert(cpy.ownsData)
            XCTAssertFalse(a.overlaps(cpy))
            XCTAssertEqual(a.dataArray, cpy.dataArray)
            XCTAssert(a.isCContiguous)
            XCTAssert(cpy.isCContiguous)
        }
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)
            let cpy = NdArray(copy: a)
            XCTAssert(a.ownsData)
            XCTAssert(cpy.ownsData)
            XCTAssertFalse(a.overlaps(cpy))
            XCTAssertEqual(a.dataArray, cpy.dataArray)
            XCTAssert(a.isFContiguous)
            XCTAssert(cpy.isFContiguous)
        }
    }

    func testInitCopyShouldCopyNonContiguousArray() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)[[0..., 0... ~ 2]]
            let cpy = NdArray(copy: a)
            XCTAssert(cpy.ownsData)
            XCTAssertFalse(a.overlaps(cpy))
            XCTAssertEqual(cpy.dataArray, [1, 3, 4, 6])
            XCTAssertFalse(a.isCContiguous)
            XCTAssert(cpy.isCContiguous)
        }
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)[[0..., 0... ~ 2]]
            let cpy = NdArray(copy: a)
            XCTAssert(cpy.ownsData)
            XCTAssertFalse(a.overlaps(cpy))
            XCTAssertEqual(cpy.dataArray, [1, 3, 4, 6])
            XCTAssertFalse(a.isFContiguous)
            XCTAssert(cpy.isCContiguous) // since the original array is not contiguous, the copy defaults to C
        }
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)[[0..., 0... ~ 2]]
            let cpy = NdArray(copy: a, order: .F)
            XCTAssert(cpy.ownsData)
            XCTAssertFalse(a.overlaps(cpy))
            XCTAssertEqual(cpy.dataArray, [1, 4, 3, 6])
            XCTAssertFalse(a.isCContiguous)
            XCTAssert(cpy.isFContiguous)
        }
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)[[0..., 0... ~ 2]]
            let cpy = NdArray(copy: a, order: .F)
            XCTAssert(cpy.ownsData)
            XCTAssertFalse(a.overlaps(cpy))
            XCTAssertEqual(cpy.dataArray, [1, 4, 3, 6])
            XCTAssertFalse(a.isFContiguous)
            XCTAssert(cpy.isFContiguous)
        }
    }

    func testInitCopyShouldCopyContiguousArrayAndSwitchAlignment() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            let cpy = NdArray(copy: a, order: .F)
            XCTAssert(cpy.ownsData)
            XCTAssertFalse(a.overlaps(cpy))
            XCTAssertEqual(cpy.dataArray, [1, 4, 2, 5, 3, 6])
            XCTAssertFalse(a.isFContiguous)
            XCTAssert(cpy.isFContiguous)
        }
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)
            let cpy = NdArray(copy: a, order: .C)
            XCTAssert(a.ownsData)
            XCTAssert(cpy.ownsData)
            XCTAssertFalse(a.overlaps(cpy))
            XCTAssertEqual(cpy.dataArray, [1, 2, 3, 4, 5, 6])
            XCTAssertFalse(a.isCContiguous)
            XCTAssert(cpy.isCContiguous)
        }
    }

    func testInitCopyShouldCopyEmptyArray() {
        let a = NdArray<Double>([])
        let cpy = NdArray(copy: a)
        XCTAssert(a.ownsData)
        XCTAssert(cpy.ownsData)
        XCTAssertFalse(a.overlaps(cpy))
        XCTAssertEqual(cpy.dataArray, [])
        XCTAssertEqual(cpy.shape, [0])
        XCTAssert(a.isCContiguous)
        XCTAssert(a.isFContiguous)
        XCTAssert(cpy.isCContiguous)
        XCTAssert(cpy.isFContiguous)
    }

    func testCopyToShouldCopyEmptyArray() {
        let a = NdArray<Double>([])
        let b = NdArray<Double>([])
        a.copyTo(b)
    }

    func testCopyToShouldCopyToFContiguousArrayWhenSrcIsNotContiguousAndOutIsFContiguous() {
        let a = NdArray<Double>.range(to: 3 * 4).reshaped([3, 4], order: .F)
        let a1 = a[[0..., 0... ~ 2]]
        let a2 = a[[0..., 2...]]
        XCTAssertFalse(a1.isContiguous)
        XCTAssert(a2.isFContiguous)
        XCTAssert(a1.overlaps(a2))
        a1.copyTo(a2)
    }

}
