#if USE_COMBINE
import CXCompatible
#else
import CXFoundation
#endif

extension Cancellable {
    
    public func cancel<S: Scheduler>(after interval: S.SchedulerTimeType.Stride, tolerance: S.SchedulerTimeType.Stride = .zero, scheduler: S, options: S.SchedulerOptions? = nil) -> DelayedAutoCancellable {
        return DelayedAutoCancellable(cancel: self, after: interval, tolerance: tolerance, scheduler: scheduler, options: options)
    }
}

public final class DelayedAutoCancellable: Cancellable {
    
    private let canceller: Cancellable
    
    private var scheduleCanceller: Cancellable!
    
    public init<S: Scheduler>(cancel: Cancellable, after interval: S.SchedulerTimeType.Stride, tolerance: S.SchedulerTimeType.Stride, scheduler: S, options: S.SchedulerOptions? = nil) {
        self.canceller = cancel
        // FIXME: we should schedule non-repeatedly, but it's not cancellable.
        self.scheduleCanceller = scheduler.schedule(after: scheduler.now.advanced(by: interval), interval: .seconds(.max), tolerance: tolerance, options: options) { [unowned self] in
            self.cancel()
        }
    }
    
    public func cancel() {
        scheduleCanceller.cancel()
        canceller.cancel()
    }
}
