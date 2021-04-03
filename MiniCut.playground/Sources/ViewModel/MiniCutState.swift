import Foundation

/// The application's state.
final class MiniCutState {
    var library = Library(clips: [Clip(bundleName: "bigBuckBunny", extension: "mp4")].compactMap { $0 }) {
        willSet { libraryWillChange.fire(newValue) }
    }
    var timeline = Timeline() {
        willSet { timelineWillChange.fire(newValue) }
        didSet { timelineDidChange.fire(timeline) }
    }
    private var _cursor: TimeInterval = 0 {
        willSet { cursorWillChange.fire(newValue) }
        didSet { cursorDidChange.fire(cursor) }
    }
    var cursor: TimeInterval {
        get { _cursor }
        set { _cursor = max(0, newValue) }
    }
    var selection: Selection? = nil {
        didSet { selectionDidChange.fire(selection) }
    }
    var timelineZoom: Double = 10 {
        didSet { timelineZoomDidChange.fire(timelineZoom) }
    }
    var isPlaying: Bool = false {
        willSet { isPlayingWillChange.fire(newValue) }
        didSet { isPlayingDidChange.fire(isPlaying) }
    }
    
    var libraryWillChange = ListenerList<Library>()
    var timelineWillChange = ListenerList<Timeline>()
    var cursorWillChange = ListenerList<TimeInterval>()
    var isPlayingWillChange = ListenerList<Bool>()
    
    var timelineDidChange = ListenerList<Timeline>()
    var cursorDidChange = ListenerList<TimeInterval>()
    var selectionDidChange = ListenerList<Selection?>()
    var timelineZoomDidChange = ListenerList<Double>()
    var isPlayingDidChange = ListenerList<Bool>()
    
    init() {}
}
