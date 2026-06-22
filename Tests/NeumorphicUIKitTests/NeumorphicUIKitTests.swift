import Testing
import UIKit
@testable import NeumorphicUIKit

@MainActor
struct NeumorphicUIKitTests {
    @Test func neumorphismInsertsTheTwoNamedShadowLayers() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.neumorphism(cornerRadius: 10, shadowRadius: 5)

        let names = Set((view.layer.sublayers ?? []).compactMap(\.name))
        #expect(names.contains("darkShadow"))
        #expect(names.contains("lightShadow"))
    }

    @Test func addNeumorphicShadowsRepaintsSynchronously() {
        Neumorphism.configure(NeumorphicColors(
            surface: .white, darkShadow: .gray, lightShadow: .red, bottom: .black))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.neumorphism(cornerRadius: 10, shadowRadius: 5)

        // Re-inject a new light-shadow colour, then refresh. The repaint must land
        // synchronously (no async hop), so an appearance change shows the right shadow
        // from its first frame instead of lingering on the old colour.
        Neumorphism.configure(NeumorphicColors(
            surface: .white, darkShadow: .gray, lightShadow: .green, bottom: .black))
        view.addNeumorphicShadows()

        let lightShadow = (view.layer.sublayers ?? []).first { $0.name == "lightShadow" }
        #expect(lightShadow?.shadowColor == UIColor.green.resolvedColor(with: view.traitCollection).cgColor)
    }

    @Test func configureStoresTheInjectedPalette() {
        Neumorphism.configure(NeumorphicColors(
            surface: .red, darkShadow: .green, lightShadow: .blue, bottom: .black))

        #expect(Neumorphism.colors.surface == .red)
        #expect(Neumorphism.colors.darkShadow == .green)
        #expect(Neumorphism.colors.lightShadow == .blue)
        #expect(Neumorphism.colors.bottom == .black)
    }
}
