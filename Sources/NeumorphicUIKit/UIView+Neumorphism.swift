import UIKit

public extension UIView {
    /// Lays the two offset shadow layers that create the neumorphic "raised" look.
    /// `cornerRadius` defaults to the view's own `layer.cornerRadius`.
    func neumorphism(cornerRadius: CGFloat? = nil, shadowRadius: CGFloat = 5) {
        let colors = Neumorphism.colors
        let corner = cornerRadius ?? layer.cornerRadius

        // ------------ DARK layer
        let darkShadow = CALayer()
        darkShadow.frame = layer.bounds
        darkShadow.name = "darkShadow"
        darkShadow.backgroundColor = colors.surface.cgColor
        darkShadow.shadowColor = colors.darkShadow.cgColor
        darkShadow.cornerRadius = corner
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = shadowRadius
        darkShadow.shadowOffset = CGSize(width: shadowRadius, height: shadowRadius)
        darkShadow.shadowPerformanceBoost()
        layer.insertSublayer(darkShadow, at: 0)

        // ------------ LIGHT layer
        let lightShadow = CALayer()
        lightShadow.name = "lightShadow"
        lightShadow.frame = layer.bounds
        lightShadow.backgroundColor = colors.surface.cgColor
        lightShadow.shadowColor = colors.lightShadow.cgColor
        lightShadow.cornerRadius = corner
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = shadowRadius
        lightShadow.shadowOffset = CGSize(width: -shadowRadius, height: -shadowRadius)
        lightShadow.shadowPerformanceBoost()
        layer.insertSublayer(lightShadow, at: 0)
    }

    /// Refreshes the two shadow layers. Pass `isButtonViewHeld` for the pressed
    /// look; `updateAfterShortDelay` lets a press settle before restoring.
    func addNeumorphicShadows(isButtonViewHeld: Bool = false, updateAfterShortDelay: Bool = false) {
        let colors = Neumorphism.colors
        let isDark = traitCollection.userInterfaceStyle == .dark
        let delay: Double = updateAfterShortDelay ? 0.2 : 0

        if isButtonViewHeld {
            for item in layer.sublayers ?? [] where item.name == "lightShadow" {
                item.backgroundColor = colors.darkShadow.resolvedColor(with: traitCollection).cgColor
                item.shadowColor = isDark
                    ? colors.darkShadow.resolvedColor(with: traitCollection).cgColor
                    : colors.darkShadow.withAlphaComponent(0.50).resolvedColor(with: traitCollection).cgColor
            }
            for item in layer.sublayers ?? [] where item.name == "darkShadow" {
                item.backgroundColor = colors.bottom.resolvedColor(with: traitCollection).cgColor
                item.shadowColor = colors.lightShadow.resolvedColor(with: traitCollection).cgColor
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                for item in self.layer.sublayers ?? [] where item.name == "lightShadow" {
                    item.backgroundColor = colors.surface.resolvedColor(with: self.traitCollection).cgColor
                    item.shadowColor = colors.lightShadow.resolvedColor(with: self.traitCollection).cgColor
                }
                for item in self.layer.sublayers ?? [] where item.name == "darkShadow" {
                    item.backgroundColor = colors.surface.resolvedColor(with: self.traitCollection).cgColor
                    item.shadowColor = colors.darkShadow.resolvedColor(with: self.traitCollection).cgColor
                }
            }
        }
    }
}
