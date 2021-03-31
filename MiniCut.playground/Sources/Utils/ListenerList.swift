import Foundation

/// A facility for pub-sub-style communication.
class ListenerList<Event> {
    private var listeners: [UUID: (Event) -> Void] = [:]
    private var silenced = Set<UUID>()
    
    /// Subscribes a listener to this list. Make sure to store the Subscription
    /// somewhere as the listener will be removed once the Subscription is dropped.
    func subscribe(_ listener: @escaping (Event) -> Void) -> Subscription {
        let id = UUID()
        listeners[id] = listener
        return Subscription(id: id) { [weak self] in
            self?.listeners[id] = nil
        }
    }
    
    /// Performs an action without notifying the listener from the given subscription.
    func silencing(_ subscription: Subscription, _ action: () -> Void) {
        silenced.insert(subscription.id)
        action()
        silenced.remove(subscription.id)
    }
    
    func fire(_ event: Event) {
        for (id, listener) in listeners where !silenced.contains(id) {
            listener(event)
        }
    }
}
