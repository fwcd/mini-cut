import Foundation
import AVFoundation
import SpriteKit

private func generateThumbnail(from clip: Clip, size: CGSize) -> SKSpriteNode {
    do {
        switch clip.content {
        case .image(let image):
            return SKSpriteNode(texture: SKTexture(image: image.image), size: size)
        case .video(let video):
            let gen = AVAssetImageGenerator(asset: video.asset)
            let duration = video.asset.duration
            let cgThumb = try gen.copyCGImage(at: CMTime(seconds: duration.seconds / 2, preferredTimescale: duration.timescale), actualTime: nil)
            let thumb = Image(cgImage: cgThumb)
            return SKSpriteNode(texture: SKTexture(image: thumb), size: size)
        default:
            break
        }
    } catch {
        print("Warning: Could not generate thumbnail: \(error)")
    }
    return SKSpriteNode(color: clip.content.color, size: size)
}

/// A clip with thumbnail in the user's library.
final class LibraryClipView: SKSpriteNode {
    convenience init(clip: Clip, size: CGSize = CGSize(width: 90, height: 50.625)) {
        self.init()
        
        addChild(generateThumbnail(from: clip, size: size))
    }
}

