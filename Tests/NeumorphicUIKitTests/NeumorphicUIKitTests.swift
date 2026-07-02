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
        // Still pressed right after touch-up (synchronous, so deterministic).
        #expect(lightFill() == UIColor.gray.resolvedColor(with: view.traitCollection).cgColor)

        // ...and settles to resting once the hold elapses. Poll for it instead of racing a
        // fixed sleep against the 0.2s timer, which is flaky on a loaded CI runner.
        await waitUntil { lightFill() == UIColor.white.resolvedColor(with: view.traitCollection).cgColor }
        #expect(lightFill() == UIColor.white.resolvedColor(with: view.traitCollection).cgColor)
    }

    /// Yields to the main run loop until `condition` holds or `timeout` elapses, so a queued
    /// settle work item can fire. Avoids racing a fixed sleep against a real timer.
    private func waitUntil(timeout: TimeInterval = 2, _ condition: () -> Bool) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
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

    @Test func legacyHelperRepaintsHostWhenAppearanceChanges() {
        // The pre-iOS 17 fallback. Red in light, green in dark.
        Neumorphism.configure(NeumorphicColors(
            surface: .white,
            darkShadow: UIColor { $0.userInterfaceStyle == .dark ? .green : .red },
            lightShadow: .white,
            bottom: .black))

        // Give the host bare named shadow layers *without* neumorphism(), so no iOS 17
        // observer exists and only the helper can drive the repaint.
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        window.overrideUserInterfaceStyle = .light
        let host = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        window.addSubview(host)
        window.makeKeyAndVisible()
        for name in ["lightShadow", "darkShadow"] {
            let layer = CALayer()
            layer.name = name
            host.layer.addSublayer(layer)
        }
        host.refreshNeumorphicShadows()

        host.addSubview(NeumorphicTraitObserver())

        func darkShadowColor() -> CGColor? {
            (host.layer.sublayers ?? []).first { $0.name == "darkShadow" }?.shadowColor
        }
        #expect(darkShadowColor() == UIColor.red.cgColor)

        window.overrideUserInterfaceStyle = .dark
        window.layoutIfNeeded()
        #expect(darkShadowColor() == UIColor.green.cgColor)
    }

    @Test func pressDownDuringPendingSettleKeepsThePressedLook() async {
        Neumorphism.configure(NeumorphicColors(
            surface: .white, darkShadow: .gray, lightShadow: .red, bottom: .black))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.neumorphism()
        func lightFill() -> CGColor? {
            (view.layer.sublayers ?? []).first { $0.name == "lightShadow" }?.backgroundColor
        }

        view.pressDown()
        view.pressUp(settle: true)   // schedules a settle-to-resting in 0.2s
        view.pressDown()             // a fresh press must cancel that pending settle

        // Wait well past the original settle window; the stale timer must not fire and flip
        // the view back to resting mid-press.
        try? await Task.sleep(nanoseconds: 400_000_000)
        #expect(lightFill() == UIColor.gray.resolvedColor(with: view.traitCollection).cgColor)
    }

    @Test func pressDownRecolorsBothLayersInLightMode() {
        Neumorphism.configure(NeumorphicColors(
            surface: .white, darkShadow: .gray, lightShadow: .red, bottom: .black))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.neumorphism()
        let tc = view.traitCollection
        func layer(_ name: String) -> CALayer? {
            (view.layer.sublayers ?? []).first { $0.name == name }
        }

        view.pressDown()
        // All four pressed-state assignments, not just the light layer's fill.
        #expect(layer("lightShadow")?.backgroundColor == UIColor.gray.resolvedColor(with: tc).cgColor)
        #expect(layer("lightShadow")?.shadowColor == UIColor.gray.withAlphaComponent(0.5).resolvedColor(with: tc).cgColor)
        #expect(layer("darkShadow")?.backgroundColor == UIColor.black.resolvedColor(with: tc).cgColor)
        #expect(layer("darkShadow")?.shadowColor == UIColor.red.resolvedColor(with: tc).cgColor)
    }

    @available(iOS 17, *)
    @Test func pressDownUsesFullStrengthShadowInDarkMode() {
        Neumorphism.configure(NeumorphicColors(
            surface: .white, darkShadow: .gray, lightShadow: .red, bottom: .black))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        window.overrideUserInterfaceStyle = .dark
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        window.addSubview(view)
        window.makeKeyAndVisible()
        view.neumorphism()

        view.pressDown()
        // In dark mode the light layer's shadow is the full dark-shadow colour, not the
        // half-alpha variant used in light mode — this exercises the isDark branch.
        let light = (view.layer.sublayers ?? []).first { $0.name == "lightShadow" }
        #expect(light?.shadowColor == UIColor.gray.resolvedColor(with: view.traitCollection).cgColor)
    }

    @Test func operationsOnAnUnstyledViewAreSafeNoOps() async {
        let bare = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))

        // None of these were preceded by neumorphism(); all must be harmless no-ops.
        bare.pressDown()
        bare.pressUp(settle: true)
        bare.refreshNeumorphicShadows()
        bare.resizeNeumorphicShadows(cornerRadius: 10)
        // Let the scheduled settle work item fire; it must not crash on a view with no shadows.
        try? await Task.sleep(nanoseconds: 300_000_000)

        let named = (bare.layer.sublayers ?? []).filter {
            $0.name == "lightShadow" || $0.name == "darkShadow"
        }
        #expect(named.isEmpty)
    }

    @Test func neumorphismAppliesGeometryAndRasterization() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.layer.cornerRadius = 12          // cornerRadius defaults to the view's own value
        view.neumorphism(shadowRadius: 7)

        let dark = (view.layer.sublayers ?? []).first { $0.name == "darkShadow" }
        let light = (view.layer.sublayers ?? []).first { $0.name == "lightShadow" }
        #expect(dark?.cornerRadius == 12)
        #expect(light?.cornerRadius == 12)
        #expect(dark?.shadowRadius == 7)
        // The two layers cast mirrored offsets — this is what makes the surface look raised.
        #expect(dark?.shadowOffset == CGSize(width: 7, height: 7))
        #expect(light?.shadowOffset == CGSize(width: -7, height: -7))
        #expect(dark?.shouldRasterize == true)
        #expect(dark?.rasterizationScale == view.traitCollection.displayScale)
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
