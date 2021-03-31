import Foundation
import CoreGraphics

protocol Scalable {
    associatedtype Factor
    
    static func *(lhs: Self, factor: Factor) -> Self
    
    static func /(lhs: Self, divisor: Factor) -> Self
}

extension Int: Scalable {
    typealias Factor = Int
}

extension Double: Scalable {
    typealias Factor = Double
}

extension CGFloat: Scalable {
    typealias Factor = CGFloat
}

extension CGPoint: Scalable {
    typealias Factor = CGFloat
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}
