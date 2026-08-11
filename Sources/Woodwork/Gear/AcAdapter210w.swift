import Cadova

public struct AcAdapter210w: Shape3D {
    public let width = 190.0
    public let depth = 86.0
    public let height = 26.0

    public init() {}

    public var body: any Geometry3D {
        // C14 inlet outline per IEC 60320 manufacturer drawings:
        // 27 mm bottom width × 21 mm tall, with ~2.5 × 3 mm chamfers at the
        // wider end (creates a ~22 mm narrow end).
        let c14W  = 27.0
        let c14H  = 21.0
        let c14Cx = 2.5  // chamfer horizontal length
        let c14Cy = 3.0  // chamfer vertical length
        let c14D  = 5.0  // recess depth

        Rectangle([width, depth])
            .rounded(radius: 2)
            .extruded(height: height, topEdge: .fillet(radius: 2), bottomEdge: .fillet(radius: 2))
            .subtracting {
                // House shape with chamfers at the BOTTOM (flipped 180° from
                // before, so the wide flat end is at the top, narrow end down).
                Polygon([
                    Vector2D(x: c14Cx,         y: 0),       // bottom-left after chamfer
                    Vector2D(x: c14W - c14Cx,  y: 0),       // bottom-right after chamfer
                    Vector2D(x: c14W,          y: c14Cy),   // mid-right
                    Vector2D(x: c14W,          y: c14H),    // top-right
                    Vector2D(x: 0,             y: c14H),    // top-left
                    Vector2D(x: 0,             y: c14Cy),   // mid-left
                ])
                .extruded(height: c14D + 1)
                .rotated(x: 90°)
                .rotated(z: 90°)
                .translated(
                    x: width - c14D,
                    y: (depth - c14W) / 2,
                    z: (height - c14H) / 2
                )
            }

        // DC output cable connector molded into the opposite short end
        // (local x=0 face): a small boss + conical strain relief.
        // The cable itself is routed separately in main.swift.
        let bossD = 8.0
        let bossL = 3.0
        let strainTopD = 4.0
        let strainL = 15.0
        let cy = depth / 2
        let cz = height / 2

        Cylinder(diameter: bossD, height: bossL)
            .rotated(y: -90°)
            .translated(y: cy, z: cz)

        Cylinder(bottomDiameter: bossD, topDiameter: strainTopD, height: strainL)
            .rotated(y: -90°)
            .translated(x: -bossL, y: cy, z: cz)
    }
}
