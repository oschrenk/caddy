import Cadova

// Vallejo Model Color 17 ml dropper bottle with cap.
//
// Bottle profile measured from a 3MF mesh (rotationally symmetric, primitives):
//   z=  0– 3     bottom fillet R=3
//   z=  3–40     body cylinder ⌀25
//   z= 40–46     shoulder fillet R=6 (⌀25 → ⌀13.4)
//   z= 46–48     neck base ⌀13.4
//   z= 48–50     thread ring ⌀17 (cap screws onto this)
//   z= 50–60     cap-fit cylinder ⌀10.5
//   z= 60–67     dropper stem taper ⌀10.5 → ⌀4
//   z= 67–72     dropper tip ⌀4
//
// Cap profile is sampled from the mesh and revolved as a polygon:
// slightly tapered shell up to z=64, then a single convex curve sweeping
// from ⌀16.7 down to a flat ⌀7 top at z=76. (The mesh has small radial
// bumps above z=68 — looked like a pagoda when modeled literally —
// smoothed here into one continuous curve as the cap actually appears.)
//
// Body color defaults to Vallejo Model Color 70.939 Smoke. The hex (#937E62)
// is an approximation sampled from Encycolorpedia's RGB swatch — Vallejo does
// not publish official hex values, so this is a best-effort visual match
// rather than a spec.
public struct VallejoBottle: Shape3D {
    public let bottleColor: Color
    public let capColor: Color

    // Bottle dimensions
    public let bodyDiameter = 25.0
    public let bodyBottomFillet = 3.0
    public let shoulderFilletRadius = 6.0
    public let bodyStraightTopZ = 40.0
    public let shoulderTopZ = 46.0

    public let neckBaseDiameter = 13.4
    public let neckBaseTopZ = 48.0

    public let threadRingDiameter = 17.0
    public let threadRingTopZ = 50.0

    public let capFitDiameter = 10.5
    public let capFitTopZ = 60.0

    public let dropperTipDiameter = 4.0
    public let dropperTaperTopZ = 67.0
    public let dropperTipTopZ = 72.0

    // Label — white shallow cylinder around the body cylinder
    public let labelDiameter = 25.4   // 0.2 mm radial padding over the body
    public let labelBottomZ = 10.0
    public let labelTopZ = 35.0

    public init(
        bottleColor: Color = Color(hex: "937E62"), // Vallejo Model Color 70.939 Smoke
        capColor: Color = Color(hex: "FFFFFF")     // white cap
    ) {
        self.bottleColor = bottleColor
        self.capColor = capColor
    }

    // Cap profile: (radius, z) points. Tapered shell up to z=64, then
    // one continuous convex curve down to a flat ⌀7 top at z=76.
    private var capProfile: [Vector2D] {
        [
            Vector2D(x: 0,    y: 51.0),
            Vector2D(x: 9.32, y: 51.0),
            Vector2D(x: 9.45, y: 51.5),
            Vector2D(x: 9.10, y: 55.5),
            Vector2D(x: 8.69, y: 60.0),
            Vector2D(x: 8.36, y: 64.0),
            Vector2D(x: 8.29, y: 64.5),
            Vector2D(x: 7.91, y: 65.0),
            Vector2D(x: 6.49, y: 65.5),
            Vector2D(x: 5.77, y: 66.0),
            Vector2D(x: 5.32, y: 66.5),
            Vector2D(x: 4.97, y: 67.0),
            Vector2D(x: 4.74, y: 67.75),
            Vector2D(x: 4.65, y: 68.0),
            Vector2D(x: 4.40, y: 70.0),
            Vector2D(x: 4.20, y: 72.0),
            Vector2D(x: 4.00, y: 74.0),
            Vector2D(x: 3.50, y: 76.0),
            Vector2D(x: 0,    y: 76.0),
        ]
    }

    public var body: any Geometry3D {
        Union {
            // ─── Bottle ─────────────────────────────────────────────────
            Union {
                Circle(diameter: bodyDiameter)
                    .extruded(
                        height: shoulderTopZ,
                        topEdge: .fillet(radius: shoulderFilletRadius),
                        bottomEdge: .fillet(radius: bodyBottomFillet)
                    )

                Cylinder(diameter: neckBaseDiameter, height: neckBaseTopZ - shoulderTopZ)
                    .translated(z: shoulderTopZ)

                Cylinder(diameter: threadRingDiameter, height: threadRingTopZ - neckBaseTopZ)
                    .translated(z: neckBaseTopZ)

                Cylinder(diameter: capFitDiameter, height: capFitTopZ - threadRingTopZ)
                    .translated(z: threadRingTopZ)

                Cylinder(
                    bottomDiameter: capFitDiameter,
                    topDiameter: dropperTipDiameter,
                    height: dropperTaperTopZ - capFitTopZ
                )
                .translated(z: capFitTopZ)

                Cylinder(diameter: dropperTipDiameter, height: dropperTipTopZ - dropperTaperTopZ)
                    .translated(z: dropperTaperTopZ)
            }
            .colored(bottleColor)

            // ─── Cap (revolved polygon, profile from mesh) ──────────────
            Polygon(capProfile)
                .revolved()
                .colored(capColor)

            // ─── Label (white wrap around the body cylinder) ────────────
            Cylinder(diameter: labelDiameter, height: labelTopZ - labelBottomZ)
                .translated(z: labelBottomZ)
                .colored(Color(hex: "FFFFFF"))
        }
    }
}
