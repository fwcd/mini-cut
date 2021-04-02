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
        case sounds = "Sounds"
    }
    
    convenience init(state: MiniCutState, dragNDrop: DragNDropController, size: CGSize) {
        self.init(color: ViewDefaults.quaternary, size: size)
        self.state = state
        self.dragNDrop = dragNDrop
        
        let tabs = Tab.allCases.map { tab in
            (tab, Button(tab.rawValue, height: 14, fontSize: 14) { [unowned self] _ in
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
    
    private func updateContent() {
        content.removeAllChildren()
        switch activeTab {
        case .clips:
            content.addChild(LibraryClipsView(state: state, dragNDrop: dragNDrop, size: contentSize))
        case .titles:
            break // TODO
        case .sounds:
            break // TODO
        }
    }
    
    private func updateTabs() {
        for (tab, node) in tabNodes {
            node.isToggled = tab == activeTab
        }
    }
}
