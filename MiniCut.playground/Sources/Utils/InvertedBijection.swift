/// An inverse view of a bijection.
struct InvertedBijection<Wrapped>: Bijection where Wrapped: Bijection {
    let wrapped: Wrapped
    
    func apply(_ value: Wrapped.Output) -> Wrapped.Input {
        wrapped.inverseApply(value)
    }
    
    func inverseApply(_ value: Wrapped.Input) -> Wrapped.Output {
        wrapped.apply(value)
    }
}

extension Bijection {
    var inverse: InvertedBijection<Self> {
        InvertedBijection(wrapped: self)
    }
}
