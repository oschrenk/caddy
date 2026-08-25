import Cadova
import Woodwork

let dims = ShoerackDimensions()

/// Three rows of boxes on a recessed plinth. Origin sits on the floor, so the
/// model stands the way the cabinet does.
///
/// The middle row is split into two boxes side by side rather than one wide
/// one. Half of 900 is 450, which matches the height and depth, so each of
/// those two is a cube — and together they occupy exactly the footprint a
/// single full-width box would.
@GeometryBuilder3D
func rack() -> any Geometry3D {
    // Plinth, inset all round so the stack appears to float.
    Box([dims.innerWidth, dims.outerDepth - 2 * dims.t1, dims.plinthHeight])
        .translated(x: dims.t1, y: dims.t1)
        .inPart(Part("Plinth", color: Color(red: 0.32, green: 0.28, blue: 0.24)))

    row(1) {
        Carcass(dims: dims, name: "Carcass 1", row: 1)
    }

    // The two narrow boxes stay plain — no tip-out fitting in either.
    row(2) {
        Carcass(dims: dims, name: "Carcass 2a", row: 2, width: dims.carcassWidth / 2, hinged: false)
        Carcass(dims: dims, name: "Carcass 2b", row: 2, width: dims.carcassWidth / 2, hinged: false)
            .translated(x: dims.carcassWidth / 2)
    }

    row(3) {
        Carcass(dims: dims, name: "Carcass 3", row: 3)
    }
}

/// Lifts a row of boxes to its place in the stack. Rows are 1-based, counting
/// up from the plinth.
func row(_ index: Int, @GeometryBuilder3D _ boxes: () -> any Geometry3D) -> any Geometry3D {
    boxes().translated(z: dims.plinthHeight + Double(index - 1) * dims.carcassHeight)
}

await Project(root: "Build/Shoerack") {

    // The tip-out fronts, the woven-rattan panels, and the pivot bores wait on
    // the hinges arriving — the listed frame sizes are ambiguous (two numbers
    // per axis) and need measuring in hand.
    await Model("shoerack") {
        rack()
    }

    // Merged single mesh, for scale mock-ups and for viewers without 3MF.
    await Model("shoerack", options: .format3D(.stl)) {
        rack()
    }

    // The tip-out fitting's steel side plate, recreated from the vendor STEP.
    // Two of these per front, mirrored. Its own model rather than part of the
    // rack, since where it lands depends on the pivot bores, which are open.
    await Model("hinge") {
        FlipDrawerHinge()
    }

    await Model("hinge", options: .format3D(.stl)) {
        FlipDrawerHinge()
    }

} // end Project
