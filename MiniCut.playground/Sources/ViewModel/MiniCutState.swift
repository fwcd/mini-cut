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
        didSet { cursorDidChange.fire(_cursor) }
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
    private var _timelineOffset: TimeInterval = 0 {
        willSet { timelineOffsetDidChange.fire(newValue) }
        didSet { timelineOffsetDidChange.fire(_timelineOffset) }
    }
    var timelineOffset: TimeInterval {
        get { _timelineOffset }
        set { _timelineOffset = max(0, newValue) }
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
    var timelineOffsetDidChange = ListenerList<Double>()
    var isPlayingDidChange = ListenerList<Bool>()
    
    init() {}
    
    /// Cuts the currently selected clip.
    func cut() {
        if let sel = selection,
           let (leftId, _) = timeline[sel.trackId]?.cut(clipId: sel.clipId, at: cursor) {
            selection?.clipId = leftId
        }
    }
}
