//
// Helpers for testing
//

import XCTest

/// assertion for arrays with accuracy
internal func XCTAssertEqual<T>(_ expression1: @autoclosure () throws -> [T],
                                _ expression2: @autoclosure () throws -> [T],
                                accuracy: T, _ message: @autoclosure () -> String = "",
                                file: StaticString = #file, line: UInt = #line) rethrows where T: FloatingPoint {
    let array1: [T] = try expression1()
    let array2: [T] = try expression2()
    XCTAssertEqual(array1.count, array2.count, file: file, line: line)

    for i in 0..<array1.count {
        XCTAssertEqual(array1[i], array2[i], accuracy: accuracy, "index: \(i)", file: file, line: line)
    }
}
