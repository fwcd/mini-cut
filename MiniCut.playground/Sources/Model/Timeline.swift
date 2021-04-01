import Foundation

/// A video project containing (overlayed) tracks.
struct Timeline {
    var tracks: [Track] = []
    
    subscript(id: UUID) -> Track? {
        tracks.first { $0.id == id }
    }
}
