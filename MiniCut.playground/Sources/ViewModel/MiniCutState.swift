import Foundation

/// The application's state.
final class MiniCutState {
    var timeline = Timeline() {
        willSet { timelineWillChange.fire(newValue) }
    }
    var cursor: TimeInterval = 0 {
        willSet { cursorWillChange.fire(newValue) }
    }
    var isPlaying: Bool = false {
        willSet { isPlayingWillChange.fire(newValue) }
    }
    
    var timelineWillChange = ListenerList<Timeline>()
    var cursorWillChange = ListenerList<TimeInterval>()
    var isPlayingWillChange = ListenerList<Bool>()
    
    init() {}
}
