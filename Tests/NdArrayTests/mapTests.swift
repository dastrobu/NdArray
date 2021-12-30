//
// Created by Daniel Strobusch on 2019-05-11.
//

import XCTest
@testable import NdArray

// swiftlint:disable:next type_name
class mapTests: XCTestCase {
    func testMap() {
        do {
            let a = NdArray<Double>.zeros([2, 3])
            let b = NdArray<Double>(copy: a)
            let c = a.map {
                $0 * 2
            }
            b *= 2
            XCTAssertEqual(c.dataArray, b.dataArray)
        }
        do {
            let a = NdArray<Double>.zeros([2, 3])[0... ~ 2]
            let b = NdArray<Double>(copy: a)
            let c: NdArray<Double> = a.map {
                $0 * 2
            }
            b *= 2
            XCTAssertEqual(c.dataArray, b.dataArray)
        }
    }
}
