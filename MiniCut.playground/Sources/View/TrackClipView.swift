import Foundation
import SpriteKit

private let trimHandleZPosition: CGFloat = 50

/// A visual representation of a track's controls.
final class TrackClipView: SKSpriteNode {
    private var clipSubscription: Subscription!
    private var selectionSubscription: Subscription!
    
    private var leftHandle: TrimHandle!
    private var rightHandle: TrimHandle!
    
    convenience init(
        state: MiniCutState,
        trackId: UUID,
        id: UUID,
        height: CGFloat,
        toViewScale: AnyBijection<TimeInterval, CGFloat>,
        toClipX: AnyBijection<TimeInterval, CGFloat>
    ) {
        self.init()
        
        let handleSize = CGSize(width: ViewDefaults.trimHandleWidth, height: height)
        leftHandle = TrimHandle(in: handleSize)
        rightHandle = TrimHandle(in: handleSize)
        
        leftHandle.zPosition = trimHandleZPosition
        rightHandle.zPosition = trimHandleZPosition
        
        var hasGeneratedThumb = false
        
        clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [unowned self] in
            guard let clip = $0[trackId]?[id] else { return }
            
            color = clip.clip.content.color
            size = CGSize(width: toViewScale.apply(clip.clip.length), height: height)
            
            centerLeftPosition = CGPoint(x: toClipX.apply(clip.offset), y: 0)
            leftHandle.centerLeftPosition = CGPoint(x: -(size.width / 2), y: 0)
            rightHandle.centerRightPosition = CGPoint(x: (size.width / 2), y: 0)
            
            if !hasGeneratedThumb {
                hasGeneratedThumb = true
                let aspectRatio: CGFloat = 16 / 9
                let thumbSize = CGSize(width: aspectRatio * height, height: height)
                let thumb = generateThumbnail(from: clip.clip, size: thumbSize)
                thumb.centerLeftPosition = CGPoint(x: -(size.width / 2), y: 0)
                addChild(thumb)
            }
        }
        
        selectionSubscription = state.selectionDidChange.subscribeFiring(state.selection) { [unowned self] in
            if let selection = $0, selection.trackId == trackId && selection.clipId == id {
                if leftHandle.parent == nil {
                    addChild(leftHandle)
                }
                if rightHandle.parent == nil {
                    addChild(rightHandle)
                }
            } else {
                if leftHandle.parent != nil {
                    leftHandle.removeFromParent()
                }
                if rightHandle.parent != nil {
                    rightHandle.removeFromParent()
                }
            }
        }
    }
}
