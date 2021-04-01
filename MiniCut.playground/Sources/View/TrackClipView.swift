import Foundation
import SpriteKit

/// A visual representation of a track's controls.
final class TrackClipView: SKSpriteNode {
    private var clipSubscription: Subscription!
    
    convenience init(
        state: MiniCutState,
        trackId: UUID,
        id: UUID,
        height: CGFloat,
        toViewScale: AnyBijection<TimeInterval, CGFloat>,
        toClipX: AnyBijection<TimeInterval, CGFloat>
    ) {
        self.init()
        
        var hasGeneratedThumb = false
        
        clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [unowned self] in
            guard let clip = $0[trackId]?[id] else { return }
            
            color = clip.clip.content.color
            size = CGSize(width: toViewScale.apply(clip.clip.length), height: height)
            
            centerLeftPosition = CGPoint(x: toClipX.apply(clip.offset), y: 0)
            
            if !hasGeneratedThumb {
                hasGeneratedThumb = true
                let aspectRatio: CGFloat = 16 / 9
                let thumbSize = CGSize(width: aspectRatio * height, height: height)
                let thumb = generateThumbnail(from: clip.clip, size: thumbSize)
                thumb.centerLeftPosition = CGPoint(x: frame.minX, y: 0)
                addChild(thumb)
            }
        }
    }
}
