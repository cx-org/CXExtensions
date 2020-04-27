import CXShim

private enum SchedulerTimeLiteral {
    
    case seconds(Int)
    case milliseconds(Int)
    case microseconds(Int)
    case nanoseconds(Int)
    case interval(Double)
    
    var timeInterval: Double {
        switch self {
        case let .seconds(s):       return Double(s)
        case let .milliseconds(ms): return Double(ms) * 1_000
        case let .microseconds(us): return Double(us) * 1_000_000
        case let .nanoseconds(ns):  return Double(ns) * 1_000_000_000
        case let .interval(s):      return s
        }
    }
}

public final class AnyScheduler: Scheduler {

    public typealias SchedulerOptions = Never
    public typealias SchedulerTimeType = AnySchedulerTimeType

    private let _now: () -> SchedulerTimeType
    private let _minimumTolerance: () -> SchedulerTimeType.Stride
    private let _schedule_action: (@escaping () -> Void) -> Void
    private let _schedule_after_tolerance_action: (SchedulerTimeType, SchedulerTimeType.Stride, @escaping () -> Void) -> Void
    private let _schedule_after_interval_tolerance_action: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerTimeType.Stride, @escaping () -> Void) -> Cancellable

    public init<S: Scheduler>(_ scheduler: S, options: S.SchedulerOptions? = nil) {
        _now = {
            SchedulerTimeType(wrapping: scheduler.now)
        }
        _minimumTolerance = {
            SchedulerTimeType.Stride(wrapping: scheduler.minimumTolerance)
        }
        _schedule_action = { action in
            scheduler.schedule(options: options, action)
        }
        _schedule_after_tolerance_action = { date, tolerance, action in
            scheduler.schedule(after: date.wrapped as! S.SchedulerTimeType, tolerance: tolerance.asType(S.SchedulerTimeType.Stride.self), options: options, action)
        }
        _schedule_after_interval_tolerance_action = { date, interval, tolerance, action in
            scheduler.schedule(after: date.wrapped as! S.SchedulerTimeType, interval: interval.asType(S.SchedulerTimeType.Stride.self), tolerance: tolerance.asType(S.SchedulerTimeType.Stride.self), options: options, action)
        }
    }
    
    public var now: SchedulerTimeType {
        return _now()
    }
    
    public var minimumTolerance: SchedulerTimeType.Stride {
        return _minimumTolerance()
    }
    
    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        return _schedule_action(action)
    }
    
    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        return _schedule_after_tolerance_action(date, tolerance, action)
    }
    
    public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        return _schedule_after_interval_tolerance_action(date, interval, tolerance, action)
    }
}

public struct AnySchedulerTimeType: Strideable {
    
    public struct Stride: Comparable, SignedNumeric, SchedulerTimeIntervalConvertible {
        
        private struct Opaque {
            
            let wrapped: Any
            
            let _init: (SchedulerTimeLiteral) -> Opaque
            let _lessThan: (Any) -> Bool
            let _equalTo: (Any) -> Bool
            let _add: (Any) -> Opaque
            let _subtract: (Any) -> Opaque
            let _multiply: (Any) -> Opaque
            
            init<T: Comparable & SignedNumeric & SchedulerTimeIntervalConvertible>(_ content: T) {
                wrapped = content
                _init = { Opaque(T.time(literal: $0)) }
                _lessThan = { content < ($0 as! T) }
                _equalTo = { content < ($0 as! T) }
                _add = { Opaque(content + ($0 as! T)) }
                _subtract = { Opaque(content - ($0 as! T)) }
                _multiply = { Opaque(content * ($0 as! T)) }
            }
        }
        
        private enum Wrapped {
            case opaque(Opaque)
            case literal(SchedulerTimeLiteral)
        }
        
        private var wrapped: Wrapped
        
        private init(_ value: Wrapped) {
            wrapped = value
        }
        
        fileprivate init<T: Comparable & SignedNumeric & SchedulerTimeIntervalConvertible>(wrapping opaque: T) {
            wrapped = .opaque(.init(opaque))
        }
        
        fileprivate func asType<T: Comparable & SignedNumeric & SchedulerTimeIntervalConvertible>(_ type: T.Type) -> T {
            switch wrapped {
            case let .opaque(opaque):
                return opaque.wrapped as! T
            case let .literal(literal):
                return T.time(literal: literal)
            }
        }
        
        public init(integerLiteral value: Int) {
            wrapped = .literal(.seconds(value))
        }
        
        public init?<T: BinaryInteger>(exactly source: T) {
            guard let value = Int(exactly: source) else {
                return nil
            }
            self.init(integerLiteral: value)
        }
        
        public var magnitude: Stride {
            // TODO: magnitude?
            fatalError()
        }
        
        public static func == (lhs: Stride, rhs: Stride) -> Bool {
            switch (lhs.wrapped, rhs.wrapped) {
            case let (.opaque(l), .opaque(r)):
                return l._equalTo(r.wrapped)
            case let (.opaque(l), .literal(r)):
                return l._equalTo(l._init(r).wrapped)
            case let (.literal(l), .opaque(r)):
                return r._init(l)._equalTo(r.wrapped)
            case let (.literal(l), .literal(r)):
                // TODO: potential precision loss
                return l.timeInterval == r.timeInterval
            }
        }
        
        public static func < (lhs: Stride, rhs: Stride) -> Bool {
            switch (lhs.wrapped, rhs.wrapped) {
            case let (.opaque(l), .opaque(r)):
                return l._lessThan(r.wrapped)
            case let (.opaque(l), .literal(r)):
                return l._lessThan(l._init(r).wrapped)
            case let (.literal(l), .opaque(r)):
                return r._init(l)._lessThan(r.wrapped)
            case let (.literal(l), .literal(r)):
                // TODO: potential precision loss
                return l.timeInterval < r.timeInterval
            }
        }
        
        public static func + (lhs: Stride, rhs: Stride) -> Stride {
            switch (lhs.wrapped, rhs.wrapped) {
            case let (.opaque(l), .opaque(r)):
                return .init(.opaque(l._add(r.wrapped)))
            case let (.opaque(l), .literal(r)):
                return .init(.opaque(l._add(l._init(r).wrapped)))
            case let (.literal(l), .opaque(r)):
                return .init(.opaque(r._init(l)._add(r.wrapped)))
            case let (.literal(l), .literal(r)):
                // TODO: potential precision loss
                return .seconds(l.timeInterval + r.timeInterval)
            }
        }
        
        public static func - (lhs: Stride, rhs: Stride) -> Stride {
            switch (lhs.wrapped, rhs.wrapped) {
            case let (.opaque(l), .opaque(r)):
                return .init(.opaque(l._subtract(r.wrapped)))
            case let (.opaque(l), .literal(r)):
                return .init(.opaque(l._subtract(l._init(r).wrapped)))
            case let (.literal(l), .opaque(r)):
                return .init(.opaque(r._init(l)._subtract(r.wrapped)))
            case let (.literal(l), .literal(r)):
                // TODO: potential precision loss
                return .seconds(l.timeInterval - r.timeInterval)
            }
        }
        
        public static func * (lhs: Stride, rhs: Stride) -> Stride {
            switch (lhs.wrapped, rhs.wrapped) {
            case let (.opaque(l), .opaque(r)):
                return .init(.opaque(l._multiply(r.wrapped)))
            case let (.opaque(l), .literal(r)):
                return .init(.opaque(l._multiply(l._init(r).wrapped)))
            case let (.literal(l), .opaque(r)):
                return .init(.opaque(r._init(l)._multiply(r.wrapped)))
            case let (.literal(l), .literal(r)):
                // TODO: potential precision loss
                return .seconds(l.timeInterval * r.timeInterval)
            }
        }
        
        public static func += (lhs: inout Stride, rhs: Stride) {
            lhs = lhs + rhs
        }
        
        public static func -= (lhs: inout Stride, rhs: Stride) {
            lhs = lhs - rhs
        }
        
        public static func *= (lhs: inout Stride, rhs: Stride) {
            lhs = lhs * rhs
        }
        
        public static func seconds(_ s: Double) -> Stride {
            return Stride(.literal(.interval(s)))
        }
        
        public static func seconds(_ s: Int) -> Stride {
            return Stride(.literal(.seconds(s)))
        }
        
        public static func milliseconds(_ ms: Int) -> Stride {
            return Stride(.literal(.milliseconds(ms)))
        }
        
        public static func microseconds(_ us: Int) -> Stride {
            return Stride(.literal(.microseconds(us)))
        }
        
        public static func nanoseconds(_ ns: Int) -> Stride {
            return Stride(.literal(.nanoseconds(ns)))
        }
    }
    
    fileprivate let wrapped: Any
    
    private let _distance_to: (Any) -> Stride
    private let _advanced_by: (Stride) -> AnySchedulerTimeType
    
    fileprivate init<T: Strideable>(wrapping opaque: T) where T.Stride: SchedulerTimeIntervalConvertible {
        self.wrapped = opaque
        self._distance_to = { other in
            return Stride(wrapping: opaque.distance(to: other as! T))
        }
        self._advanced_by = { n in
            return AnySchedulerTimeType(wrapping: opaque.advanced(by: n.asType(T.Stride.self)))
        }
    }
    
    public func distance(to other: AnySchedulerTimeType) -> Stride {
        return _distance_to(other)
    }
    
    public func advanced(by n: Stride) -> AnySchedulerTimeType {
        return _advanced_by(n)
    }
}

private extension SchedulerTimeIntervalConvertible {
    
    static func time(literal: SchedulerTimeLiteral) -> Self {
        switch literal {
        case let .seconds(s):       return .seconds(s)
        case let .milliseconds(ms): return .milliseconds(ms)
        case let .microseconds(us): return .microseconds(us)
        case let .nanoseconds(ns):  return .nanoseconds(ns)
        case let .interval(s):      return .seconds(s)
        }
    }
}
