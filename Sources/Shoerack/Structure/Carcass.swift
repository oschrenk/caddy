import Cadova

/// The bare plywood carcass: two side panels, top, bottom, back panel, and the
/// recessed plinth. No fronts, hardware, or pivot bores yet — those land once
/// the tip-out fitting is measured in hand rather than off a spec sheet.
struct Carcass: Shape3D {
    let dims: ShoerackDimensions

    var body: any Geometry3D {
        let t1 = dims.t1
        let outerWidth = dims.outerWidth
        let outerDepth = dims.outerDepth
        let innerWidth = dims.innerWidth
        let innerDepth = dims.innerDepth
        let carcassHeight = dims.carcassHeight
        let plinthHeight = dims.plinthHeight

        let sidePanel = Box([t1, outerDepth, carcassHeight])
        let horizontal = Box([innerWidth, outerDepth, t1])

        sidePanel // left, x = 0
            .adding {
                sidePanel.translated(x: outerWidth - t1) // right

                horizontal.translated(x: t1) // bottom
                horizontal.translated(x: t1, z: carcassHeight - t1) // top

                // Back panel, set in one thickness so the interior reads flush.
                Box([innerWidth, t1, carcassHeight - 2 * t1])
                    .translated(x: t1, y: innerDepth, z: t1)

                // Plinth, inset front and back so the cabinet appears to float.
                Box([innerWidth, outerDepth - 2 * t1, plinthHeight])
                    .translated(x: t1, y: t1, z: -plinthHeight)
            }
    }
}
