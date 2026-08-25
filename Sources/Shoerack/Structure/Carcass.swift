import Cadova

/// One closed plywood box, built as five separate boards rather than one solid:
/// top, bottom, two sides, and a set-in back. Each board is its own part in the
/// 3MF, tinted slightly differently so the pieces read apart on screen.
///
/// Top and bottom run the full carcass width and cap the sides, which sit
/// between them. Screws are driven vertically — down through the top, up
/// through the bottom — so no fixing shows on the visible side faces. Butt
/// joints throughout; mitres were tried and dropped, since a 45° cut in
/// plywood exposes the plies along its whole length.
///
/// Every box carries its own top *and* bottom rather than sharing a panel with
/// its neighbour, so they can be built, carried, and restacked separately. That
/// also lets a row hold two narrow boxes instead of one wide one — see
/// `width`, which defaults to the full carcass but can be halved.
///
/// The tip-out fitting's two side plates are mounted inside, one against each
/// side panel — unless `hinged` is off, which is how the narrow boxes stay
/// plain. No fronts or pivot bores yet — those land once the fitting is
/// measured in hand rather than off a spec sheet.
struct Carcass: Geometry3D {
    let dims: ShoerackDimensions
    let name: String // labels this box's parts, e.g. "Carcass 2a"
    let row: Int // 1-based position in the stack, picks the tint
    let width: Double
    let hinged: Bool // whether this box gets the tip-out fitting

    init(dims: ShoerackDimensions, name: String, row: Int, width: Double? = nil, hinged: Bool = true) {
        self.dims = dims
        self.name = name
        self.row = row
        self.width = width ?? dims.carcassWidth
        self.hinged = hinged
    }

    /// Clear width inside this box. Both sides are housed between the caps, so
    /// each eats one thickness.
    var innerWidth: Double { width - 2 * dims.t1 }

    var body: any Geometry3D {
        let t = dims.t1
        let h = dims.carcassHeight
        let depth = dims.outerDepth

        // Full-width lid and floor. These take the screws.
        let cap = Box([width, depth, t])
        cap.inPart(part("Bottom", tint: 0))
        cap.translated(z: h - t).inPart(part("Top", tint: 1))

        // Sides, housed between the caps.
        let side = Box([t, depth, dims.innerHeight])
        side.translated(z: t).inPart(part("Left side", tint: 2))
        side.translated(x: width - t, z: t).inPart(part("Right side", tint: 3))

        // Back panel, set in one thickness so the interior reads flush.
        Box([innerWidth, t, dims.innerHeight])
            .translated(x: t, y: dims.innerDepth, z: t)
            .inPart(part("Back", tint: 4))

        if hinged {
            hinges
        }
    }

    /// The tip-out fitting: one steel side plate against each side panel, the
    /// pair mirrored. The plate stands with its **long axis vertical** — 296.07
    /// tall by 198.51 deep — sitting on the carcass floor with its straight
    /// mounting edge set back one thickness from the carcass front, leaving
    /// room for the tip-out front to close flush.
    ///
    /// Which face beds against the panel is settled by the fixings: the three
    /// bolt holes run z 0 → 8.5 in the plate's own frame, through the flange,
    /// while the brackets at z 24.5 are solid steel with no bore. So the flat
    /// face lies on the panel, the screws drive out through it, and the
    /// brackets stand proud into the compartment.
    ///
    /// The plate is modelled lying flat about its pivot, so one turn about y
    /// stands it up: local +z becomes cabinet width, +y becomes depth, and +x
    /// runs downward, which puts the tip end at the bottom and the pivot
    /// `frontReach` above the floor.
    private var hinges: any Geometry3D {
        let hinge = FlipDrawerHinge()

        let plate = hinge
            .rotated(y: 90°)
            .translated(y: dims.t1 - hinge.mountEdgeY, z: dims.t1 + hinge.frontReach)

        return Union {
            plate.translated(x: dims.t1) // left side, growing inwards
            plate.flipped(along: .x).translated(x: width - dims.t1) // right side, mirrored
        }
        .inPart(Part("\(name) · Hinges", color: Color(red: 0.30, green: 0.31, blue: 0.33)))
    }

    private func part(_ label: String, tint: Int) -> Part {
        Part("\(name) · \(label)", color: Self.tone(row: row, board: tint))
    }

    /// A plywood tan, stepped down slightly per row and per board so no two
    /// touching pieces share a shade.
    private static func tone(row: Int, board: Int) -> Color {
        let shade = 1.0 - Double(row - 1) * 0.06 - Double(board) * 0.035
        return Color(red: 0.85 * shade, green: 0.70 * shade, blue: 0.48 * shade)
    }
}
