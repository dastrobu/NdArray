//
// Created by Daniel Strobusch on 2019-05-08.
//

import XCTest
@testable import NdArray

class arithmeticTestsDouble: XCTestCase {
    func testMulNdArrayScalarDouble() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            let b = a * 2
            XCTAssertEqual(b.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            let b = a * 2
            XCTAssertEqual(b.shape, [1, 0])
        }
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

    func testDivNdArrayScalarDouble() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            let b = a / 2
            XCTAssertEqual(b.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            let b = a / 2
            XCTAssertEqual(b.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            let b = a / 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 / 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)[..., 2]
            let b = a / 2
            XCTAssertEqual(NdArray(copy: a).dataArray, NdArray<Double>(rangeFrom: 0, to: 6, by: 2).dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 / 2 }))
            XCTAssertEqual(a.shape, b.shape)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            let b = a / 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 / 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isCContiguous)
            XCTAssert(b.isCContiguous)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            let b = a / 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 / 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isFContiguous)
            XCTAssert(b.isFContiguous)
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[..., 2]
            let b = a / 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[..., 2].dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 / 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(b.isCContiguous)
        }
    }

    func testAddNdArrayScalarDouble() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            let b = a + 2
            XCTAssertEqual(b.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            let b = a + 2
            XCTAssertEqual(b.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            let b = a + 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 + 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)[..., 2]
            let b = a + 2
            XCTAssertEqual(NdArray(copy: a).dataArray, NdArray<Double>(rangeFrom: 0, to: 6, by: 2).dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 + 2 }))
            XCTAssertEqual(a.shape, b.shape)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            let b = a + 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 + 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isCContiguous)
            XCTAssert(b.isCContiguous)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            let b = a + 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 + 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isFContiguous)
            XCTAssert(b.isFContiguous)
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[..., 2]
            let b = a + 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[..., 2].dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 + 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(b.isCContiguous)
        }
    }

    func testSubNdArrayScalarDouble() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            let b = a - 2
            XCTAssertEqual(b.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            let b = a - 2
            XCTAssertEqual(b.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            let b = a - 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 - 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)[..., 2]
            let b = a - 2
            XCTAssertEqual(NdArray(copy: a).dataArray, NdArray<Double>(rangeFrom: 0, to: 6, by: 2).dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 - 2 }))
            XCTAssertEqual(a.shape, b.shape)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            let b = a - 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 - 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isCContiguous)
            XCTAssert(b.isCContiguous)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            let b = a - 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 - 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isFContiguous)
            XCTAssert(b.isFContiguous)
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[..., 2]
            let b = a - 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[..., 2].dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 - 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(b.isCContiguous)
        }
    }

    func testMulNdArrayScalarDoubleInPlace() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            a *= 2
            XCTAssertEqual(a.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            a *= 2
            XCTAssertEqual(a.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            a *= 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).dataArray.map({ $0 * 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)
            a[..., 2] *= 2
            XCTAssertEqual(a.dataArray, [0, 1, 4, 3, 8, 5])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            a *= 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C).dataArray.map({ $0 * 2 }))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            a *= 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F).dataArray.map({ $0 * 2 }))
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)
            a[..., 2] *= 2
            XCTAssertEqual(a.dataArray, [0, 2, 4, 3, 4, 5, 12, 14, 16, 9, 10, 11])
        }
    }

    func testDivNdArrayScalarDoubleInPlace() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            a /= 2
            XCTAssertEqual(a.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            a /= 2
            XCTAssertEqual(a.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            a /= 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).dataArray.map({ $0 / 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)
            a[..., 2] /= 2
            XCTAssertEqual(a.dataArray, [0, 1, 1, 3, 2, 5])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            a /= 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C).dataArray.map({ $0 / 2 }))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            a /= 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F).dataArray.map({ $0 / 2 }))
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)
            a[..., 2] /= 2
            XCTAssertEqual(a.dataArray, [0.0, 0.5, 1.0, 3.0, 4.0, 5.0, 3.0, 3.5, 4.0, 9.0, 10.0, 11.0])
        }
    }

    func testAddNdArrayScalarDoubleInPlace() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            a += 2
            XCTAssertEqual(a.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            a += 2
            XCTAssertEqual(a.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            a += 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).dataArray.map({ $0 + 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)
            a[..., 2] += 2
            XCTAssertEqual(a.dataArray, [2, 1, 4, 3, 6, 5])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            a += 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C).dataArray.map({ $0 + 2 }))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            a += 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F).dataArray.map({ $0 + 2 }))
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)
            a[..., 2] += 2
            XCTAssertEqual(a.dataArray, [2, 3, 4, 3, 4, 5, 8, 9, 10, 9, 10, 11])
        }
    }

    func testSubNdArrayScalarDoubleInPlace() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            a -= 2
            XCTAssertEqual(a.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            a -= 2
            XCTAssertEqual(a.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            a -= 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).dataArray.map({ $0 - 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)
            a[..., 2] -= 2
            XCTAssertEqual(a.dataArray, [-2, 1, 0, 3, 2, 5])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            a -= 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C).dataArray.map({ $0 - 2 }))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            a -= 2
            XCTAssertEqual(a.dataArray, NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F).dataArray.map({ $0 - 2 }))
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)
            a[..., 2] -= 2
            XCTAssertEqual(a.dataArray, [-2, -1, 0, 3, 4, 5, 4, 5, 6, 9, 10, 11])
        }
    }

    func testMax() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            XCTAssertNil(a.max())
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            XCTAssertNil(a.max())
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            XCTAssertEqual(a.max()!, 5)
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)[..., 2]
            XCTAssertEqual(a.max()!, 4)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(a.max()!, 5)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(a.max()!, 5)
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[..., 2]
            XCTAssertEqual(a.max()!, 8)
        }
    }

    func testMin() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            XCTAssertNil(a.min())
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            XCTAssertNil(a.min())
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            XCTAssertEqual(a.min()!, 0)
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)[..., 2]
            XCTAssertEqual(a.min()!, 0)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(a.min()!, 0)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(a.min()!, 0)
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[1..., 2]
            XCTAssertEqual(a.min()!, 3)
        }
    }

    func testSum() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            XCTAssertEqual(a.sum(), 0)
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            XCTAssertEqual(a.sum(), 0)
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6)
            XCTAssertEqual(a.sum(), 15)
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 6)[..., 2]
            XCTAssertEqual(a.sum(), 6)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(a.sum(), 15)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeTo: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(a.sum(), 15)
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeTo: 4 * 3).reshaped([4, 3], order: .C)[1..., 2]
            XCTAssertEqual(a.sum(), 42)
        }
    }

    func testProduct() {
        // 0d
        do {
            let a = NdArray<Double>(zeros: [])
            XCTAssertEqual(a.product(), 0)
        }
        // 2d effective 0d
        do {
            let a = NdArray<Double>(zeros: [1, 0])
            XCTAssertEqual(a.product(), 0)
        }
        // 1d contiguous
        do {
            let a = NdArray<Double>(rangeFrom: 1, to: 6)
            XCTAssertEqual(a.product(), 120)
        }
        // 1d not aligned
        do {
            let a = NdArray<Double>(rangeFrom: 1, to: 7)[..., 2]
            XCTAssertEqual(a.product(), 15)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Double>(rangeFrom: 1, to: 7).reshaped([2, 3], order: .C)
            XCTAssertEqual(a.product(), 720)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Double>(rangeFrom: 1, to: 7).reshaped([2, 3], order: .F)
            XCTAssertEqual(a.product(), 720)
        }
        // 2d not aligned
        do {
            let a = NdArray<Double>(rangeFrom: 1, to: 4 * 3 + 1).reshaped([4, 3], order: .C)[1..., 2]
            XCTAssertEqual(a.product(), 158400)
        }
    }
}

