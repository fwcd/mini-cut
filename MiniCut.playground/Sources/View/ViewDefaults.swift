import SpriteKit

/// Default configurations for UI elements.
public enum ViewDefaults {
    // MARK: General
    
    public static let fontName: String = "Helvetica"
    public static let fontSize: CGFloat = 24
    public static let padding: CGFloat = 10
    public static let symbolSize: CGFloat = fontSize
    
    // MARK: Color scheme
    
    public static let primary: NSColor = .white
    public static let secondary: NSColor = NSColor(white: 1, alpha: 0.5)
    public static let tertiary: NSColor = NSColor(white: 1, alpha: 0.2)
    public static let quaternary: NSColor = NSColor(white: 1, alpha: 0.1)
    public static let inactiveBgColor: NSColor = tertiary
    public static let activeBgColor: NSColor = quaternary
}
