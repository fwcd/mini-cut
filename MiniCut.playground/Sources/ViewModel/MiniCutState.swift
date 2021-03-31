import Foundation

/// The application's state.
final class MiniCutState {
    var timeline = Timeline() {
        willSet { timelineWillChange.fire() }
    }
    var isPlaying: Bool = false {
        willSet { isPlayingWillChange.fire() }
    }
    
    var timelineWillChange = ListenerList<Void>()
    var isPlayingWillChange = ListenerList<Void>()
    
    init() {}
}
