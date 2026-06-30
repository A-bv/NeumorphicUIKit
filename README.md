# NeumorphicUIKit

[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/badge/platform-iOS%2015%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

Drop-in neumorphic depth for any `UIView` — with your colors, not ours.

NeumorphicUIKit renders the soft, two-light-source "raised" surface on UIKit views and keeps it correct through presses and light/dark switches. It carries no palette of its own: you inject your app's colors once, so it never clashes with your design system and the same build drops into any app.

## Features
- One call turns any `UIView` into a neumorphic surface.
- Correct dual (light + dark) shadows, rasterized for smooth scrolling.
- Press and dark-mode refresh built in.
- Palette-agnostic — your colors, injected once.

## Requirements
iOS 15 · Swift 5.9

> Automatic light/dark repaint is built in on iOS 17+. On iOS 15–16, call
> `refreshNeumorphicShadows()` from the host's `traitCollectionDidChange`.

## Installation
```swift
.package(url: "https://github.com/A-bv/NeumorphicUIKit", from: "3.0.0")
```

## Usage
Inject your palette once, at launch:
```swift
Neumorphism.configure(NeumorphicColors(
    surface: .myBackground,
    darkShadow: .myDarkShadow,
    lightShadow: .myLightShadow,
    bottom: .myBottom))
```
Raise a view — it then repaints itself on a light/dark change (iOS 17+) with no further calls:
```swift
card.neumorphism(cornerRadius: 16, shadowRadius: 6)
```
> **Sizing:** the shadow is built at the view's current size. For a fixed-frame view that's
> all you need. For a view that changes size — an Auto Layout view, or a control whose title
> grows with Dynamic Type — keep the shadow matched to the view by calling
> `resizeNeumorphicShadows()` from the host's `layoutSubviews` / `viewDidLayoutSubviews`:
> ```swift
> override func layoutSubviews() {
>     super.layoutSubviews()
>     card.resizeNeumorphicShadows()
> }
> ```
For a tappable control, drive the pressed look from its touch events:
```swift
button.addTarget(self, action: #selector(down), for: .touchDown)        // pressDown()
button.addTarget(self, action: #selector(up), for: .touchUpInside)      // pressUp(settle: true)
```
Pass dynamic `UIColor`s (light/dark variants) and dark mode is handled automatically. On
iOS 15–16 call `refreshNeumorphicShadows()` from the host's `traitCollectionDidChange`.

> Set the palette before any styled view appears — e.g. in `application(_:didFinishLaunchingWithOptions:)`. Xcode previews must call `configure` themselves; the bundled preview shows how.
