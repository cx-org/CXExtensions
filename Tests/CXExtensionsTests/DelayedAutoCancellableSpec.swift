import Quick
import Nimble
import CXTest
import CXShim
import CXExtensions

final class DelayedAutoCancellableSpec: QuickSpec {
    
    override func spec() {
        
        it("should cancel automatically") {
            let pub = PassthroughSubject<Int, Never>()
            let sub = TracingSubscriber<Int, Never>(initialDemand: .unlimited)
            let scheduler = VirtualTimeScheduler()
            pub.subscribe(sub)
            let canceller = sub.cancel(after: 5, scheduler: scheduler)
            expect(sub.events.count) == 1
            pub.send(1)
            expect(sub.events.count) == 2
            scheduler.advance(by: 2)
            expect(sub.subscription).toNot(beNil())
            pub.send(2)
            expect(sub.events.count) == 3
            scheduler.advance(by: 3)
            expect(sub.subscription).to(beNil()) // auto cancel here
            pub.send(3)
            expect(sub.events.count) == 3
            canceller.cancel()
            expect(sub.subscription).to(beNil())
        }
    }
}
