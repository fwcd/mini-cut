import Foundation

final class MiniCutState {
    let timeline = Timeline()
    var bijection = (IdentityBijection<CGFloat>() * 4) + 5
    
    init() {}
}
