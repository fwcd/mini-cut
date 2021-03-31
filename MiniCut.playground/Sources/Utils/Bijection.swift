/// An invertible function.
protocol Bijection {
    associatedtype Input
    associatedtype Output
    
    func apply(_ value: Input) -> Output
    
    func inverseApply(_ value: Output) -> Input
}
