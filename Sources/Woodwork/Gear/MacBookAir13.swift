import Cadova

// Simplified MacBook Air 13" (M3, 2024) — a rounded rectangular slab.
// Chassis dimensions: 304.1 × 215 × 11.3 mm.
//
// Local frame: front-left at origin, long side along x, short side along y,
// thickness along z. Color defaults to Silver.
public struct MacBookAir13: Shape3D {
    public let width: Double      // along x (long side, 304.1 mm)
    public let depth: Double      // along y (short side, 215 mm)
    public let thickness: Double  // along z (11.3 mm)
    public let cornerRadius: Double
    public let edgeFillet: Double

    public init(
        width: Double = 304.1,
        depth: Double = 215,
        thickness: Double = 11.3,
        cornerRadius: Double = 6.5,
        edgeFillet: Double = 2.0
    ) {
        self.width = width
        self.depth = depth
        self.thickness = thickness
        self.cornerRadius = cornerRadius
        self.edgeFillet = edgeFillet
    }

    public var body: any Geometry3D {
        Rectangle([width, depth])
            .rounded(radius: cornerRadius)
            .extruded(height: thickness, topEdge: .fillet(radius: edgeFillet))
            .withMaterial(color: Color(hex: "C4C4C6"), metallicness: 0.65, roughness: 0.35)
    }
}
