import Foundation

/// A trimmed clip of audiovisual content.
struct Clip {
    let content: ClipContent
    let start: TimeInterval
    let length: TimeInterval
}
