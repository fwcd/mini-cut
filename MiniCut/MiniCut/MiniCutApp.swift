//
//  MiniCutApp.swift
//  MiniCut
//
//  Created by Fredrik on 3/31/21.
//

import SwiftUI
import SpriteKit

@main
struct MiniCutApp: App {
    var body: some Scene {
        WindowGroup {
            SpriteView(scene: MiniCutScene())
        }
    }
}
