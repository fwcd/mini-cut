import Foundation

/// A facility for pub-sub-style communication.
class ListenerList<Event> {
    private var listeners: [UUID: (Event) -> Void] = [:]
    private var recursivelyInvoked = Set<UUID>()
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
    
    /// Like subscribe, but fires the listener immediately.
    func subscribeFiring(_ event: Event, _ listener: @escaping (Event) -> Void) -> Subscription {
        listener(event)
        return subscribe(listener)
    }
    
    /// Performs an action without notifying the listener from the given subscription.
    /// This can be useful to avoid cyclic listener invocations.
    func silencing(_ subscription: Subscription?, _ action: () -> Void) {
        if let id = subscription?.id {
            silenced.insert(id)
        }
        action()
        if let id = subscription?.id {
            silenced.remove(id)
        }
    }
    
    func silencing(_ subscriptions: [Subscription], _ action: () -> Void) {
        for sub in subscriptions {
            silenced.insert(sub.id)
        }
        action()
        for sub in subscriptions {
            silenced.remove(sub.id)
        }
    }
    
    func fire(_ event: Event) {
        for (id, listener) in listeners where !silenced.contains(id) {
            if recursivelyInvoked.contains(id) {
                fatalError("Listener \(id) recursively invoked itself, which is forbidden. Please use silencing to resxolve the listener cycle!")
            }
            recursivelyInvoked.insert(id)
            listener(event)
            recursivelyInvoked.remove(id)
        }
    }
}

extension ListenerList where Event == Void {
    func fire() {
        fire(())
    }
    
    func subscribeFiring(_ listener: @escaping (Event) -> Void) -> Subscription {
        subscribeFiring((), listener)
    }
}
