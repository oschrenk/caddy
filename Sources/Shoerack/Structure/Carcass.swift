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
/// No fronts, hardware, or pivot bores yet — those land once the tip-out
/// fitting is measured in hand rather than off a spec sheet.
struct Carcass: Geometry3D {
    let dims: ShoerackDimensions
    let name: String // labels this box's parts, e.g. "Carcass 2a"
    let row: Int // 1-based position in the stack, picks the tint
    let width: Double

    init(dims: ShoerackDimensions, name: String, row: Int, width: Double? = nil) {
        self.dims = dims
        self.name = name
        self.row = row
        self.width = width ?? dims.carcassWidth
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
