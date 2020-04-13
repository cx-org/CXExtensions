import CXShim
import Dispatch

extension Publisher {
    
    public func waitNext() -> Result<Output?, Failure> {
        var result: Result<Output?, Failure>? = nil
        let semaphore = DispatchSemaphore(value: 0)
        let connection = sink(receiveCompletion: { completion in
            switch completion {
            case .finished: result = .success(nil)
            case let .failure(e): result = .failure(e)
            }
            semaphore.signal()
        }, receiveValue: { value in
            result = .success(value)
            semaphore.signal()
        })
        semaphore.wait()
        connection.cancel()
        return result!
    }
}
