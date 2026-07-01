import UIKit

public extension UIView {
    /// Adds the two offset shadow layers that create the neumorphic "raised" look and
    /// keeps them correct on their own: they repaint automatically on a light/dark change
    /// (iOS 17+), with no further calls from the host. The shadow keeps the size it's
    /// created at, so set the view's frame before calling. `cornerRadius` defaults to the
    /// view's own `layer.cornerRadius`.
    func neumorphism(cornerRadius: CGFloat? = nil, shadowRadius: CGFloat = 5) {
        // Re-styling a view (or a reused cell) should replace its shadows, not stack a
        // second pair on top of the first.
        for name in ["lightShadow", "darkShadow"] {
            sublayer(named: name)?.removeFromSuperlayer()
        }
        let corner = cornerRadius ?? layer.cornerRadius
        for (name, direction) in [("darkShadow", CGFloat(1)), ("lightShadow", CGFloat(-1))] {
            let shadow = CALayer()
            shadow.name = name
            shadow.frame = layer.bounds
            shadow.cornerRadius = corner
            shadow.shadowOpacity = 1
            shadow.shadowRadius = shadowRadius
            shadow.shadowOffset = CGSize(width: direction * shadowRadius, height: direction * shadowRadius)
            shadow.shadowPerformanceBoost(scale: traitCollection.displayScale)
            layer.insertSublayer(shadow, at: 0)
        }
        applyRestingShadows()
        observeAppearanceChanges()
    }

    /// Pressed (inset) look — call on touch-down.
    func pressDown() {
        cancelPendingSettle()
        let colors = Neumorphism.colors
        let isDark = traitCollection.userInterfaceStyle == .dark
        // These are drop shadows, not inner shadows, so the inset look is faked by recoloring:
        // each layer is filled with the *opposite* tone of its name and casts the opposite
        // shadow. Hence "lightShadow" takes the dark fill here and vice-versa.
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
        cancelPendingSettle()
        guard settle else { return applyRestingShadows() }
        let work = DispatchWorkItem { [weak self] in
            self?.pendingSettle = nil
            self?.applyRestingShadows()
        }
        pendingSettle = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: work)
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
    // Stable, unique key for the per-view pending-settle work item. A `static let` pointer
    // sidesteps the mutable-static concerns of the `&someVar` associated-object idiom.
    static let pendingSettleKey = malloc(1)!

    /// The not-yet-fired `pressUp(settle:)` work item, if any.
    var pendingSettle: DispatchWorkItem? {
        get { objc_getAssociatedObject(self, UIView.pendingSettleKey) as? DispatchWorkItem }
        set { objc_setAssociatedObject(self, UIView.pendingSettleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Cancels a queued settle so a fresh press (or an immediate resting flip) isn't
    /// clobbered when the old timer fires.
    func cancelPendingSettle() {
        pendingSettle?.cancel()
        pendingSettle = nil
    }

    // Stable key for the stored trait-change registration, so a restyle can drop the
    // previous observer instead of stacking a new one on top of it.
    static let traitRegistrationKey = malloc(1)!

    /// The view's current appearance-change registration, if any. Stored as `Any?` so the
    /// property needs no iOS 17 availability annotation; callers cast at the use site.
    var traitRegistration: Any? {
        get { objc_getAssociatedObject(self, UIView.traitRegistrationKey) }
        set { objc_setAssociatedObject(self, UIView.traitRegistrationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

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
        // Re-styling (e.g. a reused cell) must replace the observer, not stack a second
        // one on top — otherwise a light/dark switch fires the repaint once per restyle.
        if let previous = traitRegistration as? UITraitChangeRegistration {
            unregisterForTraitChanges(previous)
        }
        traitRegistration = registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: UIView, _) in
            view.refreshNeumorphicShadows()
        }
    }
}
