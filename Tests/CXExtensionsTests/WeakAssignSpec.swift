import Quick
import Nimble
import CXShim
import CXExtensions

final class WeakAssignSpec: QuickSpec {
    
    override func spec() {
        
        it("should not retain object") {
            let pub = PassthroughSubject<Int, Never>()
            weak var weakObj: AnyObject?
            let connection: AnyCancellable
            do {
                let obj = A()
                weakObj = obj
                connection = pub.assign(to: \A.x, weaklyOn: obj)
                expect(obj.events) == []
                pub.send(1)
                expect(obj.events) == [1]
            }
            expect(weakObj).to(beNil())
            connection.cancel()
        }
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
