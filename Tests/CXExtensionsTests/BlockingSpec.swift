import Foundation
import Dispatch
import Quick
import Nimble
import CXTest
import CXShim
@testable import CXExtensions

final class BlockingSpec: QuickSpec {
    
    override func spec() {
        // TODO: thread method polyfill
        if #available(macOS 10.12, iOS 10.10, tvOS 10.10, watchOS 3.0, *) {
            it("should return next value") {
                let pub = PassthroughSubject<Int, Never>()
                Thread.detachNewThread {
                    Thread.sleep(forTimeInterval: 0.01)
                    pub.send(1)
                    pub.send(2)
                }
                let sub = pub.blocking()
                let value = sub.next()
                expect(value) == 1
                expect(sub.completion).to(beNil())
            }
            
            it("should return next failure") {
                let pub = PassthroughSubject<Int, E>()
                Thread.detachNewThread {
                    Thread.sleep(forTimeInterval: 0.01)
                    pub.send(completion: .failure(.e0))
                }
                let sub = pub.blocking()
                let value = sub.next()
                expect(value).to(beNil())
                expect(sub.completion) == .failure(.e0)
            }
            it("should be sequence") {
                let source = Array(0..<10)
                let pub = source.cx.publisher
                let sub = pub.blocking()
                Thread.detachNewThread {
                    Thread.sleep(forTimeInterval: 1)
                    // in case of deadlock
                    sub.cancel()
                }
                let result = Array(sub)
                expect(result) == source
                expect(sub.completion) == .finished
            }
            // TODO: non blocking Await
            xit("should not block current runloop") {
                let pub = PassthroughSubject<Int, Never>()
                RunLoop.current.cx.schedule {
                    pub.send(1)
                }
                let value = pub.blocking().next()
                expect(value) == 1
            }
        }
    }
}

private enum E: Error {
    case e0
    case e1
}
