import Cadova

/// The bare plywood cabinet: side panels, back plate, the four shelves, front
/// and back kick plates, cross-brace, and front lip — unioned into one solid.
/// No hardware, gear, or screw holes. Used for the merged `caddy.stl` export.
/// Placements mirror the frame section of `main.swift`.
struct Cabinet: Shape3D {
    let dims: CaddyDimensions

    var body: any Geometry3D {
        let t1 = dims.t1
        let backHeight = dims.backHeight
        let outerWidth = dims.outerWidth
        let outerDepth = dims.outerDepth
        let innerWidth = dims.innerWidth
        let innerDepth = dims.innerDepth
        let shelf2Z = dims.shelf2Z
        let shelf3Z = dims.shelf3Z
        let shelf4Z = dims.shelf4Z
        let skirtHeight = dims.skirtHeight
        let lipHeight = dims.lipHeight
        let frontHeight = dims.frontHeight
        let flatRun = dims.flatRun

        let sidePanel = SidePanel(
            thickness: t1,
            depth: outerDepth,
            backHeight: backHeight,
            frontHeight: frontHeight,
            flatRunback: flatRun,
            flatRunfront: flatRun,
            skirtHeight: skirtHeight
        )

        sidePanel // left, x = 0
            .adding {
                sidePanel.translated(x: outerWidth - t1) // right

                BackPlate(width: innerWidth, thickness: t1, height: backHeight - t1)
                    .translated(x: t1, y: innerDepth, z: t1)

                Shelf(width: innerWidth, depth: outerDepth, thickness: t1) // shelf 1 (bottom)
                    .translated(x: t1)

                KickPlate(width: innerWidth, thickness: t1, height: skirtHeight) // front kick
                    .translated(x: t1, z: -skirtHeight)

                KickPlate(width: innerWidth, thickness: t1, height: skirtHeight) // back kick
                    .translated(x: t1, y: outerDepth - t1, z: -skirtHeight)

                CrossBrace(thickness: t1, depth: outerDepth, height: skirtHeight)
                    .translated(x: t1 + (innerWidth - t1) / 2, z: -skirtHeight)

                Shelf(width: innerWidth, depth: innerDepth, thickness: t1) // shelf 2
                    .translated(x: t1, z: shelf2Z - t1)

                Shelf(width: innerWidth, depth: innerDepth, thickness: t1) // shelf 3
                    .translated(x: t1, z: shelf3Z - t1)

                Shelf(width: innerWidth, depth: innerDepth, thickness: t1) // shelf 4
                    .translated(x: t1, z: shelf4Z - t1)

                KickPlate(width: innerWidth, thickness: t1, height: lipHeight) // front lip
                    .translated(x: t1, z: shelf4Z)
            }
    }
}
