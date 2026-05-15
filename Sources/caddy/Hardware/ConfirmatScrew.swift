import Cadova
import Helical

// A 5mm × 40mm Confirmat (Euro-screw) for connecting plywood panel edges.
// Dimensions match the Glarks Black Confirmat M5 × 40mm spec sheet:
//   • Head: 7mm dia × 1.1mm tall, with a flange-like shape:
//       - 0.3mm of cylindrical 7mm-dia top
//       - 0.8mm chamfered transition from 7mm down to 5mm dia
//   • Drive: 3mm hex socket (3mm Allen key), ~2.5mm deep
//   • Smooth shank below head: 5.5mm (unthreaded "lead-in")
//   • Thread major diameter: 5mm
//   • Thread minor diameter: 3.5mm (the shank without threads)
//   • Tip lead-in: 5mm tapering from 5mm to 3.5mm dia
//   • Total length from under-head to tip: 40mm
struct ConfirmatScrew: Shape3D {
    let length: Double
    let majorDiameter = 5.0       // thread major / shank
    let minorDiameter = 3.5       // thread root (shank without threads)
    let pitch = 2.5
    let unthreadedShank = 5.5     // smooth section between head and threads
    let headDiameter = 7.0
    let headHeight = 1.1          // total head height
    let headTaperHeight = 0.8     // axial length of the head's bottom chamfer
    let socketWidth = 3.0
    let socketDepth = 2.5
    let tipLength = 5.0
    let tipTaperDepth = 0.75      // (major − minor) / 2

    init(length: Double = 40.0) {
        self.length = length
    }

    private var thread: ScrewThread {
        // Custom thread: major=5, minor=3.5, pitch=2.5 (Confirmat-style coarse).
        // vShapedStandard would auto-calc a much smaller minor; override it here.
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
            headShape: CylindricalBoltHeadShape(
                diameter: headDiameter,
                height: headHeight,
                topEdge: nil,
                // Chamfer at the shank-side end of the head: 7mm → 5mm over 0.8mm.
                bottomEdge: .chamfer(
                    depth: (headDiameter - majorDiameter) / 2, // 1.0mm radial
                    height: headTaperHeight
                )
            ),
            socket: PolygonalBoltHeadSocket(
                sides: 6,
                width: socketWidth,
                depth: socketDepth,
                bottomAngle: 120°
            ),
            point: LeadInBoltPoint.leadIn(.constant(depth: tipTaperDepth, length: tipLength))
        )
    }

    var body: any Geometry3D {
        bolt.withMaterial(color: .silver, metallicness: 1, roughness: 0.3)
    }

    /// A clearance hole sized for this screw, with a counterbore matching the
    /// cylindrical head so the head sits flush when driven home.
    /// Subtract this from the side panel where each screw passes through.
    func clearanceHole(depth: Double? = nil) -> ClearanceHole {
        bolt.clearanceHole(depth: depth, entry: .recessedHead)
    }
}
