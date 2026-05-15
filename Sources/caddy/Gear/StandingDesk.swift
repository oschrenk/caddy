import Cadova

/// Visual reference model of an electric height-adjustable standing desk,
/// placed next to the caddy for scale. Two T-feet with vertical column posts
/// joined by a crossbar, supporting a rectangular desktop.
///
/// Defaults reflect a typical 2-leg frame in the Uplift V2 / IKEA Bekant class
/// sized for a 55" × 28" (1397 × 711 mm) top. Several frame dimensions are
/// estimates where vendor spec sheets did not publish them.
///
/// Local frame: origin at the front-left of the desktop footprint, z = 0 at
/// the floor (under the feet).
struct StandingDesk: Shape3D {
    // Top
    let topWidth: Double // along x (1397 = 55")
    let topDepth: Double // along y (711  = 28")
    let topThickness: Double

    // Frame
    let deskHeight: Double // top surface of the desktop above the floor
    let footLength: Double // along y (front-to-back)
    let footWidth: Double // along x (narrow dimension of the foot)
    let footHeight: Double // along z
    let columnWidth: Double // along x
    let columnDepth: Double // along y
    let columnInsetFromEnd: Double // x-distance from each end of the top to column centerline
    let crossbarLengthCutout: Double // gap left at each end of the crossbar (column thickness)
    let crossbarHeight: Double // cross-section along z
    let crossbarDepth: Double // cross-section along y
    let crossbarZ: Double // z of the crossbar's vertical centerline

    init(
        topWidth: Double = 1397, // 55"
        topDepth: Double = 711, // 28"
        topThickness: Double = 25, // typical 1" laminate/MDF top
        deskHeight: Double = 730, // standing height, mid-range of typical 650–1280 travel
        footLength: Double = 600, // estimate; Uplift V2 Commercial foot ≈ 531 mm
        footWidth: Double = 65, // estimate; ≈ 3" aluminum/steel T-foot
        footHeight: Double = 70, // estimate; Uplift V2 Commercial ≈ 85 mm, others lower
        columnWidth: Double = 80, // Uplift V2 standard column 80 × 50 mm
        columnDepth: Double = 50,
        columnInsetFromEnd: Double = 175, // column centers inset from desktop ends
        crossbarHeight: Double = 60, // estimate
        crossbarDepth: Double = 40, // estimate
        crossbarZ: Double = 500 // estimate; about mid-column for a desk at standing height
    ) {
        self.topWidth = topWidth
        self.topDepth = topDepth
        self.topThickness = topThickness
        self.deskHeight = deskHeight
        self.footLength = footLength
        self.footWidth = footWidth
        self.footHeight = footHeight
        self.columnWidth = columnWidth
        self.columnDepth = columnDepth
        self.columnInsetFromEnd = columnInsetFromEnd
        crossbarLengthCutout = columnWidth
        self.crossbarHeight = crossbarHeight
        self.crossbarDepth = crossbarDepth
        self.crossbarZ = crossbarZ
    }

    var body: any Geometry3D {
        let columnLeftX = columnInsetFromEnd
        let columnRightX = topWidth - columnInsetFromEnd
        let footY = (topDepth - footLength) / 2
        let columnYCenter = topDepth / 2
        let columnTopZ = deskHeight - topThickness
        let columnHeight = columnTopZ - footHeight

        let crossbarX0 = columnLeftX + columnWidth / 2
        let crossbarX1 = columnRightX - columnWidth / 2

        let frame = Union {
            // Left foot + column
            Box([footWidth, footLength, footHeight])
                .translated(x: columnLeftX - footWidth / 2, y: footY)
            Box([columnWidth, columnDepth, columnHeight])
                .translated(
                    x: columnLeftX - columnWidth / 2,
                    y: columnYCenter - columnDepth / 2,
                    z: footHeight
                )

            // Right foot + column
            Box([footWidth, footLength, footHeight])
                .translated(x: columnRightX - footWidth / 2, y: footY)
            Box([columnWidth, columnDepth, columnHeight])
                .translated(
                    x: columnRightX - columnWidth / 2,
                    y: columnYCenter - columnDepth / 2,
                    z: footHeight
                )

            // Horizontal crossbar tying the two columns together
            Box([crossbarX1 - crossbarX0, crossbarDepth, crossbarHeight])
                .translated(
                    x: crossbarX0,
                    y: columnYCenter - crossbarDepth / 2,
                    z: crossbarZ - crossbarHeight / 2
                )
        }
        .withMaterial(color: Color(hex: "2A2A2A"), metallicness: 0.6, roughness: 0.4)

        let top = Box([topWidth, topDepth, topThickness])
            .translated(z: deskHeight - topThickness)
            .withMaterial(color: Color(hex: "D8C088"), metallicness: 0, roughness: 0.6)

        return Union {
            top
            frame
        }
    }
}
