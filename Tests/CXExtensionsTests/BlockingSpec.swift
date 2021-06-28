import Foundation
import Dispatch
import XCTest
import CXTest
import CXShim
@testable import CXExtensions

class BlockingTests: XCTest {
    
    // TODO: `Thread.detachNewThread(_:)` has system requirement.
    @available(macOS 10.12, iOS 10.10, tvOS 10.10, watchOS 3.0, *)
    func testNextValue() {
        let pub = PassthroughSubject<Int, Never>()
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            pub.send(1)
            pub.send(2)
        }
        let sub = pub.blocking()
        let value = sub.next()
        XCTAssertEqual(value, 1)
        XCTAssertNil(sub.completion)
    }
    
    @available(macOS 10.12, iOS 10.10, tvOS 10.10, watchOS 3.0, *)
    func testNextFailure() {
        let pub = PassthroughSubject<Int, E>()
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            pub.send(completion: .failure(.e0))
        }
        let sub = pub.blocking()
        let value = sub.next()
        XCTAssertNil(value)
        XCTAssertEqual(sub.completion, .failure(.e0))
    }
    
    @available(macOS 10.12, iOS 10.10, tvOS 10.10, watchOS 3.0, *)
    func testSequenceConformance() {
        let source = Array(0..<10)
        let pub = source.cx.publisher
        let sub = pub.blocking()
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 1)
            // in case of deadlock
            sub.cancel()
        }
        let result = Array(sub)
        XCTAssertEqual(result, source)
        XCTAssertEqual(sub.completion, .finished)
    }
    
//    func testRunloopBlocking() {
//        let pub = PassthroughSubject<Int, Never>()
//        RunLoop.current.cx.schedule {
//            pub.send(1)
//        }
//        let value = pub.blocking().next()
//        expect(value) == 1
//    }
}

private enum E: Error {
    case e0
    case e1
}
