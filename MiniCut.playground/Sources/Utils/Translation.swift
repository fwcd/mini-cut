import Foundation

/// A simple affine mapping.
struct Translation<Value>: Bijection where Value: Translatable {
    let offset: Value.Offset
    
    func apply(_ value: Value) -> Value {
        value + offset
    }
    
    func inverseApply(_ value: Value) -> Value {
        value - offset
    }
}

/// A simple affine mapping.
struct InverseTranslation<Value>: Bijection where Value: Translatable {
    let offset: Value.Offset
    
    func apply(_ value: Value) -> Value {
        value - offset
    }
    
    func inverseApply(_ value: Value) -> Value {
        value + offset
    }
}

extension Bijection where Output: Translatable {
    static func +(lhs: Self, rhs: Output.Offset) -> ComposedBijection<Translation<Output>, Self> {
        Translation(offset: rhs).compose(lhs)
    }
    
    static func -(lhs: Self, rhs: Output.Offset) -> ComposedBijection<InverseTranslation<Output>, Self> {
        InverseTranslation(offset: rhs).compose(lhs)
    }
}
