import Quick
import XCTest

@testable import CXExtensionsTests

QCKMain([
    BlockingSpec.self,
    DelayedAutoCancellableSpec.self,
    IgnoreErrorSpec.self,
    InvokeSpec.self,
    WeakAssignSpec.self,
])
