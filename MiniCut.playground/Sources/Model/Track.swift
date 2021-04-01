import Foundation

/// A sequence of offset clips.
struct Track: Identifiable {
    var id: UUID = UUID()
    var name: String = "New Track"
    var clipsById: [UUID: OffsetClip] = [:]
    var clips: [OffsetClip] { Array(clipsById.values) }
    
    subscript(id: UUID) -> OffsetClip? {
        get { clipsById[id] }
        set { clipsById[id] = newValue }
    }
    
    mutating func insert(clip: OffsetClip) {
        self[clip.id] = clip
    }
}
