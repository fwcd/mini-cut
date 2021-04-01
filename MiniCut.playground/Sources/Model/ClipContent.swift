import Foundation
import AVFoundation

/// Some form of audiovisual content.
enum ClipContent {
    case text(ClipText)
    case video(ClipVideo)
    case audio(ClipAudio)
    case image(ClipImage)
    case color(ClipColor)
    
    struct ClipText {
        var text: String
        var size: CGFloat
        var color: Color
    }
    
    struct ClipVideo {
        var asset: AVAsset
    }
    
    struct ClipAudio {
        var asset: AVAsset
    }
    
    struct ClipImage {
        var image: Image
    }
    
    struct ClipColor {
        var color: Color
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
    var color: Color {
        switch self {
        case .text(_):
            return Color(red: 0.6, green: 0.3, blue: 0.7, alpha: 1) // purple-ish
        case .audio(_):
            return Color(red: 0, green: 0.5, blue: 0, alpha: 1) // green-ish
        case .color(let color):
            return color.color
        default:
            return Color(red: 0, green: 0.4, blue: 0.7, alpha: 1) // blue-ish
        }
    }
}
