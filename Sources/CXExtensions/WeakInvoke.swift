import CXShim
import CXUtility

extension Publisher where Failure == Never {
    
    public func invoke<Target: AnyObject>(_ method: @escaping (Target) -> (Output) -> Void, weaklyOn object: Target) -> AnyCancellable {
        let invoke = Subscribers.WeakInvoke(object: object, method: method)
        self.subscribe(invoke)
        return AnyCancellable(invoke)
    }
}

extension Subscribers {
    
    public final class WeakInvoke<Target: AnyObject, Input>: Subscriber, Cancellable, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible {
        
        public typealias Failure = Never
        
        private weak var object: Target?
        
        private let method: (Target) -> (Input) -> Void
        
        private let lock = Lock()
        private var subscription: Subscription?
        
        public init(object: Target, method: @escaping (Target) -> (Input) -> Void) {
            self.object = object
            self.method = method
        }
        
        public func receive(subscription: Subscription) {
            self.lock.lock()
            if self.subscription == nil {
                self.subscription = subscription
                self.lock.unlock()
                subscription.request(.unlimited)
            } else {
                self.lock.unlock()
                subscription.cancel()
            }
        }
        
        public func receive(_ value: Input) -> Subscribers.Demand {
            self.lock.lock()
            guard self.subscription != nil, let obj = self.object else {
                self.lock.unlock()
                return .none
            }
            self.lock.unlock()
            method(obj)(value)
            return .none
        }
        
        public func receive(completion: Subscribers.Completion<Never>) {
            self.cancel()
        }
        
        public func cancel() {
            self.lock.lock()
            guard let subscription = self.subscription else {
                self.lock.unlock()
                return
            }
            
            self.subscription = nil
            self.object = nil
            self.lock.unlock()
            
            subscription.cancel()
        }
        
        public var description: String {
            return "WeakInvoke \(Target.self)"
        }
        
        public var customMirror: Mirror {
            return Mirror(self, children: [
                "object": self.object as Any,
                "method": self.method,
                "upstreamSubscription": self.subscription as Any
            ])
        }
        
        public var playgroundDescription: Any {
            return self.description
        }
    }
}
