# NeumorphicUIKit

Drop-in neumorphic depth for any `UIView` — with your colors, not ours.

NeumorphicUIKit renders the soft, two-light-source "raised" surface on UIKit views and keeps it correct through presses and light/dark switches. It carries no palette of its own: you inject your app's colors once, so it never clashes with your design system and the same build drops into any app.

## Features
- One call turns any `UIView` into a neumorphic surface.
- Correct dual (light + dark) shadows, rasterized for smooth scrolling.
- Press and dark-mode refresh built in.
- Palette-agnostic — your colors, injected once.

## Requirements
iOS 17 · Swift 5.9

## Installation
```swift
.package(url: "https://github.com/A-bv/NeumorphicUIKit", from: "1.0.0")
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
Raise a view, and refresh it on press or trait change:
```swift
card.neumorphism(cornerRadius: 16, shadowRadius: 6)
button.addNeumorphicShadows(isButtonViewHeld: isPressed)
```
Pass dynamic `UIColor`s (light/dark variants) and dark mode is handled automatically.

> Set the palette before any styled view appears — e.g. in `application(_:didFinishLaunchingWithOptions:)`. Xcode previews must call `configure` themselves; the bundled preview shows how.
