# NdArray

[![Swift Version](https://img.shields.io/badge/swift-5.1-blue.svg)](https://swift.org) 
![Platform](https://img.shields.io/badge/platform-osx--64-lightgray.svg)
[![Build Travis-CI Status](https://travis-ci.org/dastrobu/NdArray.svg?branch=master)](https://travis-ci.org/dastrobu/NdArray) 
[![documentation](https://github.com/dastrobu/NdArray/raw/master/docs/badge.svg?sanitize=true)](https://dastrobu.github.io/NdArray/)

N dimensional array package for numeric computing in swift.

The package is inspired by [NumPy](https://www.numpy.org), the well known python package for numerical computations. 
This swift package is certainly far away from the maturity of NumPy but implements some key features
to enable fast and simple handling of multidimensional data.

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
(generated with [DocToc](https://github.com/thlorenz/doctoc))

- [Multiple Views on Underlying Data.](#multiple-views-on-underlying-data)
- [Sliced and Strided Access](#sliced-and-strided-access)
  - [`UnboundedRange` Slices](#unboundedrange-slices)
  - [`Range` and `ClosdeRange` Slices](#range-and-closderange-slices)
  - [`PartialRangeFrom`, `PartialRangeUpTo` and `PartialRangeThrough` Slices](#partialrangefrom-partialrangeupto-and-partialrangethrough-slices)
- [Linear Algebra Operations for `Double` and `Float` NdArrays.](#linear-algebra-operations-for-double-and-float-ndarrays)
- [Pretty Printing](#pretty-printing)
- [Numerical Backend](#numerical-backend)
- [Not Implemented](#not-implemented)
- [Out of Scope](#out-of-scope)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Multiple Views on Underlying Data

Two arrays can easily point to the same data and data can be modified through both views. This is significantly 
different from the Swift internal array object, which has copy on wrie semantics, meaning you cannot pass around 
pointers to the same data. Whereas this behaviour is very nice for small amounts of data, since it reduces side effects. 
For numerical computation with huge arrays, it is preferable to let the programmer manage copies. 
The behaviour of the NdArray is very similar to NumPy's ndarray object. Here is an example:

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
print(b.strides) // [1]
b[...].set(0)
print(a) // [0.0, 1.0, 0.0, 3.0, 0.0, 5.0, 0.0, 7.0, 0.0, 9.0]
print(b) // [0.0, 0.0, 0.0, 0.0, 0.0]
``` 
This creates an array first, then a strided view on the data, making it easy to set every second element to 0. 

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

### `Range` and `ClosdeRange` Slices

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

## Linear Algebra Operations for `Double` and `Float` NdArrays.

Linear algebra support is currently very basic.
// TODO 
```swift
let A = Matrix<Double>.ones([2, 2])
let x = Vector<Double>.ones(2)
print(A * x) // [2.0, 2.0]
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

## Numerical Backend

Numerical operations are performed using [BLAS](http://www.netlib.org/blas), see also 
[BLAS cheat sheet](http://www.netlib.org/blas/blasqr.pdf) for an overview and [LAPACK](http://www.netlib.org/lapack). 
The functions of these libraries are provided by the 
[Accelerate Framework](https://developer.apple.com/documentation/accelerate) and are available on most Apple platforms.

## Not Implemented

Some features are not implemented yet, but are planned for the near future.
 * Trigonometric functions
 * Elementwise multiplication of Double and Float arrays. Planned as `multiply(elementwiseBy, divide(elementwiseBy)` employing `vDSP_vmulD`
   Note that this can be done with help of `map` currently.

## Out of Scope 

Some features would be nice to have at some time but currently out of scope.

 * Complex numbers (currently support for complex numbers is not planned)

