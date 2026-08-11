import Cadova

// Simplified MacBook Neo 13" (2026) — a rounded rectangular slab.
// Chassis dimensions: 297.5 × 206.4 × 12.7 mm.
//
// Local frame: front-left at origin, long side along x, short side along y,
// thickness along z. Color defaults to the Indigo finish.
public struct MacBookNeo: Shape3D {
    public let width: Double      // along x (long side, 297.5 mm)
    public let depth: Double      // along y (short side, 206.4 mm)
    public let thickness: Double  // along z (12.7 mm)
    public let cornerRadius: Double
    public let edgeFillet: Double

    public init(
        width: Double = 297.5,
        depth: Double = 206.4,
        thickness: Double = 12.7,
        cornerRadius: Double = 6.0,
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
            .withMaterial(color: Color(hex: "4B5B7E"), metallicness: 0.45, roughness: 0.4)
    }
}
