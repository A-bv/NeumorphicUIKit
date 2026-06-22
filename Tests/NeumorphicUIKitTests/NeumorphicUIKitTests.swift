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

    @Test func configureStoresTheInjectedPalette() {
        Neumorphism.configure(NeumorphicColors(
            surface: .red, darkShadow: .green, lightShadow: .blue, bottom: .black))

        #expect(Neumorphism.colors.surface == .red)
        #expect(Neumorphism.colors.darkShadow == .green)
        #expect(Neumorphism.colors.lightShadow == .blue)
        #expect(Neumorphism.colors.bottom == .black)
    }
}
