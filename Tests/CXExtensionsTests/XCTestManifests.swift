import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CXExtensionsTests.allTests),
    ]
}
#endif
