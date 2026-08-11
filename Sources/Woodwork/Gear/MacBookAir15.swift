import Cadova

// Simplified MacBook Air 15" (M3, 2024) — a rounded rectangular slab.
// Chassis dimensions: 340.4 × 237.6 × 11.5 mm.
//
// Local frame: front-left at origin, long side along x, short side along y,
// thickness along z. Color defaults to Silver.
public struct MacBookAir15: Shape3D {
    public let width: Double      // along x (long side, 340.4 mm)
    public let depth: Double      // along y (short side, 237.6 mm)
    public let thickness: Double  // along z (11.5 mm)
    public let cornerRadius: Double
    public let edgeFillet: Double

    public init(
        width: Double = 340.4,
        depth: Double = 237.6,
        thickness: Double = 11.5,
        cornerRadius: Double = 7.0,
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
