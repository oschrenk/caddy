/// Primary and derived dimensions for the shoe rack in millimeters.
///
/// The rack is three rows of closed boxes stacked on one plinth. The full-width
/// rows are 900 × 450 × 450; the middle row splits into two 450 mm cubes, which
/// is what fixes the width at 900. All three outer dimensions are chosen by hand
/// rather than dictated by the hardware — at 450 deep the box clears the 235 mm steel
/// tip-out frame with room to spare, so `hingeFrameDepth` only has to fit, not
/// drive. `hingeDepthSlack` reports how much is left over.
/// See `Docs/Shoerack/README.md`.
struct ShoerackDimensions {
    // Inputs
    // ---------------
    let t1: Double // plywood thickness (single thickness throughout)
    let wiggleRoom: Double // slack around the hinge frame
    let hingeFrameDepth: Double // steel tip-out frame, front-to-back
    let hingeFrameHeight: Double // steel tip-out frame, floor-to-top when shut
    let carcassWidth: Double // one carcass, overall in x
    let carcassDepth: Double // one carcass, overall in y
    let carcassHeight: Double // one carcass, overall in z
    let modules: Int // stacked carcasses
    let plinthHeight: Double // recessed base under the whole stack

    init(
        t1: Double = 15.0,
        wiggleRoom: Double = 15.0,
        hingeFrameDepth: Double = 235.0,
        hingeFrameHeight: Double = 260.0,
        carcassWidth: Double = 900.0,
        carcassDepth: Double = 450.0,
        carcassHeight: Double = 450.0,
        modules: Int = 3,
        plinthHeight: Double = 60.0
    ) {
        self.t1 = t1
        self.wiggleRoom = wiggleRoom
        self.hingeFrameDepth = hingeFrameDepth
        self.hingeFrameHeight = hingeFrameHeight
        self.carcassWidth = carcassWidth
        self.carcassDepth = carcassDepth
        self.carcassHeight = carcassHeight
        self.modules = modules
        self.plinthHeight = plinthHeight
    }

    // Derived
    // ---------------

    /// Clear space in front of the back panel, which is set in one thickness.
    var innerDepth: Double { carcassDepth - t1 }

    /// Kept as the name the rest of the model builds against.
    var outerDepth: Double { carcassDepth }

    /// Spare depth once the tip-out frame and its slack are accounted for.
    /// Must stay positive or the fronts will not close.
    var hingeDepthSlack: Double { innerDepth - hingeFrameDepth - wiggleRoom }

    var innerWidth: Double { carcassWidth - 2 * t1 }

    /// Clear opening height inside one carcass. Each carcass is its own closed
    /// box, so both its top and bottom eat a thickness.
    var innerHeight: Double { carcassHeight - 2 * t1 }

    /// What one tip-out opening needs. `innerHeight` must clear this — at the
    /// defaults there is ~145 mm spare, which is where a shoe tray lives.
    var tierHeight: Double { hingeFrameHeight + wiggleRoom }

    /// The three carcasses together, plinth excluded.
    var stackHeight: Double { Double(modules) * carcassHeight }

    var overallHeight: Double { stackHeight + plinthHeight }

    /// One tip-out front per carcass, flush across the opening with a hairline
    /// gap all round so neighbouring fronts do not bind.
    var frontHeight: Double { carcassHeight - 2.0 }

    var frontWidth: Double { carcassWidth - 2.0 }
}
