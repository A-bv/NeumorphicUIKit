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

    @Test func refreshRepaintsShadowsSynchronously() {
        Neumorphism.configure(NeumorphicColors(
            surface: .white, darkShadow: .gray, lightShadow: .red, bottom: .black))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.neumorphism(cornerRadius: 10, shadowRadius: 5)

        // Re-inject a new light-shadow colour, then refresh — the repaint lands
        // synchronously, so an appearance change shows the right shadow immediately.
        Neumorphism.configure(NeumorphicColors(
            surface: .white, darkShadow: .gray, lightShadow: .green, bottom: .black))
        view.refreshNeumorphicShadows()

        let light = (view.layer.sublayers ?? []).first { $0.name == "lightShadow" }
        #expect(light?.shadowColor == UIColor.green.resolvedColor(with: view.traitCollection).cgColor)
    }

    @Test func pressTogglesBetweenPressedAndRestingFills() {
        Neumorphism.configure(NeumorphicColors(
            surface: .white, darkShadow: .gray, lightShadow: .red, bottom: .black))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.neumorphism()
        func lightFill() -> CGColor? {
            (view.layer.sublayers ?? []).first { $0.name == "lightShadow" }?.backgroundColor
        }

        view.pressDown()
        #expect(lightFill() == UIColor.gray.resolvedColor(with: view.traitCollection).cgColor)

        view.pressUp()
        #expect(lightFill() == UIColor.white.resolvedColor(with: view.traitCollection).cgColor)
    }

    @Test func refreshResyncsShadowFrameToBounds() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.neumorphism()

        view.bounds = CGRect(x: 0, y: 0, width: 120, height: 120)
        view.refreshNeumorphicShadows()

        let light = (view.layer.sublayers ?? []).first { $0.name == "lightShadow" }
        #expect(light?.frame.size == CGSize(width: 120, height: 120))
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
