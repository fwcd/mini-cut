/// A type-erased version of Bijection.
struct AnyBijection<Input, Output>: Bijection {
    let _apply: (Input) -> Output
    let _inverseApply: (Output) -> Input
    
    init(_ apply: @escaping (Input) -> Output, _ inverseApply: @escaping (Output) -> Input) {
        _apply = apply
        _inverseApply = inverseApply
    }
    
    init<B>(_ bijection: B) where B: Bijection, B.Input == Input, B.Output == Output {
        _apply = bijection.apply
        _inverseApply = bijection.inverseApply
    }
    
    func apply(_ value: Input) -> Output {
        _apply(value)
    }
    
    func inverseApply(_ value: Output) -> Input {
        _inverseApply(value)
    }
}

extension Bijection {
    /// Type-erases the bijection.
    func erase() -> AnyBijection<Input, Output> {
        AnyBijection(self)
    }
}
