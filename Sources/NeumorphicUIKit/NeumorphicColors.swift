import UIKit

/// The colors the neumorphic surface needs. Every value has a sensible default, so a
/// host app injects only what it wants to override via ``Neumorphism/configure(_:)``.
/// Pass dynamic (light/dark) `UIColor`s for automatic dark mode.
public struct NeumorphicColors {
    public let surface: UIColor
    public let darkShadow: UIColor
    public let lightShadow: UIColor
    public let bottom: UIColor

    public init(
        surface: UIColor = .systemBackground,
        darkShadow: UIColor = .systemGray,
        lightShadow: UIColor = .white,
        bottom: UIColor = .black
    ) {
        self.surface = surface
        self.darkShadow = darkShadow
        self.lightShadow = lightShadow
        self.bottom = bottom
    }
}
