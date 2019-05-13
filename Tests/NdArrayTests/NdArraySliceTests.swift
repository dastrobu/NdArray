//
// Created by Daniel Strobusch on 2019-05-11.
//

import XCTest
@testable import NdArray

class NdArraySliceTests: XCTestCase {

    func testDebugDescription() {
        let a = NdArraySlice(NdArray<Double>.zeros([2, 3, 4]), sliced: 0)
        XCTAssert(a.debugDescription.contains("NdArraySlice(-, "))

        // 1d
        XCTAssert(a[...].debugDescription.contains("[...]"))
        XCTAssert(a[...2].debugDescription.contains("[...2]"))
        XCTAssert(a[..<2].debugDescription.contains("[..<2]"))
        XCTAssert(a[1...2].debugDescription.contains("[1...2]"))
        XCTAssert(a[1..<2].debugDescription.contains("[1..<2]"))

        // 2d
        XCTAssert(a[...][...].debugDescription.contains("[...][...]"))
        XCTAssert(a[...][...2].debugDescription.contains("[...][...2]"))
        XCTAssert(a[...][..<2].debugDescription.contains("[...][..<2]"))
        XCTAssert(a[...][1...2].debugDescription.contains("[...][1...2]"))
        XCTAssert(a[...][1..<2].debugDescription.contains("[...][1..<2]"))

        XCTAssert(a[...2][...].debugDescription.contains("[...2][...]"))
        XCTAssert(a[...2][...2].debugDescription.contains("[...2][...2]"))
        XCTAssert(a[...2][..<2].debugDescription.contains("[...2][..<2]"))
        XCTAssert(a[...2][1...2].debugDescription.contains("[...2][1...2]"))
        XCTAssert(a[...2][1..<2].debugDescription.contains("[...2][1..<2]"))

        XCTAssert(a[..<2][...].debugDescription.contains("[..<2][...]"))
        XCTAssert(a[..<2][...2].debugDescription.contains("[..<2][...2]"))
        XCTAssert(a[..<2][..<2].debugDescription.contains("[..<2][..<2]"))
        XCTAssert(a[..<2][1...2].debugDescription.contains("[..<2][1...2]"))
        XCTAssert(a[..<2][1..<2].debugDescription.contains("[..<2][1..<2]"))

        XCTAssert(a[1...2][...].debugDescription.contains("[1...2][...]"))
        XCTAssert(a[1...2][...2].debugDescription.contains("[1...2][...2]"))
        XCTAssert(a[1...2][..<2].debugDescription.contains("[1...2][..<2]"))
        XCTAssert(a[1...2][1...2].debugDescription.contains("[1...2][1...2]"))
        XCTAssert(a[1...2][1..<2].debugDescription.contains("[1...2][1..<2]"))

        XCTAssert(a[1..<2][...].debugDescription.contains("[1..<2][...]"))
        XCTAssert(a[1..<2][...2].debugDescription.contains("[1..<2][...2]"))
        XCTAssert(a[1..<2][..<2].debugDescription.contains("[1..<2][..<2]"))
        XCTAssert(a[1..<2][1...2].debugDescription.contains("[1..<2][1...2]"))
        XCTAssert(a[1..<2][1..<2].debugDescription.contains("[1..<2][1..<2]"))

        // 1d strided
        XCTAssert(a[..., 2].debugDescription.contains("[..., 2]"))
        XCTAssert(a[...2, 2].debugDescription.contains("[...2, 2]"))
        XCTAssert(a[..<2, 2].debugDescription.contains("[..<2, 2]"))
        XCTAssert(a[1...2, 2].debugDescription.contains("[1...2, 2]"))
        XCTAssert(a[1..<2, 2].debugDescription.contains("[1..<2, 2]"))

        // 2d strided
        XCTAssert(a[..., 2][..., 2].debugDescription.contains("[..., 2][..., 2]"))
        XCTAssert(a[..., 2][...2, 2].debugDescription.contains("[..., 2][...2, 2]"))
        XCTAssert(a[..., 2][..<2, 2].debugDescription.contains("[..., 2][..<2, 2]"))
        XCTAssert(a[..., 2][1...2, 2].debugDescription.contains("[..., 2][1...2, 2]"))
        XCTAssert(a[..., 2][1..<2, 2].debugDescription.contains("[..., 2][1..<2, 2]"))

        XCTAssert(a[...2, 2][..., 2].debugDescription.contains("[...2, 2][..., 2]"))
        XCTAssert(a[...2, 2][...2, 2].debugDescription.contains("[...2, 2][...2, 2]"))
        XCTAssert(a[...2, 2][..<2, 2].debugDescription.contains("[...2, 2][..<2, 2]"))
        XCTAssert(a[...2, 2][1...2, 2].debugDescription.contains("[...2, 2][1...2, 2]"))
        XCTAssert(a[...2, 2][1..<2, 2].debugDescription.contains("[...2, 2][1..<2, 2]"))

        XCTAssert(a[..<2, 2][..., 2].debugDescription.contains("[..<2, 2][..., 2]"))
        XCTAssert(a[..<2, 2][...2, 2].debugDescription.contains("[..<2, 2][...2, 2]"))
        XCTAssert(a[..<2, 2][..<2, 2].debugDescription.contains("[..<2, 2][..<2, 2]"))
        XCTAssert(a[..<2, 2][1...2, 2].debugDescription.contains("[..<2, 2][1...2, 2]"))
        XCTAssert(a[..<2, 2][1..<2, 2].debugDescription.contains("[..<2, 2][1..<2, 2]"))

        XCTAssert(a[1...2, 2][..., 2].debugDescription.contains("[1...2, 2][..., 2]"))
        XCTAssert(a[1...2, 2][...2, 2].debugDescription.contains("[1...2, 2][...2, 2]"))
        XCTAssert(a[1...2, 2][..<2, 2].debugDescription.contains("[1...2, 2][..<2, 2]"))
        XCTAssert(a[1...2, 2][1...2, 2].debugDescription.contains("[1...2, 2][1...2, 2]"))
        XCTAssert(a[1...2, 2][1..<2, 2].debugDescription.contains("[1...2, 2][1..<2, 2]"))

        XCTAssert(a[1..<2, 2][..., 2].debugDescription.contains("[1..<2, 2][..., 2]"))
        XCTAssert(a[1..<2, 2][...2, 2].debugDescription.contains("[1..<2, 2][...2, 2]"))
        XCTAssert(a[1..<2, 2][..<2, 2].debugDescription.contains("[1..<2, 2][..<2, 2]"))
        XCTAssert(a[1..<2, 2][1...2, 2].debugDescription.contains("[1..<2, 2][1...2, 2]"))
        XCTAssert(a[1..<2, 2][1..<2, 2].debugDescription.contains("[1..<2, 2][1..<2, 2]"))
    }

}
