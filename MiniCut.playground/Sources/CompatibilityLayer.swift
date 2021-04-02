import Foundation
import SpriteKit

/// A small compatibility layer for running the playground on different platforms
/// like macOS and iOS while sharing a common codebase. This works, since AppKit
/// and UIKit share many similarities, making it easy to abstract over the (few)
/// differences.

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

private func keyboardKey(from char: Character) -> KeyboardKey {
    switch char {
    case Character(UnicodeScalar(NSBackspaceCharacter)!):
        return .backspace
    case Character(UnicodeScalar(NSDeleteCharacter)!):
        return .delete
    default:
        return .char(char)
    }
}

private func keyboardKeys(from event: NSEvent) -> [KeyboardKey] {
    event.charactersIgnoringModifiers?.map(keyboardKey(from:)) ?? []
}

// Slightly hacky, relies on the fact that the Objective-C runtime
// allows us to override methods from extensions.

extension SKNode {
    public dynamic override func mouseDown(with event: NSEvent) {
        (self as? SKInputHandler)?.inputDown(at: event.location(in: self))
    }
    
    public dynamic override func mouseDragged(with event: NSEvent) {
        (self as? SKInputHandler)?.inputDragged(to: event.location(in: self))
    }
    
    public dynamic override func mouseUp(with event: NSEvent) {
        (self as? SKInputHandler)?.inputUp(at: event.location(in: self))
    }
    
    public dynamic override func keyDown(with event: NSEvent) {
        (self as? SKInputHandler)?.inputKeyDown(with: keyboardKeys(from: event))
    }
    
    public dynamic override func keyUp(with event: NSEvent) {
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
        guard let touch = touches.first else { return }
        (self as? SKInputHandler)?.inputDown(at: touch.location(in: self))
    }
    
    public dynamic override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        (self as? SKInputHandler)?.inputDragged(to: touch.location(in: self))
    }
    
    public dynamic override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        (self as? SKInputHandler)?.inputUp(at: touch.location(in: self))
    }
}

#else
#error("Unsupported platform")
#endif
