import UIKit
import NeumorphicUIKit

// A small, self-contained demo that ties the README snippets together: inject a
// palette once, raise a card, and drive a button's pressed look from its touches.
//
// To run it, add NeumorphicUIKit to an iOS app via Swift Package Manager, drop this
// file in, and make `DemoViewController` the root view controller. Call
// `Neumorphism.configure(.demo)` once at launch — e.g. in the app delegate's
// `application(_:didFinishLaunchingWithOptions:)`, before any styled view appears.
//
// The palette below uses dynamic (light/dark) colors, which is what makes the
// automatic light/dark switch visible.

extension NeumorphicColors {
    /// A sample soft-grey palette with light and dark variants.
    static let demo = NeumorphicColors(
        surface: .demo(light: 0xE0E5EC, dark: 0x2A2D32),
        darkShadow: .demo(light: 0xA3B1C6, dark: 0x181A1E),
        lightShadow: .demo(light: 0xFFFFFF, dark: 0x363A42),
        bottom: .demo(light: 0xC8CED9, dark: 0x1E2025))
}

final class DemoViewController: UIViewController {
    private let card = UIView()
    private let button = UIButton(type: .custom)
    private var styled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .demo(light: 0xE0E5EC, dark: 0x2A2D32)

        view.addSubview(card)

        button.setTitle("Button", for: .normal)
        button.setTitleColor(.demo(light: 0x6B7A90, dark: 0xAEB6C2), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        // Drive the pressed look from the button's own touch events.
        button.addTarget(self, action: #selector(down), for: .touchDown)
        button.addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        view.addSubview(button)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        card.bounds = CGRect(x: 0, y: 0, width: 140, height: 140)
        button.bounds = CGRect(x: 0, y: 0, width: 150, height: 62)
        card.center = CGPoint(x: view.bounds.midX - 95, y: view.bounds.midY)
        button.center = CGPoint(x: view.bounds.midX + 95, y: view.bounds.midY)

        // Style once; the shadows then keep themselves correct on light/dark changes.
        guard !styled else { return }
        styled = true
        card.neumorphism(cornerRadius: 30, shadowRadius: 10)
        button.neumorphism(cornerRadius: 22, shadowRadius: 8)
    }

    @objc private func down() { button.pressDown() }
    @objc private func up() { button.pressUp(settle: true) }
}

private extension UIColor {
    /// A dynamic color built from two `0xRRGGBB` values, one per interface style.
    static func demo(light: UInt, dark: UInt) -> UIColor {
        func rgb(_ hex: UInt) -> UIColor {
            UIColor(red: CGFloat((hex >> 16) & 0xFF) / 255,
                    green: CGFloat((hex >> 8) & 0xFF) / 255,
                    blue: CGFloat(hex & 0xFF) / 255,
                    alpha: 1)
        }
        return UIColor { $0.userInterfaceStyle == .dark ? rgb(dark) : rgb(light) }
    }
}
