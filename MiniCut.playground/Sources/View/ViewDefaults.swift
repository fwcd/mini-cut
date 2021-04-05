import SpriteKit

/// Default configurations for UI elements.
public enum ViewDefaults {
    // MARK: General
    
    public static let fontName: String = "Helvetica"
    public static let fontSize: CGFloat = 24
    public static let titleFontSize: CGFloat = 36
    public static let headerFontSize: CGFloat = 18
    public static let padding: CGFloat = 10
    public static let symbolSize: CGFloat = fontSize
    public static let thumbnailSize: CGSize = CGSize(width: 70, height: 39.375)
    public static let thumbnailFontSize: CGFloat = 18
    public static let thumbnailLabelFontSize: CGFloat = 12
    public static let textFieldHeight: CGFloat = 24
    public static let textFieldFontSize: CGFloat = 18
    public static let hintFontSize: CGFloat = 16
    public static let trackHeight: CGFloat = 36
    public static let trackControlsWidth: CGFloat = 100
    public static let trackSpacing: CGFloat = 0
    public static let trimHandleWidth: CGFloat = 10
    public static let trimHandleThickness: CGFloat = 6
    public static let sliderKnobRadius: CGFloat = 10
    public static let sliderTrackThickness: CGFloat = 5
    public static let smallButtonSize: CGFloat = 14
    public static let clipPadding: CGFloat = 2
    public static let clipLabelPadding: CGFloat = 5
    public static let resizeHandleRadius: CGFloat = 6
    
    // MARK: Color scheme
    
    public static let primary: Color = .white
    public static let secondary: Color = Color(white: 1, alpha: 0.5)
    public static let tertiary: Color = Color(white: 1, alpha: 0.2)
    public static let quaternary: Color = Color(white: 1, alpha: 0.1)
    public static let background: Color = Color(white: 0.15, alpha: 1)
    public static let translucentBackground: Color = background.withAlphaComponent(0.5)
    public static let transparent: Color = Color(white: 0, alpha: 0)
    public static let inactiveBgColor: Color = tertiary
    public static let activeBgColor: Color = quaternary
    public static let fieldInactiveBgColor: Color = quaternary
    public static let fieldActiveBgColor: Color = tertiary
    public static let knobInactiveBgColor: Color = primary
    public static let knobActiveBgColor: Color = secondary
    public static let formLabelFontColor: Color = secondary
    public static let hintFontColor: Color = tertiary
    public static let cursorColor: Color = Color(red: 0.7, green: 0.1, blue: 0.1, alpha: 1)
    public static let trimHandleColor: Color = .yellow
    public static let resizeHandleColor: Color = .yellow
}
