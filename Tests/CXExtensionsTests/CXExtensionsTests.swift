import XCTest
import CXShim
import CXExtensions

final class CXExtensionsTests: XCTestCase {
    
    func testExample() {
        // we just need it to compile before we can use CXTestUtility.
        _ = Just(Void()).invoke(CXExtensionsTests.foo, weaklyOn: self)
    }
    
    func foo() {}

    static var allTests = [
        ("testExample", testExample),
    ]
}
