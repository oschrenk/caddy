import Cadova

struct Unas: Shape3D {
    let width = 135.0
    let depth = 129.0
    let height = 223.7
    let cornerRadius = 15.0

    // Stadium-shaped cutout on the front face
    let pillWidth = 20.0
    let pillHeight = 37.3
    let pillCutDepth = 2.0

    var body: any Geometry3D {
        let r = pillWidth / 2
        let middleH = pillHeight - 2 * r

        Rectangle([width, depth])
            .rounded(radius: cornerRadius)
            .extruded(height: height, bottomEdge: .chamfer(depth: 10, height: 10))
            .withMaterial(color: Color(hex: "F5F5F5"), metallicness: 0, roughness: 0.35)
            .subtracting {
                // Stadium-shaped cutter built from box + 2 cylindrical caps.
                // (Rectangle.rounded + extrude + rotate fails to subtract in
                // Cadova — likely a CSG quirk — so we build the prism manually.)
                let cutterLen = pillCutDepth + 1

                Box([pillWidth, cutterLen, middleH])
                    .translated(x: (width - pillWidth) / 2, y: -1, z: (height - pillHeight) / 2 + r)
                Cylinder(diameter: pillWidth, height: cutterLen).rotated(x: 90°)
                    .translated(x: width / 2, y: pillCutDepth, z: (height - pillHeight) / 2 + r)
                Cylinder(diameter: pillWidth, height: cutterLen).rotated(x: 90°)
                    .translated(x: width / 2, y: pillCutDepth, z: (height + pillHeight) / 2 - r)
            }
            .adding {
                // Black shiny stadium-shaped fill, sitting flush in the recess.
                Union {
                    Box([pillWidth, pillCutDepth, middleH])
                        .translated(x: (width - pillWidth) / 2, y: 0, z: (height - pillHeight) / 2 + r)
                    Cylinder(diameter: pillWidth, height: pillCutDepth).rotated(x: 90°)
                        .translated(x: width / 2, y: pillCutDepth, z: (height - pillHeight) / 2 + r)
                    Cylinder(diameter: pillWidth, height: pillCutDepth).rotated(x: 90°)
                        .translated(x: width / 2, y: pillCutDepth, z: (height + pillHeight) / 2 - r)
                }
                .withMaterial(color: .black, metallicness: 0, roughness: 0.15)
            }
            .subtracting {
                // Cable-exit saddle: trapezoid with rounded top, cut from back-bottom.
                // Height matches the bottom chamfer (10mm).
                let baseW = 15.0
                let topW = 10.0
                let saddleH = 10.0
                let cornerR = 2.0
                let cutDepth = 12.0
                let baseY = -cornerR - 1.0 // sink rounded bottom corners below z=0

                Polygon([
                    Vector2D(-baseW / 2, baseY),
                    Vector2D(-topW / 2, saddleH),
                    Vector2D(topW / 2, saddleH),
                    Vector2D(baseW / 2, baseY),
                ])
                .rounded(outsideRadius: cornerR)
                .extruded(height: cutDepth)
                .rotated(x: 90°)
                .translated(x: width / 2, y: depth + 0.5, z: 0)
            }
    }
}
