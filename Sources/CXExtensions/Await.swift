import CXShim
import Foundation

extension Publisher {
    
    public func sync() -> Subscribers.Await<Output, Failure> {
        let await = Subscribers.Await<Output, Failure>()
        self.subscribe(await)
        return await
    }
}

extension Subscribers {
    
    public final class Await<Input, Failure: Error>: Subscriber, Cancellable, Sequence, IteratorProtocol {
        
        private enum SubscribingState {
            case awaitingSubscription
            case connected(Subscription)
            case finished(Subscribers.Completion<Failure>)
            case cancelled
        }
        
        private enum DemandingState {
            case idle
            case demanding(CFRunLoop)
            case recived(Input?)
        }
        
        private let lock = NSLock()
        private var subscribingState = SubscribingState.awaitingSubscription
        private var demandingState = DemandingState.idle
        
        public init() {}
        
        public func receive(subscription: Subscription) {
            lock.lock()
            guard case .awaitingSubscription = subscribingState else {
                lock.unlock()
                subscription.cancel()
                return
            }
            subscribingState = .connected(subscription)
            lock.unlock()
        }
        
        public func receive(_ input: Input) -> Subscribers.Demand {
            lock.lock()
            guard case let .demanding(loop) = demandingState else {
                lock.unlock()
                fatalError()
            }
            demandingState = .recived(input)
            lock.unlock()
            CFRunLoopStop(loop)
            return .none
        }
        
        public func receive(completion: Subscribers.Completion<Failure>) {
            lock.lock()
            switch subscribingState {
            case .awaitingSubscription:
                lock.unlock()
                fatalError()
            case .finished, .cancelled:
                lock.unlock()
                return
            case .connected:
                subscribingState = .finished(completion)
                switch demandingState {
                case .idle, .recived:
                    lock.unlock()
                case let .demanding(loop):
                    demandingState = .recived(nil)
                    lock.unlock()
                    CFRunLoopStop(loop)
                }
            }
        }
        
        public func cancel() {
            self.lock.lock()
            guard case let .connected(subscription) = subscribingState else {
                self.lock.unlock()
                return
            }
            subscribingState = .cancelled
            switch demandingState {
            case .idle, .recived:
                lock.unlock()
            case let .demanding(loop):
                demandingState = .recived(nil)
                lock.unlock()
                CFRunLoopStop(loop)
            }
            subscription.cancel()
        }
        
        public func next() -> Input? {
            lock.lock()
            guard case .idle = demandingState else {
                lock.unlock()
                fatalError()
            }
            switch subscribingState {
            case .awaitingSubscription:
                lock.unlock()
                fatalError()
            case .finished, .cancelled:
                return nil
            case let .connected(subscription):
                demandingState = .demanding(CFRunLoopGetCurrent())
                lock.unlock()
                subscription.request(.max(1))
                while true {
                    guard CFRunLoopRunInMode(.defaultMode, .infinity, false) == .stopped else {
                        continue
                    }
                    lock.lock()
                    if case let .recived(value) = demandingState {
                        demandingState = .idle
                        lock.unlock()
                        return value
                    }
                    lock.unlock()
                }
            }
        }
    }
}
