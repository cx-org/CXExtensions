import Quick
import XCTest

@testable import CXExtensionsTests

QCKMain([
    DelayedAutoCancellableSpec.self,
    IgnoreErrorSpec.self,
    InvokeSpec.self,
    WaitNextSpec.self,
    WeakAssignSpec.self,
])
