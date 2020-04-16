import Quick
import XCTest

@testable import CXExtensionsTests

QCKMain([
    AwaitSpec.self,
    DelayedAutoCancellableSpec.self,
    IgnoreErrorSpec.self,
    InvokeSpec.self,
    WeakAssignSpec.self,
])
