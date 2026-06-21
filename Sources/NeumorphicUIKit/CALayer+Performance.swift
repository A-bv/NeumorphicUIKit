import UIKit

extension CALayer {
    /// Rasterizes the layer so the soft shadows don't recompute every frame.
    func shadowPerformanceBoost() {
        shouldRasterize = true
        rasterizationScale = UITraitCollection.current.displayScale
    }
}
