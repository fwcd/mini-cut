import Foundation
import AVFoundation
import CoreGraphics

/// A trimmed clip of audiovisual content.
struct Clip: Identifiable {
    static var defaultLength: TimeInterval = 10
    
    var id: UUID
    var name: String
    var content: ClipContent
    
    private var _start: TimeInterval
    private var _length: TimeInterval
    
    var start: TimeInterval {
        get { _start }
        set { _start = max(0, newValue) }
    }
    var length: TimeInterval {
        get { _length }
        set { _length = min(max(0, newValue), content.duration.map { $0 - start } ?? .infinity) }
    }
    
    var visualOffsetDx: Double = 0 // Normalized
    var visualOffsetDy: Double = 0
    var visualScale: Double = 1
    var visualAlpha: Double = 1
    
    init(
        id: UUID = UUID(),
        name: String = "<unnamed>",
        content: ClipContent,
        start: TimeInterval = 0,
        length: TimeInterval? = nil
    ) {
        self.id = id
        self.name = name
        self.content = content
        _start = max(0, start)
        _length = max(0, length ?? content.duration ?? Self.defaultLength)
    }
    
    init(url: URL) {
        let asset = AVAsset(url: url)
        self.init(name: url.lastPathComponent, content: .video(.init(asset: asset)))
    }
    
    init?(bundleName: String, extension: String) {
        guard let url = Bundle.main.url(forResource: bundleName, withExtension: `extension`) else { return nil }
        self.init(url: url)
    }
}
