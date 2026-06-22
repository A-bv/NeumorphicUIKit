#if DEBUG
import SwiftUI
import UIKit

// Living preview for the neumorphic surface, configured with a sample palette.
// Uses `PreviewProvider` (not the `#Preview` macro) so the package stays iOS 15+.
struct NeumorphicSurface_Previews: PreviewProvider {
    static var previews: some View {
        SurfacePreview()
            .frame(width: 320, height: 420)
    }

    private struct SurfacePreview: UIViewRepresentable {
        func makeUIView(context: Context) -> UIView {
            Neumorphism.configure(NeumorphicColors(
                surface: UIColor(white: 0.93, alpha: 1),
                darkShadow: UIColor(white: 0.70, alpha: 1),
                lightShadow: .white,
                bottom: UIColor(white: 0.85, alpha: 1)))

            let canvas = UIView()
            canvas.backgroundColor = UIColor(white: 0.93, alpha: 1)
            let tile = UIView(frame: CGRect(x: 80, y: 130, width: 160, height: 160))
            tile.neumorphism(cornerRadius: 24, shadowRadius: 8)
            canvas.addSubview(tile)
            return canvas
        }

        func updateUIView(_ uiView: UIView, context: Context) {}
    }
}
#endif
