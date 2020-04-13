import Foundation
import Dispatch
import Quick
import Nimble
import CXShim
import CXExtensions

final class WaitNextSpec: QuickSpec {
    
    override func spec() {
        // TODO: thread method polyfill
        if #available(macOS 10.12, iOS 10.10, tvOS 10.10, watchOS 3.0, *) {
            it("should return next value") {
                let pub = PassthroughSubject<Int, Never>()
                Thread.detachNewThread {
                    Thread.sleep(forTimeInterval: 0.01)
                    pub.send(1)
                }
                let value = pub.waitNext()
                expect(value) == .success(1)
            }
            
            it("should return next failure") {
                let pub = PassthroughSubject<Int, E>()
                Thread.detachNewThread {
                    Thread.sleep(forTimeInterval: 0.01)
                    pub.send(completion: .failure(.e0))
                }
                let value = pub.waitNext()
                expect(value) == .failure(.e0)
            }
        }
    }
}

private enum E: Error {
    case e0
    case e1
}
