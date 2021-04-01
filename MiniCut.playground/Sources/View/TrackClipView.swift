import Foundation
import SpriteKit

/// A visual representation of a track's controls.
final class TrackClipView: SKSpriteNode {
    convenience init(
        state: MiniCutState,
        trackId: UUID,
        id: UUID,
        height: CGFloat,
        toViewScale: AnyBijection<TimeInterval, CGFloat>,
        toClipX: AnyBijection<TimeInterval, CGFloat>
    ) {
        // TODO: Subscribe to listeners
        guard let clip = state.timeline[trackId]?[id] else {
            fatalError("Could not find track with id \(trackId)")
        }
        
        self.init(color: clip.clip.content.color, size: CGSize(width: toViewScale.apply(clip.clip.length), height: height))
        
        let aspectRatio: CGFloat = 16 / 9
        let thumbSize = CGSize(width: aspectRatio * height, height: height)
        let thumb = generateThumbnail(from: clip.clip, size: thumbSize)
        thumb.centerLeftPosition = CGPoint(x: frame.minX, y: 0)
        addChild(thumb)
        
        centerLeftPosition = CGPoint(x: toClipX.apply(clip.offset), y: 0)
    }
}
