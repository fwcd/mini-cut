import Foundation

/// A clip with a position on a track.
struct OffsetClip: Identifiable {
    var id: UUID = UUID()
    var clip: Clip
    var offset: TimeInterval
}
