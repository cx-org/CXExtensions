import Quick
import Nimble
import CXTest
import CXShim
import CXExtensions

final class IgnoreErrorSpec: QuickSpec {
    
    override func spec() {
        
        it("should ignore error") {
            let pub = PassthroughSubject<Int, E>()
            let sub = TracingSubscriber<Int, Never>(initialDemand: .unlimited)
            pub.ignoreError().subscribe(sub)
            expect(sub.events.count) == 1
            pub.send(1)
            expect(sub.events.count) == 2
            pub.send(completion: .failure(.e0))
            expect(sub.events.dropFirst()) == [.value(1), .completion(.finished)]
        }
    }
}

private enum E: Error {
    case e0
    case e1
}
