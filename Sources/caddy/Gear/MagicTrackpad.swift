import Cadova

// Apple Magic Trackpad (USB-C).
// Chassis dimensions per Apple specs: 160 × 114.9 × 4.9–10.9 mm (wedge profile).
// Modeled as a flat-top box at max height for placeholder use.
//
// Local frame: front-left at origin, long side along x, short side along y,
// thickness along z.
struct MagicTrackpad: Shape3D {
    let width = 160.0
    let depth = 114.9
    let height = 10.9

    var body: any Geometry3D {
        Box([width, depth, height])
            .colored(Color(hex: "FFFFFF"))
    }
}
