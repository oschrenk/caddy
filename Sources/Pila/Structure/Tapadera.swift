import Cadova

/// The wooden lid: a slatted deck on three tapered cleats.
///
/// The cleats do two jobs. They hold the deck off the wet rim so the underside
/// can dry, and their taper tilts the whole deck toward the free corner, so
/// runoff never travels toward the building walls the pila sits against.
///
/// Origin is the low-x, low-y corner of the tank opening, at rim height.
/// The **high corner is at x = 0, y = 0** — put that against the building.
struct Tapadera: Geometry3D {
    let dims: PilaDimensions

    var body: any Geometry3D {
        SlatDeck(dims: dims)
            .adding {
                // Cleats span the block only — they have to bear on it. The
                // deck oversails them at the front and the right.
                for x in dims.cleatPositions {
                    TaperedCleat(
                        width: dims.cleatWidth,
                        length: dims.outerDepth,
                        heightStart: dims.cleatHeight(x: x, y: 0),
                        heightEnd: dims.cleatHeight(x: x, y: dims.outerDepth)
                    )
                    .translated(x: x)
                }
            }
            .subtracting {
                // Only cut if the deck actually fouls the spout. With no y-fall
                // the deck stays low enough at the back to slide underneath, so
                // this normally contributes nothing.
                if dims.needsSpoutNotch {
                    Box([
                        dims.spoutNotchWidth,
                        dims.spoutNotchDepth,
                        dims.cleatHeight(x: 0, y: dims.lidDepth) + dims.slatThickness * 3,
                    ])
                    .translated(
                        x: dims.spoutLocalX - dims.spoutNotchWidth / 2,
                        y: dims.lidDepth - dims.spoutNotchDepth
                    )
                }
            }
    }
}

/// The slats, laid across the depth and tilted onto the cleat plane.
struct SlatDeck: Geometry3D {
    let dims: PilaDimensions

    var body: any Geometry3D {
        let deck = Union {
            for i in 0..<dims.slatCount {
                Box([dims.lidWidth, dims.slatWidth, dims.slatThickness])
                    .translated(y: dims.slatPitch * Double(i))
            }
        }

        // No drip grooves. On a *slatted* deck they earn almost nothing: water
        // travels at most 35 mm before reaching a 9.4 mm gap and dropping into
        // the basin, so only the front slat ever sheds along an edge — roughly
        // 9% of the rain. The two side grooves would also run cross-grain and
        // land 8 mm from the thirstiest end grain on the lid.
        //
        // **If this ever becomes a full solid lid, put them back.** Then water
        // genuinely does sheet across the surface to the edges, and a groove
        // 8 mm in from each overhang edge (3 mm wide × 4 mm deep, cut in the
        // underside before tilting) stops it curling around the edge and
        // tracking back inward. `dripGrooveInset/Width/Depth` are still in
        // `PilaDimensions` for exactly that case — see the git history of this
        // file for the geometry.
        //
        // The cleats keep their bevel regardless. That answers a different and
        // real path: water running down a cleat's side, curling under a square
        // bottom edge, into the one interface that must stay dry.

        // Shifted so the deck oversails the left and front edges of the block,
        // then tilted onto the same plane the cleats define: falling toward +x
        // and toward -y, so the low corner is x = max, y = min.
        deck
            .translated(x: -dims.lidLeftOverhang, y: -dims.lidFrontOverhang)
            .rotated(x: dims.lidSlopeY, y: dims.lidSlopeX)
            .translated(z: dims.cleatHeight(x: 0, y: 0))
    }
}

/// A cleat that tapers along its length, from `heightStart` at y = 0 down to
/// `heightEnd` at y = length. Cut as the waste below a tilted plane, so the two
/// cleats share one taper angle and differ only in starting stock thickness.
struct TaperedCleat: Geometry3D {
    let width: Double
    let length: Double
    let heightStart: Double
    let heightEnd: Double

    var body: any Geometry3D {
        // Signed, so the cleat may rise or fall along its length.
        let theta = atan2(heightStart - heightEnd, length)
        let tallest = max(heightStart, heightEnd)

        Box([width, length, tallest])
            .subtracting {
                Box([width, length * 2, tallest * 2])
                    .rotated(x: -theta)
                    .translated(z: heightStart)
            }
    }
}
