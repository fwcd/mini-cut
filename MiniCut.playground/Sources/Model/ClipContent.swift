import Foundation
import AppKit
import AVFoundation

/// Some form of audiovisual content.
enum ClipContent {
    case text(Text)
    case video(Video)
    case audio(Audio)
    case image(Image)
    case color(Color)
    
    struct Text {
        var text: String
        var size: CGFloat
        var color: NSColor
    }
    
    struct Video {
        var asset: AVAsset
    }
    
    struct Audio {
        var asset: AVAsset
    }
    
    struct Image {
        var image: NSImage
    }
    
    struct Color {
        var color: NSColor
    }
    
    var duration: TimeInterval? {
        switch self {
        case .video(let video):
            return video.asset.duration.seconds
        case .audio(let audio):
            return audio.asset.duration.seconds
        default:
            return nil
        }
    }
}
