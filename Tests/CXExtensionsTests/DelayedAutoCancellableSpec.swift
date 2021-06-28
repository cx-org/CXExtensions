import XCTest
import CXTest
import CXShim
import CXExtensions

class DelayedAutoCancellableTests: XCTest {
    
    func testCancel() {
        let pub = PassthroughSubject<Int, Never>()
        let sub = TracingSubscriber<Int, Never>(initialDemand: .unlimited)
        let scheduler = VirtualTimeScheduler()
        pub.subscribe(sub)
        let canceller = sub.cancel(after: 5, scheduler: scheduler)
        XCTAssertEqual(sub.events.count, 1)
        pub.send(1)
        XCTAssertEqual(sub.events.count, 2)
        scheduler.advance(by: 2)
        XCTAssertNotNil(sub.subscription)
        pub.send(2)
        XCTAssertEqual(sub.events.count, 3)
        scheduler.advance(by: 3)
        XCTAssertNil(sub.subscription) // auto cancel here
        pub.send(3)
        XCTAssertEqual(sub.events.count, 3)
        canceller.cancel()
        XCTAssertNil(sub.subscription)
    }
}
