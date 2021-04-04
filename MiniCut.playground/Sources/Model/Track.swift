import Foundation

private let log = Logger(name: "Model.Track")

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
    
    /// Splits the clip at the given (track-level) offset into two clips.
    @discardableResult
    mutating func cut(clipId: UUID, at trackOffset: TimeInterval) -> (leftId: UUID, rightId: UUID)? {
        guard self[clipId]?.isPlaying(at: trackOffset) ?? false else {
            log.warn("Could not cut, not playing at offset \(trackOffset)")
            return nil
        }
        guard let clip = remove(clipId: clipId) else {
            log.warn("Could not cut, invalid clip id: \(clipId)")
            return nil
        }
        
        var left = clip
        var right = clip
        
        let relativeOffset = clip.relativeOffset(for: trackOffset)
        
        left.id = UUID()
        left.clip.length = relativeOffset
        
        right.id = UUID()
        right.offset += relativeOffset
        right.clip.start += relativeOffset
        right.clip.length -= relativeOffset
        
        insert(clip: left)
        insert(clip: right)
        
        return (left.id, right.id)
    }
}
