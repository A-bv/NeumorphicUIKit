# ``NeumorphicUIKit``

Add a soft, "raised" neumorphic look to any UIKit view — using your own colors.

## Overview

NeumorphicUIKit renders the two-light-source neumorphic shadow on any `UIView`
and keeps it correct through presses and light/dark switches. Inject your palette
once with ``Neumorphism/configure(_:)``, then call `neumorphism(cornerRadius:shadowRadius:)`
on any view. For a pressed look on a button, forward its touch events to
`pressDown()` and `pressUp(settle:)`.

The palette adapts to light and dark automatically when you pass dynamic colors
(a color set from your asset catalog is the simplest). See the
[README](https://github.com/A-bv/NeumorphicUIKit) for a walkthrough and a
runnable example.

## Topics

### Setup

- ``Neumorphism``
- ``NeumorphicColors``
