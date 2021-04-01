import SpriteKit
import AVFoundation

private struct CacheKey: Hashable {
    let clipId: UUID
    let offset: TimeInterval
}

private var cache = LRUCache<CacheKey, SKTexture>()

/// Creates a thumbnail for the given clip within the given frame.
func generateThumbnail(from clip: Clip, at offset: TimeInterval? = nil, size: CGSize) -> SKSpriteNode {
    let offset = offset ?? (clip.start + min(15, clip.length / 2))
    let key = CacheKey(clipId: clip.id, offset: offset)
    var texture: SKTexture?
    
    do {
        
        if let cached = cache[key] {
            texture = cached
        } else {
            switch clip.content {
            case .image(let image):
                texture = SKTexture(image: image.image)
            case .video(let video):
                let gen = AVAssetImageGenerator(asset: video.asset)
                let duration = video.asset.duration
                let cgThumb = try gen.copyCGImage(at: CMTime(seconds: offset, preferredTimescale: duration.timescale), actualTime: nil)
                let thumb = Image(fromCG: cgThumb)
                texture = SKTexture(image: thumb)
            default:
                break
            }
            
            cache[key] = texture
        }
    } catch {
        print("Warning: Could not generate thumbnail: \(error)")
    }
    
    
    if let texture = texture {
        return SKSpriteNode(texture: texture, size: size)
    } else {
        return SKSpriteNode(color: clip.content.color, size: size)
    }
}
