import Foundation

/// A video project containing (overlayed) tracks.
struct Timeline {
    /// Intentionally not a dictionary to preserve order.
    /// First element is highest on the z-axis (topmost).
    var tracks: [Track] = []
    
    /// The 'ending' time offset in the timeline.
    var maxOffset: TimeInterval {
        tracks.compactMap { $0.clips.map { $0.offset + $0.clip.length }.max() }.max() ?? 0
    }
    
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
    
    struct PlayingClip: Identifiable {
        let trackId: UUID
        let clip: OffsetClip
        let zIndex: Int
        
        var id: UUID { clip.id }
    }
    
    /// The clips that are playing at the given offset.
    /// First element is highest on the z-axis (topmost).
    func playingClips(at offset: TimeInterval) -> [PlayingClip] {
        tracks
            .flatMap { track in track.clips.filter { $0.isPlaying(at: offset) }.map { (track.id, $0) } }
            .enumerated()
            .map { (i, p) in PlayingClip(trackId: p.0, clip: p.1, zIndex: -i) }
    }
}
