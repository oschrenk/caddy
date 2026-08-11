import Cadova

// The mounting base plate of a caster — the flange that screws to the
// underside of the bottom shelf. A thin rounded-corner rectangle with four
// screw holes. Modeled with its footprint corner at the origin and its TOP
// face at z = 0, so it sits flush against the shelf underside.
public struct CasterPlate: Shape3D {
    public let width = 33.1     // short side (x)
    public let depth = 39.2     // long side (y)
    public let thickness = 1.3
    public let cornerRadius = 4.0

    public let holeDiameter = 4.0
    // Measured plate-edge → nearest hole edge; add the radius for hole centers.
    public let holeGapFromShortEdge = 2.5 // hole-edge gap along the long axis (y)
    public let holeGapFromLongEdge = 2.3  // hole-edge gap along the short axis (x)

    public init() {}

    public var body: any Geometry3D {
        let r = holeDiameter / 2
        let xInset = holeGapFromLongEdge + r
        let yInset = holeGapFromShortEdge + r
        let xs = [xInset, width - xInset]
        let ys = [yInset, depth - yInset]
        return Rectangle([width, depth])
            .rounded(radius: cornerRadius)
            .extruded(height: thickness)
            .subtracting {
                for x in xs {
                    for y in ys {
                        Circle(diameter: holeDiameter)
                            .extruded(height: thickness + 2)
                            .translated(x: x, y: y, z: -1)
                    }
                }
            }
            .translated(z: -thickness) // top face flush at z = 0
    }
}

// A single swivel caster, centered on its swivel axis at the origin in x/y
// with the base plate's top face flush at z = 0 (screwed to the shelf
// underside). The mechanism hangs below: swivel housing → fork → wheel.
//
// Dimensionally accurate: the base plate, the wheel diameter (32.1 mm), and
// the overall height (44.5 mm from the top of the plate to the bottom of the
// wheel). The swivel housing and fork are plausible estimates for looks.
public struct Caster: Shape3D {
    public let wheelDiameter = 32.1
    public let totalHeight = 44.5 // top of base plate → bottom of wheel

    public let wheelWidth = 13.0 // measured

    // Estimated (not measured) — refine when known.
    public let trail = 6.0            // wheel-axle offset from the swivel axis (x)
    public let swivelDiameter = 26.0  // round bearing race under the plate
    public let swivelHeight = 7.0
    public let forkLegThickness = 3.0
    public let forkGap = 1.5          // clearance between wheel face and fork leg
    public let axleDiameter = 5.0

    public init() {}

    public var body: any Geometry3D {
        let plate = CasterPlate()

        let wheelRadius = wheelDiameter / 2
        let wheelCenterZ = -(totalHeight - wheelRadius)

        let housingTopZ = -plate.thickness
        let housingBottomZ = housingTopZ - swivelHeight

        let legInnerY = wheelWidth / 2 + forkGap
        let legOuterY = legInnerY + forkLegThickness
        let legLengthX = 12.0
        let legBottomZ = wheelCenterZ
        let legHeight = housingBottomZ - legBottomZ

        // Everything below the plate swivels as a unit about the vertical axis.
        let mechanism = Union {
            // Swivel housing (bearing race) directly under the plate.
            Cylinder(diameter: swivelDiameter, height: swivelHeight)
                .translated(z: housingBottomZ)

            // Fork crown bridging the housing to the two legs.
            Box([legLengthX + trail, 2 * legOuterY, swivelHeight])
                .translated(x: -legLengthX / 2, y: -legOuterY, z: housingBottomZ)

            // Two fork legs straddling the wheel, down to the axle.
            for sy in [legInnerY, -legOuterY] {
                Box([legLengthX, forkLegThickness, legHeight])
                    .translated(x: trail - legLengthX / 2, y: sy, z: legBottomZ)
            }

            // Wheel — a horizontal cylinder on the axle, trailing the swivel axis.
            Cylinder(diameter: wheelDiameter, height: wheelWidth)
                .rotated(x: 90°)
                .translated(x: trail, y: wheelWidth / 2, z: wheelCenterZ)

            // Axle through the fork and wheel.
            Cylinder(diameter: axleDiameter, height: 2 * legOuterY)
                .rotated(x: 90°)
                .translated(x: trail, y: legOuterY, z: wheelCenterZ)
        }

        return Union {
            // Base plate, centered on the swivel axis (orientation fixed).
            plate.translated(x: -plate.width / 2, y: -plate.depth / 2)

            // Swivel assembly, rotated 90° about the vertical axis.
            mechanism.rotated(z: 90°)
        }
    }
}

// Casters placed at the given swivel-axis mount points (x, y).
public func casters(at points: [(x: Double, y: Double)]) -> any Geometry3D {
    Union {
        for p in points {
            Caster().translated(x: p.x, y: p.y)
        }
    }
}
