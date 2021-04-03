import Foundation
import SpriteKit

/// A view of resources available for use in the project.
final class LibraryView: SKSpriteNode {
    private var state: MiniCutState!
    private var dragNDrop: DragNDropController!
    
    private var content: SKNode!
    private var contentSize: CGSize!
    
    private var tabNodes: [Tab: Button] = [:]
    private var activeTab: Tab = .clips {
        didSet {
            updateContent()
            updateTabs()
        }
    }
    
    private enum Tab: String, CaseIterable {
        case clips = "Clips"
        case titles = "Titles"
        case colors = "Colors"
        case sounds = "Sounds"
    }
    
    init(state: MiniCutState, dragNDrop: DragNDropController, size: CGSize) {
        super.init(texture: nil, color: ViewDefaults.quaternary, size: size)
        self.state = state
        self.dragNDrop = dragNDrop
        
        let tabs = Tab.allCases.map { tab in
            (tab, Button(tab.rawValue, height: ViewDefaults.smallButtonSize, fontSize: ViewDefaults.smallButtonSize) { [unowned self] _ in
                activeTab = tab
            })
        }
        
        tabNodes = Dictionary(uniqueKeysWithValues: tabs)
        let tabBar = Stack.horizontal(useFixedPositions: true, tabs.map(\.1))
        let tabBarFrame = tabBar.calculateAccumulatedFrame()
        tabBar.centerPosition = CGPoint(x: 0, y: (size.height / 2) - ViewDefaults.padding - (tabBarFrame.height / 2))
        addChild(tabBar)
        
        content = SKNode()
        contentSize = CGSize(width: size.width, height: size.height - (2 * ViewDefaults.padding) - tabBarFrame.height)
        addChild(content)
        
        updateContent()
        updateTabs()
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    private func updateContent() {
        content.removeAllChildren()
        
        let node: SKNode
        
        switch activeTab {
        case .clips:
            node = LibraryClipsView(state: state, dragNDrop: dragNDrop, category: .video, size: contentSize)
        case .titles:
            node = LibraryStaticClipsView(clips: [
                Clip(name: "Text", content: .text(.init(text: "Text"))),
            ], dragNDrop: dragNDrop, size: contentSize)
        case .colors:
            node = LibraryStaticClipsView(clips: [
                Clip(name: "Black", content: .color(.init(color: .black))),
                Clip(name: "Blue", content: .color(.init(color: .blue))),
                Clip(name: "Green", content: .color(.init(color: .green))),
                Clip(name: "Magenta", content: .color(.init(color: .magenta))),
                Clip(name: "Yellow", content: .color(.init(color: .yellow))),
                Clip(name: "White", content: .color(.init(color: .white))),
            ], dragNDrop: dragNDrop, size: contentSize)
        case .sounds:
            node = LibraryClipsView(state: state, dragNDrop: dragNDrop, category: .audio, size: contentSize)
        }
        
        content.addChild(node)
    }
    
    private func updateTabs() {
        for (tab, node) in tabNodes {
            node.isToggled = tab == activeTab
        }
    }
}
