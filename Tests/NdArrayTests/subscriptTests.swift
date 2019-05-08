//
// Created by Daniel Strobusch on 2019-05-03.
//

@testable import NdArray
import XCTest

class subscriptTests: XCTestCase {
    func testSubscriptShouldReturnElementWhenIndexed() {
        let a = NdArray<Double>([1, 2, 3])
        XCTAssertEqual(a[[0]], 1)
        XCTAssertEqual(a[[1]], 2)
        XCTAssertEqual(a[[2]], 3)
    }

    func testSubscriptShouldReturnElementWhenArrayIs2d() {
        let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]])
        XCTAssertEqual(a[[0, 0]], 1)
        XCTAssertEqual(a[[0, 1]], 2)
        XCTAssertEqual(a[[0, 2]], 3)
        XCTAssertEqual(a[[1, 0]], 4)
        XCTAssertEqual(a[[1, 1]], 5)
        XCTAssertEqual(a[[1, 2]], 6)
    }

    func testSubscriptShouldSetCorrectElementWhenArrayIs2d() {
        let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]])
        a[[0, 0]] = 42
        XCTAssertEqual(a[[0, 0]], 42)
        a[[1, 2]] = 43
        XCTAssertEqual(a[[1, 2]], 43)
    }

    func testSubscriptShouldReturnRowSliceWhen2dArray() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            let r0: NdArraySlice<Double> = a[0]
            XCTAssertEqual(r0.strides, [1])
            XCTAssertEqual(r0.shape, [3])
            XCTAssertEqual(r0[[0]], 1)
            XCTAssertEqual(r0[[1]], 2)
            XCTAssertEqual(r0[[2]], 3)
            let r1: NdArraySlice<Double> = a[1]
            XCTAssertEqual(r1.strides, [1])
            XCTAssertEqual(r1.shape, [3])
            XCTAssertEqual(r1[[0]], 4)
            XCTAssertEqual(r1[[1]], 5)
            XCTAssertEqual(r1[[2]], 6)
        }

        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)
            let r0: NdArraySlice<Double> = a[0]
            XCTAssertEqual(r0.strides, [2])
            XCTAssertEqual(r0.shape, [3])
            XCTAssertEqual(r0[[0]], 1)
            XCTAssertEqual(r0[[1]], 2)
            XCTAssertEqual(r0[[2]], 3)
            let r1: NdArraySlice<Double> = a[1]
            XCTAssertEqual(r1.strides, [2])
            XCTAssertEqual(r1.shape, [3])
            XCTAssertEqual(r1[[0]], 4)
            XCTAssertEqual(r1[[1]], 5)
            XCTAssertEqual(r1[[2]], 6)
        }
    }

    func testSubscriptShouldReturnColSliceWhen2dArray() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            let c0: NdArraySlice<Double> = a[...][0]
            XCTAssertEqual(c0.strides, [3])
            XCTAssertEqual(c0.shape, [2])
            XCTAssertEqual(c0[[0]], 1)
            XCTAssertEqual(c0[[1]], 4)
            let c1: NdArraySlice<Double> = a[...][1]
            XCTAssertEqual(c1.strides, [3])
            XCTAssertEqual(c1.shape, [2])
            XCTAssertEqual(c1[[0]], 2)
            XCTAssertEqual(c1[[1]], 5)
            let c2: NdArraySlice<Double> = a[...][2]
            XCTAssertEqual(c2.strides, [3])
            XCTAssertEqual(c2.shape, [2])
            XCTAssertEqual(c2[[0]], 3)
            XCTAssertEqual(c2[[1]], 6)
        }

        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)
            let c0: NdArraySlice<Double> = a[...][0]
            XCTAssertEqual(c0.strides, [1])
            XCTAssertEqual(c0.shape, [2])
            XCTAssertEqual(c0[[0]], 1)
            XCTAssertEqual(c0[[1]], 4)
            let c1: NdArraySlice<Double> = a[...][1]
            XCTAssertEqual(c1.strides, [1])
            XCTAssertEqual(c1.shape, [2])
            XCTAssertEqual(c1[[0]], 2)
            XCTAssertEqual(c1[[1]], 5)
            let c2: NdArraySlice<Double> = a[...][2]
            XCTAssertEqual(c2.strides, [1])
            XCTAssertEqual(c2.shape, [2])
            XCTAssertEqual(c2[[0]], 3)
            XCTAssertEqual(c2[[1]], 6)
        }
    }

    func testRangeSubscriptShouldReturnRowSlices() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            let b = a[0..<2]
            XCTAssertEqual(b.strides, a.strides)
            XCTAssertEqual(b.shape, a.shape)
            let r0: NdArraySlice<Double> = a[0..<1]
            XCTAssertEqual(r0.strides, [3, 1])
            XCTAssertEqual(r0.shape, [1, 3])
            XCTAssertEqual(r0[[0, 0]], 1)
            XCTAssertEqual(r0[[0, 1]], 2)
            XCTAssertEqual(r0[[0, 2]], 3)
            let r1: NdArraySlice<Double> = a[1..<2]
            XCTAssertEqual(r1.strides, [3, 1])
            XCTAssertEqual(r1.shape, [1, 3])
            XCTAssertEqual(r1[[0, 0]], 4)
            XCTAssertEqual(r1[[0, 1]], 5)
            XCTAssertEqual(r1[[0, 2]], 6)
        }

        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)
            let b = a[0..<2]
            XCTAssertEqual(b.strides, a.strides)
            XCTAssertEqual(b.shape, a.shape)
            let r0: NdArraySlice<Double> = a[0..<1]
            XCTAssertEqual(r0.strides, [1, 2])
            XCTAssertEqual(r0.shape, [1, 3])
            XCTAssertEqual(r0[[0, 0]], 1)
            XCTAssertEqual(r0[[0, 1]], 2)
            XCTAssertEqual(r0[[0, 2]], 3)
            let r1: NdArraySlice<Double> = a[1..<2]
            XCTAssertEqual(r1.strides, [1, 2])
            XCTAssertEqual(r1.shape, [1, 3])
            XCTAssertEqual(r1[[0, 0]], 4)
            XCTAssertEqual(r1[[0, 1]], 5)
            XCTAssertEqual(r1[[0, 2]], 6)
        }
    }

    func testRangeSubscriptShouldReturnColSlices() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            let b = a[...][0..<3]
            XCTAssertEqual(b.strides, a.strides)
            XCTAssertEqual(b.shape, a.shape)
            let r0: NdArraySlice<Double> = a[...][0..<1]
            XCTAssertEqual(r0.strides, [3, 1])
            XCTAssertEqual(r0.shape, [2, 1])
            XCTAssertEqual(r0[[0, 0]], 1)
            XCTAssertEqual(r0[[1, 0]], 4)
            let r1: NdArraySlice<Double> = a[...][1..<2]
            XCTAssertEqual(r1.strides, [3, 1])
            XCTAssertEqual(r1.shape, [2, 1])
            XCTAssertEqual(r1[[0, 0]], 2)
            XCTAssertEqual(r1[[1, 0]], 5)
            let r2: NdArraySlice<Double> = a[...][2..<3]
            XCTAssertEqual(r2.strides, [3, 1])
            XCTAssertEqual(r2.shape, [2, 1])
            XCTAssertEqual(r2[[0, 0]], 3)
            XCTAssertEqual(r2[[1, 0]], 6)
        }

        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)
            let b = a[...][0..<3]
            XCTAssertEqual(b.strides, a.strides)
            XCTAssertEqual(b.shape, a.shape)
            let r0: NdArraySlice<Double> = a[...][0..<1]
            XCTAssertEqual(r0.strides, [1, 2])
            XCTAssertEqual(r0.shape, [2, 1])
            XCTAssertEqual(r0[[0, 0]], 1)
            XCTAssertEqual(r0[[1, 0]], 4)
            let r1: NdArraySlice<Double> = a[...][1..<2]
            XCTAssertEqual(r1.strides, [1, 2])
            XCTAssertEqual(r1.shape, [2, 1])
            XCTAssertEqual(r1[[0, 0]], 2)
            XCTAssertEqual(r1[[1, 0]], 5)
            let r2: NdArraySlice<Double> = a[...][2..<3]
            XCTAssertEqual(r2.strides, [1, 2])
            XCTAssertEqual(r2.shape, [2, 1])
            XCTAssertEqual(r2[[0, 0]], 3)
            XCTAssertEqual(r2[[1, 0]], 6)
        }
    }

    func testPartialRangeSubscriptShouldReturnRowSlices() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            XCTAssertEqual(a[1...].shape, [1, 3])
            XCTAssertEqual(a[1...].strides, [3, 1])
            XCTAssertEqual(a[1...][[0, 0]], 4)

            XCTAssertEqual(a[...1].shape, [2, 3])
            XCTAssertEqual(a[...1].strides, [3, 1])
            XCTAssertEqual(a[...1][[0, 0]], 1)

            XCTAssertEqual(a[..<1].shape, [1, 3])
            XCTAssertEqual(a[..<1].strides, [3, 1])
            XCTAssertEqual(a[..<1][[0, 0]], 1)
        }

        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)
            XCTAssertEqual(a[1...].shape, [1, 3])
            XCTAssertEqual(a[1...].strides, [1, 2])
            XCTAssertEqual(a[1...][[0, 0]], 4)

            XCTAssertEqual(a[...1].shape, [2, 3])
            XCTAssertEqual(a[...1].strides, [1, 2])
            XCTAssertEqual(a[...1][[0, 0]], 1)

            XCTAssertEqual(a[..<1].shape, [1, 3])
            XCTAssertEqual(a[..<1].strides, [1, 2])
            XCTAssertEqual(a[..<1][[0, 0]], 1)
        }
    }

    func testPartialRangeSubscriptShouldReturnColSlices() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            XCTAssertEqual(a[...][1...].shape, [2, 2])
            XCTAssertEqual(a[...][1...].strides, [3, 1])
            XCTAssertEqual(a[...][1...][[0, 0]], 2)

            XCTAssertEqual(a[...][...1].shape, [2, 2])
            XCTAssertEqual(a[...][...1].strides, [3, 1])
            XCTAssertEqual(a[...][...1][[0, 0]], 1)

            XCTAssertEqual(a[...][..<1].shape, [2, 1])
            XCTAssertEqual(a[...][..<1].strides, [3, 1])
            XCTAssertEqual(a[...][..<1][[0, 0]], 1)
        }

        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)

            XCTAssertEqual(a[...][1...].shape, [2, 2])
            XCTAssertEqual(a[...][1...].strides, [1, 2])
            XCTAssertEqual(a[...][1...][[0, 0]], 2)

            XCTAssertEqual(a[...][...1].shape, [2, 2])
            XCTAssertEqual(a[...][...1].strides, [1, 2])
            XCTAssertEqual(a[...][...1][[0, 0]], 1)

            XCTAssertEqual(a[...][..<1].shape, [2, 1])
            XCTAssertEqual(a[...][..<1].strides, [1, 2])
            XCTAssertEqual(a[...][..<1][[0, 0]], 1)
        }
    }

    func testClosedRangeSubscriptShouldReturnRowSlices() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            XCTAssertEqual(a[1...2].shape, [1, 3])
            XCTAssertEqual(a[1...2].strides, [3, 1])
            XCTAssertEqual(a[1...2][[0, 0]], 4)

            XCTAssertEqual(a[1...3].shape, [1, 3])
            XCTAssertEqual(a[1...3].strides, [3, 1])
            XCTAssertEqual(a[1...3][[0, 0]], 4)
        }

        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)
            XCTAssertEqual(a[1...2].shape, [1, 3])
            XCTAssertEqual(a[1...2].strides, [1, 2])
            XCTAssertEqual(a[1...2][[0, 0]], 4)

            XCTAssertEqual(a[1...3].shape, [1, 3])
            XCTAssertEqual(a[1...3].strides, [1, 2])
            XCTAssertEqual(a[1...3][[0, 0]], 4)
        }
    }

    func testClosedRangeSubscriptShouldReturnColSlices() {
        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
            XCTAssertEqual(a[...][1..<2].shape, [2, 1])
            XCTAssertEqual(a[...][1..<2].strides, [3, 1])
            XCTAssertEqual(a[...][1..<2][[0, 0]], 2)
            XCTAssertEqual(a[...][1..<2][[1, 0]], 5)

            XCTAssertEqual(a[...][1...2].shape, [2, 2])
            XCTAssertEqual(a[...][1...2].strides, [3, 1])
            XCTAssertEqual(a[...][1...2][[0, 0]], 2)
            XCTAssertEqual(a[...][1...2][[0, 1]], 3)
            XCTAssertEqual(a[...][1...2][[1, 0]], 5)
            XCTAssertEqual(a[...][1...2][[1, 1]], 6)
        }

        do {
            let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .F)
            XCTAssertEqual(a[...][1..<2].shape, [2, 1])
            XCTAssertEqual(a[...][1..<2].strides, [1, 2])
            XCTAssertEqual(a[...][1..<2][[0, 0]], 2)
            XCTAssertEqual(a[...][1..<2][[1, 0]], 5)

            XCTAssertEqual(a[...][1...2].shape, [2, 2])
            XCTAssertEqual(a[...][1...2].strides, [1, 2])
            XCTAssertEqual(a[...][1...2][[0, 0]], 2)
            XCTAssertEqual(a[...][1...2][[0, 1]], 3)
            XCTAssertEqual(a[...][1...2][[1, 0]], 5)
            XCTAssertEqual(a[...][1...2][[1, 1]], 6)
        }
    }

    func testRangeSubscriptShouldEmptyShapeWhenRangeIsEmpty() {
        let a = NdArray<Double>([[1, 2, 3], [4, 5, 6]], order: .C)
        XCTAssertEqual(a[2..<2].shape, [0, 3])
        XCTAssertEqual(a[2..<2].count, 0)
        XCTAssertEqual(a[...][2..<2].shape, [2, 0])
        XCTAssertEqual(a[...][2..<2].count, 0)

        XCTAssertEqual(a[2...2].shape, [0, 3])
        XCTAssertEqual(a[2...2].count, 0)
        XCTAssertEqual(a[...][3...3].shape, [2, 0])
        XCTAssertEqual(a[...][3...3].count, 0)

    }

    func testStridesSliceAccessWhenRangeIsUnboundAndArray1d() {
        let a = NdArray<Double>([1, 2, 3, 4, 5, 6])
        XCTAssertEqual(a[..., 1].shape, [6])
        XCTAssertEqual(a[..., 1].strides, [1])

        XCTAssertEqual(a[..., 2].shape, [3])
        XCTAssertEqual(a[..., 2].strides, [2])

        XCTAssertEqual(a[..., 3].shape, [2])
        XCTAssertEqual(a[..., 3].strides, [3])

        XCTAssertEqual(a[..., 4].shape, [2])
        XCTAssertEqual(a[..., 4].strides, [4])

        XCTAssertEqual(a[..., 5].shape, [2])
        XCTAssertEqual(a[..., 5].strides, [5])

        XCTAssertEqual(a[..., 6].shape, [1])
        XCTAssertEqual(a[..., 6].strides, [6])

        XCTAssertEqual(a[..., 7].shape, [1])
        XCTAssertEqual(a[..., 7].strides, [7])
    }

    func testStridesSliceAccessWhenRangeIsPartialToAndArray1d() {
        let a = NdArray<Double>([1, 2, 3, 4, 5, 6])
        XCTAssertEqual(a[..<5, 1].shape, [5])
        XCTAssertEqual(a[..<5, 1].strides, [1])

        XCTAssertEqual(a[..<5, 2].shape, [3])
        XCTAssertEqual(a[..<5, 2].strides, [2])

        XCTAssertEqual(a[..<5, 3].shape, [2])
        XCTAssertEqual(a[..<5, 3].strides, [3])

        XCTAssertEqual(a[..<7, 3].shape, [2])
        XCTAssertEqual(a[..<7, 3].strides, [3])
    }

    func testStridesSliceAccessWhenRangeIsPartialThroughAndArray1d() {
        let a = NdArray<Double>([1, 2, 3, 4, 5, 6])
        XCTAssertEqual(a[...5, 1].shape, [6])
        XCTAssertEqual(a[...5, 1].strides, [1])

        XCTAssertEqual(a[...5, 2].shape, [3])
        XCTAssertEqual(a[...5, 2].strides, [2])

        XCTAssertEqual(a[...5, 3].shape, [2])
        XCTAssertEqual(a[...5, 3].strides, [3])

        XCTAssertEqual(a[...7, 3].shape, [2])
        XCTAssertEqual(a[...7, 3].strides, [3])
    }

    func testStridesSliceAccessWhenRangeIsClosedAndArray1d() {
        let a = NdArray<Double>([1, 2, 3, 4, 5, 6])
        XCTAssertEqual(a[1...5, 1].shape, [5])
        XCTAssertEqual(a[1...5, 1].strides, [1])
        XCTAssertEqual(a[1...5, 1][[0]], 2)
        XCTAssertEqual(a[1...5, 1][[1]], 3)

        XCTAssertEqual(a[1...5, 2].shape, [3])
        XCTAssertEqual(a[1...5, 2].strides, [2])
        XCTAssertEqual(a[1...5, 2][[0]], 2)
        XCTAssertEqual(a[1...5, 2][[1]], 4)

        XCTAssertEqual(a[2...5, 3].shape, [2])
        XCTAssertEqual(a[2...5, 3].strides, [3])
        XCTAssertEqual(a[2...5, 3][[0]], 3)
        XCTAssertEqual(a[2...5, 3][[1]], 6)

        XCTAssertEqual(a[2...7, 3].shape, [2])
        XCTAssertEqual(a[2...7, 3].strides, [3])
        XCTAssertEqual(a[2...7, 3][[0]], 3)
        XCTAssertEqual(a[2...7, 3][[1]], 6)
    }


    func testStridesSliceAccessWhenRangeIsPartialFromAndArray1d() {
        let a = NdArray<Double>([1, 2, 3, 4, 5, 6])
        XCTAssertEqual(a[0..., 1].shape, [6])
        XCTAssertEqual(a[0..., 1].strides, [1])

        XCTAssertEqual(a[1..., 2].shape, [3])
        XCTAssertEqual(a[1..., 2].strides, [2])
    }

    func testStridesSliceAccessWhenRangeAndArray1d() {
        let a = NdArray<Double>([1, 2, 3, 4, 5, 6])
        XCTAssertEqual(a[0..<1, 1].shape, [1])
        XCTAssertEqual(a[0..<1, 1].strides, [1])

        XCTAssertEqual(a[1..<5, 2].shape, [2])
        XCTAssertEqual(a[1..<5, 2].strides, [2])
        XCTAssertFalse(a[1..<5, 2].isContiguous)
    }

    func testSliceAssignmentWhenOverlap() {
        do {
            let a = NdArray<Double>(rangeTo: 6)
            let b = a[..., 2]
            a[1..., 2] = b
            XCTAssertEqual(a.dataArray, [0, 0, 2, 2, 4, 4])
        }
        do {
            let a = NdArray<Double>(rangeTo: 6)
            let b = a[1..<6]
            a[0..<5] = b
            XCTAssertEqual(a.dataArray, [1, 2, 3, 4, 5, 5])
        }
    }

    func testSliceAssignmentToRowOrCol() {
        do {
            let a = NdArray<Double>(zeros: [2, 2])
            let b = NdArray<Double>(ones: [2, 2])
            a[0][...] = b[0][...]
            XCTAssertEqual(a.dataArray, [1, 1, 0, 0])
        }
        do {
            let a = NdArray<Double>(zeros: [2, 2])
            let b = NdArray<Double>(ones: [2, 2])
            a[0] = b[0]
            XCTAssertEqual(a.dataArray, [1, 1, 0, 0])
        }
        do {
            let a = NdArray<Double>(zeros: [2, 2])
            let b = NdArray<Double>(ones: [2, 2])
            a[0] = b[0][...]
            XCTAssertEqual(a.dataArray, [1, 1, 0, 0])
        }
        do {
            let a = NdArray<Double>(zeros: [2, 2])
            let b = NdArray<Double>(ones: [2, 2])
            a[...][0] = b[...][0]
            XCTAssertEqual(a.dataArray, [1, 0, 1, 0])
        }

        do {
            let a = NdArray<Double>(zeros: [2, 2], order: .F)
            let b = NdArray<Double>(ones: [2, 2])
            a[0][...] = b[0][...]
            XCTAssertEqual(a.dataArray, [1, 0, 1, 0])
        }
        do {
            let a = NdArray<Double>(zeros: [2, 2], order: .F)
            let b = NdArray<Double>(ones: [2, 2])
            a[0][...] = b[0]
            XCTAssertEqual(a.dataArray, [1, 0, 1, 0])
        }
        do {
            let a = NdArray<Double>(zeros: [2, 2], order: .F)
            let b = NdArray<Double>(ones: [2, 2])
            a[0] = b[0][...]
            XCTAssertEqual(a.dataArray, [1, 0, 1, 0])
        }
        do {
            let a = NdArray<Double>(zeros: [2, 2], order: .F)
            let b = NdArray<Double>(ones: [2, 2])
            a[0] = b[0]
            XCTAssertEqual(a.dataArray, [1, 0, 1, 0])
        }
        do {
            let a = NdArray<Double>(zeros: [2, 2], order: .F)
            let b = NdArray<Double>(ones: [2, 2])
            a[...][0] = b[...][0]
            XCTAssertEqual(a.dataArray, [1, 1, 0, 0])
        }
    }

    func testSliceAssignment3d() {
        do {
            let a = NdArray<Double>(rangeTo: 3 * 4 * 5).reshaped([3, 4, 5])
            let b = NdArray<Double>(ones: 3 * 4 * 5).reshaped([3, 4, 5])
            a[...][0][...] = b[...][1][...]
            XCTAssertEqual(NdArray(copy: a[...][0]).dataArray, NdArray(copy: b[...][1]).dataArray)
            print(a)
        }
        do {
            let a = NdArray<Double>(rangeTo: 3 * 4 * 5).reshaped([3, 4, 5])
            let b = NdArray<Double>(ones: 3 * 4 * 5).reshaped([3, 4, 5])
            a[...][..., 2][...] = b[...][..., 2][...]
            XCTAssertEqual(NdArray(copy: a[...][..., 2]).dataArray, NdArray(copy: b[...][..., 2]).dataArray)
            print(a)
        }
    }

    func testSliceAccesst3d() {
        do {
            let a = NdArray<Int>(rangeTo: 2 * 2 * 3).reshaped([2, 2, 3])
            XCTAssertEqual(NdArray(copy: a[0], order: .C).dataArray, [0, 1, 2, 3, 4, 5])
        }

        do {
            let a = NdArray<Int>(NdArray<Int>(rangeTo: 2 * 2 * 3).reshaped([2, 2, 3]), order: .F)
            XCTAssertEqual(NdArray(copy: a[0], order: .C).dataArray, [0, 1, 2, 3, 4, 5])
        }
    }
}
