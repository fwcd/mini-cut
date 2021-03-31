import Foundation

/// A video project containing (overlayed) tracks.
struct Timeline {
    var cursor: TimeInterval = 0
    var tracks: [Track] = []
}
