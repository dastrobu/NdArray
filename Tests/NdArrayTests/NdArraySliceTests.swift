//
// Created by Daniel Strobusch on 2019-05-11.
//

import XCTest
@testable import NdArray

class NdArraySliceTests: XCTestCase {

    func testDebugDescription() {
        let a = NdArraySlice(NdArray<Double>.zeros([2, 3, 4]), sliced: 0)
        XCTAssert(a.debugDescription.contains("NdArraySlice(-, "))
    }

}
