import Foundation

/// A clip with a position on a track.
struct OffsetClip: Identifiable {
    var id: UUID
    var clip: Clip
    
    private var _offset: TimeInterval
    var offset: TimeInterval {
        get { _offset }
        set { _offset = max(0, newValue) }
    }
    
    init(
        id: UUID = UUID(),
        clip: Clip,
        offset: TimeInterval
    ) {
        self.id = id
        self.clip = clip
        _offset = max(0, offset)
    }
    
    /// Whether the clip is playing at the given track-level offset (e.g. a cursor offset).
    func isPlaying(at trackOffset: TimeInterval) -> Bool {
        trackOffset >= offset && trackOffset < offset + clip.length
    }
    
    /// Converts a track-level offset to a relative offset.
    func relativeOffset(for trackOffset: TimeInterval) -> TimeInterval {
        trackOffset - offset
    }
    
    /// Converts a track-level offset to a clip-level offset.
    func clipOffset(for trackOffset: TimeInterval) -> TimeInterval {
        relativeOffset(for: trackOffset) + clip.start
    }
}
