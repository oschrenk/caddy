import Cadova

/// Side pane
/// Profile in the y-z plane: flat at `backHeight`
/// for `flatRunback`mm from the back, then sloping straight down to
/// `frontHeight`, then flat at `frontHeight` for `flatRunfront`mm to the
/// front edge. Extruded by `thickness` along x.
/// Optionally extends below z=0 by `skirtHeight` to form a foot that hides the
/// casters (set `skirtHeight = 0` for a flat-bottomed panel).
struct SidePanel: Shape3D {
    let thickness: Double
    let depth: Double
    let backHeight: Double
    let frontHeight: Double
    let flatRunback: Double
    let flatRunfront: Double
    let skirtHeight: Double

    init(
        thickness: Double,
        depth: Double,
        backHeight: Double,
        frontHeight: Double,
        flatRunback: Double,
        flatRunfront: Double = 0,
        skirtHeight: Double = 0
    ) {
        self.thickness = thickness
        self.depth = depth
        self.backHeight = backHeight
        self.frontHeight = frontHeight
        self.flatRunback = flatRunback
        self.flatRunfront = flatRunfront
        self.skirtHeight = skirtHeight
    }

    // 2D profile of the side panel — the polygon the panel is cut from.
    // x: front-to-back (0 to depth). y: floor-to-top (-skirtHeight to backHeight).
    // Reusable for nesting / sheet-layout outputs.
    var profile: any Geometry2D {
        Polygon([
            Vector2D(x: 0, y: -skirtHeight), // front-bottom (floor)
            Vector2D(x: depth, y: -skirtHeight), // back-bottom (floor)
            Vector2D(x: depth, y: backHeight), // back-top
            Vector2D(x: depth - flatRunback, y: backHeight), // end of back flat
            Vector2D(x: flatRunfront, y: frontHeight), // end of slope / start of front flat
            Vector2D(x: 0, y: frontHeight), // front-top
        ])
    }

    var body: any Geometry3D {
        profile
            .extruded(height: thickness)
            .rotated(x: 90°)
            .rotated(z: 90°)
    }
}
