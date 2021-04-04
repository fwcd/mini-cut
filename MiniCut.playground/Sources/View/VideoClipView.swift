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
    private var isPlayingSubscription: Subscription?
    private(set) var cursorSubscription: Subscription?
    
    private var player: AVPlayer!
    
    init(state: MiniCutState, trackId: UUID, id: UUID, size: CGSize, zIndex: Int) {
        super.init()
        self.state = state
        
        zPosition = CGFloat(100 + zIndex)
        
        log.info("Creating")
        
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
            addChild(video)
            
            let updatePlayer = { [weak self] in
                guard let currentClip = state.timeline[trackId]?[id] else { return }
                let originalRelative = (state.cursor - currentClip.offset) + currentClip.clip.start
                let relative = originalRelative * currentClip.clip.speed
                self?.player.rate = Float(currentClip.clip.speed)
                self?.player.seek(to: CMTime(seconds: relative, preferredTimescale: 1000))
            }
            
            clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { _ in updatePlayer() }
            cursorSubscription = state.cursorDidChange.subscribeFiring(state.cursor) { _ in updatePlayer() }
            
            isPlayingSubscription = state.isPlayingDidChange.subscribeFiring(state.isPlaying) { [weak self] in
                guard let speed = state.timeline[trackId]?[id]?.clip.speed else { return }
                if $0 {
                    self?.player.play()
                    self?.player.rate = Float(speed)
                } else {
                    self?.player.pause()
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
            
            addChild(label)
        case .color(let color):
            let backdrop = SKSpriteNode(color: color.color, size: size)
            
            clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) {
                guard case .color(let currentColor) = $0[trackId]?[id]?.clip.content else { return }
                backdrop.color = currentColor.color
            }
            
            addChild(backdrop)
        default:
            // TODO: Deal with other clip types
            break
        }
        
        transformSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [weak self] in
            guard let currentClip = $0[trackId]?[id]?.clip else { return }
            self?.position = CGPoint(
                x: CGFloat(currentClip.visualOffsetDx) * size.width,
                y: CGFloat(currentClip.visualOffsetDy) * size.height
            )
            self?.setScale(CGFloat(currentClip.visualScale))
            self?.alpha = CGFloat(currentClip.visualAlpha)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    deinit {
        log.info("Dropping")
        player?.replaceCurrentItem(with: nil)
    }
}
