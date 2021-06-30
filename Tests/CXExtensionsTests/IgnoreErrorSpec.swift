import XCTest
import CXTest
import CXShim
import CXExtensions

class IgnoreErrorTests: XCTestCase {
    
    func testIgnoreError() {
        let pub = PassthroughSubject<Int, E>()
        let sub = TracingSubscriber<Int, Never>(initialDemand: .unlimited)
        pub.ignoreError().subscribe(sub)
        XCTAssertEqual(sub.events.count, 1)
        pub.send(1)
        XCTAssertEqual(sub.events.count, 2)
        pub.send(completion: .failure(.e0))
        XCTAssertEqual(sub.events.dropFirst(), [.value(1), .completion(.finished)])
    }
}

private enum E: Error {
    case e0
    case e1
}
