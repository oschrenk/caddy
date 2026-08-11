import Cadova

// A tray with 8mm walls, open at the top.
// Front and back faces have a stadium-shaped handle cutout near the top.
public struct Tray: Shape3D {
    public let width = 380.0
    public let depth = 240.0
    public let height = 40.0
    public let wall = 8.0

    // Handle cutout
    public let handleWidth = 80.0
    public let handleHeight = 18.0
    public let handleInsetTop = 10.0 // distance from top of tray to top of handle

    public init() {}

    public var body: any Geometry3D {
        Box([width, depth, height])
            .subtracting {
                // Hollow interior, open at the top.
                Box([width - 2 * wall, depth - 2 * wall, height - wall])
                    .translated(x: wall, y: wall, z: wall)

                // Stadium-shaped handle, punched through left and right walls.
                // Long axis runs along Y (the tray's depth), short axis along Z.
                let r = handleHeight / 2
                Union {
                    Circle(radius: r).translated(x: r, y: r)
                    Circle(radius: r).translated(x: r, y: handleWidth - r)
                }
                .convexHull()
                .extruded(height: width + 2)
                .rotated(y: 90°)
                .translated(
                    x: -1,
                    y: (depth - handleWidth) / 2,
                    z: height - handleInsetTop
                )
            }
    }
}
