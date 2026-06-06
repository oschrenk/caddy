import Cadova

// Vallejo Model Color 17 ml dropper bottle with cap.
//
// Profiles measured from two 3MF meshes (rotationally symmetric around z).
//
// Bottle (no cap), bottom to top:
//   z=  0– 3     bottom fillet R=3
//   z=  3–40     body cylinder ⌀25
//   z= 40–46     shoulder fillet R=6 (⌀25 → ⌀13.4)
//   z= 46–48     neck base ⌀13.4
//   z= 48–50     thread ring ⌀17 (cap screws onto this)
//   z= 50–60     cap-fit cylinder ⌀10.5
//   z= 60–67     dropper stem taper ⌀10.5 → ⌀4
//   z= 67–72     dropper tip ⌀4
//
// Cap, bottom to top — slightly tapered cylinder with a chamfered shoulder
// and a coned-in top (not a rounded dome):
//   z= 51–65     main shell, tapered ⌀18.9 → ⌀16.7
//   z= 65–68     chamfered shoulder, ⌀16.7 → ⌀10 (sharp cone)
//   z= 68–76     tapered finial, ⌀10 → ⌀7
//
// Body color defaults to Vallejo Model Color 70.939 Smoke. The hex (#937E62)
// is an approximation sampled from Encycolorpedia's RGB swatch — Vallejo does
// not publish official hex values, so this is a best-effort visual match
// rather than a spec.
struct VallejoBottle: Shape3D {
    let bottleColor: Color
    let capColor: Color

    // Bottle dimensions
    let bodyDiameter = 25.0
    let bodyBottomFillet = 3.0
    let shoulderFilletRadius = 6.0
    let bodyStraightTopZ = 40.0
    let shoulderTopZ = 46.0           // bodyStraightTopZ + shoulderFilletRadius

    let neckBaseDiameter = 13.4
    let neckBaseTopZ = 48.0

    let threadRingDiameter = 17.0
    let threadRingTopZ = 50.0

    let capFitDiameter = 10.5
    let capFitTopZ = 60.0

    let dropperTipDiameter = 4.0
    let dropperTaperTopZ = 67.0
    let dropperTipTopZ = 72.0

    // Cap dimensions
    let capBottomZ = 51.0
    let capBottomDiameter = 18.9
    let capShellTopZ = 65.0
    let capShellTopDiameter = 16.7
    let capChamferTopZ = 68.0
    let capChamferTopDiameter = 10.0
    let capFinialDiameter = 7.0
    let capTopZ = 76.0

    init(
        bottleColor: Color = Color(hex: "937E62"), // Vallejo Model Color 70.939 Smoke
        capColor: Color = Color(hex: "FFFFFF")     // white cap
    ) {
        self.bottleColor = bottleColor
        self.capColor = capColor
    }

    var body: any Geometry3D {
        Union {
            // ─── Bottle ─────────────────────────────────────────────────
            Union {
                // Body cylinder with bottom and top fillets.
                Circle(diameter: bodyDiameter)
                    .extruded(
                        height: shoulderTopZ,
                        topEdge: .fillet(radius: shoulderFilletRadius),
                        bottomEdge: .fillet(radius: bodyBottomFillet)
                    )

                // Neck base below the thread ring.
                Cylinder(diameter: neckBaseDiameter, height: neckBaseTopZ - shoulderTopZ)
                    .translated(z: shoulderTopZ)

                // Thread ring.
                Cylinder(diameter: threadRingDiameter, height: threadRingTopZ - neckBaseTopZ)
                    .translated(z: neckBaseTopZ)

                // Cap-fit cylinder.
                Cylinder(diameter: capFitDiameter, height: capFitTopZ - threadRingTopZ)
                    .translated(z: threadRingTopZ)

                // Dropper stem taper.
                Cylinder(
                    bottomDiameter: capFitDiameter,
                    topDiameter: dropperTipDiameter,
                    height: dropperTaperTopZ - capFitTopZ
                )
                .translated(z: capFitTopZ)

                // Dropper tip stub.
                Cylinder(diameter: dropperTipDiameter, height: dropperTipTopZ - dropperTaperTopZ)
                    .translated(z: dropperTaperTopZ)
            }
            .colored(bottleColor)

            // ─── Cap ────────────────────────────────────────────────────
            Union {
                // Main shell — slightly tapered.
                Cylinder(
                    bottomDiameter: capBottomDiameter,
                    topDiameter: capShellTopDiameter,
                    height: capShellTopZ - capBottomZ
                )
                .translated(z: capBottomZ)

                // Chamfered shoulder — sharp cone, not a rounded dome.
                Cylinder(
                    bottomDiameter: capShellTopDiameter,
                    topDiameter: capChamferTopDiameter,
                    height: capChamferTopZ - capShellTopZ
                )
                .translated(z: capShellTopZ)

                // Tapered finial on top.
                Cylinder(
                    bottomDiameter: capChamferTopDiameter,
                    topDiameter: capFinialDiameter,
                    height: capTopZ - capChamferTopZ
                )
                .translated(z: capChamferTopZ)
            }
            .colored(capColor)
        }
    }
}
