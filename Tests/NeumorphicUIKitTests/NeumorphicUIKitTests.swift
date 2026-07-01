import Testing
import UIKit
@testable import NeumorphicUIKit

// Serialized because every test shares the `Neumorphism.colors` singleton; running them in
// parallel lets one test's `configure` race into another's assertions.
@Suite(.serialized)
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

    @Test func refreshKeepsShadowSizeWhenBoundsCollapse() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.neumorphism()

        // A view sized by a fixed frame (not constraints) can report zero bounds after
        // layout — the shadow must keep its created size through a repaint, not vanish.
        view.bounds = .zero
        view.refreshNeumorphicShadows()

        let light = (view.layer.sublayers ?? []).first { $0.name == "lightShadow" }
        #expect(light?.frame.size == CGSize(width: 80, height: 80))
    }

    @Test func resizeUpdatesShadowFrameAndCornerToBounds() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 44))
        view.neumorphism(cornerRadius: 22)

        // The view grows (as a Dynamic Type control would); resizing must follow.
        view.bounds = CGRect(x: 0, y: 0, width: 120, height: 70)
        view.resizeNeumorphicShadows(cornerRadius: 35)

        let dark = (view.layer.sublayers ?? []).first { $0.name == "darkShadow" }
        #expect(dark?.frame.size == CGSize(width: 120, height: 70))
        #expect(dark?.cornerRadius == 35)
    }

    @Test func neumorphismIsIdempotentAndDoesNotStackLayers() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.neumorphism()
        view.neumorphism()

        let shadows = (view.layer.sublayers ?? []).filter {
            $0.name == "lightShadow" || $0.name == "darkShadow"
        }
        #expect(shadows.count == 2)
    }

    @Test func settleHoldsThePressedLookThenSettlesToResting() async {
        Neumorphism.configure(NeumorphicColors(
            surface: .white, darkShadow: .gray, lightShadow: .red, bottom: .black))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.neumorphism()
        func lightFill() -> CGColor? {
            (view.layer.sublayers ?? []).first { $0.name == "lightShadow" }?.backgroundColor
        }

        view.pressDown()
        view.pressUp(settle: true)
        // Still pressed right after touch-up...
        #expect(lightFill() == UIColor.gray.resolvedColor(with: view.traitCollection).cgColor)

        // ...and settled to resting once the hold elapses.
        try? await Task.sleep(nanoseconds: 300_000_000)
        #expect(lightFill() == UIColor.white.resolvedColor(with: view.traitCollection).cgColor)
    }

    @available(iOS 17, *)
    @Test func appearanceChangeRepaintsShadowsAfterRepeatedRestyle() {
        // A dark-aware dark-shadow colour: red in light, green in dark.
        Neumorphism.configure(NeumorphicColors(
            surface: .white,
            darkShadow: UIColor { $0.userInterfaceStyle == .dark ? .green : .red },
            lightShadow: .white,
            bottom: .black))

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        window.overrideUserInterfaceStyle = .light
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        window.addSubview(view)
        window.makeKeyAndVisible()

        // Restyle more than once: the trait observer must not stack, and must still fire.
        view.neumorphism()
        view.neumorphism()
        window.layoutIfNeeded()

        func darkShadowColor() -> CGColor? {
            (view.layer.sublayers ?? []).first { $0.name == "darkShadow" }?.shadowColor
        }
        #expect(darkShadowColor() == UIColor.red.cgColor)

        // Flip appearance; the iOS 17 observer should repaint to the dark variant.
        window.overrideUserInterfaceStyle = .dark
        window.layoutIfNeeded()
        #expect(darkShadowColor() == UIColor.green.cgColor)
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
