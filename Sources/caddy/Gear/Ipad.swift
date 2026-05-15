import Cadova

// Simplified iPad Pro 11" (M4) — a rounded rectangular slab.
// Chassis dimensions: 249.7 × 177.5 × 5.3 mm.
//
// Local frame: front-left at origin, long side along x, short side along y,
// thickness along z.
struct Ipad: Shape3D {
    let width: Double      // along x (long side, 249.7 mm)
    let depth: Double      // along y (short side, 177.5 mm)
    let thickness: Double  // along z (5.3 mm)
    let cornerRadius: Double
    let edgeFillet: Double

    init(
        width: Double = 249.7,
        depth: Double = 177.5,
        thickness: Double = 5.3,
        cornerRadius: Double = 18.0,
        edgeFillet: Double = 1.5
    ) {
        self.width = width
        self.depth = depth
        self.thickness = thickness
        self.cornerRadius = cornerRadius
        self.edgeFillet = edgeFillet
    }

    var body: any Geometry3D {
        Rectangle([width, depth])
            .rounded(radius: cornerRadius)
            .extruded(height: thickness, topEdge: .fillet(radius: edgeFillet))
            .withMaterial(color: Color(hex: "2A2A2C"), metallicness: 0.4, roughness: 0.35)
    }
}
