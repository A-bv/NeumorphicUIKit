import UIKit

/// An invisible helper view that repaints its host's neumorphic shadows when the system
/// switches between light and dark mode, on iOS versions without the iOS 17 trait API.
///
/// It is added as a subview of the styled host, so it inherits the host's appearance and is
/// told when that appearance changes. That lets the package keep the shadows correct on its
/// own, instead of asking the host to call `refreshNeumorphicShadows()` by hand.
final class NeumorphicTraitObserver: UIView {
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("NeumorphicTraitObserver is created in code, never from a nib")
    }

    // `traitCollectionDidChange` is the only appearance hook before iOS 17, and this helper
    // is only installed on those systems, so the deprecation on newer ones does not apply.
    @available(iOS, deprecated: 17.0)
    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        guard traitCollection.userInterfaceStyle != previous?.userInterfaceStyle else { return }
        superview?.refreshNeumorphicShadows()
    }
}
