import Cadova

// AirPods Max: 187.3 mm tall × 168.6 mm wide × 83.4 mm deep.
// STL bounds were 27.46 × 28.95 × 24.16 — non-AirPods-proportioned, so we
// scale per-axis. Axis mapping assumes STL x=wide, y=deep, z=tall.
public struct Headphones: Shape3D {
    public let width = 168.6
    public let depth = 145.95 // AirPods Max 83.4 mm + 75% to compensate for STL shape
    public let height = 187.3

    public init() {}

    public var body: any Geometry3D {
        Import(model: "Assets/models/Headphones.stl")
            .scaled(x: width / 27.46, y: depth / 28.95, z: height / 24.16)
            .colored(Color(hex: "2A2A2A"))
    }
}
