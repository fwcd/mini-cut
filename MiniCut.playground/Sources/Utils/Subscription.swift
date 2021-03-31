/// An opaque object that performs cleanup after being dropped.
class Subscription {
    private let handleEnd: () -> Void
    
    init(handleEnd: @escaping () -> Void) {
        self.handleEnd = handleEnd
    }
    
    deinit {
        handleEnd()
    }
}
