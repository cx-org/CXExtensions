import CXShim

extension Cancellable {
    
    /// Automatically cancel itself after specified delay.
    public func cancel<S: Scheduler>(after interval: S.SchedulerTimeType.Stride, tolerance: S.SchedulerTimeType.Stride? = nil, scheduler: S, options: S.SchedulerOptions? = nil) -> DelayedAutoCancellable {
        return DelayedAutoCancellable(cancel: self.cancel, after: interval, tolerance: tolerance, scheduler: scheduler, options: options)
    }
}

/// Automatically cancel itself after specified delay.
public final class DelayedAutoCancellable: Cancellable {
    
    private var cancelBody: (() -> Void)?
    
    private var scheduleCanceller: Cancellable?
    
    public init<S: Scheduler>(cancel: @escaping () -> Void, after interval: S.SchedulerTimeType.Stride, tolerance: S.SchedulerTimeType.Stride? = nil, scheduler: S, options: S.SchedulerOptions? = nil) {
        self.cancelBody = cancel
        // FIXME: we should schedule non-repeatedly, but it's not cancellable.
        self.scheduleCanceller = scheduler.schedule(after: scheduler.now.advanced(by: interval), interval: .seconds(.max), tolerance: tolerance ?? scheduler.minimumTolerance, options: options) { [unowned self] in
            self.cancel()
        }
    }
    
    public func cancel() {
        scheduleCanceller?.cancel()
        scheduleCanceller = nil
        cancelBody?()
        cancelBody = nil
    }
}
