import Foundation

/// The application's state.
final class MiniCutState {
    var timeline = Timeline() {
        willSet { onWillChange.fire(()) }
    }
    var isPlaying: Bool = false {
        willSet { onWillChange.fire(()) }
    }
    
    var onWillChange = ListenerList<Void>()
    
    init() {}
}
