import XCTest
import Darwin
@testable import NdArray

class LuTestsFloat: XCTestCase {
    func testLuUnit() throws {
        let a = Matrix<Float>([
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
        ])
        let (p, l, u) = try a.lu()
        XCTAssertEqual((p * l * u).dataArray, a.dataArray, accuracy: 1e-15)

        XCTAssertEqual(p.dataArray, Matrix<Float>([
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
        ], order: .F).dataArray, accuracy: 1e-15)
        XCTAssertEqual(l.dataArray, Matrix<Float>([
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
        ], order: .F).dataArray, accuracy: 1e-15)
        XCTAssertEqual(u.dataArray, Matrix<Float>([
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
        ], order: .F).dataArray, accuracy: 1e-15)
    }

    func testLuWide() throws {
        let a = Matrix<Float>([
            [1, 2, 3],
            [4, 5, 6],
        ])
        let (p, l, u) = try a.lu()

        XCTAssertEqual((p * l * u).dataArray, a.dataArray, accuracy: 1e-15)

        XCTAssertEqual(p.dataArray, Matrix<Float>([
            [0.0, 1.0],
            [1.0, 0.0]
        ], order: .F).dataArray, accuracy: 1e-15)
        XCTAssertEqual(l.dataArray, Matrix<Float>([
            [1.0, 0.0],
            [0.25, 1.0]
        ], order: .F).dataArray, accuracy: 1e-15)
        XCTAssertEqual(u.dataArray, Matrix<Float>([
            [4.0, 5.0, 6.0],
            [0.0, 0.75, 1.5]
        ], order: .F).dataArray, accuracy: 1e-15)
    }
}
