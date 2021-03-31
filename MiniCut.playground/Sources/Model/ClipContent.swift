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
        let text: String
        let size: CGFloat
        let color: NSColor
    }
    
    struct Video {
        let asset: AVAsset
    }
    
    struct Audio {
        let asset: AVAsset
    }
    
    struct Image {
        let image: NSImage
    }
    
    struct Color {
        let color: NSColor
    }
}
