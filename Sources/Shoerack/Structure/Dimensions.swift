/// Primary and derived dimensions for the shoe rack in millimeters.
///
/// The tip-out fitting drives the geometry, not the other way round: the steel
/// frame is 235 mm deep and 260 mm tall, so the carcass interior has to clear
/// both. Changing `hingeFrameDepth` without swapping the hardware will produce
/// a cabinet the fronts cannot close into. See `Docs/Shoerack/README.md`.
struct ShoerackDimensions {
    // Inputs
    // ---------------
    let t1: Double // plywood thickness (single thickness throughout)
    let wiggleRoom: Double // slack around the hinge frame
    let hingeFrameDepth: Double // steel tip-out frame, front-to-back
    let hingeFrameHeight: Double // steel tip-out frame, floor-to-top when shut
    let outerWidth: Double // overall footprint in x
    let tiers: Int // number of stacked tip-out fronts
    let plinthHeight: Double // recessed base below the lowest front

    init(
        t1: Double = 12.0,
        wiggleRoom: Double = 15.0,
        hingeFrameDepth: Double = 235.0,
        hingeFrameHeight: Double = 260.0,
        outerWidth: Double = 600.0,
        tiers: Int = 2,
        plinthHeight: Double = 60.0
    ) {
        self.t1 = t1
        self.wiggleRoom = wiggleRoom
        self.hingeFrameDepth = hingeFrameDepth
        self.hingeFrameHeight = hingeFrameHeight
        self.outerWidth = outerWidth
        self.tiers = tiers
        self.plinthHeight = plinthHeight
    }

    // Derived
    // ---------------

    /// Clear space the hinge frame swings in. The fitting sweeps forward, so
    /// the slack is depth-wise only — it needs nothing extra sideways.
    var innerDepth: Double { hingeFrameDepth + wiggleRoom }

    /// Back panel sits in a rebate behind the interior, hence one thickness.
    var outerDepth: Double { innerDepth + t1 }

    var innerWidth: Double { outerWidth - 2 * t1 }

    /// One tip-out opening. The pivot shafts mount through the side panels at
    /// the bottom of each opening, so tiers stack without a divider between.
    var tierHeight: Double { hingeFrameHeight + wiggleRoom }

    /// Overall height excluding the plinth.
    var carcassHeight: Double { Double(tiers) * tierHeight + 2 * t1 }

    var overallHeight: Double { carcassHeight + plinthHeight }

    /// Height of one tip-out front. Sits flush across the opening with a
    /// hairline gap top and bottom so neighbouring fronts do not bind.
    var frontHeight: Double { tierHeight - 2.0 }

    var frontWidth: Double { outerWidth - 2.0 }
}
