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
}
