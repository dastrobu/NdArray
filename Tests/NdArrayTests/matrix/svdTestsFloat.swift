import XCTest
import Darwin
@testable import NdArray

class SvdTestsFloat: XCTestCase {
    func testSvdUnit() throws {
        let a = Matrix<Float>([
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
        ])
        let (U, s, Vt) = try a.svd()
        let S = Matrix(diag: s)
        XCTAssertEqual((U * S * Vt).dataArray, a.dataArray, accuracy: 1e-15)

        XCTAssertEqual(U.dataArray, Matrix<Float>([
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
        ], order: .F).dataArray, accuracy: 1e-15)
        XCTAssertEqual(S.dataArray, Matrix<Float>([
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
        ], order: .F).dataArray, accuracy: 1e-15)
        XCTAssertEqual(Vt.dataArray, Matrix<Float>([
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
        ], order: .F).dataArray, accuracy: 1e-15)
    }

    func testSvdWide() throws {
        let a = Matrix<Float>([
            [1, 2, 3],
            [4, 5, 6],
        ])
        let (U, s, Vt) = try a.svd()
        let Sd = Matrix(diag: s)
        let S = Matrix<Float>.zeros(a.shape)
        let mn = a.shape.min()!
        S[..<mn, ..<mn] = Sd
        print("a")
        print(a)
        print("U * S * Vt")
        print(U * S * Vt)
        XCTAssertEqual(NdArray(U * S * Vt, order: .C).dataArray, a.dataArray, accuracy: 1e-5)

        print("U")
        print(U)
        XCTAssertEqual(U.dataArray, Matrix<Float>([
            [-0.3863177, -0.92236578],
            [-0.92236578, 0.3863177]
        ], order: .F).dataArray, accuracy: 1e-5)
        print("s")
        print(s)
        XCTAssertEqual(s.dataArray, Matrix<Float>([[9.508032, 0.77286964]]).dataArray, accuracy: 1e-5)
        print("Vt")
        print(Vt)
        XCTAssertEqual(Vt.dataArray, Matrix<Float>([
            [-0.42866713, -0.56630692, -0.7039467],
            [0.80596391, 0.11238241, -0.58119908],
            [0.40824829, -0.81649658, 0.40824829],
        ], order: .F).dataArray, accuracy: 1e-5)
    }

    func testSvdTall() throws {
        let a = Matrix<Float>([
            [1, 2],
            [3, 4],
            [5, 6],
        ])
        let (U, s, Vt) = try a.svd()
        let Sd = Matrix(diag: s)
        let S = Matrix<Float>.zeros(a.shape)
        let mn = a.shape.min()!
        S[..<mn, ..<mn] = Sd
        print("a")
        print(a)
        print("U * S * Vt")
        print(U * S * Vt)
        XCTAssertEqual(NdArray(U * S * Vt, order: .C).dataArray, a.dataArray, accuracy: 1e-5)

        print("U")
        print(U)
        XCTAssertEqual(U.dataArray, Matrix<Float>([
            [-0.2298477, 0.88346102, 0.40824829],
            [-0.52474482, 0.24078249, -0.81649658],
            [-0.81964194, -0.40189603, 0.40824829]
        ], order: .F).dataArray, accuracy: 1e-5)
        print("s")
        print(s)
        XCTAssertEqual(s.dataArray, Matrix<Float>([[9.52551809, 0.51430058]]).dataArray, accuracy: 1e-5)
        print("Vt")
        print(Vt)
        XCTAssertEqual(Vt.dataArray, Matrix<Float>([
            [-0.61962948, -0.78489445],
            [-0.78489445, 0.61962948],
        ], order: .F).dataArray, accuracy: 1e-5)
    }
}
