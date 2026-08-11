import Cadova

public struct PiRack: Shape3D {
    public let count = 3
    public let baseLift = 11.0

    // Measured STL bounds:
    // Pi (after X 90°, Z 90° rotations):     58.4 × 89.0 × 19.9
    // Tower (after Z 90°, originally 96.1×78.4×4.6): 78.4 × 96.1 × 4.6
    public let boardThickness = 19.9
    public let towerThickness = 4.6
    public let piBoardDepth = 89.0   // Y extent of the Pi (narrower than the tower)

    public var width: Double { 78.4 }
    public var depth: Double { 96.1 }
    public var height: Double { baseLift + Double(count) * (towerThickness + boardThickness) }

    // Pi back face in rack-local Y (Pi is centered inside the tower's depth).
    public var piBackY: Double { (depth - piBoardDepth) / 2 + piBoardDepth }

    // Z position (rack-local, bottom-up) of each Pi board's mid-height.
    public var piCenterZs: [Double] {
        (0 ..< count).map { i in
            baseLift + Double(i + 1) * towerThickness + (Double(i) + 0.5) * boardThickness
        }
    }

    public init() {}

    public var body: any Geometry3D {
        let pi = Import(model: "Assets/Raspberry Pi 4 Model B.stl")
            .rotated(x: 90°)
            .rotated(z: 90°)
            .withMaterial(color: Color(hex: "50A03C"), metallicness: 0.3, roughness: 0.55)
        let tower = Import(model: "Assets/Tower.stl")
            .rotated(z: 90°)
            .colored(.white, alpha: 0.5)

        Stack(.z, alignment: .centerX, .centerY) {
            for _ in 0..<count {
                tower
                pi
            }
        }
        .aligned(at: .min)
        .translated(z: baseLift)
    }
}
