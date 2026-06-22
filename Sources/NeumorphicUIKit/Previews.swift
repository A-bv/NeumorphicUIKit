import SwiftUI
import UIKit

// Living preview for the neumorphic surface, configured with a sample palette so it
// renders standalone. The host app injects its own via `Neumorphism.configure(_:)`.
#Preview("Raised surface") {
    Neumorphism.configure(NeumorphicColors(
        surface: UIColor(white: 0.93, alpha: 1),
        darkShadow: UIColor(white: 0.70, alpha: 1),
        lightShadow: .white,
        bottom: UIColor(white: 0.85, alpha: 1)))

    let canvas = UIView()
    canvas.backgroundColor = UIColor(white: 0.93, alpha: 1)
    let tile = UIView(frame: CGRect(x: 80, y: 160, width: 160, height: 160))
    tile.neumorphism(cornerRadius: 24, shadowRadius: 8)
    canvas.addSubview(tile)
    return canvas
}
