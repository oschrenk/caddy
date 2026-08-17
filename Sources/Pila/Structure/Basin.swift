import Cadova

/// The concrete pila: a plain rectangular block with two basins sunk into the
/// top, split by a central divider wall. No washboard wing, no drain edge.
///
/// Modelled as a fit-check reference for the lid, not as something to build.
struct Basin: Geometry3D {
    let dims: PilaDimensions

    var body: any Geometry3D {
        Box([dims.outerWidth, dims.outerDepth, dims.blockHeight])
            .subtracting {
                for x in dims.basinOriginsX {
                    Box([dims.basinWidth, dims.basinDepthY, dims.basinDepth + 1])
                        .translated(x: x, y: dims.wallThickness, z: dims.basinFloorZ)
                }
            }
    }
}
