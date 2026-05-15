import Cadova

// A wooden box (e.g. for pens) with 8mm walls, open at the top.
// Front and back faces have a stadium-shaped handle cutout near the top.
struct WoodenBox: Shape3D {
    let width = 254.0   // 10 in
    let depth = 127.0   // 5 in
    let height = 109.22 // 4.3 in
    let wall = 8.0

    // Handle cutout
    let handleWidth = 80.0
    let handleHeight = 25.0
    let handleInsetTop = 15.0 // distance from top of box to top of handle

    var body: any Geometry3D {
        Box([width, depth, height])
            .subtracting {
                // Hollow interior, open at the top.
                Box([width - 2 * wall, depth - 2 * wall, height - wall])
                    .translated(x: wall, y: wall, z: wall)

                // Stadium-shaped handle, punched through left and right walls.
                // Long axis runs along Y (the box's depth), short axis along Z.
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
