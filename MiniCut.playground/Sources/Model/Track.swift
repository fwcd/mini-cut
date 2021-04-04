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
    
    @discardableResult
    mutating func remove(clipId: UUID) -> OffsetClip? {
        let clip = self[clipId]
        self[clipId] = nil
        return clip
    }
    
    /// Splits the clip at the given offset (within the clip) into two clips.
    mutating func cut(clipId: UUID, at offset: TimeInterval) {
        if self[clipId]?.isPlaying(at: offset) ?? false, let clip = remove(clipId: clipId) {
            var left = clip
            var right = clip
            
            left.id = UUID()
            left.clip.length = offset
            
            right.id = UUID()
            right.offset += offset
            right.clip.start += offset
            right.clip.length -= offset
            
            insert(clip: left)
            insert(clip: right)
        }
    }
}
