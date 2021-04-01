import Foundation

/// The application's state.
final class MiniCutState {
    var library = Library(clips: [Clip(bundleName: "bigBuckBunny", extension: "mp4")].compactMap { $0 }) {
        willSet { libraryWillChange.fire(newValue) }
    }
    var timeline = Timeline() {
        willSet { timelineWillChange.fire(newValue) }
    }
    var cursor: TimeInterval = 0 {
        willSet { cursorWillChange.fire(newValue) }
    }
    var isPlaying: Bool = false {
        willSet { isPlayingWillChange.fire(newValue) }
    }
    
    var libraryWillChange = ListenerList<Library>()
    var timelineWillChange = ListenerList<Timeline>()
    var cursorWillChange = ListenerList<TimeInterval>()
    var isPlayingWillChange = ListenerList<Bool>()
    
    init() {}
}
