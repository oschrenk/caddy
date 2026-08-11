import Cadova

// Apple Magic Trackpad (USB-C).
// Chassis dimensions per Apple specs: 160 × 114.9 × 4.9–10.9 mm (wedge profile).
// Modeled as a flat-top box at max height for placeholder use.
//
// Local frame: front-left at origin, long side along x, short side along y,
// thickness along z.
public struct MagicTrackpad: Shape3D {
    public let width = 160.0
    public let depth = 114.9
    public let height = 10.9

    public init() {}

    public var body: any Geometry3D {
        Box([width, depth, height])
            .colored(Color(hex: "FFFFFF"))
    }
}
