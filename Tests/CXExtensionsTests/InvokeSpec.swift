import Quick
import Nimble
import CXShim
import CXExtensions

final class InvokeSpec: QuickSpec {
    
    override func spec() {
        
        it("should retain strongly referenced target") {
            let pub = PassthroughSubject<Int, Never>()
            weak var weakObj: AnyObject?
            let connection: AnyCancellable
            do {
                let obj = A<Int>()
                weakObj = obj
                connection = pub.invoke(A.action, on: obj)
                expect(obj.events) == []
                pub.send(1)
                expect(obj.events) == [1]
                pub.send(2)
                expect(obj.events) == [1, 2]
            }
            expect(weakObj).toNot(beNil())
            connection.cancel()
            expect(weakObj).to(beNil())
        }
        
        it("should not retain weakly referenced target") {
            let pub = PassthroughSubject<Int, Never>()
            weak var weakObj: AnyObject?
            let connection: AnyCancellable
            do {
                let obj = A<Int>()
                weakObj = obj
                connection = pub.invoke(A.action, weaklyOn: obj)
                expect(obj.events) == []
                pub.send(1)
                expect(obj.events) == [1]
            }
            expect(weakObj).to(beNil())
            connection.cancel()
        }
        
        it("should invoke parameterless function for publisher with Void output") {
            let pub = PassthroughSubject<Void, Never>()
            let obj = B()
            let connection = pub.invoke(B.action, on: obj)
            expect(obj.eventCount) == 0
            pub.send()
            expect(obj.eventCount) == 1
            connection.cancel()
        }
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
