import Foundation
import SpriteKit

/// A small compatibility layer for running the playground on different platforms.

protocol SKInputHandler {
    func inputDown(at point: CGPoint)
    
    func inputDragged(to point: CGPoint)
    
    func inputUp(at point: CGPoint)
}

#if canImport(AppKit)

import AppKit

public typealias Image = NSImage
public typealias Color = NSColor

// Slightly hacky, relies on the fact that the Objective-C runtime
// allows us to override methods from extensions.

extension SKNode {
    public override func mouseDown(with event: NSEvent) {
        (self as? SKInputHandler)?.inputDown(at: event.location(in: self))
    }
    
    public override func mouseDragged(with event: NSEvent) {
        (self as? SKInputHandler)?.inputDragged(to: event.location(in: self))
    }
    
    public override func mouseUp(with event: NSEvent) {
        (self as? SKInputHandler)?.inputUp(at: event.location(in: self))
    }
}

#elseif canImport(UIKit)

import UIKit

public typealias Image = UIImage
public typealias Color = UIColor

extension SKNode {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        (self as? SKInputHandler)?.inputDown(at: touch.location(in: self))
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        (self as? SKInputHandler)?.inputDragged(to: touch.location(in: self))
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        (self as? SKInputHandler)?.inputUp(at: touch.location(in: self))
    }
}

#else
#error("Unsupported platform")
#endif
