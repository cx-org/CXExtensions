#if USE_COMBINE
import CXCompatible
#else
import CXFoundation
#endif

extension Publisher {
    
    public func ignoreError() -> Publishers.IgnoreError<Self> {
        return .init(upstream: self)
    }
}

extension Publishers {
    
    public struct IgnoreError<Upstream>: Publisher where Upstream: Publisher {
        
        public typealias Output = Upstream.Output
        public typealias Failure = Never
        
        public let upstream: Upstream
        
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            self.upstream
                .catch { _ in
                    Empty()
                }
                .receive(subscriber: subscriber)
        }
    }
}
