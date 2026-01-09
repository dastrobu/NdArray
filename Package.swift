// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NdArray",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "NdArray",
            targets: ["NdArray"]),
    ],
    dependencies: {
        // https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/
        var deps: [PackageDescription.Package.Dependency] = []
        #if swift(>=5.6.0)
        deps.append(
            .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
        )
        #endif
        return deps
    }(),
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "NdArray",
            dependencies: []),
        .testTarget(
            name: "NdArrayTests",
            dependencies: ["NdArray"]),
    ]
)
