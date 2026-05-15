import Cadova

// Simplified MacBook Pro 16" — a rounded rectangular slab. Dimensions match
// the current (M-series) chassis: 355.7 × 248.1 × 16.8 mm.
//
// Local frame: front-left at origin, long side along x, short side along y,
// thickness along z.
struct MacBookPro16: Shape3D {
    let width: Double      // along x (long side, 355.7 mm)
    let depth: Double      // along y (short side, 248.1 mm)
    let thickness: Double  // along z (16.8 mm)
    let cornerRadius: Double
    let edgeFillet: Double

    init(
        width: Double = 355.7,
        depth: Double = 248.1,
        thickness: Double = 16.8,
        cornerRadius: Double = 8.0,
        edgeFillet: Double = 2.5
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
            .withMaterial(color: Color(hex: "8E8E93"), metallicness: 0.65, roughness: 0.35)
    }
}
