import XCTest
@testable import NdArray

// swiftlint:disable:next type_name
class initTests: XCTestCase {
    func testInitShouldConstructContiguousArrayWhenInitializedFrom2dArrays() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            XCTAssertEqual(a.dataArray, [1, 2, 3, 4, 5, 6])
            XCTAssertEqual(a.strides, [3, 1])
            XCTAssertTrue(a.isCContiguous)
            XCTAssertFalse(a.isFContiguous)
        }

        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)
            XCTAssertEqual(a.dataArray, [1, 4, 2, 5, 3, 6])
            XCTAssertEqual(a.strides, [1, 2])
            XCTAssertTrue(a.isFContiguous)
            XCTAssertFalse(a.isCContiguous)
        }
    }

    func testInit1dShouldCreateContiguousArray() {
        let a = NdArray<Double>([1, 2, 3])
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [1, 2, 3])
        XCTAssertEqual(a.shape, [3])
        XCTAssertEqual(a.strides, [1])
        XCTAssert(a.isCContiguous)
        XCTAssert(a.isFContiguous)
    }

    func testInit1dShouldCreateEmptyArray() {
        let a = NdArray<Double>([])
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [])
        XCTAssertEqual(a.shape, [0])
        XCTAssertEqual(a.strides, [1])
        XCTAssert(a.isCContiguous)
        XCTAssert(a.isFContiguous)
    }

    func testInit2dShouldCreateContiguousArray() {
        let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]])
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(a.shape, [2, 3])
        XCTAssertEqual(a.strides, [3, 1])
        XCTAssert(a.isCContiguous)
        XCTAssertFalse(a.isFContiguous)
    }

    func testInit2dShouldCreateEmptyArray() {
        let a = NdArray<Double>([[Double]]())
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [])
        XCTAssertEqual(a.shape, [1, 0])
        XCTAssertEqual(a.strides, [1, 1])
        XCTAssert(a.isCContiguous)
        XCTAssert(a.isFContiguous)
    }

    func testInit3dShouldCreateEmptyArray() {
        let a = NdArray<Double>([[[Double]]]())
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [])
        XCTAssertEqual(a.shape, [1, 1, 0])
        XCTAssertEqual(a.strides, [1, 1, 1])
        XCTAssert(a.isCContiguous)
        XCTAssert(a.isFContiguous)
    }

    func testInit3dShouldCreateCContiguousArray() {
        let a = NdArray<Double>(
            [[[ 0, 1, 2],
              [ 3, 4, 5]],

            [[ 6, 07, 08],
             [ 9, 10, 11]]])
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
        XCTAssertEqual(a.shape, [2, 2, 3])
        XCTAssertEqual(a.strides, [6, 3, 1])
        XCTAssert(a.isCContiguous)
        XCTAssertFalse(a.isFContiguous)
    }

    func testInit3dShouldCreateFContiguousArray() {
        let a = NdArray<Double>(
            [[[ 0, 1, 2],
              [ 3, 4, 5]],

                [[ 6, 07, 08],
                 [ 9, 10, 11]]], order: .F)
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [ 0, 6, 3, 9, 1, 7, 4, 10, 2, 8, 5, 11])
        XCTAssertEqual(a.shape, [2, 2, 3])
        XCTAssertEqual(a.strides, [1, 2, 4])
        XCTAssertFalse(a.isCContiguous)
        XCTAssert(a.isFContiguous)
    }

    func testInitZeros1dShouldCreateZerosArray() {
        do {
            let a = NdArray<Double>.zeros(3)
            XCTAssertEqual(a.dataArray, [0, 0, 0])
            XCTAssertEqual(a.shape, [3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Float>.zeros(3)
            XCTAssertEqual(a.dataArray, [0, 0, 0])
            XCTAssertEqual(a.shape, [3])
            XCTAssert(a.isCContiguous)
        }
    }

    func testInitOnes1dShouldCreateZerosArray() {
        do {
            let a = NdArray<Double>.ones(3)
            XCTAssertEqual(a.dataArray, [1, 1, 1])
            XCTAssertEqual(a.shape, [3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Float>.ones(3)
            XCTAssertEqual(a.dataArray, [1, 1, 1])
            XCTAssertEqual(a.shape, [3])
            XCTAssert(a.isCContiguous)
        }
    }

    func testInitRepeating1dShouldCreateZerosArray() {
        do {
            let a = NdArray<Double>.repeating(3, count: 3)
            XCTAssertEqual(a.dataArray, [3, 3, 3])
            XCTAssertEqual(a.shape, [3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Float>.repeating(3, count: 3)
            XCTAssertEqual(a.dataArray, [3, 3, 3])
            XCTAssertEqual(a.shape, [3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Int>.repeating(3, count: 3)
            XCTAssertEqual(a.dataArray, [3, 3, 3])
            XCTAssertEqual(a.shape, [3])
            XCTAssert(a.isCContiguous)
        }
    }

    func testInitZeros2dShouldCreateZerosArray() {
        do {
            let a = NdArray<Double>.zeros([2, 3], order: .C)
            XCTAssertEqual(a.dataArray, [0, 0, 0, 0, 0, 0])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Double>.zeros([2, 3], order: .F)
            XCTAssertEqual(a.dataArray, [0, 0, 0, 0, 0, 0])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isFContiguous)
        }
        do {
            let a = NdArray<Float>.zeros([2, 3], order: .C)
            XCTAssertEqual(a.dataArray, [0, 0, 0, 0, 0, 0])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Float>.zeros([2, 3], order: .F)
            XCTAssertEqual(a.dataArray, [0, 0, 0, 0, 0, 0])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isFContiguous)
        }
    }

    func testInitOnes2dShouldCreateZerosArray() {
        do {
            let a = NdArray<Double>.ones([2, 3], order: .C)
            XCTAssertEqual(a.dataArray, [1, 1, 1, 1, 1, 1])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Double>.ones([2, 3], order: .F)
            XCTAssertEqual(a.dataArray, [1, 1, 1, 1, 1, 1])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isFContiguous)
        }
        do {
            let a = NdArray<Float>.ones([2, 3], order: .C)
            XCTAssertEqual(a.dataArray, [1, 1, 1, 1, 1, 1])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Float>.ones([2, 3], order: .F)
            XCTAssertEqual(a.dataArray, [1, 1, 1, 1, 1, 1])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isFContiguous)
        }
    }

    func testInitRepeating2dShouldCreateZerosArray() {
        do {
            let a = NdArray<Double>.repeating(3, shape: [2, 3], order: .C)
            XCTAssertEqual(a.dataArray, [3, 3, 3, 3, 3, 3])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Double>.repeating(3, shape: [2, 3], order: .F)
            XCTAssertEqual(a.dataArray, [3, 3, 3, 3, 3, 3])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isFContiguous)
        }

        do {
            let a = NdArray<Float>.repeating(3, shape: [2, 3], order: .C)
            XCTAssertEqual(a.dataArray, [3, 3, 3, 3, 3, 3])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Float>.repeating(3, shape: [2, 3], order: .F)
            XCTAssertEqual(a.dataArray, [3, 3, 3, 3, 3, 3])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isFContiguous)
        }
        do {
            let a = NdArray<Int>.repeating(3, shape: [2, 3], order: .C)
            XCTAssertEqual(a.dataArray, [3, 3, 3, 3, 3, 3])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isCContiguous)
        }
        do {
            let a = NdArray<Int>.repeating(3, shape: [2, 3], order: .F)
            XCTAssertEqual(a.dataArray, [3, 3, 3, 3, 3, 3])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssert(a.isFContiguous)
        }
    }

    func testInitShouldCreateCContiguousViewWhenSourceIsCContiguous() {
        let a = NdArray<Double>.range(to: 5)
        let b = NdArray<Double>(a, order: .C)
        XCTAssertEqual(a.dataArray, b.dataArray)
        XCTAssert(a.ownsData)
        XCTAssertFalse(b.ownsData)
        XCTAssert(a.isCContiguous)
        XCTAssert(b.isCContiguous)
    }

    func testInitShouldCreateCContiguousViewWhenSourceIsNotCContiguous() {
        let a = NdArray<Double>.range(to: 5)[0... ~ 2]
        let b = NdArray<Double>(a, order: .C)
        XCTAssert(b.ownsData)
        XCTAssert(b.ownsData)
        XCTAssertFalse(a.isCContiguous)
        XCTAssert(b.isCContiguous)
    }

    func testInitShouldCreateFContiguousViewWhenSourceIsCContiguous() {
        let a = NdArray<Double>.range(to: 5)
        let b = NdArray<Double>(a, order: .F)
        XCTAssertEqual(a.dataArray, b.dataArray)
        XCTAssert(a.ownsData)
        XCTAssertFalse(b.ownsData)
        XCTAssert(a.isCContiguous)
        XCTAssert(b.isCContiguous)
    }

    func testInitShouldCreateFContiguousViewWhenSourceIsNotCContiguous() {
        let a = NdArray<Double>.range(to: 5)[0... ~ 2]
        let b = NdArray<Double>(a, order: .F)
        XCTAssert(b.ownsData)
        XCTAssert(b.ownsData)
        XCTAssertFalse(a.isCContiguous)
        XCTAssert(b.isCContiguous)
    }

    func testInitShouldCreateCContiguousCopyWhenSourceIsCContiguous() {
        let a = NdArray<Double>.range(to: 5)
        let b = NdArray<Double>(copy: a, order: .C)
        XCTAssertEqual(a.dataArray, b.dataArray)
        XCTAssert(a.ownsData)
        XCTAssert(b.ownsData)
        XCTAssert(a.isCContiguous)
        XCTAssert(b.isCContiguous)
    }

    func testInitShouldCreateCContiguousCopyWhenSourceIsNotCContiguous() {
        let a = NdArray<Double>.range(to: 5)[0... ~ 2]
        let b = NdArray<Double>(copy: a, order: .C)
        XCTAssert(b.ownsData)
        XCTAssert(b.ownsData)
        XCTAssertFalse(a.isCContiguous)
        XCTAssert(b.isCContiguous)
    }

    func testInitShouldCreateFContiguousCopyWhenSourceIsCContiguous() {
        let a = NdArray<Double>.range(to: 5)
        let b = NdArray<Double>(copy: a, order: .F)
        XCTAssertEqual(a.dataArray, b.dataArray)
        XCTAssert(a.ownsData)
        XCTAssert(b.ownsData)
        XCTAssert(a.isCContiguous)
        XCTAssert(b.isCContiguous)
    }

    func testInitShouldCreateFContiguousCopyWhenSourceIsNotCContiguous() {
        let a = NdArray<Double>.range(to: 5)[0... ~ 2]
        let b = NdArray<Double>(copy: a, order: .F)
        XCTAssert(b.ownsData)
        XCTAssert(b.ownsData)
        XCTAssertFalse(a.isCContiguous)
        XCTAssert(b.isCContiguous)
    }

    func testRangeShouldCreateHalfOpenIntervalWhenTypeIsDouble() {
        XCTAssertEqual(NdArray<Double>.range(to: 3).dataArray, [0, 1, 2])
        XCTAssertEqual(NdArray<Double>.range(from: 1, to: 3).dataArray, [1, 2])
        XCTAssertEqual(NdArray<Double>.range(from: 1, to: 3, by: 2).dataArray, [1])

        XCTAssertEqual(NdArray<Double>.range(to: 3, by: 0.7).dataArray, [0.0, 0.7, 1.4, 2.1, 2.8], accuracy: 1e-15)
        XCTAssertEqual(NdArray<Double>.range(to: 3, by: 1.1).dataArray, [0.0, 1.1, 2.2], accuracy: 1e-15)

        XCTAssertEqual(NdArray<Double>.range(to: 3, by: -1).dataArray, [])
        XCTAssertEqual(NdArray<Double>.range(from: 3, to: 0, by: 1).dataArray, [])

        XCTAssertEqual(NdArray<Double>.range(from: 3, to: 0, by: -1).dataArray, [3, 2, 1])
        XCTAssertEqual(NdArray<Double>.range(from: 3, to: 0, by: -1.1).dataArray, [3.0, 1.9, 0.8], accuracy: 1e-15)
        XCTAssertEqual(NdArray<Double>.range(from: 3, to: 0, by: -0.7).dataArray, [3.0, 2.3, 1.6, 0.9, 0.2], accuracy: 1e-15)
    }

    func testRangeShouldCreateHalfOpenIntervalWhenTypeIsFloat() {
        XCTAssertEqual(NdArray<Float>.range(to: 3).dataArray, [0, 1, 2])
        XCTAssertEqual(NdArray<Float>.range(from: 1, to: 3).dataArray, [1, 2])
        XCTAssertEqual(NdArray<Float>.range(from: 1, to: 3, by: 2).dataArray, [1])

        XCTAssertEqual(NdArray<Float>.range(to: 3, by: 0.7).dataArray, [0.0, 0.7, 1.4, 2.1, 2.8], accuracy: 1e-6)
        XCTAssertEqual(NdArray<Float>.range(to: 3, by: 1.1).dataArray, [0.0, 1.1, 2.2], accuracy: 1e-6)

        XCTAssertEqual(NdArray<Float>.range(to: 3, by: -1).dataArray, [])
        XCTAssertEqual(NdArray<Float>.range(from: 3, to: 0, by: 1).dataArray, [])

        XCTAssertEqual(NdArray<Float>.range(from: 3, to: 0, by: -1).dataArray, [3, 2, 1])
        XCTAssertEqual(NdArray<Float>.range(from: 3, to: 0, by: -1.1).dataArray, [3.0, 1.9, 0.8], accuracy: 1e-6)
        XCTAssertEqual(NdArray<Float>.range(from: 3, to: 0, by: -0.7).dataArray, [3.0, 2.3, 1.6, 0.9, 0.2], accuracy: 1e-6)
    }
}
