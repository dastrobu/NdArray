# NdArray

[![Swift Version](https://img.shields.io/badge/swift-5.5-blue.svg)](https://swift.org)
![Platform](https://img.shields.io/badge/platform-macOS-lightgray.svg)
![Build](https://github.com/dastrobu/NdArray/actions/workflows/ci.yaml/badge.svg)
[![documentation](https://github.com/dastrobu/NdArray/raw/master/docs/badge.svg?sanitize=true)](https://dastrobu.github.io/NdArray/)

N dimensional array package for numeric computing in swift.

The package is inspired by [NumPy](https://www.numpy.org), the well known python package for numerical computations.
This swift package is certainly far away from the maturity of NumPy but implements some key features to enable fast and
simple handling of multidimensional data.

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
- [Multiple Views on Underlying Data](#multiple-views-on-underlying-data)
- [Sliced and Strided Access](#sliced-and-strided-access)
    - [Single Slice](#single-slice)
    - [`UnboundedRange` Slices](#unboundedrange-slices)
    - [`Range` and `ClosedRange` Slices](#range-and-closedrange-slices)
    - [`PartialRangeFrom`, `PartialRangeUpTo` and `PartialRangeThrough` Slices](#partialrangefrom-partialrangeupto-and-partialrangethrough-slices)
- [Element Manipulation](#element-manipulation)
- [Reshaping](#reshaping)
- [Linear Algebra Operations for `Double` and `Float` NdArrays.](#linear-algebra-operations-for-double-and-float-ndarrays)
    - [Matrix Vector Multiplication](#matrix-vector-multiplication)
    - [Matrix Matrix Multiplication](#matrix-matrix-multiplication)
    - [Matrix Inversion](#matrix-inversion)
    - [Solve Linear System of Equations](#solve-linear-system-of-equations)
- [Pretty Printing](#pretty-printing)
- [Type Concept](#type-concept)
    - [Subtypes](#subtypes)
- [Numerical Backend](#numerical-backend)
- [Not Implemented](#not-implemented)
- [Out of Scope](#out-of-scope)
- [Docs](#docs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation

### Swift Package Manager

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/dastrobu/NdArray.git", from: "0.2.1"),
    ]
)
```

## Multiple Views on Underlying Data

Two arrays can easily point to the same data and data can be modified through both views. This is significantly
different from the Swift internal array object, which has copy on write semantics, meaning you cannot pass around
pointers to the same data. Whereas this behaviour is very nice for small amounts of data, since it reduces side effects.
For numerical computation with huge arrays, it is preferable to let the programmer manage copies. The behaviour of the
NdArray is very similar to NumPy's ndarray object. Here is an example:

```swift
let a = NdArray<Double>([9, 9, 0, 9])
let b = NdArray(a)
a[[2]] = 9.0
print(b) // [9.0, 9.0, 9.0, 9.0]
print(a.ownsData) // true
print(b.ownsData) // false
``` 

## Sliced and Strided Access

Like NumPy's ndarray, slices and strides can be created.

```swift
let a = NdArray<Double>.range(to: 10)
let b = NdArray(a[..., 2])
print(a) // [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
print(b) // [0.0, 2.0, 4.0, 6.0, 8.0]
print(b.strides) // [2]
b[...].set(0)
print(a) // [0.0, 1.0, 0.0, 3.0, 0.0, 5.0, 0.0, 7.0, 0.0, 9.0]
print(b) // [0.0, 0.0, 0.0, 0.0, 0.0]
``` 

This creates an array first, then a strided view on the data, making it easy to set every second element to 0.

### Single Slice

A single slice e.g. a row of a matrix is indexed by simple integer

```swift
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
``` 

Note, using element index on a one dimensional array will not access the element,
use [element indexing](#element-manipulation) instead or use the `Vector` subtype which supports element indexing.

```swift
let a = NdArray<Double>.range(to: 4)
print(a[0]) // [0.0]
print(a[[0]]) // 0.0
let v = Vector(a)
print(v[0] as Double) // 0.0
print(v[[0]]) // 0.0
```

### `UnboundedRange` Slices

Unbound ranges select all elements, this is helpful to access lower dimensions of a multidimensional array

```swift
let a = NdArray<Double>.ones([2, 2])
print(a)
// [[1.0, 1.0],
//  [1.0, 1.0]]
a[...][1].set(0.0)
print(a)
// [[1.0, 0.0],
//  [1.0, 0.0]]
``` 

or with a stride, selecting every nth element.

```swift
let a = NdArray<Double>.range(to: 10).reshaped([5, 2])
print(a)
// [[0.0, 1.0],
//  [2.0, 3.0],
//  [4.0, 5.0],
//  [6.0, 7.0],
//  [8.0, 9.0]]
a[..., 2].set(0.0)
print(a)
// [[0.0, 0.0],
//  [2.0, 3.0],
//  [0.0, 0.0],
//  [6.0, 7.0],
//  [0.0, 0.0]]
``` 

### `Range` and `ClosedRange` Slices

Ranges `n..<m` and closed ranges `n...m` allow to select certain sub arrays.

```swift
let a = NdArray<Double>.range(to: 10)
print(a[2..<4]) // [2.0, 3.0]
print(a[2...4]) // [2.0, 3.0, 4.0]
print(a[2...4, 2]) // [2.0, 4.0]
``` 

### `PartialRangeFrom`, `PartialRangeUpTo` and `PartialRangeThrough` Slices

Partial ranges `...<m`, `...m` and `n...` define only one bound.

```swift
let a = NdArray<Double>.range(to: 10)
print(a[..<4]) // [0.0, 1.0, 2.0, 3.0]
print(a[...4]) // [0.0, 1.0, 2.0, 3.0, 4.0]
print(a[4...]) // [4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
print(a[4..., 2]) // [4.0, 6.0, 8.0]
``` 

## Element Manipulation

The syntax for indexing individual elements is by passing an (Swift) array as index. Passing indices individually cannot
be implemented, since Swift does not support varargs on subscript.

```swift
let a = NdArray<Double>.range(to: 12).reshaped([2, 2, 3])
a[[0, 1, 2]]
a[0, 1, 2]  // does not work with Swift
```

For efficient iteration of all indices consider using e.g. `apply`, `map` or `reduce`.

```swift
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
```

Scaling every second element in a matrix by its row index could be done in the following way

```swift
let a = NdArray<Double>.ones([4, 3])
for i in 0..<a.shape[0] {
    a[i][..., 2].apply {
        $0 * Double(i)
    }
}
print(a)
// [[0.0, 1.0, 0.0],
//  [1.0, 1.0, 1.0],
//  [2.0, 1.0, 2.0],
//  [3.0, 1.0, 3.0]]
```

Alternatively one can use classical loops and convert each row to a vector for efficient element indexing

```swift
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
```

## Reshaping

Like in NumPy, an array can be reshaped to any compatible shape without modifying data. That means the shape and strides
are recomputed to re-interpret the data.

```swift
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
```

A copy will only be made if required to create an array with the specified order.

## Elementwise Operations

### Scalars

Arithmetic operations with scalars work in-place,

```swift
let a = NdArray<Double>.ones([2, 2])
a *= 2
a /= 2
a += 2
a /= 2
```

or with implicit copies.

```swift
var b: NdArray<Double>
b = a * 2
b = a / 2
b = a + 2
b = a - 2
```

### Basic Functions

The following basic functions can be applied to any `Float` or `Double` array.

```swift
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
```

The `abs` function is also defined for `SignedNumeric`, such as `Int` arrays.

```swift
let a = NdArray<Int>.range(from: -2, to: 2)
print(a) // [-2, -1,  0,  1]
print(abs(a)) // [2, 1, 0, 1]
```

## Linear Algebra Operations for `Double` and `Float` `NdArray`s.

Linear algebra support is currently very basic.

### Matrix Vector Multiplication

```swift
let A = Matrix<Double>.ones([2, 2])
let x = Vector<Double>.ones(2)
print(A * x) // [2.0, 2.0]
```

### Matrix Matrix Multiplication

```swift
let A = Matrix<Double>.ones([2, 2])
let x = Matrix<Double>.ones([2, 2])
print(A * x)
// [[2.0, 2.0],
//  [2.0, 2.0]]
```

### Matrix Inversion

```swift
let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
print(try A.inverted())
// [[-1.5,  0.5],
//  [ 1.0,  0.0]]
```

### Solve Linear System of Equations

with single right hand side

```swift
let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
let x = Vector<Double>.ones(2)
print(try A.solve(x)) // [-1.0,  1.0]
```

with multiple right hand sides

```swift
let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
let x = Matrix<Double>.ones([2, 2])
print(try A.solve(x))
// [[-1.0, -1.0],
//  [ 1.0,  1.0]]
```

## Pretty Printing

Multi dimensional arrays can be printed in a human friendly way.

```swift
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
```

## Type Concept

The idea is to have basic `NdArray` type, which keeps a pointer to data and stores shape and stride information. Since
there can be multiple `NdArray` objects referring to the same data, ownership is tracked explicitly. If an array owns
its data is stored in the `ownsData` flag (similar to NumPy's ndarray)
When creating a new array from an existing one, no copy is made unless necessary. Here are a few examples

```swift
let A = NdArray<Double>.ones(5)
var B = NdArray(A) // no copy
B = NdArray(copy: A) // copy explicitly required
B = NdArray(A[..., 2]) // no copy, but B will not be contiguous
B = NdArray(A[..., 2], order: .C) // copy, because otherwise new array will not have C ordering
```

When using slices on an `NdArray` it returns a `NdArraySlice` object. This slice object is similar to an array but keeps
track how deeply it is sliced.

```swift
let A = NdArray<Double>.ones([2, 2, 2])
var B = A[...] // NdArraySlice with sliced = 1, i.e. one dimension has been sliced
B = A[...][..., 2] // NdArraySlice with sliced = 2, i.e. one dimension has been sliced
B = A[...][..., 2][..<1] // NdArraySlice with sliced = 3, i.e. one dimension has been sliced
B = A[...][..., 2][..<1][...] // Assertion failed: Cannot slice array with ndim 3 more than 3 times.
```

So it is recommended to convert to an `NdArray` after slicing before continuing to work with the data.

```swift
let A = NdArray<Double>.ones([2, 2, 2])
var B = NdArray(A[...]) // B has shape [2, 2, 2]
B = NdArray(A[...][..., 2]) // B has shape [2, 1, 2]
B = NdArray(A[...][..., 2][..<1]) // B has shape [2, 1, 1]
```

When using slices to assign data, no type conversion is required.

```swift
let A = NdArray<Double>.ones([2, 2])
let B = NdArray<Double>.zeros(2)
A[...][0] = B[...]
print(A)
// [[0.0, 1.0],
//  [0.0, 1.0]]
```

### Subtypes

To be able to define operators for matrix vector multiplication and matrix matrix multiplication, sub types like
`Matrix` and `Vector` are defined. Since no data is copied when creating a matrix or vector from an array, they can be
converted anytime, thereby making sure the shapes match requirements of the sub type.

```swift
let a = NdArray<Double>.ones([2, 2])
let b = NdArray<Double>.zeros(2)
let A = Matrix<Double>(a) // matrix from array without copy
let x = Vector<Double>(b) // vector from array without copy
let Ax = A * x; // matrix vector multiplication is defined
let _ = Vector<Double>(a) // Assertion failed: Cannot create vector with shape [2, 2]. Vector must have one dimension.
````

Furthermore algorithms specific for subtypes like a matrix will be defined as method on the subtype, e.g. `solve`

```swift
let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
let x = Vector<Double>.ones(2)
print(try A.solve(x)) // [-1.0,  1.0]
```

## Numerical Backend

Numerical operations are performed using [BLAS](http://www.netlib.org/blas), see also
[BLAS cheat sheet](http://www.netlib.org/blas/blasqr.pdf) for an overview and [LAPACK](http://www.netlib.org/lapack).
The functions of these libraries are provided by the
[Accelerate Framework](https://developer.apple.com/documentation/accelerate) and are available on most Apple platforms.

## Not Implemented

Some features are not implemented yet, but are planned for the near future.

* Elementwise multiplication of Double and Float arrays. Planned as `multiply(elementwiseBy, divide(elementwiseBy)`
  employing `vDSP_vmulD`
  Note that this can be done with help of `map` currently.

## Out of Scope

Some features would be nice to have at some time but currently out of scope.

* Complex numbers (currently support for complex numbers is not planned)

## Docs

Read the generated [docs](https://dastrobu.github.io/NdArray).