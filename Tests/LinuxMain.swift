import Quick
import XCTest

@testable import CXExtensionsTests

QCKMain([
    AnySchedulerSpec.self,
    DelayedAutoCancellableSpec.self,
    IgnoreErrorSpec.self,
    InvokeSpec.self,
    WeakAssignSpec.self,
])
