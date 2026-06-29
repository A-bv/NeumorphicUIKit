import UIKit

public extension UIView {
    /// Adds the two offset shadow layers that create the neumorphic "raised" look and
    /// keeps them correct on their own: they repaint automatically on a light/dark change
    /// (iOS 17+), with no further calls from the host. The shadow keeps the size it's
    /// created at, so set the view's frame before calling. `cornerRadius` defaults to the
    /// view's own `layer.cornerRadius`.
    func neumorphism(cornerRadius: CGFloat? = nil, shadowRadius: CGFloat = 5) {
        let corner = cornerRadius ?? layer.cornerRadius
        for (name, direction) in [("darkShadow", CGFloat(1)), ("lightShadow", CGFloat(-1))] {
            let shadow = CALayer()
            shadow.name = name
            shadow.frame = layer.bounds
            shadow.cornerRadius = corner
            shadow.shadowOpacity = 1
            shadow.shadowRadius = shadowRadius
            shadow.shadowOffset = CGSize(width: direction * shadowRadius, height: direction * shadowRadius)
            shadow.shadowPerformanceBoost()
            layer.insertSublayer(shadow, at: 0)
        }
        applyRestingShadows()
        observeAppearanceChanges()
    }

    /// Pressed (inset) look — call on touch-down.
    func pressDown() {
        let colors = Neumorphism.colors
        let isDark = traitCollection.userInterfaceStyle == .dark
        if let light = sublayer(named: "lightShadow") {
            light.backgroundColor = colors.darkShadow.resolvedColor(with: traitCollection).cgColor
            light.shadowColor = (isDark ? colors.darkShadow : colors.darkShadow.withAlphaComponent(0.5))
                .resolvedColor(with: traitCollection).cgColor
        }
        if let down = sublayer(named: "darkShadow") {
            down.backgroundColor = colors.bottom.resolvedColor(with: traitCollection).cgColor
            down.shadowColor = colors.lightShadow.resolvedColor(with: traitCollection).cgColor
        }
    }

    /// Resting (raised) look — call on touch-up. `settle` holds the pressed look for a
    /// beat first, so a quick tap stays visible.
    func pressUp(settle: Bool = false) {
        guard settle else { return applyRestingShadows() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.applyRestingShadows()
        }
    }

    /// Repaints the resting shadows for the current appearance. Happens automatically on
    /// iOS 17+; on earlier systems call this from the host's `traitCollectionDidChange`.
    func refreshNeumorphicShadows() {
        applyRestingShadows()
    }

    /// Resizes the shadow layers to the view's current `bounds` (and an optional new
    /// `cornerRadius`). The shadows are otherwise fixed at their creation-time size, so call
    /// this from the host's `layoutSubviews` for a shadowed view that changes size — e.g. a
    /// control whose title grows with Dynamic Type. Views that keep their size never need it.
    func resizeNeumorphicShadows(cornerRadius: CGFloat? = nil) {
        for name in ["lightShadow", "darkShadow"] {
            guard let shadow = sublayer(named: name) else { continue }
            shadow.frame = layer.bounds
            if let cornerRadius { shadow.cornerRadius = cornerRadius }
        }
    }
}

private extension UIView {
    func applyRestingShadows() {
        let colors = Neumorphism.colors
        for name in ["lightShadow", "darkShadow"] {
            guard let shadow = sublayer(named: name) else { continue }
            shadow.backgroundColor = colors.surface.resolvedColor(with: traitCollection).cgColor
            shadow.shadowColor = (name == "lightShadow" ? colors.lightShadow : colors.darkShadow)
                .resolvedColor(with: traitCollection).cgColor
        }
    }

    func sublayer(named name: String) -> CALayer? {
        (layer.sublayers ?? []).first { $0.name == name }
    }

    /// Registers the view to repaint itself on a light/dark change. Registering on the
    /// shadowed view (not a parent) means its own `traitCollection` is already settled when
    /// the closure runs, so the repaint is correct synchronously — no deferred work needed.
    func observeAppearanceChanges() {
        guard #available(iOS 17, *) else { return }
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: UIView, _) in
            view.refreshNeumorphicShadows()
        }
    }
}
