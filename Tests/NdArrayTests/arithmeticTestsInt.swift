import XCTest
@testable import NdArray

// swiftlint:disable:next type_name
class arithmeticTestsInt: XCTestCase {
    func testMulNdArrayScalarInt() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            let b = a * 2
            XCTAssertEqual(b.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            let b = a * 2
            XCTAssertEqual(b.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            let b = a * 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 * 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)[0... ~ 2]
            let b = a * 2
            XCTAssertEqual(NdArray(copy: a).dataArray, NdArray<Int>.range(from: 0, to: 6, by: 2).dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 * 2 }))
            XCTAssertEqual(a.shape, b.shape)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            let b = a * 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 * 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isCContiguous)
            XCTAssert(b.isCContiguous)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            let b = a * 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 * 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isFContiguous)
            XCTAssert(b.isFContiguous)
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)[0... ~ 2]
            let b = a * 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)[0... ~ 2].dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 * 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(b.isCContiguous)
        }
    }

    func testAddNdArrayScalarInt() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            let b = a + 2
            XCTAssertEqual(b.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            let b = a + 2
            XCTAssertEqual(b.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            let b = a + 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 + 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)[0... ~ 2]
            let b = a + 2
            XCTAssertEqual(NdArray(copy: a).dataArray, NdArray<Int>.range(from: 0, to: 6, by: 2).dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 + 2 }))
            XCTAssertEqual(a.shape, b.shape)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            let b = a + 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 + 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isCContiguous)
            XCTAssert(b.isCContiguous)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            let b = a + 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 + 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isFContiguous)
            XCTAssert(b.isFContiguous)
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)[0... ~ 2]
            let b = a + 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)[0... ~ 2].dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 + 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(b.isCContiguous)
        }
    }

    func testSubNdArrayScalarInt() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            let b = a - 2
            XCTAssertEqual(b.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            let b = a - 2
            XCTAssertEqual(b.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            let b = a - 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 - 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)[0... ~ 2]
            let b = a - 2
            XCTAssertEqual(NdArray(copy: a).dataArray, NdArray<Int>.range(from: 0, to: 6, by: 2).dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 - 2 }))
            XCTAssertEqual(a.shape, b.shape)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            let b = a - 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 - 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isCContiguous)
            XCTAssert(b.isCContiguous)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            let b = a - 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F).dataArray)
            XCTAssertEqual(b.dataArray, a.dataArray.map({ $0 - 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(a.isFContiguous)
            XCTAssert(b.isFContiguous)
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)[0... ~ 2]
            let b = a - 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)[0... ~ 2].dataArray)
            XCTAssertEqual(b.dataArray, NdArray(copy: a).dataArray.map({ $0 - 2 }))
            XCTAssertEqual(a.shape, b.shape)
            XCTAssert(b.isCContiguous)
        }
    }

    func testMulNdArrayScalarIntInPlace() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            a *= 2
            XCTAssertEqual(a.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            a *= 2
            XCTAssertEqual(a.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            a *= 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).dataArray.map({ $0 * 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)
            a[0... ~ 2] *= 2
            XCTAssertEqual(a.dataArray, [0, 1, 4, 3, 8, 5])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            a *= 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C).dataArray.map({ $0 * 2 }))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            a *= 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F).dataArray.map({ $0 * 2 }))
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)
            a[0... ~ 2] *= 2
            XCTAssertEqual(a.dataArray, [0, 2, 4, 3, 4, 5, 12, 14, 16, 9, 10, 11])
        }
    }

    func testAddNdArrayScalarIntInPlace() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            a += 2
            XCTAssertEqual(a.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            a += 2
            XCTAssertEqual(a.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            a += 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).dataArray.map({ $0 + 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)
            a[0... ~ 2] += 2
            XCTAssertEqual(a.dataArray, [2, 1, 4, 3, 6, 5])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            a += 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C).dataArray.map({ $0 + 2 }))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            a += 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F).dataArray.map({ $0 + 2 }))
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)
            a[0... ~ 2] += 2
            XCTAssertEqual(a.dataArray, [2, 3, 4, 3, 4, 5, 8, 9, 10, 9, 10, 11])
        }
    }

    func testSubNdArrayScalarIntInPlace() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            a -= 2
            XCTAssertEqual(a.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            a -= 2
            XCTAssertEqual(a.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            a -= 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).dataArray.map({ $0 - 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)
            a[0... ~ 2] -= 2
            XCTAssertEqual(a.dataArray, [-2, 1, 0, 3, 2, 5])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            a -= 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C).dataArray.map({ $0 - 2 }))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            a -= 2
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F).dataArray.map({ $0 - 2 }))
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)
            a[0... ~ 2] -= 2
            XCTAssertEqual(a.dataArray, [-2, -1, 0, 3, 4, 5, 4, 5, 6, 9, 10, 11])
        }
    }

    func testMax() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            XCTAssertNil(a.max())
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            XCTAssertNil(a.max())
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            XCTAssertEqual(a.max()!, 5)
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)[0... ~ 2]
            XCTAssertEqual(a.max()!, 4)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(a.max()!, 5)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(a.max()!, 5)
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)[0... ~ 2]
            XCTAssertEqual(a.max()!, 8)
        }
    }

    func testMin() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            XCTAssertNil(a.min())
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            XCTAssertNil(a.min())
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            XCTAssertEqual(a.min()!, 0)
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)[0... ~ 2]
            XCTAssertEqual(a.min()!, 0)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(a.min()!, 0)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(a.min()!, 0)
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)[1... ~ 2]
            XCTAssertEqual(a.min()!, 3)
        }
    }

    func testSum() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            XCTAssertEqual(a.sum(), 0)
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            XCTAssertEqual(a.sum(), 0)
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            XCTAssertEqual(a.sum(), 15)
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)[0... ~ 2]
            XCTAssertEqual(a.sum(), 6)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            XCTAssertEqual(a.sum(), 15)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            XCTAssertEqual(a.sum(), 15)
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)[1... ~ 2]
            XCTAssertEqual(a.sum(), 42)
        }
    }

    func testProduct() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            XCTAssertEqual(a.product(), 0)
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            XCTAssertEqual(a.product(), 0)
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(from: 1, to: 6)
            XCTAssertEqual(a.product(), 120)
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(from: 1, to: 7)[0... ~ 2]
            XCTAssertEqual(a.product(), 15)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(from: 1, to: 7).reshaped([2, 3], order: .C)
            XCTAssertEqual(a.product(), 720)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(from: 1, to: 7).reshaped([2, 3], order: .F)
            XCTAssertEqual(a.product(), 720)
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(from: 1, to: 4 * 3 + 1).reshaped([4, 3], order: .C)[1... ~ 2]
            XCTAssertEqual(a.product(), 158400)
        }
    }

    func testAddArrayInPlace() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            a += a
            XCTAssertEqual(a.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            a += a
            XCTAssertEqual(a.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            a += a
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).dataArray.map({ $0 * 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)
            a[0... ~ 2] += a[1... ~ 2]
            XCTAssertEqual(a.dataArray, [1, 1, 5, 3, 9, 5])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            a += a
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C).dataArray.map({ $0 * 2 }))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            a += a
            XCTAssertEqual(a.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F).dataArray.map({ $0 * 2 }))
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)
            a[0... ~ 2] += a[1... ~ 2]
            XCTAssertEqual(a.dataArray, [3, 5, 7, 3, 4, 5, 15, 17, 19, 9, 10, 11])
        }

    }

    func testSubtractArrayInPlace() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            a -= a
            XCTAssertEqual(a.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            a -= a
            XCTAssertEqual(a.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            a -= a
            XCTAssertEqual(a.dataArray, NdArray<Int>.zeros(6).dataArray)
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)
            a[0... ~ 2] -= a[1... ~ 2]
            XCTAssertEqual(a.dataArray, [-1, 1, -1, 3, -1, 5])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            a -= a
            XCTAssertEqual(a.dataArray, NdArray<Int>.zeros(6).reshaped([2, 3], order: .C).dataArray)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            a -= a
            XCTAssertEqual(a.dataArray, NdArray<Int>.zeros(6).reshaped([2, 3], order: .F).dataArray)
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)
            a[0... ~ 2] -= a[1... ~ 2]
            XCTAssertEqual(a.dataArray, [-3, -3, -3, 3, 4, 5, -3, -3, -3, 9, 10, 11])
        }
    }

    func testAddArray() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            let b = a + a
            XCTAssertEqual(b.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            let b = a + a
            XCTAssertEqual(b.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            let b = a + a
            XCTAssertEqual(b.dataArray, NdArray<Int>.range(to: 6).dataArray.map({ $0 * 2 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)
            let b = a[0... ~ 2] + a[1... ~ 2]
            XCTAssertEqual(b.dataArray, [1, 5, 9])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            let b = a + a
            XCTAssertEqual(b.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C).dataArray.map({ $0 * 2 }))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            let b = a + a
            XCTAssertEqual(b.dataArray, NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F).dataArray.map({ $0 * 2 }))
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)
            let b = a[0... ~ 2] + a[1... ~ 2]
            XCTAssertEqual(b.dataArray, [3, 5, 7, 15, 17, 19])
        }
    }

    func testSubtractArray() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            let b = a - a
            XCTAssertEqual(b.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            let b = a - a
            XCTAssertEqual(b.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            let b = a - a
            XCTAssertEqual(b.dataArray, NdArray<Int>.zeros(6).dataArray)
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)
            let b = a[0... ~ 2] - a[1... ~ 2]
            XCTAssertEqual(b.dataArray, [-1, -1, -1])
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            let b = a - a
            XCTAssertEqual(b.dataArray, NdArray<Int>.zeros(6).reshaped([2, 3], order: .C).dataArray)
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            let b = a - a
            XCTAssertEqual(b.dataArray, NdArray<Int>.zeros(6).reshaped([2, 3], order: .F).dataArray)
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)
            let b = a[0... ~ 2] - a[1... ~ 2]
            XCTAssertEqual(b.dataArray, [-3, -3, -3, -3, -3, -3])
        }
    }

    func testNegate() {
        // 0d
        do {
            let a = NdArray<Int>.zeros([])
            let b = -a
            XCTAssertEqual(b.shape, [])
        }
        // 2d effective 0d
        do {
            let a = NdArray<Int>.zeros([1, 0])
            let b = -a
            XCTAssertEqual(b.shape, [1, 0])
        }
        // 1d contiguous
        do {
            let a = NdArray<Int>.range(to: 6)
            let b = -a
            XCTAssertEqual(b.dataArray, NdArray<Int>.range(to: 6).dataArray.map({ -$0 }))
        }
        // 1d not aligned
        do {
            let a = NdArray<Int>.range(to: 6)
            let b = -a[0... ~ 2]
            XCTAssertEqual(b.dataArray, NdArray<Int>(copy: a[0... ~ 2]).map({ -$0 }).dataArray)
        }
        // 2d C contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .C)
            let b = -a
            XCTAssertEqual(b.dataArray, a.dataArray.map({ -$0 }))
        }
        // 2d F contiguous
        do {
            let a = NdArray<Int>.range(to: 6).reshaped([2, 3], order: .F)
            let b = -a
            XCTAssertEqual(b.dataArray, a.dataArray.map({ -$0 }))
        }
        // 2d not aligned
        do {
            let a = NdArray<Int>.range(to: 4 * 3).reshaped([4, 3], order: .C)
            let b = -a[0... ~ 2]
            XCTAssertEqual(b.dataArray, NdArray<Int>(copy: a[0... ~ 2]).map({ -$0 }).dataArray)
        }
    }

    func testAddScalarToArray() {
        let a = NdArray<Int>.range(to: 6)
        XCTAssertEqual((3 + a).dataArray, (a + 3).dataArray)
    }

    func testMultiplyScalarWithArray() {
        let a = NdArray<Int>.range(to: 6)
        XCTAssertEqual((3 * a).dataArray, (a * 3).dataArray)
    }
}
