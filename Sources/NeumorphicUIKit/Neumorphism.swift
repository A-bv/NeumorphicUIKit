import UIKit

/// Entry point for the UIKit neumorphic theme. Call ``configure(_:)`` once at
/// launch with the app's palette, then use the `UIView` styling methods.
@MainActor
public enum Neumorphism {
    static var colors = NeumorphicColors()

    /// Injects the app's palette. Call once, before any styled view is shown.
    public static func configure(_ colors: NeumorphicColors) {
        self.colors = colors
    }
}
