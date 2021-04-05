import Foundation
import AVFoundation
import SpriteKit

private let cursorActionKey = "cursorAction"
private let cursorStride: TimeInterval = 0.1

private let log = Logger(name: "View.VideoClipView")

/// A view of a single clip's video.
final class VideoClipView: SKNode {
    private var state: MiniCutState!
    private var clipSubscription: Subscription?
    private var transformSubscription: Subscription?
    private var selectionSubscription: Subscription?
    private var isPlayingSubscription: Subscription?
    private(set) var cursorSubscription: Subscription?
    
    let trackId: UUID
    let id: UUID
    
    private var player: AVPlayer!
    
    private var dragState: DragState? = nil
    var isResizing: Bool { dragState != nil }
    
    private struct DragState {
        let corner: Corner
    }
    
    init(state: MiniCutState, trackId: UUID, id: UUID, size: CGSize, zIndex: Int) {
        self.trackId = trackId
        self.id = id
        
        super.init()
        self.state = state
        
        zPosition = CGFloat(100 + zIndex)
        
        log.info("Creating")
        
        let contentWrapper = SKNode()
        addChild(contentWrapper)
        
        // We don't attach the entire thing as a timeline listener since we don't want to create a
        // new video node every time the timeline changes. Unfortunately this also means
        // that we cannot swap out the video URL while a VideoClipView is playing
        // (or: we can, but it won't be detected, if the clip's ID stays the same)
        // However, since this is probably an uncommon use case, we ignore it for now.
        
        guard let clip = state.timeline[trackId]?[id] else { return }
        
        switch clip.clip.content {
        case .audiovisual(let content):
            player = AVPlayer(playerItem: AVPlayerItem(asset: content.asset))
            
            let video = SKVideoNode(avPlayer: player)
            video.size = size
            contentWrapper.addChild(video)
            
            let updatePlayer = { [weak self] in
                guard let self = self, let currentClip = state.timeline[trackId]?[id] else { return }
                let clipOffset = currentClip.clipOffset(for: state.cursor)
                self.player.seek(to: CMTime(seconds: clipOffset, preferredTimescale: 1000))
            }
            
            clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { _ in updatePlayer() }
            cursorSubscription = state.cursorDidChange.subscribeFiring(state.cursor) { _ in updatePlayer() }
            
            isPlayingSubscription = state.isPlayingDidChange.subscribeFiring(state.isPlaying) { [weak self] in
                guard let self = self, let currentClip = state.timeline[trackId]?[id] else { return }
                if $0 {
                    // Changing the volume seems to only be possible while paused
                    self.player.volume = Float(currentClip.clip.volume)
                    self.player.play()
                } else {
                    self.player.pause()
                }
            }
        case .text(let text):
            let label = Label(text.text, fontSize: text.size, fontColor: text.color)
            
            clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) {
                guard case .text(let currentText) = $0[trackId]?[id]?.clip.content else { return }
                label.text = currentText.text
                label.fontSize = currentText.size
                label.fontColor = currentText.color
            }
            
            contentWrapper.addChild(label)
        case .color(let color):
            let backdrop = SKSpriteNode(color: color.color, size: size)
            
            clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) {
                guard case .color(let currentColor) = $0[trackId]?[id]?.clip.content else { return }
                backdrop.color = currentColor.color
            }
            
            contentWrapper.addChild(backdrop)
        default:
            // TODO: Deal with other clip types
            break
        }
        
        let handleNodes = [Corner: SKNode](uniqueKeysWithValues: Corner.allCases.map { ($0, ResizeHandle()) })
        let handleWrapper = SKNode()
        addChild(handleWrapper)
        
        transformSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [weak self] in
            guard let self = self, let currentClip = $0[trackId]?[id]?.clip else { return }
            
            contentWrapper.position = CGPoint(
                x: CGFloat(currentClip.visualOffsetDx) * size.width,
                y: CGFloat(currentClip.visualOffsetDy) * size.height
            )
            contentWrapper.setScale(CGFloat(currentClip.visualScale))
            contentWrapper.alpha = CGFloat(currentClip.visualAlpha)
            
            for (corner, handle) in handleNodes {
                handle.position = self.convert(contentWrapper[cornerPosition: corner], to: handleWrapper)
            }
        }
        
        selectionSubscription = state.selectionDidChange.subscribeFiring(state.selection) {
            let isSelected = $0.map { $0.trackId == trackId && $0.clipId == id } ?? false
            
            for handle in handleNodes.values {
                handleWrapper.setVisibility(of: handle, to: isSelected)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    deinit {
        log.info("Dropping")
        player?.replaceCurrentItem(with: nil)
    }
    
    func tryBeginResizing(at parentPoint: CGPoint) {
//        guard let clip = clip, let parent = parent else { return }
//        let point = parent.convert(parentPoint, to: self)
//        
//        if leftHandle.calculateAccumulatedFrame().contains(point) {
//            dragState = DragState(side: .left, startPoint: parentPoint, startClip: clip)
//        } else if rightHandle.calculateAccumulatedFrame().contains(point) {
//            dragState = DragState(side: .right, startPoint: parentPoint, startClip: clip)
//        }
    }
    
    func moveResizer(to parentPoint: CGPoint) {
//        guard let dragState = dragState, var newClip = clip else { return }
//
//        let dx = parentPoint.x - dragState.startPoint.x
//        let delta = toViewScale.inverseApply(dx)
//
//        switch dragState.side {
//        case .left:
//            newClip.offset = dragState.startClip.offset + delta
//            newClip.clip.start = dragState.startClip.clip.start + delta
//            newClip.clip.length = dragState.startClip.clip.length - delta
//        case .right:
//            newClip.clip.length = dragState.startClip.clip.length + delta
//        }
//
//        clip = newClip
    }
    
    func finishResizing() {
//        dragState = nil
    }
}
