import Foundation

/// A video project containing (overlayed) tracks.
final class Timeline {
    var cursor: TimeInterval = 0
    var tracks: [Track] = []
}
