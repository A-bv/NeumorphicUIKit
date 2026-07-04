# DemoApp

The little demo shown in the [main README](../../README.md) GIF: a raised card and a
button whose pressed look follows its touches, adapting automatically to light and dark.

[`DemoViewController.swift`](DemoViewController.swift) is a single, self-contained file
that ties together everything the README describes — injecting a palette, raising a
view, wiring a button, and using a dynamic (light/dark) palette.

## Run it
1. Create a new iOS App in Xcode.
2. Add this package: **File → Add Package Dependencies…**, then paste
   `https://github.com/A-bv/NeumorphicUIKit`.
3. Drop `DemoViewController.swift` into the app target.
4. Call `Neumorphism.configure(.demo)` once at launch (in your app or scene delegate),
   and make `DemoViewController` the root view controller.
