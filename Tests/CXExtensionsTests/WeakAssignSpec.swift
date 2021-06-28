import XCTest
import CXShim
import CXExtensions

class WeakAssignTests: XCTest {
    
    func testWeakRef() {
        let pub = PassthroughSubject<Int, Never>()
        weak var weakObj: AnyObject?
        let connection: AnyCancellable
        do {
            let obj = A()
            weakObj = obj
            connection = pub.assign(to: \A.x, weaklyOn: obj)
            XCTAssertEqual(obj.events, [])
            pub.send(1)
            XCTAssertEqual(obj.events, [1])
        }
        XCTAssertNil(weakObj)
        connection.cancel()
    }
}

private class A {
    
    var events: [Int] = []
    
    var x = 0 {
        didSet {
            events.append(x)
        }
    }
}
