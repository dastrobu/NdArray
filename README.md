# NdArray

N dimensional array package for numeric computing in swift.

The package is inspired by [NumPy](https://www.numpy.org), the well known python package for numerical computations. 
This swift package is certainly far away from the maturity of NumPy but implements some key features
to enable fast and simple handling of multidimensional data.

## Features

 * Multiple views on underlying data.
 * Sliced and strided access.
 * Linear algebra operations for `Double` and `Float` arrays.

## Numerical Backend

Numerical operations are performed using [BLAS](http://www.netlib.org/blas), see also 
[BLAS cheat sheet](http://www.netlib.org/blas/blasqr.pdf) for an overview and [LAPACK](http://www.netlib.org/lapack). 
The functions of these libraries are provided by the 
[Accelerate Framework](https://developer.apple.com/documentation/accelerate) and are available on most Apple platforms.

## Not Implemented

Some features are not implemented yet, but are planned for the near future.
 * Trigonometric functions
 * Elementwise multiplication of Double and Float arrays. Planned as `multiply(elementwiseBy, divide(elementwiseBy)` employing `vDSP_vmulD`

## Out of Scope 

Some features would be nice to have at some time but currently out of scope.

 * Complex numbers (currently support for complex numbers is not planned)

