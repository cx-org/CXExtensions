import XCTest
import CXShim
import CXExtensions

class InvokeTests: XCTestCase {
        
    func testStrongRef() {
        let pub = PassthroughSubject<Int, Never>()
        weak var weakObj: AnyObject?
        let connection: AnyCancellable
        do {
            let obj = A<Int>()
            weakObj = obj
            connection = pub.invoke(A.action, on: obj)
            XCTAssertEqual(obj.events, [])
            pub.send(1)
            XCTAssertEqual(obj.events, [1])
            pub.send(2)
            XCTAssertEqual(obj.events, [1, 2])
        }
        XCTAssertNotNil(weakObj)
        connection.cancel()
        XCTAssertNil(weakObj)
    }
    
    func testWeakRef() {
        let pub = PassthroughSubject<Int, Never>()
        weak var weakObj: AnyObject?
        let connection: AnyCancellable
        do {
            let obj = A<Int>()
            weakObj = obj
            connection = pub.invoke(A.action, weaklyOn: obj)
            XCTAssertEqual(obj.events, [])
            pub.send(1)
            XCTAssertEqual(obj.events, [1])
        }
        XCTAssertNil(weakObj)
        connection.cancel()
    }
    
    func testVoidOutput() {
        let pub = PassthroughSubject<Void, Never>()
        let obj = B()
        let connection = pub.invoke(B.action, on: obj)
        XCTAssertEqual(obj.eventCount, 0)
        pub.send()
        XCTAssertEqual(obj.eventCount, 1)
        connection.cancel()
    }
}

private class A<T> {
    
    var events: [T] = []
    
    func action(_ v: T) {
        events.append(v)
    }
}

private class B {
    
    var eventCount = 0
    
    func action() {
        eventCount += 1
    }
}
