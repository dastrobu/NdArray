//
// Created by Daniel Strobusch on 13.01.20.
//

import XCTest
import NdArray

class ReadmeExamples: XCTestCase {
    func testAliasing() {
        let a = NdArray<Double>([9, 9, 0, 9])
        let b = NdArray(a)
        a[2] = 9.0
        print(b) // [9.0, 9.0, 9.0, 9.0]
        print(a.ownsData) // true
        print(b.ownsData) // false
    }

    func testSlices() {
        let a = NdArray<Double>.range(to: 10)
        let b = NdArray(a[0... ~ 2]) // every second element
        print(a) // [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
        print(b) // [0.0, 2.0, 4.0, 6.0, 8.0]
        print(b.strides) // [2]
        b[0...].set(0)
        print(a) // [0.0, 1.0, 0.0, 3.0, 0.0, 5.0, 0.0, 7.0, 0.0, 9.0]
        print(b) // [0.0, 0.0, 0.0, 0.0, 0.0]
    }

    func testSingleSlice() {
        do {
            let a = NdArray<Double>.ones([2, 2])
            print(a)
            // [[1.0, 1.0],
            //  [1.0, 1.0]]
            a[Slice(1)].set(0.0)
            print(a)
            // [[1.0, 1.0],
            //  [0.0, 0.0]]
            a[0..., 1].set(2.0)
            print(a)
            // [[1.0, 2.0],
            //  [0.0, 2.0]]
        }
        do {
            let a = NdArray<Double>.range(to: 4)
            print(a[Slice(0)]) // [0.0]
            print(a[0]) // 0.0
            let v = Vector(a)
            print(v[0] as Double) // 0.0
            print(v[0]) // 0.0
        }
    }

    func testUnboundRange() {
        do {
            let a = NdArray<Double>.ones([2, 2])
            print(a)
            // [[1.0, 1.0],
            //  [1.0, 1.0]]
            a[0..., 1].set(0.0)
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
            a[0... ~ 2].set(0.0)
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
        print(a[2...4 ~ 2]) // [2.0, 4.0]
    }

    func testPartialRanges() {
        let a = NdArray<Double>.range(to: 10)
        print(a[..<4]) // [0.0, 1.0, 2.0, 3.0]
        print(a[...4]) // [0.0, 1.0, 2.0, 3.0, 4.0]
        print(a[4...]) // [4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
        print(a[4... ~ 2]) // [4.0, 6.0, 8.0]
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
        _ = b
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

            _ = b
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
            print(A.transposed())
            // [[0.0,  2.0],
            //  [1.0,  3.0]]
        }
        do {
            let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
            print(A.transposed())
            // [[0.0,  2.0],
            //  [1.0,  3.0]]
        }
        do {
            let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
            print(try A.inverted())
            // [[-1.5,  0.5],
            //  [ 1.0,  0.0]]
        }
        do {
            print("SVD")
            let A = Matrix<Double>(NdArray.range(from: 1, to: 9).reshaped([2, 4]))
            let (U, s, Vt) = try A.svd()
            print(U)
            // [[-0.3761682344281408, -0.9265513797988838],
            //  [-0.9265513797988838,  0.3761682344281408]]
            print(s)
            // [14.227407412633742, 1.2573298353791098]
            print(Vt)
            // [[ -0.3520616924890126, -0.44362578258952023,  -0.5351898726900277,  -0.6267539627905352],
            //  [  0.7589812676751458,  0.32124159914593237,  -0.1164980693832819,   -0.554237737912496],
            //  [ -0.4000874340557387,  0.25463292200666415,   0.6909964581538871,  -0.5455419461048127],
            //  [ -0.3740722458438949,   0.7969705609558909,   -0.471724384380099,  0.04882606926810252]]
            let Sd = Matrix(diag: s)
            let S = Matrix<Double>.zeros(A.shape)
            let mn = A.shape.min()!
            S[..<mn, ..<mn] = Sd
            print(S)
            // [[14.227407412633742,                0.0,                0.0,                0.0],
            //  [               0.0, 1.2573298353791098,                0.0,                0.0]]
            print(U * S * Vt)
            // [[1.0000000000000004,                2.0, 3.0000000000000004, 3.9999999999999996],
            //  [ 4.999999999999999,  6.000000000000001,  7.000000000000001,                8.0]]
        }
        do {
            print("LU Factorization")
            let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
            let (P, L, U) = try A.lu()
            print(P)
            // [[0.0, 1.0],
            //  [1.0, 0.0]]
            print(L)
            // [[1.0, 0.0],
            //  [0.0, 1.0]]
            print(U)
            // [[2.0, 3.0],
            //  [0.0, 1.0]]
            print(P * L * U)
            // [[0.0, 1.0],
            //  [2.0, 3.0]]
        }
        do {
            print("Solve a Linear System of Equations")
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

    func testDataArray() {
        let a = [1, 2, 3]
        let b = NdArray(a)
        let c = b.dataArray
        print(c)
        // [1, 2, 3]
    }

    func testSequenceProtocol() {
        let v = Vector<Int>([1, 2, 3])
        print(Array(v))
        // [1, 2, 3]
        let M = Matrix<Int>([
            [1, 2, 3],
            [3, 2, 1],
        ])
        let a = Array(M).map({ Array($0) })
        print(a)
        // [[1, 2, 3], [3, 2, 1]]
    }

    func testData() {
        let a = NdArray([1, 2, 3])
        let aData = a.data
        print(aData)
        // UnsafeMutableBufferPointer(start: 0x0000600002796760, count: 3)
    }

    func testTypes() {
        do {
            let A = NdArray<Double>.ones(5)
            var B = NdArray(A) // no copy
            B = NdArray(copy: A) // copy explicitly required
            B = NdArray(A[0... ~ 2]) // no copy, but B will not be contiguous
            B = NdArray(A[0... ~ 2], order: .C) // copy, because otherwise new array will not have C ordering

            _ = B
        }
        do {
            let A = NdArray<Double>.ones([2, 2, 2])
            var B = A[0...] // return NdArraySlice with sliced = 1, i.e. one dimension has been sliced
            B = A[0..., 0... ~ 2] // return NdArraySlice with sliced = 2, i.e. one dimension has been sliced
            B = A[0..., 0... ~ 2, ...1] // return NdArraySlice with sliced = 2, i.e. one dimension has been sliced
            // B = A[0..., 0... ~ 2, ...1, 0...] // Precondition failed: Cannot slice array with ndim 3 more than 3 times.

            _ = B
        }
        do {
            let A = NdArray<Double>.ones([2, 2, 2])
            var B = NdArray(A[0...]) // B has shape [2, 2, 2]
            print(B.shape)
            B = NdArray(A[0..., 0... ~ 2]) // B has shape [2, 1, 2]
            print(B.shape)
            B = NdArray(A[0..., 0... ~ 2, ..<1]) // B has shape [2, 1, 1]
            print(B.shape)
        }
        do {
            let A = NdArray<Double>.ones([2, 2])
            let B = NdArray<Double>.zeros(2)
            A[0..., Slice(0)] = B[0...]
            print(A)
            // [[0.0, 1.0],
            //  [0.0, 1.0]]
        }
        do {
            let a = NdArray<Double>.ones([2, 2])
            let b = NdArray<Double>.zeros(2)
            let A = Matrix<Double>(a) // matrix from array without copy
            let x = Vector<Double>(b) // vector from array without copy
            let Ax = A * x // matrix vector multiplication is defined
            // let _ = Vector<Double>(a) // fails

            _ = Ax
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
                a[Slice(i), 0... ~ 2] *= Double(i)
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
                let ai = Vector(a[Slice(i)])
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
