import UIKit

extension CALayer {
    /// Rasterizes the layer so the soft shadows don't recompute every frame. `scale` should
    /// be the owning view's `displayScale` so the cached bitmap stays crisp on Retina —
    /// reading the ambient `UITraitCollection.current` can pick up the wrong scale when the
    /// layer is built outside a settled screen-trait context.
    func shadowPerformanceBoost(scale: CGFloat) {
        shouldRasterize = true
        rasterizationScale = scale
    }
}
