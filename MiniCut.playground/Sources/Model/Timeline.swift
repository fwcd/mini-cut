import Foundation

/// A video project containing (overlayed) tracks.
struct Timeline {
    // Intentionally not a dictionary to preserve order
    var tracks: [Track] = []
    
    subscript(id: UUID) -> Track? {
        get { tracks.first { $0.id == id } }
        set {
            if let newTrack = newValue {
                for (i, track) in tracks.enumerated() {
                    if track.id == id {
                        tracks[i] = newTrack
                        return
                    }
                }
                tracks.append(newTrack)
            } else {
                tracks.removeAll { $0.id == id }
            }
        }
    }
    
    mutating func insert(track: Track) {
        self[track.id] = track
    }
}
