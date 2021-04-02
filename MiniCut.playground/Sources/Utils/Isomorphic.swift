import CoreGraphics

/// A structure-preserving bijection from Self to some other type exists.
protocol Isomorphic {
    associatedtype Isomorphism: Bijection
    
    static var isomorphism: Isomorphism { get }
}

extension Double: Isomorphic {
    static var isomorphism: AnyBijection<Double, CGFloat> {
        AnyBijection(CGFloat.init(_:), Double.init(_:))
    }
}

extension CGFloat: Isomorphic {
    static var isomorphism: IdentityBijection<CGFloat> {
        IdentityBijection()
    }
}
