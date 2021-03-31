import Foundation

final class MiniCutState {
    let timeline = Timeline()
    var bijection: AnyBijection<Never, Never>!
    
    init() {}
}
