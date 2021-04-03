import Foundation
import AVFoundation

/// Some form of audiovisual content.
enum ClipContent {
    case text(ClipText)
    case audiovisual(ClipAV)
    case image(ClipImage)
    case color(ClipColor)
    
    struct ClipText {
        var text: String = ""
        var size: CGFloat = 24
        var color: Color = .white
    }
    
    struct ClipAV {
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
        case .audiovisual(let av):
            return av.asset.duration.seconds
        default:
            return nil
        }
    }
}
