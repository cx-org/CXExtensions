import CXShim
import Foundation
import Dispatch
import CoreFoundation

extension Publisher {
    
    public func blocking() -> Subscribers.Blocking<Output, Failure> {
        let await = Subscribers.Blocking<Output, Failure>()
        self.subscribe(await)
        return await
    }
}

extension Subscribers {
    
    public class Blocking<Input, Failure: Error>: Subscriber, Cancellable, Sequence, IteratorProtocol {
        
        private enum SubscribingState {
            case awaitingSubscription
            case connected(Subscription)
            case finished(Subscribers.Completion<Failure>)
            case cancelled
        }
        
        private enum DemandingState {
            case idle
            case demanding(DispatchSemaphore)
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
            guard case .demanding = demandingState else {
                lock.unlock()
                fatalError()
            }
            lockedSignal(input)
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
                case .demanding:
                    lockedSignal(nil)
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
            case .demanding:
                lockedSignal(nil)
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
                lock.unlock()
                return nil
            case let .connected(subscription):
                return lockedWait(subscription)
            }
        }
        
        func lockedWait(_ subscription: Subscription) -> Input? {
            let semaphore = DispatchSemaphore(value: 0)
            demandingState = .demanding(semaphore)
            lock.unlock()
            subscription.request(.max(1))
            semaphore.wait()
            lock.lock()
            guard case let .recived(value) = demandingState else {
                fatalError("Internal Inconsistency")
            }
            demandingState = .idle
            lock.unlock()
            return value
        }
        
        func lockedSignal(_ value: Input?) {
            guard case let .demanding(semaphore) = demandingState else {
                fatalError("Internal Inconsistency")
            }
            demandingState = .recived(value)
            lock.unlock()
            semaphore.signal()
        }
    }
}

#if false
extension Subscribers {
    
    class AwaitNonBlockingRunLoop: Await {
        override func lockedWait(_ subscription: Subscription) -> Input? {
            // demandingState = .demanding(???)
            lock.unlock()
            subscription.request(.max(1))
            #if canImport(Darwin)
            let runLoopMode = CFRunLoopMode.defaultMode
            let result = CFRunLoopRunResult.stopped
            #else
            let runLoopMode = kCFRunLoopDefaultMode
            let result = kCFRunLoopRunStopped
            #endif
            while true {
                guard CFRunLoopRunInMode(runLoopMode, .infinity, false) == result else {
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
        
        override func lockedSignal(_ value: Input?) {
            
        }
    }
}
#endif