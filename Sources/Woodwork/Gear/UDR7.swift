import Cadova

// Ubiquiti UniFi Dream Router 7 (UDR7) — a white polycarbonate cylinder with
// a small status display on the upper front.
//
// Specs (ui.com techspecs): ⌀110 × 184.1 mm, 1.1 kg, 0.96" status display.
//
// Local frame matches the other gear: the ⌀110 footprint sits front-left at the
// origin (width along x, depth along y), body extruded up +z. The cylinder is
// centered within that 110 × 110 footprint. The display faces -y (the "front").
public struct UDR7: Shape3D {
    public let diameter = 110.0
    public let height = 184.1
    public let topFillet = 8.0      // rounded top edge

    // 0.96" status display — small dark glass panel, centered in x on the front,
    // in the upper portion of the body.
    public let screenWidth = 24.0   // along x
    public let screenHeight = 16.0  // along z
    public let screenCornerRadius = 2.5
    public let screenCenterZ = 150.0
    public let screenInset = 2.0    // how far the glass embeds into the curved surface

    // Footprint is square so the round body centers cleanly when placed.
    public var width: Double { diameter }
    public var depth: Double { diameter }

    public init() {}

    public var body: any Geometry3D {
        let r = diameter / 2

        Union {
            // ─── Body — white cylinder with a rounded top edge ──────────────
            Circle(diameter: diameter)
                .extruded(height: height, topEdge: .fillet(radius: topFillet))
                .withMaterial(color: Color(hex: "F5F5F5"), metallicness: 0, roughness: 0.4)

            // ─── Status display — dark glass on the front (-y) face ─────────
            // Built as a thin rounded slab embedded into the cylinder surface
            // so it reads flush; the curve's sagitta over 24 mm is ~1.3 mm.
            Rectangle([screenWidth, screenHeight])
                .rounded(radius: screenCornerRadius)
                .extruded(height: screenInset + 2)
                .rotated(x: -90°)  // face the slab toward -y
                .translated(
                    x: r - screenWidth / 2,
                    y: screenInset,           // front of slab pokes just past y=0
                    z: screenCenterZ - screenHeight / 2
                )
                .withMaterial(color: Color(hex: "1A1A1A"), metallicness: 0.2, roughness: 0.2)
        }
        .translated(x: r, y: r)  // center the body within the square footprint
    }
}
