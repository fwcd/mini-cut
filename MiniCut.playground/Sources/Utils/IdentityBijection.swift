import Foundation

/// The identity function.
struct IdentityBijection<Value>: Bijection {
    func apply(_ value: Value) -> Value {
        value
    }
    
    func inverseApply(_ value: Value) -> Value {
        value
    }
}
