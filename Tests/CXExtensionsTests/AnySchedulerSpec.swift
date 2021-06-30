import XCTest
import CXTest
import CXShim
import CXExtensions

class AnySchedulerTests: XCTestCase {
    
    func testAnyScheduler() {
        let scheduler = VirtualTimeScheduler()
        let anyScheduler = AnyScheduler(scheduler)
        var events: [Int] = []
        var cancellers = Set<AnyCancellable>()
        anyScheduler.schedule {
            events.append(1)
        }
        anyScheduler.schedule(after: anyScheduler.now.advanced(by: .seconds(10))) {
            events.append(2)
            anyScheduler.schedule(after: anyScheduler.now.advanced(by: .seconds(20))) {
                events.append(3)
                cancellers.removeAll()
            }
        }
        anyScheduler.schedule {
            events.append(4)
        }
        anyScheduler.schedule(after: anyScheduler.now.advanced(by: .seconds(5)), interval: .seconds(10)) {
            events.append(5)
        }.store(in: &cancellers)
        scheduler.advance(by: 0)
        XCTAssertEqual(events, [1, 4])
        scheduler.advance(by: 40)
        XCTAssertEqual(events, [1, 4, 5, 2, 5, 5, 3])
        // time:                0, 0, 5, 10,15,25,30
    }
}
