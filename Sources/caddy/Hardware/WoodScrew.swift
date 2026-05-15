import Cadova
import Helical

// A typical wood screw — Phillips countersunk head, coarse wood thread, sharp
// pointed tip. Modeled approximately on a #8 / M4-ish wood screw.
//
//   • Head: 8mm dia countersunk (90° cone), Phillips drive
//   • Thread: 4mm major, 2.5mm minor, 1.7mm pitch (~15 TPI, typical wood)
//   • Tip: tapered conical point
struct WoodScrew: Shape3D {
    let length: Double
    let majorDiameter = 4.0
    let minorDiameter = 2.5
    let pitch = 1.7
    let headDiameter = 8.0
    let unthreadedShank = 3.0

    init(length: Double = 25.0) {
        self.length = length
    }

    private var thread: ScrewThread {
        ScrewThread(
            pitch: pitch,
            majorDiameter: majorDiameter,
            minorDiameter: minorDiameter,
            form: .trapezoidal(angle: 60°, crestWidth: pitch / 8.0)
        )
    }

    private var bolt: Bolt {
        Bolt(
            thread: thread,
            length: length,
            unthreadedLength: unthreadedShank,
            unthreadedDiameter: majorDiameter,
            headShape: CountersunkBoltHeadShape(
                angle: 90°,
                topDiameter: headDiameter,
                boltDiameter: majorDiameter
            ),
            socket: PhillipsBoltHeadSocket.phillips(size: .ph2, width: 4.0),
            // Tip tapers to ~0.4mm dia (not a perfect point — avoids zero-radius
            // cylinder asserts).
            point: ProfiledBoltPoint(depth: majorDiameter / 2 - 0.2, length: 4.0)
        )
    }

    var body: any Geometry3D {
        bolt.withMaterial(color: .darkGray, metallicness: 1, roughness: 0.3)
    }

    /// A clearance hole sized for this screw, with a countersink to match the
    /// head so it sits flush. Subtract from the board the screw passes through.
    func clearanceHole(depth: Double? = nil) -> ClearanceHole {
        bolt.clearanceHole(depth: depth, entry: .recessedHead)
    }
}
