//
// Created by Daniel Strobusch on 13.01.20.
//

import XCTest
import NdArray

class ReadmeExamples: XCTestCase {

    func testAliasing() {
        let a = NdArray<Double>([9, 9, 0, 9])
        let b = NdArray(a)
        a[[2]] = 9.0
        print(b) // [9.0, 9.0, 9.0, 9.0]
        print(a.ownsData) // true
        print(b.ownsData) // false
    }

    func testSlices() {
        let a = NdArray<Double>.range(to: 10)
        let b = NdArray(a[..., 2])
        print(a) // [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
        print(b) // [0.0, 2.0, 4.0, 6.0, 8.0]
        print(b.strides) //
        b[...].set(0)
        print(a) // [0.0, 1.0, 0.0, 3.0, 0.0, 5.0, 0.0, 7.0, 0.0, 9.0]
        print(b) // [0.0, 0.0, 0.0, 0.0, 0.0]
    }

    func testUnboundRange() {
        do {

            let a = NdArray<Double>.ones([2, 2])
            print(a)
            // [[1.0, 1.0],
            //  [1.0, 1.0]]
            a[...][1].set(0.0)
            print(a)
            // [[1.0, 0.0],
            //  [1.0, 0.0]]
        }
        do {
            let a = NdArray<Double>.range(to: 10).reshaped([5, 2])
            print(a)
            // [[0.0, 1.0],
            // [2.0, 3.0],
            // [4.0, 5.0],
            // [6.0, 7.0],
            // [8.0, 9.0]]
            a[..., 2].set(0.0)
            print(a)
            // [[0.0, 0.0],
            // [2.0, 3.0],
            // [0.0, 0.0],
            // [6.0, 7.0],
            // [0.0, 0.0]]
        }
    }

    func testRangeAndClosedRange() {
        let a = NdArray<Double>.range(to: 10)
        print(a[2..<4]) // [2.0, 3.0]
        print(a[2...4]) // [2.0, 3.0, 4.0]
        print(a[2...4, 2]) // [2.0, 4.0]
    }

    func testPartialRanges() {
        let a = NdArray<Double>.range(to: 10)
        print(a[..<4]) // [0.0, 1.0, 2.0, 3.0]
        print(a[...4]) // [0.0, 1.0, 2.0, 3.0, 4.0]
        print(a[4...]) // [4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
        print(a[4..., 2]) // [4.0, 6.0, 8.0]
    }

    func testLinearAlgebra() throws {
        do {
            let A = Matrix<Double>.ones([2, 2])
            let x = Vector<Double>.ones(2)
            print(A * x) // [2.0, 2.0]
        }

        do {
            let A = Matrix<Double>.ones([2, 2])
            let x = Matrix<Double>.ones([2, 2])
            print(A * x)
            // [[2.0, 2.0],
            //  [2.0, 2.0]]
        }
        do {
            let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
            print(try A.inverted())
            // [[-1.5,  0.5],
            //  [ 1.0,  0.0]]
        }
        do {
            let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
            let x = Vector<Double>.ones(2)
            print(try A.solve(x)) // [-1.0,  1.0]
        }
        do {
            let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
            let x = Matrix<Double>.ones([2, 2])
            print(try A.solve(x))
            // [[-1.0, -1.0],
            //  [ 1.0,  1.0]]
        }
    }

    func testPrettyPrinting() {
        print(NdArray<Double>.ones([2, 3, 4]))
        // [[[1.0, 1.0, 1.0, 1.0],
        //  [1.0, 1.0, 1.0, 1.0],
        //  [1.0, 1.0, 1.0, 1.0]],
        //
        // [[1.0, 1.0, 1.0, 1.0],
        //  [1.0, 1.0, 1.0, 1.0],
        //  [1.0, 1.0, 1.0, 1.0]]]
        print("this is a 2d array in one line \(NdArray<Double>.zeros([2, 2]), style: .singleLine)")
        // this is a 2d array in one line [[0.0, 0.0], [0.0, 0.0]]
        print("this is a 2d array in multi line format line \n\(NdArray<Double>.zeros([2, 2]), style: .multiLine)")
        // this is a 2d array in multi line format line
        // [[0.0, 0.0],
        //  [0.0, 0.0]]
    }
}
