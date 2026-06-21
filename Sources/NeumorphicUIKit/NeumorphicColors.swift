import UIKit

/// The four colors the neumorphic surface needs. The host app injects its own
/// palette through ``Neumorphism/configure(_:)`` so this package stays
/// palette-agnostic. Pass dynamic (light/dark) `UIColor`s for automatic dark mode.
public struct NeumorphicColors {
    public let surface: UIColor
    public let darkShadow: UIColor
    public let lightShadow: UIColor
    public let bottom: UIColor

    public init(surface: UIColor, darkShadow: UIColor, lightShadow: UIColor, bottom: UIColor) {
        self.surface = surface
        self.darkShadow = darkShadow
        self.lightShadow = lightShadow
        self.bottom = bottom
    }
}
