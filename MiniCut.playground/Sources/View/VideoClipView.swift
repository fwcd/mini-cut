import Foundation
import AVFoundation
import SpriteKit

private let cursorActionKey = "cursorAction"
private let cursorStride: TimeInterval = 0.1

private let log = Logger(name: "View.VideoClipView")

/// A view of a single clip's video.
final class VideoClipView: SKNode {
    private let state: MiniCutState
    let trackId: UUID
    let id: UUID
    let zIndex: Int
    
    private var clipSubscription: Subscription?
    private var transformSubscription: Subscription?
    private var selectionSubscription: Subscription?
    private var isPlayingSubscription: Subscription?
    private(set) var cursorSubscription: Subscription?
    
    private var clip: OffsetClip? {
        get { state.timeline[trackId]?[id] }
        set { state.timeline[trackId]?[id] = newValue }
    }
    private var content: ClipContent? {
        get { clip?.clip.content }
        set { clip?.clip.content = newValue! }
    }
    
    private let size: CGSize
    private var actualUnscaledSize: CGSize!
    private var player: AVPlayer!
    private var contentWrapper: SKNode!
    private var handleWrapper: SKNode!
    private var handleNodes: [Corner: SKNode] = [:]
    
    private var dragState: DragState? = nil
    var isResizing: Bool { dragState != nil }
    
    private struct DragState {
        let corner: Corner
        let startPoint: CGPoint
        let startClip: Clip
    }
    
    init(state: MiniCutState, trackId: UUID, id: UUID, size: CGSize, zIndex: Int) {
        self.state = state
        self.trackId = trackId
        self.id = id
        self.size = size
        self.zIndex = zIndex
        
        super.init()
        
        zPosition = CGFloat(100 + zIndex)
        
        log.info("Creating")
        
        contentWrapper = SKNode()
        addChild(contentWrapper)
        
        // We don't attach the entire thing as a timeline listener since we don't want to create a
        // new video node every time the timeline changes. Unfortunately this also means
        // that we cannot swap out the video URL while a VideoClipView is playing
        // (or: we can, but it won't be detected, if the clip's ID stays the same)
        // However, since this is probably an uncommon use case, we ignore it for now.
        
        switch content {
        case .audiovisual(let content):
            player = AVPlayer(playerItem: AVPlayerItem(asset: content.asset))
            actualUnscaledSize = size
            
            let video = SKVideoNode(avPlayer: player)
            video.size = size
            contentWrapper.addChild(video)
            
            let updatePlayer = { [weak self] in
                guard let clip = self?.clip else { return }
                let clipOffset = clip.clipOffset(for: state.cursor)
                self?.player.seek(to: CMTime(seconds: clipOffset, preferredTimescale: 1000))
            }
            
            clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { _ in updatePlayer() }
            cursorSubscription = state.cursorDidChange.subscribeFiring(state.cursor) { _ in updatePlayer() }
            
            isPlayingSubscription = state.isPlayingDidChange.subscribeFiring(state.isPlaying) { [weak self] in
                guard let self = self, let clip = self.clip else { return }
                if $0 {
                    // Changing the volume seems to only be possible while paused
                    self.player.volume = Float(clip.clip.volume)
                    self.player.play()
                } else {
                    self.player.pause()
                }
            }
        case .text(let text):
            let label = Label(text.text, fontSize: text.size, fontColor: text.color)
            actualUnscaledSize = label.frame.size
            
            clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) {
                guard case .text(let currentText) = $0[trackId]?[id]?.clip.content else { return }
                label.text = currentText.text
                label.fontSize = currentText.size
                label.fontColor = currentText.color
            }
            
            contentWrapper.addChild(label)
        case .color(let color):
            let backdrop = SKSpriteNode(color: color.color, size: size)
            actualUnscaledSize = size
            
            clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) {
                guard case .color(let currentColor) = $0[trackId]?[id]?.clip.content else { return }
                backdrop.color = currentColor.color
            }
            
            contentWrapper.addChild(backdrop)
        default:
            // TODO: Deal with other clip types
            break
        }
        
        handleNodes = [Corner: SKNode](uniqueKeysWithValues: Corner.allCases.map { ($0, ResizeHandle()) })
        handleWrapper = SKNode()
        addChild(handleWrapper)
        
        transformSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [weak self] in
            guard let self = self, let clip = $0[trackId]?[id]?.clip else { return }
            
            self.contentWrapper.position = CGPoint(
                x: CGFloat(clip.visualOffsetDx) * size.width,
                y: CGFloat(clip.visualOffsetDy) * size.height
            )
            self.contentWrapper.setScale(CGFloat(clip.visualScale))
            self.contentWrapper.alpha = CGFloat(clip.visualAlpha)
            
            for (corner, handle) in self.handleNodes {
                handle.position = self.convert(self.contentWrapper[cornerPosition: corner], to: self.handleWrapper)
            }
        }
        
        selectionSubscription = state.selectionDidChange.subscribeFiring(state.selection) { [weak self] in
            guard let self = self else { return }
            let isSelected = $0.map { $0.trackId == trackId && $0.clipId == id } ?? false
            
            for handle in self.handleNodes.values {
                self.handleWrapper.setVisibility(of: handle, to: isSelected)
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
        guard let clip = clip, let parent = parent else { return }
        let handlePoint = parent.convert(parentPoint, to: handleWrapper)
        
        for (corner, handle) in self.handleNodes {
            if handle.calculateAccumulatedFrame().contains(handlePoint) {
                dragState = DragState(corner: corner, startPoint: parentPoint, startClip: clip.clip)
                break
            }
        }
    }
    
    func moveResizer(to parentPoint: CGPoint) {
        guard let dragState = dragState, var newClip = clip else { return }

        let dx = parentPoint.x - dragState.startPoint.x
        let dy = parentPoint.y - dragState.startPoint.y
        let normal = dragState.corner.direction
        let length = normal.dx * dx + normal.dy * dy
        let sideLength: CGFloat
        
        switch dragState.corner {
        case .topLeft, .topRight, .bottomLeft, .bottomRight:
            sideLength = (actualUnscaledSize.width + actualUnscaledSize.height) / 2
        case .centerLeft, .centerRight:
            sideLength = actualUnscaledSize.width
        case .topCenter, .bottomCenter:
            sideLength = actualUnscaledSize.height
        }

        let normLength = Double(length / sideLength)
        newClip.clip.visualScale = dragState.startClip.visualScale + (2 * normLength)

        clip = newClip
    }
    
    func finishResizing() {
        dragState = nil
    }
}
