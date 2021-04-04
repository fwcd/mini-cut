import Foundation
import AVFoundation
import CoreGraphics

/// A trimmed clip of audiovisual content.
struct Clip: Identifiable {
    static var defaultLength: TimeInterval = 10
    
    var id: UUID
    var name: String
    var category: ClipCategory
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
    
    /// Playback speed factor, 1 corresponds to normal playback rate. Only applies to audiovisual content.
    var speed: Double = 1
    
    init(
        id: UUID = UUID(),
        name: String = "<unnamed>",
        category: ClipCategory = .other,
        content: ClipContent,
        start: TimeInterval = 0,
        length: TimeInterval? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.content = content
        _start = max(0, start)
        _length = max(0, length ?? content.duration ?? Self.defaultLength)
    }
    
    init(url: URL) {
        let asset = AVAsset(url: url)
        self.init(
            name: url.lastPathComponent.split(separator: ".").first.map(String.init) ?? "",
            category: categoryOf(asset: asset),
            content: .audiovisual(.init(asset: asset))
        )
    }
    
    init?(bundleName: String, extension: String) {
        guard let url = Bundle.main.url(forResource: bundleName, withExtension: `extension`) else { return nil }
        self.init(url: url)
    }
    
    var color: Color {
        switch (content, category) {
        case (.text(_), _):
            return Color(red: 0.6, green: 0.3, blue: 0.7, alpha: 1) // purple-ish
        case (.audiovisual(_), .audio):
            return Color(red: 0, green: 0.5, blue: 0, alpha: 1) // green-ish
        case (.color(let color), _):
            return color.color
        default:
            return Color(red: 0, green: 0.4, blue: 0.7, alpha: 1) // blue-ish
        }
    }
}

private func categoryOf(asset: AVAsset) -> ClipCategory {
    if !asset.tracks(withMediaType: .video).isEmpty {
        return .video
    } else if !asset.tracks(withMediaType: .audio).isEmpty {
        return .audio
    } else {
        return .other
    }
}
