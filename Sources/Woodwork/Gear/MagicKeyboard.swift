import Cadova

// Apple Magic Keyboard (compact, no numeric keypad).
// Chassis dimensions per Apple specs: 279 × 114.9 × 4.1–10.9 mm (wedge profile).
// Modeled as a flat-top box at max height for placeholder use.
//
// Local frame: front-left at origin, long side along x, short side along y,
// thickness along z.
public struct MagicKeyboard: Shape3D {
    public let width = 279.0
    public let depth = 114.9
    public let height = 10.9

    public init() {}

    public var body: any Geometry3D {
        Box([width, depth, height])
            .colored(Color(hex: "FFFFFF"))
    }
}
