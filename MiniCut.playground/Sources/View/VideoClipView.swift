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
    private var isPlayingSubscription: Subscription?
    private(set) var cursorSubscription: Subscription?
    
    private var player: AVPlayer!
    
    convenience init(state: MiniCutState, trackId: UUID, id: UUID, size: CGSize, zIndex: Int) {
        self.init()
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
        case .video(let content):
            player = AVPlayer(playerItem: AVPlayerItem(asset: content.asset))
            let video = SKVideoNode(avPlayer: player)
            video.size = size
            addChild(video)
            
            clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [weak self] in
                guard let currentClip = $0[trackId]?[id] else { return }
                let relative = (state.cursor - currentClip.offset) + currentClip.clip.start
                self?.player.seek(to: CMTime(seconds: relative, preferredTimescale: 1000))
            }
            
            cursorSubscription = state.cursorDidChange.subscribeFiring(state.cursor) { [weak self] in
                guard let currentClip = state.timeline[trackId]?[id] else { return }
                let relative = ($0 - currentClip.offset) + currentClip.clip.start
                self?.player.seek(to: CMTime(seconds: relative, preferredTimescale: 1000))
            }
            
            isPlayingSubscription = state.isPlayingDidChange.subscribeFiring(state.isPlaying) {
                if $0 {
                    video.play()
                } else {
                    video.pause()
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
        default:
            // TODO: Deal with other clip types
            break
        }
    }
    
    deinit {
        log.info("Dropping")
        player?.replaceCurrentItem(with: nil)
    }
}
