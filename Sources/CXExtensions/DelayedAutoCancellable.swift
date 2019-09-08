#if USE_COMBINE
import CXCompatible
#else
import CXFoundation
#endif

extension Cancellable {
    
    public func cancel<S: Scheduler>(after interval: S.SchedulerTimeType.Stride, tolerance: S.SchedulerTimeType.Stride, scheduler: S, options: S.SchedulerOptions?) -> DelayedAutoCancellable {
        let cancel = DelayedAutoCancellable(self)
        scheduler.schedule(after: scheduler.now.advanced(by: interval), tolerance: tolerance, options: options) {
            cancel.cancel()
        }
        return cancel
    }
}

public final class DelayedAutoCancellable: Cancellable {
    
    private let c: Cancellable
    
    init<C>(_ cancel: C) where C: Cancellable {
        self.c = cancel
    }
    
    public func cancel() {
        self.c.cancel()
    }
}
