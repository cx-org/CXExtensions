import Quick
import Nimble
import CXTest
import CXShim
import CXExtensions

final class AnySchedulerSpec: QuickSpec {
    
    override func spec() {
        
        it("should wrap Scheduler") {
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
            expect(events) == [1, 4]
            scheduler.advance(by: 40)
            expect(events) == [1, 4, 5, 2, 5, 5, 3]
            // time:           0, 0, 5, 10,15,25,30
        }
    }
}
