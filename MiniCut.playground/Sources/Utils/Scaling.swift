import Foundation

/// A simple linear mapping.
struct Scaling<Value>: Bijection where Value: Scalable {
    let factor: Value.Factor
    
    func apply(_ value: Value) -> Value {
        value * factor
    }
    
    func inverseApply(_ value: Value) -> Value {
        value / factor
    }
}

/// A simple linear mapping.
struct InverseScaling<Value>: Bijection where Value: Scalable {
    let divisor: Value.Factor
    
    func apply(_ value: Value) -> Value {
        value / divisor
    }
    
    func inverseApply(_ value: Value) -> Value {
        value * divisor
    }
}

extension Bijection where Output: Scalable {
    static func *(lhs: Self, rhs: Output.Factor) -> ComposedBijection<Scaling<Output>, Self> {
        Scaling(factor: rhs).compose(lhs)
    }
    
    static func /(lhs: Self, rhs: Output.Factor) -> ComposedBijection<InverseScaling<Output>, Self> {
        InverseScaling(divisor: rhs).compose(lhs)
    }
}
