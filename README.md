# NdArray

[![Swift Version](https://img.shields.io/badge/swift-6.2-blue.svg)](https://swift.org)
![Platform](https://img.shields.io/badge/platform-macOS|iOS|tvOS|whatchOS-lightgray.svg)
![Build](https://github.com/dastrobu/NdArray/actions/workflows/ci.yaml/badge.svg)

N dimensional array package for numeric computing in [Swift](https://swift.org).

The package is inspired by [NumPy](https://www.numpy.org), the well known [python](https://python.org) package for
numerical computations. This Swift package is certainly far away from the maturity of NumPy but implements some key
features to enable fast and simple handling of multidimensional numeric data.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
- [Multiple Views on Underlying Data](#multiple-views-on-underlying-data)
- [Sliced and Strided Access](#sliced-and-strided-access)
  - [Slices and the Stride Operator `~`](#slices-and-the-stride-operator-)
  - [Single Slice](#single-slice)
  - [`UnboundedRange` Slices](#unboundedrange-slices)
  - [`Range` and `ClosedRange` Slices](#range-and-closedrange-slices)
  - [`PartialRangeFrom`, `PartialRangeUpTo` and `PartialRangeThrough` Slices](#partialrangefrom-partialrangeupto-and-partialrangethrough-slices)
- [Element Manipulation](#element-manipulation)
- [Reshaping](#reshaping)
- [Elementwise Operations](#elementwise-operations)
  - [Scalars](#scalars)
  - [Basic Functions](#basic-functions)
- [Linear Algebra Operations for `Double` and `Float` `NdArray`s.](#linear-algebra-operations-for-double-and-float-ndarrays)
  - [Matrix Vector Multiplication](#matrix-vector-multiplication)
  - [Matrix Matrix Multiplication](#matrix-matrix-multiplication)
  - [Matrix Transpose](#matrix-transpose)
  - [Matrix Inversion](#matrix-inversion)
  - [LU Factorization](#lu-factorization)
  - [Singular Value Decomposition (SVD)](#singular-value-decomposition-svd)
  - [Solve a Linear System of Equations](#solve-a-linear-system-of-equations)
- [Pretty Printing](#pretty-printing)
- [Interaction with Swift Arrays](#interaction-with-swift-arrays)
- [Raw Data Access](#raw-data-access)
- [Type Concept](#type-concept)
  - [Subtypes](#subtypes)
- [Numerical Backend](#numerical-backend)
- [Debugging](#debugging)
- [API Changes](#api-changes)
  - [TLDR](#tldr)
  - [Removal of `NdArraySlice`](#removal-of-ndarrayslice)
- [Not Implemented](#not-implemented)
- [Out of Scope](#out-of-scope)
- [Docs](#docs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation

The API is stable from versions up to `0.3.0`. Version `0.4.0` deprecates the old slicing API and introduces a more type
safe API. Version `0.5.0` will remove the old slicing API and thus contain breaking changes. It is recommended to fix
all compiler warnings on `0.4.0` before upgrading to `0.5.0`, see also [API Changes](#api-changes).

### Swift Package Manager

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/dastrobu/NdArray.git", from: "0.7.0"),
    ]
)
```

## Multiple Views on Underlying Data

Two arrays can easily point to the same data and data can be modified through both views. This is significantly
different from the Swift internal array object, which has copy on write semantics, meaning you cannot pass around
pointers to the same data. Whereas this behaviour is very nice for small amounts of data, since it reduces side effects.
For numerical computation with huge arrays, it is preferable to let the programmer manage copies. The behaviour of the
NdArray is very similar to
[NumPy's ndarray object](https://numpy.org/doc/stable/reference/generated/numpy.ndarray.html). Here is an example:

```swift
let a = NdArray<Double>([9, 9, 0, 9])
let b = NdArray(a)
a[2] = 9.0
print(b) // [9.0, 9.0, 9.0, 9.0]
print(a.ownsData) // true
print(b.ownsData) // false
``` 

## Sliced and Strided Access

Like NumPy's ndarray, slices and strides can be created.

```swift
let a = NdArray<Double>.range(to: 10)
let b = NdArray(a[0... ~ 2]) // every second element
print(a) // [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
print(b) // [0.0, 2.0, 4.0, 6.0, 8.0]
print(b.strides) // [2]
b[0...].set(0)
print(a) // [0.0, 1.0, 0.0, 3.0, 0.0, 5.0, 0.0, 7.0, 0.0, 9.0]
print(b) // [0.0, 0.0, 0.0, 0.0, 0.0]
``` 

This creates an array first, then a strided view on the data, making it easy to set every second element to 0.

### Slices and the Stride Operator `~`

As shown in the previous example, strides can be defined via the stride operator `~`. The unbounded range slice `0...`
takes all elements along an axis. The stride `~ 2` selects only every second element. Here is a short comparison with
NumPy's syntax.

```
NdArray        NumPy
a[0...]        a[::]
a[0... ~ 2]    a[::2]
a[..<42 ~ 2]   a[:42:2]
a[3..<42 ~ 2]  a[3:42:2]
a[3...42 ~ 2]  a[3:41:2]
```

Alternatively, slice objects can be created programmatically. The following notations are equivalent:

```
 a[0...] ≡ a[Slice()]
 a[1...] ≡ a[Slice(lowerBound: 1)]
 a[..<42] ≡ a[Slice(upperBound: 42)]
 a[...42] ≡ a[Slice(upperBound: 43)]
 a[1..<42] ≡ a[Slice(lowerBound: 1, upperBound: 42)]
 a[1... ~ 2] ≡ a[Slice(lowerBound: 1, upperBound, stride: 2)]
 a[..<42 ~ 3] ≡ a[Slice(upperBound: 42, stride: 3)]
 a[1..<42 ~ 3] ≡ a[Slice(lowerBound: 1, upperBound: 42, stride: 3)]
```

Note, to avoid confusion with pure indexing, integer literals need to be converted to a slice explicitly. This means

```swift
let a = NdArray<Double>.range(to: 10)
let _ = a[1] // does not work
let s1: NdArray<Double> = a[Slice(1)] // selects slice at index one along zeroth dimension
let a1: Double = a[1] // selects first element
```

More detailed examples on each slice type are provided in the sections below.

### Single Slice

A single slice e.g. a row of a matrix is indexed by a so called index slice `Slice(_: Int)`:

```swift
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
``` 

Note, using element index on a one dimensional array will not access the element,
use [element indexing](#element-manipulation) instead or use the `Vector` subtype which supports element indexing.

```swift
let a = NdArray<Double>.range(to: 4)
print(a[Slice(0)]) // [0.0]
print(a[0]) // 0.0
let v = Vector(a)
print(v[0] as Double) // 0.0
print(v[0]) // 0.0
```

### `UnboundedRange` Slices

Unbounded ranges select all elements, this is helpful to access lower dimensions of a multidimensional array

```swift
let a = NdArray<Double>.ones([2, 2])
print(a)
// [[1.0, 1.0],
//  [1.0, 1.0]]
a[0..., 1].set(0.0)
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
a[0... ~ 2].set(0.0)
print(a)
// [[0.0, 0.0],
//  [2.0, 3.0],
//  [0.0, 0.0],
//  [6.0, 7.0],
//  [0.0, 0.0]]
``` 

Due to a limitation in the type system, the true unbounded range operator `...` cannot be used. Instead, the
idiom `0...`
should be preferred to specify an unbound range.

### `Range` and `ClosedRange` Slices

Ranges `n..<m` and closed ranges `n...m` allow selecting certain sub arrays.

```swift
let a = NdArray<Double>.range(to: 10)
print(a[2..<4]) // [2.0, 3.0]
print(a[2...4]) // [2.0, 3.0, 4.0]
print(a[2...4 ~ 2]) // [2.0, 4.0]
``` 

### `PartialRangeFrom`, `PartialRangeUpTo` and `PartialRangeThrough` Slices

Partial ranges `...<m`, `...m` and `n...` define only one bound.

```swift
let a = NdArray<Double>.range(to: 10)
print(a[..<4]) // [0.0, 1.0, 2.0, 3.0]
print(a[...4]) // [0.0, 1.0, 2.0, 3.0, 4.0]
print(a[4...]) // [4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
print(a[4... ~ 2]) // [4.0, 6.0, 8.0]
``` 

## Element Manipulation

Individual elements can be indexed by passing a (Swift) array as index or varargs.

```swift
let a = NdArray<Double>.range(to: 12).reshaped([2, 2, 3])
a[[0, 1, 2]]
a[0, 1, 2]
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
    a[Slice(i), 0... ~ 2] *= Double(i)
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

### Matrix Transpose

```swift
let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
print(A.transposed())
// [[0.0,  2.0],
//  [1.0,  3.0]]
```

### Matrix Inversion

```swift
let A = Matrix<Double>(NdArray.range(to: 4).reshaped([2, 2]))
print(try A.inverted())
// [[-1.5,  0.5],
//  [ 1.0,  0.0]]
```

### LU Factorization

```swift
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
```

See also `luInPlace()` for more advanced use cases that avoid creating full matrices.

### Singular Value Decomposition (SVD)

```swift
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
```

### Solve a Linear System of Equations

with single right-hand side

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

Multidimensional arrays can be printed in a human friendly way.

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

## Interaction with Swift Arrays

Normal Swift arrays can be converted to a NdArray and back as follows.

```swift
let a = [1, 2, 3]
let b = NdArray(a)
let c = b.dataArray
print(c)
// [1, 2, 3]
```

It should be noted that the conversion requires copying data. This is usually quite fast, but if a numeric algorithm
would convert very small array back and forth, it could slow down the algorithm unnecessarily.
Multidimensional arrays will be represented as flat arrays, to convert a vector or a matrix to nested arrays, make use
of the sequence protocols as shown below.

```swift
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
```

## Raw Data Access

Instead of converting to another type, sometimes it can be helpful to access raw data. Especially, when passing data to
another low level numeric library.
Raw data can be accessed via the `data` property.

```swift
let a = NdArray([1, 2, 3])
let aData = a.data
print(aData)
// UnsafeMutableBufferPointer(start: 0x0000600002796760, count: 3)
```

Note that strides and dimensions must be taken care of manually.

## Type Concept

The idea is to have basic `NdArray` type, which keeps a pointer to data and stores shape and stride information. Since
there can be multiple `NdArray` objects referring to the same data, ownership is tracked explicitly. If an array owns
its data is stored in the `ownsData` flag (similar to NumPy's ndarray)
When creating a new array from an existing one, no copy is made unless necessary. Here are a few examples

```swift
let A = NdArray<Double>.ones(5)
var B = NdArray(A) // no copy
B = NdArray(copy: A) // copy explicitly required
B = NdArray(A[0... ~ 2]) // no copy, but B will not be contiguous
B = NdArray(A[0... ~ 2], order: .C) // copy, because otherwise new array will not have C ordering
```

### Subtypes

To be able to define operators for matrix vector multiplication and matrix matrix multiplication, subtypes like
`Matrix` and `Vector` are defined. Since no data is copied when creating a matrix or vector from an array, they can be
converted anytime, thereby making sure the shapes match requirements of the subtype.

```swift
let a = NdArray<Double>.ones([2, 2])
let b = NdArray<Double>.zeros(2)
let A = Matrix<Double>(a) // matrix from array without copy
let x = Vector<Double>(b) // vector from array without copy
let Ax = A * x // matrix vector multiplication is defined
let _ = Vector<Double>(a) // Precondition failed: Cannot create vector with shape [2, 2]. Vector must have one dimension.
````

Furthermore, algorithms specific for subtypes like a matrix will be defined as method on the subtype, e.g. `solve`

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

## Debugging

When debugging some code, sometimes it can be helpful to look at the raw data in the debugger. This can be done with
help of the `data` property, which is a typed `UnsafeMutableBufferPointer` pointing to the raw data.

Here is an example in lldb:

```
(lldb) p a.data
(UnsafeMutableBufferPointer<Double>) $R1 = 6 values (0x113d05000) {
  [0] = 1
  [1] = 2
  [2] = 3
  [3] = 4
  [4] = 5
  [5] = 6
}
```

## API Changes

### TLDR

To migrate from `<=0.3.0` to `0.4.0` upgrade to `0.4.0` first and fix all compile warnings. Do not skip `0.4.0`, since
this can result in undesired behaviour (`a[0..., 2]` will be interpreted as "take slice along zeroth and first
dimension" from `0.5.0` instead of "take slice along zeroth dimension with stride 2" `<=0.3.0`).

Here are a few rules of thumb to fix compile warnings after upgrading to `0.4.0`:

```
a[...] => a[[0...]] // UnboundedRange is now expresed by 0...
a[..., 2] => a[[0... ~ 2]] // strides are now expressed by the stride operator ~
a[...][3] => a[[0..., Slice(3)]] // multi dimensional slices are now created within one subscript call [] not many [][][]
```

### Removal of `NdArraySlice`

Prior to version `0.4.0` using slices on an `NdArray` returned a `NdArraySlice` object. This slice object is similar to
an array but keeps track how deeply it is sliced.

```swift
let A = NdArray<Double>.ones([2, 2, 2])
var B = A[...] // NdArraySlice with sliced = 1, i.e. one dimension has been sliced
B = A[0...][0... ~ 2] // NdArraySlice with sliced = 2, i.e. one dimension has been sliced
B = A[0...][0... ~ 2][..<1] // NdArraySlice with sliced = 3, i.e. one dimension has been sliced
B = A[0...][0... ~ 2][..<1][0...] // Precondition failed: Cannot slice array with ndim 3 more than 3 times.
```

So it was recommended to convert to an `NdArray` after slicing before continuing to work with the data.

```swift
let A = NdArray<Double>.ones([2, 2, 2])
var B = NdArray(A[...]) // B has shape [2, 2, 2]
B = NdArray(A[...][..., 2]) // B has shape [2, 1, 2]
B = NdArray(A[0...][0..., 2][..<1]) // B has shape [2, 1, 1]
```

When using slices to assign data, no type conversion is required.

```swift
let A = NdArray<Double>.ones([2, 2])
let B = NdArray<Double>.zeros(2)
A[0..., 0] = B[0...]
print(A)
// [[0.0, 1.0],
//  [0.0, 1.0]]
```

These conversions are not necessary anymore, starting from version `0.4.0`. With the new slice API, based on the `Slice`
object, slices are obtained by

```swift
let A = NdArray<Double>.ones([2, 2, 2])
var B = A[0...] // NdArray with sliced = 1, i.e. one dimension has been sliced
B = A[0..., 0... ~ 2] // NdArray with sliced = 2, i.e. one dimension has been sliced
B = A[0..., 0... ~ 2, ..<1] // NdArray with sliced = 3, i.e. one dimension has been sliced
B = A[0..., 0... ~ 2, ..<1, 0...] // Precondition failed: Cannot slice array with ndim 3 more than 3 times.
```

With this API, there is no subtypes returned when slicing, requiring to remember how many times the array was already
sliced. The old slice API is deprecated and will be removed in `0.5.0`.

## Not Implemented

Some features are not implemented yet, but are planned for the near future.

* Elementwise multiplication of Double and Float arrays. Planned as `multiply(elementwiseBy), divide(elementwiseBy)`
  employing `vDSP_vmulD`
  Note that this can be done with help of `map` currently.

## Out of Scope

Some features would be nice to have at some time but currently out of scope.

* Complex number arithmetic (explicit support for complex numbers is not planned). One can create arrays for any type
  though (`NdArray<Complex>`), just arithmetic operations will not be defined. These could of course be added inside
  application code.

## Docs

Read the generated [docs](https://dastrobu.github.io/NdArray/documentation/ndarray).
