import Cadova

/// The two building walls the pila sits against — reference geometry, so the
/// fall direction can be checked against something real.
///
/// The walls occupy the x = 0 and y = 0 planes and run away from the pila, which
/// sits in the +x / -y quadrant. Their inside corner is the model origin.
///
/// Split at `wallSplitHeight`: bare concrete below, dark stained boarding above.
/// `band` picks which half to build, so the two can carry different materials.
struct Walls: Geometry3D {
    enum Band {
        case lower
        case upper
    }

    let dims: PilaDimensions
    let band: Band

    var body: any Geometry3D {
        let t = dims.buildingWallThickness
        let over = dims.buildingWallOverhang

        let (baseZ, height) = switch band {
        case .lower: (0.0, dims.wallSplitHeight)
        case .upper: (dims.wallSplitHeight, dims.buildingWallHeight - dims.wallSplitHeight)
        }

        // Behind the pila: the wall on the y = 0 plane, running in +y.
        let back = Box([dims.outerWidth + over + t, t, height])
            .translated(x: -t)

        // Left of the pila: the wall on the x = 0 plane, running in -x.
        let left = Box([t, dims.outerDepth + over + t, height])
            .translated(x: -t, y: -(dims.outerDepth + over))

        back
            .adding { left }
            .translated(z: baseZ)
    }
}
