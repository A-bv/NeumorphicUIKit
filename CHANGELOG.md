# Changelog

All notable changes to NeumorphicUIKit are listed here, newest first.
Versions follow [semantic versioning](https://semver.org).

## 3.2.1 — 2026-07-02
- Added a demo GIF to the README showing the raised look, the button press,
  and the automatic light/dark switch.
- Documented that the automatic light/dark switch needs a dynamic palette,
  and corrected doc comments that still described dark mode as iOS 17+ only.
- README polish: CI status badge, current install version, and a resize
  snippet that compiles where it's pasted.
- CI now treats Swift warnings as errors.
- Broadened the tests (settle cancellation, full press recolour, geometry,
  safe no-ops on unstyled views) and removed a timing-flaky test.

## 3.2.0 — 2026-07-01
- Dark mode is now handled automatically on iOS 15–16 as well; calling
  `refreshNeumorphicShadows()` by hand is no longer needed on any version.
- Fixed a leak where re-styling a view (for example a reused cell) stacked a
  new light/dark observer on top of the old one.
- Added the MIT license.
- Added a CI workflow that builds and tests on every push.
- Rewrote the README in plainer language.

## 3.1.1 — 2026-06-30
- Fixed shadows so they stay correct across layout passes and presses.
- Extended test coverage and serialized the test suite.

## 3.1.0 — 2026-06-29
- Added `resizeNeumorphicShadows()` for views that change size.

## 3.0.1 — 2026-06-23
- Fixed shadow size so it survives repaints.

## 3.0.0 — 2026-06-23
- **Breaking:** views now manage their own shadows, and the press API was
  renamed to `pressDown()` / `pressUp(settle:)`.

## 2.1.2 — 2026-06-23
- Added a next-run-loop repaint as a safety net while an appearance change
  settles.

## 2.1.1 — 2026-06-23
- Fixed shadows to repaint synchronously on a trait change.

## 2.1.0 — 2026-06-22
- Lowered the minimum to iOS 15 by using `PreviewProvider` instead of the
  `#Preview` macro.

## 2.0.0 — 2026-06-22
- **Breaking:** corner and shadow radii became optional parameters, and every
  palette color gained a default.

## 1.0.1 — 2026-06-22
- Added the README, a standalone preview, and the first unit tests.

## 1.0.0 — 2026-06-22
- First release: a palette-agnostic neumorphic theme with a single
  `configure` entry point.
