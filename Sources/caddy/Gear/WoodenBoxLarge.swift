import Cadova

// A large square wooden box (from cemaco), open at the top. Outer footprint
// 254 × 254 mm, 102 mm tall. Two opposite faces have a stadium-shaped handle
// cutout near the top, like the smaller WoodenBox.
struct WoodenBoxLarge: Shape3D {
    let width = 254.0  // 10 in (outer)
    let depth = 254.0  // 10 in (outer)
    let height = 102.0 // 10 cm (outer)
    let wall = 6.8     // same as WoodenBoxSmall

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
