import Cadova

// Square replacement base plate for the Bosch GKF 18V-8 palm router,
// rebuilt from the mesh in Router+Square.3mf.
//
// 110 mm square, 6.5 mm thick, centred on the origin in X and Y with its
// bottom face at z = 0. The screw pattern is not symmetric front to back,
// so the two hole rows carry different offsets.
//
// Checked against the source mesh: same bounding box, and the volume agrees
// to 0.01% (the remainder is arc tessellation in the fillets).
struct RouterSquareBase: Geometry3D {
    // Plate
    let side = 110.0
    let thickness = 6.5
    let cornerRadius = 3.0
    let edgeRound = 1.0 // round-over on the top and bottom perimeter

    // Notch in the +Y edge, clearing the router's depth-adjust lever.
    let notchWidth = 31.0
    let notchDepth = 17.5
    let notchFillet = 1.0      // inner corners at the bottom of the notch
    let notchMouthFillet = 3.0 // where the notch meets the +Y edge

    // Bit opening: a circle with a slot running out towards -Y.
    let openingRadius = 21.5
    let slotWidth = 20.0
    let slotEndY = -32.5
    let slotFillet = 1.0

    // Recess in the top face that the router's own base sits in. Four
    // semicircular bites at the diagonals leave the plate full thickness
    // there, which is what locates the router.
    let recessRadius = 26.0
    let recessDepth = 1.8
    let lobeRadius = 4.5

    // Mounting screws: countersunk from below into the router body.
    let screwHoleDiameter = 5.0
    let counterboreDiameter = 10.0
    let counterboreDepth = 3.5 // from the bottom face
    let counterboreFillet = 0.5
    let screwPositions: [Vector2D] = [
        [-22.25, 32.5], [22.25, 32.5], [-15.5, -36.0], [15.5, -36.0],
    ]

    init() {}

    // The plate seen from above: a rounded square with the notch taken out.
    var outline: any Geometry2D {
        Rectangle(side)
            .aligned(at: .center)
            .rounded(outsideRadius: cornerRadius)
            .subtracting { notchCutter }
    }

    // Cut as one shape so the mouth fillets fall out of `rounded(insideRadius:)`
    // rather than being placed by hand. The wide upper block sets where the
    // notch meets the +Y edge; the step between the two blocks is the corner
    // that gets filleted.
    var notchCutter: any Geometry2D {
        let edge = side / 2
        let floorY = edge - notchDepth
        return Union {
            Rectangle(x: notchWidth, y: edge + 5 - floorY)
                .translated(x: -notchWidth / 2, y: floorY)
                .rounded(radius: notchFillet)
            Rectangle(x: notchWidth + 2 * notchMouthFillet, y: 10)
                .translated(x: -(notchWidth / 2 + notchMouthFillet), y: edge)
        }
        .rounded(insideRadius: notchMouthFillet)
    }

    // Circle plus slot. The slot's own top corners land inside the circle and
    // are swallowed by the union, so rounding all four is safe.
    func keyhole(radius: Double) -> any Geometry2D {
        Union {
            Circle(radius: radius)
            Rectangle(x: slotWidth, y: -slotEndY)
                .translated(x: -slotWidth / 2, y: slotEndY)
                .rounded(radius: slotFillet)
        }
        .rounded(insideRadius: slotFillet)
    }

    // The lobes are subtracted after the fillet pass so their junctions with
    // the R26 arc stay sharp, which is how the original is drawn.
    var recessProfile: any Geometry2D {
        keyhole(radius: recessRadius)
            .subtracting {
                for angle in [45°, 135°, 225°, 315°] {
                    Circle(radius: lobeRadius)
                        .translated(x: recessRadius)
                        .rotated(angle)
                }
            }
    }

    // Revolved rather than extruded so the counterbore mouth can carry its
    // round-over. X is the radius, Y is height above the bottom face.
    var screwCutter: any Geometry3D {
        let boreRadius = counterboreDiameter / 2
        let f = counterboreFillet
        return Union {
            Circle(diameter: screwHoleDiameter)
                .extruded(height: thickness + 2)
                .translated(z: -1)

            Union {
                Rectangle(x: boreRadius, y: counterboreDepth)
                Rectangle(x: boreRadius + f, y: f)
                    .subtracting { Circle(radius: f).translated(x: boreRadius + f, y: f) }
                Rectangle(x: boreRadius + f, y: 1).translated(y: -1)
            }
            .revolved()
        }
    }

    var body: any Geometry3D {
        outline
            .extruded(
                height: thickness,
                topEdge: .fillet(radius: edgeRound),
                bottomEdge: .fillet(radius: edgeRound)
            )
            .subtracting {
                // Bit opening, with a round-over where it breaks through the
                // bottom face. `formingEdgeProfile` grows the cutter outwards,
                // which is what leaves a fillet behind rather than a sharp lip.
                keyhole(radius: openingRadius)
                    .extruded(height: thickness)
                    .formingEdgeProfile(.fillet(radius: edgeRound), on: .bottom)

                recessProfile
                    .extruded(height: recessDepth + 1)
                    .translated(z: thickness - recessDepth)

                for position in screwPositions {
                    screwCutter.translated(x: position.x, y: position.y)
                }
            }
    }
}
