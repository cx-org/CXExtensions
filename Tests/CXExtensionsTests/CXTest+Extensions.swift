import CXShim
import CXTest

extension TracingSubscriber {
    
    convenience init(initialDemand: Subscribers.Demand) {
        self.init(receiveSubscription: { subscription in
            subscription.request(initialDemand)
        })
    }
}

extension TracingSubscriber: Cancellable {
    public func cancel() {
        self.subscription?.cancel()
        self.releaseSubscription()
    }
}
