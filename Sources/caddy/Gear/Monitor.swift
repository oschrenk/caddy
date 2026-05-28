import Cadova

// Simplified monitor: a flat rectangular screen panel on a vertical neck
// rising from a rectangular base. Defaults to a roughly 27" 16:9 display.
//
// Local frame: front-left of base at origin, z = 0 at the bottom of the base.
// Screen faces -y (toward a viewer on the low-y side).
struct Monitor: Shape3D {
    let screenWidth: Double     // along x
    let screenHeight: Double    // along z
    let screenThickness: Double // along y
    let neckWidth: Double       // along x
    let neckDepth: Double       // along y
    let neckHeight: Double      // along z, from top of base to top of neck
    let baseWidth: Double       // along x
    let baseDepth: Double       // along y
    let baseHeight: Double      // along z
    let screenBottomZ: Double   // bottom edge of screen above the base top

    init(
        screenWidth: Double = 568,    // display + bezel
        screenHeight: Double = 331,
        screenThickness: Double = 50,
        neckWidth: Double = 60,
        neckDepth: Double = 30,
        neckHeight: Double = 220,
        baseWidth: Double = 260,
        baseDepth: Double = 200,
        baseHeight: Double = 18,
        screenBottomZ: Double = 60
    ) {
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self.screenThickness = screenThickness
        self.neckWidth = neckWidth
        self.neckDepth = neckDepth
        self.neckHeight = neckHeight
        self.baseWidth = baseWidth
        self.baseDepth = baseDepth
        self.baseHeight = baseHeight
        self.screenBottomZ = screenBottomZ
    }

    var body: any Geometry3D {
        let neckX = (baseWidth - neckWidth) / 2
        let neckY = baseDepth - neckDepth
        let screenX = (baseWidth - screenWidth) / 2
        let screenY = baseDepth - neckDepth - screenThickness

        let frame = Union {
            // Base
            Box([baseWidth, baseDepth, baseHeight])
            // Neck rising from the back-center of the base
            Box([neckWidth, neckDepth, neckHeight])
                .translated(x: neckX, y: neckY, z: baseHeight)
        }
        .withMaterial(color: Color(hex: "1A1A1A"), metallicness: 0.4, roughness: 0.45)

        let screen = Box([screenWidth, screenThickness, screenHeight])
            .translated(x: screenX, y: screenY, z: baseHeight + screenBottomZ)
            .withMaterial(color: Color(hex: "0A0A0A"), metallicness: 0.2, roughness: 0.25)

        return Union {
            frame
            screen
        }
    }
}
