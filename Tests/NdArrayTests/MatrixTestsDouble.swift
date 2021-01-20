import XCTest
import Foundation
@testable import NdArray

class MatrixTestsDouble: XCTestCase {
    func testInit2dShouldCreateContiguousArray() {
        let a = Matrix<Double>([[1, 2, 3], [4, 5, 6]])
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(a.shape, [2, 3])
        XCTAssertEqual(a.strides, [3, 1])
        XCTAssert(a.isCContiguous)
        XCTAssertFalse(a.isFContiguous)
    }

    func testInit2dShouldCreateEmptyArray() {
        let a = Matrix<Double>([[Double]]())
        XCTAssert(a.ownsData)
        XCTAssertEqual(a.dataArray, [])
        XCTAssertEqual(a.shape, [1, 0])
        XCTAssertEqual(a.strides, [1, 1])
        XCTAssert(a.isCContiguous)
        XCTAssert(a.isFContiguous)
    }

    func testReshape() {
        let a = Matrix<Double>(empty: 3 * 2)
        XCTAssertEqual(a.shape, [1, 6])
        XCTAssertEqual(a.reshaped([2, 3]).shape, [2, 3])
    }

    func testTransposedView() {
        // 2d effective 0d
        do {
            let a = Matrix<Double>.zeros([1, 0])
            XCTAssertEqual(a.transposed().shape, [1, 0])
        }
        // 2d C contiguous
        do {
            let a = Matrix<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3], order: .C))
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [3, 1])
            XCTAssertEqual(a.transposed().strides, [1, 3])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>.range(to: 6).dataArray)
        }
        // 2d F contiguous
        do {
            let a = Matrix<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3], order: .F))
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [1, 2])
            XCTAssertEqual(a.transposed().strides, [2, 1])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>(NdArray<Double>.range(to: 6), order: .F).dataArray)
        }
        // 2d not aligned
        do {
            let a = Matrix(NdArray<Double>.range(to: 4 * 3).reshaped([4, 3], order: .C)[..., 2])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [6, 1])
            XCTAssertEqual(a.transposed().strides, [1, 6])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>.range(to: 4 * 3).dataArray)
        }
    }

    func testTransposedCopy() {
        // 2d effective 0d
        do {
            let a = Matrix<Double>.zeros([1, 0])
            let at = Matrix<Double>.empty(shape: a.shape)
            a.transposed(out: at)
            XCTAssertEqual(at.shape, [1, 0])
        }
        // 2d C contiguous -> C contiguous
        do {
            let a = Matrix<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3], order: .C))
            let at = Matrix<Double>.empty(shape: a.shape.reversed())
            a.transposed(out: at)
            XCTAssertEqual(at.shape, [3, 2])
            XCTAssertEqual(a.strides, [3, 1])
            XCTAssertEqual(at.strides, [2, 1])
            XCTAssertEqual(at.dataArray, NdArray<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3]), order: .F).dataArray)
        }
        // 2d C contiguous -> F contiguous
        do {
            let a = Matrix<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3], order: .C))
            let at = Matrix<Double>.empty(shape: a.shape.reversed(), order: .F)
            a.transposed(out: at)
            XCTAssertEqual(at.shape, [3, 2])
            XCTAssertEqual(a.strides, [3, 1])
            XCTAssertEqual(at.strides, [1, 3])
            XCTAssertEqual(at.dataArray, NdArray<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3]), order: .C).dataArray)
        }
        // 2d F contiguous -> C contiguous
        do {
            let a = Matrix<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3], order: .F))
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [1, 2])
            XCTAssertEqual(a.transposed().strides, [2, 1])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>(NdArray<Double>.range(to: 6), order: .F).dataArray)
        }
        // 2d F contiguous -> F contiguous
        do {
            let a = Matrix<Double>(NdArray<Double>.range(to: 6).reshaped([2, 3], order: .F))
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [1, 2])
            XCTAssertEqual(a.transposed().strides, [2, 1])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>(NdArray<Double>.range(to: 6), order: .F).dataArray)
        }
        // 2d not aligned -> C contiguous
        do {
            let a = Matrix(NdArray<Double>.range(to: 4 * 3).reshaped([4, 3], order: .C)[..., 2])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [6, 1])
            XCTAssertEqual(a.transposed().strides, [1, 6])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>.range(to: 4 * 3).dataArray)
        }
        // 2d not aligned -> F contiguous
        do {
            let a = Matrix(NdArray<Double>.range(to: 4 * 3).reshaped([4, 3], order: .C)[..., 2])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [6, 1])
            XCTAssertEqual(a.transposed().strides, [1, 6])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>.range(to: 4 * 3).dataArray)
        }
        // 2d not aligned -> not aligned
        do {
            let a = Matrix(NdArray<Double>.range(to: 4 * 3).reshaped([4, 3], order: .C)[..., 2])
            XCTAssertEqual(a.shape, [2, 3])
            XCTAssertEqual(a.transposed().shape, [3, 2])
            XCTAssertEqual(a.strides, [6, 1])
            XCTAssertEqual(a.transposed().strides, [1, 6])
            XCTAssertEqual(a.transposed().dataArray, NdArray<Double>.range(to: 4 * 3).dataArray)
        }
    }

    func testMatMatMul() {
        let A = Matrix<Double>.ones([2, 2])
        let B = Matrix<Double>.ones([2, 2, ])
        XCTAssertEqual((A * B).shape, [2, 2])
        XCTAssertEqual((A * B).dataArray, [2.0, 2.0, 2.0, 2.0])
    }

    func testMatVecMul() {
        let M = Matrix<Double>.ones([2, 2])
        let x = Vector<Double>.ones(2)
        XCTAssertEqual((M * x).shape, [2])
        XCTAssertEqual((M * x).dataArray, [2.0, 2.0])
    }

    func testSolveAndInverted() throws {
        // 2d effective 0d
        do {
            let a = Matrix<Double>.zeros([0, 0])
            let b = Vector(NdArray<Double>.ones([0]))
            XCTAssertEqual(b.shape, [0])
            let x = try a.solve(b)
            XCTAssertEqual(x.shape, [0])
        }
        // C contiguous
        do {
            let A = Matrix(NdArray<Double>.range(from: 1, to: 5).reshaped([2, 2], order: .C))
            let b = Vector(NdArray<Double>.ones([2]))
            let x1 = try A.solve(b)

            let Ai = try A.inverted()
            let x2 = Ai * b
            XCTAssertEqual(x1.dataArray, x2.dataArray, accuracy: 1e-15)
        }
        // F contiguous
        do {
            let A = Matrix(NdArray<Double>.range(from: 1, to: 5).reshaped([2, 2], order: .F))
            let b = Vector(NdArray<Double>.ones([2]))
            let x1 = try A.solve(b)

            let Ai = try A.inverted()
            let x2 = Ai * b
            XCTAssertEqual(x1.dataArray, x2.dataArray, accuracy: 1e-15)
        }
        // not aligned
        do {
            let A = Matrix(NdArray<Double>.range(to: 4 * 2).reshaped([4, 2], order: .C)[..., 2])
            let b = Vector(NdArray<Double>.ones([2]))
            let x1 = try A.solve(b)

            let Ai = try A.inverted()
            let x2 = Ai * b
            XCTAssertEqual(x1.dataArray, x2.dataArray, accuracy: 1e-15)
        }

        // multiple rhs C contiguous
        do {
            let A = Matrix(NdArray<Double>.range(from: 1, to: 5).reshaped([2, 2], order: .C))
            let B = Matrix(NdArray<Double>.ones([2, 3]), order: .F)
            B[...][1].set(2.0)
            B[...][2].set(3.0)
            let X1 = try A.solve(B)

            let Ai = try A.inverted()
            let X2 = Ai * B
            XCTAssertEqual(X1.dataArray, X2.dataArray, accuracy: 1e-15)
        }
        // multiple rhs F contiguous
        do {
            let A = Matrix(NdArray<Double>.range(from: 1, to: 5).reshaped([2, 2], order: .C))
            let B = Matrix(NdArray<Double>.ones([2, 3]), order: .F)
            B[...][1].set(2.0)
            B[...][2].set(3.0)
            let X1 = try A.solve(B)

            let Ai = try A.inverted()
            let X2 = Ai * B
            XCTAssertEqual(X1.dataArray, X2.dataArray, accuracy: 1e-15)
        }
        // multiple rhs not aligned
        do {
            let A = Matrix(NdArray<Double>.range(from: 1, to: 5).reshaped([2, 2], order: .C))
            let B = Matrix(Matrix(NdArray<Double>.ones([2, 3]), order: .F)[...][..., 2])
            B[...][1].set(2.0)
            let X1 = try A.solve(B)

            let Ai = try A.inverted()
            let X2 = Ai * B
            XCTAssertEqual(X1.dataArray, X2.dataArray, accuracy: 1e-15)
        }
        // C contiguous -> out F contiguous
        do {
            let A = Matrix(NdArray<Double>.range(from: 1, to: 5).reshaped([2, 2], order: .C))
            let B = Matrix(NdArray<Double>.ones([2, 3]), order: .F)
            B[...][1].set(2.0)
            B[...][2].set(3.0)
            let X1 = Matrix<Double>(empty: B.shape, order: .F)
            try A.solve(B, out: X1)

            let Ai = try A.inverted()
            let X2 = Ai * B
            XCTAssertEqual(X1.dataArray, X2.dataArray, accuracy: 1e-15)
        }
    }
}
