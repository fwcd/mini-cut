import SpriteKit

/// Default configurations for UI elements.
public enum ViewDefaults {
    // MARK: General
    
    public static let fontName: String = "Helvetica"
    public static let fontSize: CGFloat = 14
    public static let titleFontSize: CGFloat = 36
    public static let headerFontSize: CGFloat = 18
    public static let padding: CGFloat = 10
    public static let symbolSize: CGFloat = fontSize
    
    // MARK: Color scheme
    
    public static let primary: Color = .white
    public static let secondary: Color = Color(white: 1, alpha: 0.5)
    public static let tertiary: Color = Color(white: 1, alpha: 0.2)
    public static let quaternary: Color = Color(white: 1, alpha: 0.1)
    public static let background: Color = Color(white: 0.15, alpha: 1)
    public static let inactiveBgColor: Color = tertiary
    public static let activeBgColor: Color = quaternary
    public static let cursorColor: Color = Color(red: 0.7, green: 0.1, blue: 0.1, alpha: 1)
}
