import Foundation
import SpriteKit

/// A small compatibility layer for running the playground on different platforms
/// like macOS and iOS while sharing a common codebase. This works, since AppKit
/// and UIKit share many similarities, making it easy to abstract over the (few)
/// differences.

private let log = Logger(name: "CompatibilityLayer")

enum KeyboardKey: Hashable {
    case char(Character)
    case backspace
    case delete
}

protocol SKInputHandler {
    func inputDown(at point: CGPoint)
    
    func inputDragged(to point: CGPoint)
    
    func inputUp(at point: CGPoint)
    
    func inputKeyDown(with keys: [KeyboardKey])
    
    func inputKeyUp(with keys: [KeyboardKey])
}

extension SKInputHandler {
    func inputDown(at point: CGPoint) {}
    
    func inputDragged(to point: CGPoint) {}
    
    func inputUp(at point: CGPoint) {}
    
    func inputKeyDown(with keys: [KeyboardKey]) {}
    
    func inputKeyUp(with keys: [KeyboardKey]) {}
}

#if canImport(AppKit)

import AppKit

public typealias Image = NSImage
public typealias Color = NSColor

extension NSImage {
    public convenience init(fromCG cgImage: CGImage) {
        self.init(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
    }
}

private func keyboardKeys(from event: NSEvent) -> [KeyboardKey] {
    switch event.keyCode {
    case 0x33:
        return [.backspace]
    case 0x75:
        return [.delete]
    default:
        return event.charactersIgnoringModifiers?.map { .char($0) } ?? []
    }
}

// Slightly hacky, relies on the fact that the Objective-C runtime
// allows us to override methods from extensions.

extension SKNode {
    public dynamic override func mouseDown(with event: NSEvent) {
        log.debug("Mouse down on \(self)")
        (self as? SKInputHandler)?.inputDown(at: event.location(in: self))
    }
    
    public dynamic override func mouseDragged(with event: NSEvent) {
        log.debug("Mouse dragged on \(self)")
        (self as? SKInputHandler)?.inputDragged(to: event.location(in: self))
    }
    
    public dynamic override func mouseUp(with event: NSEvent) {
        log.debug("Mouse up on \(self)")
        (self as? SKInputHandler)?.inputUp(at: event.location(in: self))
    }
    
    public dynamic override func keyDown(with event: NSEvent) {
        log.debug("Key down on \(self)")
        (self as? SKInputHandler)?.inputKeyDown(with: keyboardKeys(from: event))
    }
    
    public dynamic override func keyUp(with event: NSEvent) {
        log.debug("Key up on \(self)")
        (self as? SKInputHandler)?.inputKeyUp(with: keyboardKeys(from: event))
    }
}

#elseif canImport(UIKit)

import UIKit

public typealias Image = UIImage
public typealias Color = UIColor

extension UIImage {
    public convenience init(fromCG cgImage: CGImage) {
        self.init(cgImage: cgImage)
    }
}

extension SKNode {
    public dynamic override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        log.debug("Touch began on \(self)")
        guard let touch = touches.first else { return }
        (self as? SKInputHandler)?.inputDown(at: touch.location(in: self))
    }
    
    public dynamic override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        log.debug("Touch moved on \(self)")
        guard let touch = touches.first else { return }
        (self as? SKInputHandler)?.inputDragged(to: touch.location(in: self))
    }
    
    public dynamic override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        log.debug("Touch ended on \(self)")
        guard let touch = touches.first else { return }
        (self as? SKInputHandler)?.inputUp(at: touch.location(in: self))
    }
}

#else
#error("Unsupported platform")
#endif
