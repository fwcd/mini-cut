import Foundation

/// An opaque object that performs cleanup after being dropped.
class Subscription: Identifiable {
    let id: UUID
    
    private let handleEnd: () -> Void
    
    init(id: UUID = UUID(), handleEnd: @escaping () -> Void) {
        self.id = id
        self.handleEnd = handleEnd
    }
    
    deinit {
        handleEnd()
    }
}
