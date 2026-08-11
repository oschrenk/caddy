import Cadova
import Foundation

// 150 mL laboratory wash bottle (LDPE squeeze bottle) — solid silhouette mockup.
// Body axis runs along z. A single one-piece tube exits the cap, tapers
// gradually along a 90° bend, and ends in a quick conical jet tip aimed +y.
public struct WashBottle: Shape3D {
    public let bodyDiameter = 51.0
    public let bodyHeight = 85.8           // straight cylindrical section
    public let bodyTopFillet = 5.0         // rounded shoulder at top of body
    public let neckDiameter = 31.2
    public let neckHeight = 25.0           // includes the screw cap

    // Delivery tube: tapers linearly along arc-length from cap to spout base.
    public let tubeDiameterAtCap = 7.8
    public let tubeDiameterAtSpoutBase = 6.1
    public let trunkHeight = 45.0          // vertical reach from cap to bend center
    public let spoutLength = 63.0          // horizontal reach from bend center to tip
    public let bendRadius = 20.0           // centerline radius of the 90° bend

    // Jet tip (continues the taper at the very end).
    public let spoutTipDiameter = 3.1
    public let spoutTipLength = 15.5

    // Smoothness of the discretized tapered bend.
    public let bendSegments = 64

    // Bounding box. Body axis sits at (bodyDiameter/2, bodyDiameter/2);
    // the spout extends in +y past the body's depth.
    public var width: Double { bodyDiameter }
    public var depth: Double { bodyDiameter / 2 + spoutLength }
    public var height: Double {
        bodyHeight + neckHeight + trunkHeight + tubeDiameterAtCap / 2
    }

    public init() {}

    public var body: any Geometry3D {
        let axisX = bodyDiameter / 2
        let axisY = bodyDiameter / 2
        let zNeck = bodyHeight
        let zTrunk = zNeck + neckHeight
        let zBend = zTrunk + trunkHeight

        let vertStraight = trunkHeight - bendRadius           // vertical riser length
        let horizStraight = spoutLength - spoutTipLength - bendRadius  // horizontal straight length
        let arcLen = bendRadius * .pi / 2
        let totalArc = vertStraight + arcLen + horizStraight

        // Linear taper from cap-end (s=0) to spout-base (s=totalArc).
        func dAt(_ s: Double) -> Double {
            tubeDiameterAtCap + (tubeDiameterAtSpoutBase - tubeDiameterAtCap) * (s / totalArc)
        }
        let dBendStart = dAt(vertStraight)
        let dBendEnd = dAt(vertStraight + arcLen)

        let zVertTop = zTrunk + vertStraight  // arc starts here

        // 90° bend as a fan of frusta. Each chord runs from P(θ_i) to P(θ_{i+1});
        // the math (verified) makes consecutive frusta meet exactly at the chord
        // endpoints, so the union is leak-free.
        let arcFrusta = (0 ..< bendSegments).map { i -> any Geometry3D in
            let theta0 = Double(i) / Double(bendSegments) * .pi / 2
            let theta1 = Double(i + 1) / Double(bendSegments) * .pi / 2
            let thetaMid = (theta0 + theta1) / 2
            let chord = 2 * bendRadius * sin((theta1 - theta0) / 2)
            let p0y = bendRadius * (1 - cos(theta0))
            let p0z = zVertTop + bendRadius * sin(theta0)
            let s0 = vertStraight + bendRadius * theta0
            let s1 = vertStraight + bendRadius * theta1
            return Cylinder(bottomDiameter: dAt(s0), topDiameter: dAt(s1), height: chord)
                .rotated(x: Angle(radians: -thetaMid))
                .translated(y: p0y, z: p0z)
        }

        return Union {
            Circle(diameter: bodyDiameter)
                .extruded(height: bodyHeight, topEdge: .fillet(radius: bodyTopFillet))

            Cylinder(diameter: neckDiameter, height: neckHeight)
                .translated(z: zNeck)

            // Vertical straight tapered section.
            Cylinder(bottomDiameter: tubeDiameterAtCap, topDiameter: dBendStart, height: vertStraight)
                .translated(z: zTrunk)

            arcFrusta

            // Horizontal straight tapered section.
            Cylinder(bottomDiameter: dBendEnd, topDiameter: tubeDiameterAtSpoutBase, height: horizStraight)
                .rotated(x: -90°)
                .translated(y: bendRadius, z: zBend)

            // Tapered jet tip; flush continuation of the tube.
            Cylinder(
                bottomDiameter: tubeDiameterAtSpoutBase,
                topDiameter: spoutTipDiameter,
                height: spoutTipLength
            )
            .rotated(x: -90°)
            .translated(y: spoutLength - spoutTipLength, z: zBend)
        }
        .translated(x: axisX, y: axisY)
        .colored(Color(hex: "F2F2F2"))
    }
}
