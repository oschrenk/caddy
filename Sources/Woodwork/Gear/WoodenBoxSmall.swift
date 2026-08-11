import Cadova

// A smaller wooden box, square in plan, open at the top. No handle cutouts.
public struct WoodenBoxSmall: Shape3D {
    public let width = 127.0 // 5 in
    public let depth = 127.0 // 5 in
    public let height = 63.5 // 2.5 in
    public let wall = 6.8

    public init() {}

    public var body: any Geometry3D {
        Box([width, depth, height])
            .subtracting {
                Box([width - 2 * wall, depth - 2 * wall, height - wall])
                    .translated(x: wall, y: wall, z: wall)
            }
    }
}
