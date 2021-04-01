import Foundation

/// A sequence of offset clips.
struct Track: Identifiable {
    var id: UUID = UUID()
    var name: String = "New Track"
    var clips: [OffsetClip] = []
    
    subscript(id: UUID) -> OffsetClip? {
        clips.first { $0.id == id }
    }
}
