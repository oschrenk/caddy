import Cadova

public struct SwitchFlex: Shape3D {
    public let width = 212.9
    public let depth = 99.4
    public let height = 33.5

    public init() {}

    public var body: any Geometry3D {
        Rectangle([width, depth])
            .rounded(radius: 6)
            .extruded(
                height: height,
                topEdge: .fillet(depth: 18, height: 6),
                bottomEdge: .fillet(depth: 18, height: 6)
            )
    }
}
