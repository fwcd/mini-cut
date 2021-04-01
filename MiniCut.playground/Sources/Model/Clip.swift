import Foundation
import AVFoundation

/// A trimmed clip of audiovisual content.
struct Clip {
    static var defaultLength: TimeInterval = 5
    
    var content: ClipContent
    var start: TimeInterval
    var length: TimeInterval
    
    init(
        content: ClipContent,
        start: TimeInterval = 0,
        length: TimeInterval? = nil
    ) {
        self.content = content
        self.start = start
        self.length = length ?? content.duration ?? Self.defaultLength
    }
    
    init(url: URL) {
        let asset = AVAsset(url: url)
        self.init(content: .video(.init(asset: asset)))
    }
    
    init?(bundleName: String, extension: String) {
        guard let url = Bundle.main.url(forResource: bundleName, withExtension: `extension`) else { return nil }
        self.init(url: url)
    }
}
