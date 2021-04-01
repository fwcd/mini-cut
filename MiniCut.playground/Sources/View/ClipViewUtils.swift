import SpriteKit
import AVFoundation

/// Creates a thumbnail for the given clip within the given frame.
func generateThumbnail(from clip: Clip, at offset: TimeInterval? = nil, size: CGSize) -> SKSpriteNode {
    do {
        switch clip.content {
        case .image(let image):
            return SKSpriteNode(texture: SKTexture(image: image.image), size: size)
        case .video(let video):
            let gen = AVAssetImageGenerator(asset: video.asset)
            let duration = video.asset.duration
            let cgThumb = try gen.copyCGImage(at: CMTime(seconds: offset ?? (clip.start + (clip.length / 2)), preferredTimescale: duration.timescale), actualTime: nil)
            let thumb = Image(fromCG: cgThumb)
            return SKSpriteNode(texture: SKTexture(image: thumb), size: size)
        default:
            break
        }
    } catch {
        print("Warning: Could not generate thumbnail: \(error)")
    }
    return SKSpriteNode(color: clip.content.color, size: size)
}
