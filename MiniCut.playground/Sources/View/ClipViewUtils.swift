import SpriteKit
import AVFoundation

private struct CacheKey: Hashable {
    let clipId: UUID
    let offset: TimeInterval
}

private var cache = LRUCache<CacheKey, SKTexture>()

/// Creates a thumbnail for the given clip within the given frame.
func generateThumbnail(from clip: Clip, at offset: TimeInterval? = nil, size: CGSize) -> SKNode {
    let offset = offset ?? clip.content.duration ?? 0
    let key = CacheKey(clipId: clip.id, offset: offset)
    var texture: SKTexture?
    
    do {
        if let cached = cache[key] {
            texture = cached
        } else {
            switch (clip.content, clip.category) {
            case (.image(let image), _):
                texture = SKTexture(image: image.image)
            case (.audiovisual(let video), .video):
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
    }
    
    let node = SKSpriteNode(color: clip.color, size: size)
    
    switch (clip.content, clip.category) {
    case (.text(let text), _):
        node.addChild(Label(text.text.truncated(to: 7), fontSize: ViewDefaults.thumbnailFontSize))
    case (.audiovisual(_), .audio):
        let sideLength = min(size.width, size.height)
        node.addChild(SKSpriteNode(texture: IconTextures.audio, size: CGSize(width: sideLength, height: sideLength)))
    default:
        break
    }
    
    return node
}
