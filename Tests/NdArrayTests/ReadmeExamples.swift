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
        print(b.strides) // [2]
        b[...].set(0)
        print(a) // [0.0, 1.0, 0.0, 3.0, 0.0, 5.0, 0.0, 7.0, 0.0, 9.0]
        print(b) // [0.0, 0.0, 0.0, 0.0, 0.0]
    }
    func testSingleSlice() {
        do {
            let a = NdArray<Double>.ones([2, 2])
            print(a)
            // [[1.0, 1.0],
            //  [1.0, 1.0]]
            a[1].set(0.0)
            print(a)
            // [[1.0, 1.0],
            //  [0.0, 0.0]]
            a[...][1].set(2.0)
            print(a)
            // [[1.0, 2.0],
            //  [0.0, 2.0]]
        }
        do {
            let a = NdArray<Double>.range(to: 4)
            print(a[0]) // [0.0]
            print(a[[0]]) // 0.0
            let v = Vector(a)
            print(v[0] as Double) // 0.0
            print(v[[0]]) // 0.0
        }
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
    func testScalars() {
        let a = NdArray<Double>.ones([2, 2])
        a *= 2
        a /= 2
        a += 2
        a /= 2

        var b: NdArray<Double>
        b = a * 2
        b = a / 2
        b = a + 2
        b = a - 2
    }
    func testBasicFunctions() {
        do {
            let a = NdArray<Double>.ones([2, 2])
            var b: NdArray<Double>

            b = abs(a)

            b = acos(a)
            b = asin(a)
            b = atan(a)

            b = cos(a)
            b = sin(a)
            b = tan(a)

            b = cosh(a)
            b = sinh(a)
            b = tanh(a)

            b = exp(a)
            b = exp2(a)

            b = log(a)
            b = log10(a)
            b = log1p(a)
            b = log2(a)
            b = logb(a)
        }
        do {
            let a = NdArray<Int>.range(from: -2, to: 2)
            print(a) // [-2, -1,  0,  1]
            print(abs(a)) // [2, 1, 0, 1]
        }
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
    func testReshape() {
        let a = NdArray<Double>.range(to: 12)
        print(a.reshaped([2, 6]))
        // [[ 0.0,  1.0,  2.0,  3.0,  4.0,  5.0],
        //  [ 6.0,  7.0,  8.0,  9.0, 10.0, 11.0]]
        print(a.reshaped([2, 6], order: .F))
        // [[ 0.0,  2.0,  4.0,  6.0,  8.0, 10.0],
        //  [ 1.0,  3.0,  5.0,  7.0,  9.0, 11.0]]
        print(a.reshaped([3, 4]))
        // [[ 0.0,  1.0,  2.0,  3.0],
        //  [ 4.0,  5.0,  6.0,  7.0],
        //  [ 8.0,  9.0, 10.0, 11.0]]
        print(a.reshaped([4, 3]))
        // [[ 0.0,  1.0,  2.0],
        //  [ 3.0,  4.0,  5.0],
        //  [ 6.0,  7.0,  8.0],
        //  [ 9.0, 10.0, 11.0]]
        print(a.reshaped([2, 2, 3]))
        // [[[ 0.0,  1.0,  2.0],
        //   [ 3.0,  4.0,  5.0]],
        //
        //  [[ 6.0,  7.0,  8.0],
        //   [ 9.0, 10.0, 11.0]]]
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
    func testTypes() {
        do {
            let A = NdArray<Double>.ones(5)
            var B = NdArray(A) // no copy
            B = NdArray(copy: A) // copy explicitly required
            B = NdArray(A[..., 2]) // no copy, but B will not be contiguous
            B = NdArray(A[..., 2], order: .C) // copy, because otherwise new array will not have C ordering
        }
        do {
            let A = NdArray<Double>.ones([2, 2, 2])
            var B = A[...] // return NdArraySlice with sliced = 1, i.e. one dimension has been sliced
            B = A[...][..., 2] // return NdArraySlice with sliced = 2, i.e. one dimension has been sliced
            B = A[...][..., 2][...1] // return NdArraySlice with sliced = 2, i.e. one dimension has been sliced
            // B = A[...][..., 2][...1][...] // Assertion failed: Cannot slice array with ndim 3 more than 3 times.
        }
        do {
            let A = NdArray<Double>.ones([2, 2, 2])
            var B = NdArray(A[...]) // B has shape [2, 2, 2]
            print(B.shape)
            B = NdArray(A[...][..., 2]) // B has shape [2, 1, 2]
            print(B.shape)
            B = NdArray(A[...][..., 2][..<1]) // B has shape [2, 1, 1]
            print(B.shape)
        }
        do {
            let A = NdArray<Double>.ones([2, 2])
            let B = NdArray<Double>.zeros(2)
            A[...][0] = B[...]
            print(A)
            // [[0.0, 1.0],
            //  [0.0, 1.0]]
        }
        do {
            let a = NdArray<Double>.ones([2, 2])
            let b = NdArray<Double>.zeros(2)
            let A = Matrix<Double>(a) // matrix from array without copy
            let x = Vector<Double>(b) // vector from array without copy
            let Ax = A * x; // matrix vector multiplication is defined
            // let _ = Vector<Double>(a) // fails
        }
    }
    func testElementIndexing() {
        do {
            let a = NdArray<Double>.ones(4).reshaped([2, 2])
            let b = a.map {
                $0 * 2
            } // map to new array
            print(b)
            // [[2.0, 2.0],
            //  [2.0, 2.0]]
            a.apply {
                $0 * 3
            } // in place
            print(a)
            // [[3.0, 3.0],
            //  [3.0, 3.0]]
            print(a.reduce(0) {
                $0 + $1
            }) // 12.0
        }
        do {
            let a = NdArray<Double>.ones([4, 3])
            for i in 0..<a.shape[0] {
                a[i][..., 2] *= Double(i)
            }
            print(a)
            // [[0.0, 1.0, 0.0],
            //  [1.0, 1.0, 1.0],
            //  [2.0, 1.0, 2.0],
            //  [3.0, 1.0, 3.0]]
        }
        do {
            let a = NdArray<Double>.ones([4, 3])
            for i in 0..<a.shape[0] {
                let ai = Vector(a[i])
                for j in stride(from: 0, to: a.shape[1], by: 2) {
                    ai[j] *= Double(i)
                }
            }
            print(a)
            // [[0.0, 1.0, 0.0],
            //  [1.0, 1.0, 1.0],
            //  [2.0, 1.0, 2.0],
            //  [3.0, 1.0, 3.0]]
        }
    }
}
