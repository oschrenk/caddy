import Cadova

/// A surface appearance. Rendering only — carries no meaning for the build.
///
/// Cadova keeps `Material`'s roughness/metallicness initialiser internal, so
/// these are applied through `withMaterial(color:metallicness:roughness:)`
/// rather than built as `Material` values.
struct Finish {
    let name: String
    let color: Color
    let metallicness: Double
    let roughness: Double
}

extension Geometry3D {
    func finished(_ f: Finish) -> any Geometry3D {
        withMaterial(
            color: f.color, metallicness: f.metallicness, roughness: f.roughness, name: f.name
        )
    }
}

enum PilaFinishes {
    /// Pale pine. Rough and non-metallic, so it reads as bare timber rather
    /// than something varnished.
    static let pine = Finish(
        name: "Pine", color: Color(hex: "D9B382"), metallicness: 0, roughness: 0.75
    )

    /// Light red stone, the tone a tinted concrete pila weathers to.
    static let stone = Finish(
        name: "Stone (light red)", color: Color(hex: "C48A7C"), metallicness: 0, roughness: 0.9
    )

    /// Bare concrete, for the lower metre of the walls.
    static let concrete = Finish(
        name: "Concrete", color: Color(hex: "9C9A94"), metallicness: 0, roughness: 1.0
    )

    /// Dark stained boarding, for the walls above the concrete.
    static let stainedWood = Finish(
        name: "Stained wood", color: Color(hex: "46311F"), metallicness: 0, roughness: 0.6
    )

    /// Chrome, for the waterspout.
    static let chrome = Finish(
        name: "Chrome", color: Color(hex: "C9CDD2"), metallicness: 0.9, roughness: 0.25
    )
}

/// Dimensions for the pila and its wooden lid, in millimeters.
///
/// The pila is a plain rectangular block with two basins sunk into the top. No
/// washboard wing, no sloped drain edge.
///
/// **Given:** outer footprint 1000 × 770, outer walls 35 mm, a 25 mm wall
/// dividing the block into two basins. **Assumed:** basin depth and block
/// height — measure the real pila and correct them here.
struct PilaDimensions {
    // Pila block
    let outerWidth: Double // x — given
    let outerDepth: Double // y — given
    let wallThickness: Double // given
    let dividerThickness: Double // given
    let basinDepth: Double // assumed
    let blockHeight: Double // assumed — rim height above ground

    // Building walls — reference geometry only, not something to build
    let buildingWallHeight: Double
    let buildingWallThickness: Double
    let buildingWallOverhang: Double // how far the walls run past the pila
    let wallGapX: Double // pila stands off the left wall by this
    let wallGapY: Double // pila stands off the back wall by this

    // Waterspout, over the second basin from the left
    let spoutDiameter: Double
    /// Height of the **underside** of the spout above the top of the block —
    /// the measured 53 mm. The axis sits half a diameter higher.
    let spoutHeightAboveBlock: Double
    let spoutReach: Double // projection from the back wall face
    let spoutTipDrop: Double
    let spoutClearance: Double // margin around the spout when notching the lid

    // Tapadera — the wooden lid, covering the whole block
    let slatCount: Int
    let slatWidth: Double
    let slatThickness: Double
    let cleatWidth: Double
    let cleatMinHeight: Double // clearance at the low corner, over wet concrete
    let lidOverhang: Double // oversail on left, right and front
    // Drip groove — currently unused. Kept for a solid-lid variant, where water
    // does sheet across the surface to the edges. On a slatted deck the gaps
    // drain it long before it gets there. See the note in `SlatDeck`.
    let dripGrooveInset: Double // groove distance from the overhang edge
    let dripGrooveWidth: Double // saw kerf
    let dripGrooveDepth: Double
    let lidFallX: Double // drop across the 1000 mm run
    let lidFallY: Double // drop across the 770 mm run

    init(
        outerWidth: Double = 1000.0,
        outerDepth: Double = 770.0,
        wallThickness: Double = 35.0,
        dividerThickness: Double = 25.0,
        basinDepth: Double = 400.0,
        blockHeight: Double = 900.0,
        buildingWallHeight: Double = 1500.0,
        buildingWallThickness: Double = 150.0,
        buildingWallOverhang: Double = 300.0,
        wallGapX: Double = 30.0,
        wallGapY: Double = 1.0,
        spoutDiameter: Double = 22.0,
        spoutHeightAboveBlock: Double = 53.0,
        spoutReach: Double = 140.0,
        // Zero by default: a downturned tip would hang below the 53 mm and hit
        // the deck. Set it only if the real spout actually turns down, and
        // expect to deal with the collision.
        spoutTipDrop: Double = 0.0,
        spoutClearance: Double = 15.0,
        slatCount: Int = 10,
        slatWidth: Double = 70.0,
        // The spout sits at y-max, where the y-fall makes the deck highest, so
        // every mm of slat thickness comes straight off the headroom under it.
        // 12 mm calculates fine, but the species is not settled yet — 15 mm
        // leaves margin for softer or wetter stock than assumed.
        slatThickness: Double = 15.0,
        cleatWidth: Double = 35.0,
        // 10 rather than 15, for the same reason. Still a real air gap.
        cleatMinHeight: Double = 10.0,
        lidOverhang: Double = 15.0,
        dripGrooveInset: Double = 8.0,
        dripGrooveWidth: Double = 3.0,
        dripGrooveDepth: Double = 4.0,
        lidFallX: Double = 20.0,
        // Charged in full against the spout headroom, because the spout sits at
        // y-max — unlike the x-fall, which is 74% spent by the time it gets
        // there. 15 mm over 770 is 1:51, still comfortably shedding.
        lidFallY: Double = 15.0
    ) {
        self.outerWidth = outerWidth
        self.outerDepth = outerDepth
        self.wallThickness = wallThickness
        self.dividerThickness = dividerThickness
        self.basinDepth = basinDepth
        self.blockHeight = blockHeight
        self.buildingWallHeight = buildingWallHeight
        self.buildingWallThickness = buildingWallThickness
        self.buildingWallOverhang = buildingWallOverhang
        self.wallGapX = wallGapX
        self.wallGapY = wallGapY
        self.spoutDiameter = spoutDiameter
        self.spoutHeightAboveBlock = spoutHeightAboveBlock
        self.spoutReach = spoutReach
        self.spoutTipDrop = spoutTipDrop
        self.spoutClearance = spoutClearance
        self.slatCount = slatCount
        self.slatWidth = slatWidth
        self.slatThickness = slatThickness
        self.cleatWidth = cleatWidth
        self.cleatMinHeight = cleatMinHeight
        self.lidOverhang = lidOverhang
        self.dripGrooveInset = dripGrooveInset
        self.dripGrooveWidth = dripGrooveWidth
        self.dripGrooveDepth = dripGrooveDepth
        self.lidFallX = lidFallX
        self.lidFallY = lidFallY
    }

    // Basins — derived
    // ---------------

    /// Clear width inside the outer walls, before the divider takes its share.
    var interiorWidth: Double { outerWidth - 2 * wallThickness }

    /// Each basin, assuming the divider splits the block across its long axis.
    var basinWidth: Double { (interiorWidth - dividerThickness) / 2 }

    var basinDepthY: Double { outerDepth - 2 * wallThickness }

    var basinFloorZ: Double { blockHeight - basinDepth }

    /// x of the left edge of each basin.
    var basinOriginsX: [Double] {
        [wallThickness, wallThickness + basinWidth + dividerThickness]
    }

    var dividerOriginX: Double { wallThickness + basinWidth }

    // Lid — derived
    // ---------------

    /// The lid oversails on three sides — left, right and front — so runoff and
    /// drips fall clear of the block face instead of running down it.
    ///
    /// **Not the back.** There is only `wallGapY` (1 mm) to the building wall,
    /// and it is the high edge anyway, so no water reaches it.
    var lidWidth: Double { outerWidth + 2 * lidOverhang }
    var lidDepth: Double { outerDepth + lidOverhang }

    /// Deck starts this far to the -x side of the block.
    var lidLeftOverhang: Double { lidOverhang }

    /// Deck starts this far to the -y side of the block.
    var lidFrontOverhang: Double { lidOverhang }

    /// Gap between slats, solved so the slats fill the depth exactly rather than
    /// leaving a ragged last gap. 10 slats of 70 mm over 770 mm gives 7.8 mm.
    var slatGap: Double {
        (lidDepth - Double(slatCount) * slatWidth) / Double(slatCount - 1)
    }

    var slatPitch: Double { slatWidth + slatGap }

    /// Cleat height at a point on the lid. The plane is highest at the corner
    /// against the building and falls to the free corner diagonally opposite,
    /// so runoff leaves by the two open edges and never travels toward a wall.
    ///
    /// High corner is **x = 0, y = max**. Water runs toward +x and toward -y —
    /// that is, to the right and toward whoever is standing at the pila.
    /// Referenced to the **block**, not the lid, so adding an overhang extends
    /// the same tilted plane rather than changing its slope.
    func cleatHeight(x: Double, y: Double) -> Double {
        cleatMinHeight + lidFallX * (1 - x / outerWidth) + lidFallY * (y / outerDepth)
    }

    /// x of the left edge of each cleat. Cleats must land on something solid, so
    /// they sit over the two side walls and over the central divider — not over
    /// a basin, where they would carry nothing.
    var cleatPositions: [Double] {
        [
            0,
            dividerOriginX + dividerThickness / 2 - cleatWidth / 2,
            outerWidth - cleatWidth,
        ]
    }

    /// Fall angles, derived from the drops so the deck and the cleats agree.
    var lidSlopeX: Angle { atan2(lidFallX, lidWidth) }
    var lidSlopeY: Angle { atan2(lidFallY, lidDepth) }

    // Placement — derived
    // ---------------

    /// The pila stands off both walls, so it sits in the +x / -y quadrant with
    /// a gap on each side rather than hard against the corner.
    var pilaOffsetX: Double { wallGapX }
    var pilaOffsetY: Double { -(outerDepth + wallGapY) }

    // Spout — derived
    // ---------------

    /// Centre of the second basin from the left, in pila-local x.
    var spoutLocalX: Double { basinOriginsX[1] + basinWidth / 2 }

    /// Underside of the spout, in model z. This is the surface the lid must clear.
    var spoutUndersideZ: Double { blockHeight + spoutHeightAboveBlock }

    /// Centreline of the spout pipe, half a diameter above its underside.
    var spoutAxisZ: Double { spoutUndersideZ + spoutDiameter / 2 }

    /// Top of the deck directly under the spout, measured above the block.
    /// Highest along the spout's reach, so this is the number that has to clear.
    var deckTopUnderSpout: Double {
        cleatHeight(x: spoutLocalX, y: lidDepth) + slatThickness
    }

    /// Headroom between the deck and the spout arm. Negative means they collide
    /// and the lid needs notching; positive means it slides underneath.
    var spoutHeadroom: Double { spoutHeightAboveBlock - deckTopUnderSpout }

    /// Only cut a notch if the deck actually fouls the spout.
    var needsSpoutNotch: Bool { spoutHeadroom < 0 }

    var spoutNotchWidth: Double { spoutDiameter + 2 * spoutClearance }

    /// Measured back from the lid's wall edge.
    var spoutNotchDepth: Double { spoutReach - wallGapY + spoutClearance }

    // Walls — derived
    // ---------------

    /// The walls change material at this height: concrete below, dark stained
    /// boarding above.
    var wallSplitHeight: Double { 1000.0 }
}
