# NeumorphicUIKit

[![CI](https://github.com/A-bv/NeumorphicUIKit/actions/workflows/ci.yml/badge.svg)](https://github.com/A-bv/NeumorphicUIKit/actions/workflows/ci.yml)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/badge/platform-iOS%2015%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

Soft, "raised" neumorphic depth for any UIKit view (cards, buttons, any control), using your own colors.

![NeumorphicUIKit demo: a raised card and a button that presses, following light and dark](Docs/demo.gif)

> The demo above is [`Examples/DemoApp`](Examples/DemoApp).

## What it does
- Styles any `UIView`, including buttons and other controls.
- Uses the colors you give it, so it matches your app.
- Follows light and dark mode automatically.
- Has a pressed look for buttons.

## Installation
In Xcode: **File > Add Package Dependencies…**, then paste:

```
https://github.com/A-bv/NeumorphicUIKit
```

Or in `Package.swift`:

```swift
.package(url: "https://github.com/A-bv/NeumorphicUIKit", from: "3.2.1")
```

## Usage
You create the views and buttons yourself. NeumorphicUIKit only adds the raised look on top of them.

**1. Set your colors once, at launch.** These four make up the whole look:

```swift
Neumorphism.configure(NeumorphicColors(
    surface: .myBackground,    // the view's fill color
    darkShadow: .myDarkEdge,   // the darker, shaded corner
    lightShadow: .myLightEdge, // the lighter, highlighted corner
    bottom: .myPressedFill))   // the fill shown while a button is pressed
```

For dark mode, give these colors light and dark variants (an asset-catalog color set is simplest). The look then follows the system on its own, with nothing else to call.

**2. Raise any view you made:**

```swift
card.neumorphism(cornerRadius: 16)
```

**3. For a button, forward its touches** to get the pressed look:

```swift
button.neumorphism(cornerRadius: 16)

// Connect the button's touches to the pressed / raised look:
button.addTarget(self, action: #selector(down), for: .touchDown)
button.addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])

@objc func down() { button.pressDown() }            // finger down: pressed look
@objc func up()   { button.pressUp(settle: true) }  // finger up: back to raised
```

## Layout
```
Package.swift   ┐
Sources/        │  the package SwiftPM builds and ships
Tests/          ┘

README.md       ┐
LICENSE         │  docs and license, at the root by convention
CHANGELOG.md    ┘

Examples/       runnable demo app (the GIF above)
Docs/           the README GIF
.github/        CI workflow
.spi.yml        Swift Package Index config
```
It's a **UIKit** library (no SwiftUI API): it adds shadow layers to views you already have.

## License
MIT. See [LICENSE](LICENSE).
