import XCTest
import Darwin
@testable import NdArray

class PermutationTests: XCTestCase {
    func testPermutationVector() {
        do {
            let p = permutationVector(n: 4, ipiv: Vector([3, 2, 3, 4]))
            XCTAssertEqual(p, Vector([2, 1, 0, 3]))
        }
        do {
            let p = permutationVector(n: 4, ipiv: Vector([2]))
            XCTAssertEqual(p, Vector([1, 0, 2, 3]))
        }
    }

    func testPermutationMatrix() {
        do {
            let P: NdArray<Double> = permutationMatrix(n: 4, ipiv: Vector([3, 2, 3, 4]))
            XCTAssertEqual(P, Matrix([
                [0, 0, 1, 0],
                [0, 1, 0, 0],
                [1, 0, 0, 0],
                [0, 0, 0, 1]
            ]
            ))
        }
        do {
            let P: NdArray<Double> = permutationMatrix(n: 4, ipiv: Vector([2]))
            XCTAssertEqual(P, Matrix([
                [0, 1, 0, 0],
                [1, 0, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
            ]
            ))
        }
    }
}
