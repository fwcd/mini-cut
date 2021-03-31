import Foundation

/// A facility for pub-sub-style communication.
class ListenerList<Event> {
    private var listeners: [UUID: (Event) -> Void] = [:]
    
    /// Subscribes a listener to this list. Make sure to store the Subscription
    /// somewhere as the listener will be removed once the Subscription is dropped.
    func subscribe(_ listener: @escaping (Event) -> Void) -> Subscription {
        let id = UUID()
        listeners[id] = listener
        return Subscription { [weak self] in
            self?.listeners[id] = nil
        }
    }
    
    func fire(_ event: Event) {
        for listener in listeners.values {
            listener(event)
        }
    }
}
