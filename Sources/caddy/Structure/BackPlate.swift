import Cadova

// Back plate between the side panels, sitting on top of the bottom plate.
// Has a cable-grommet hole in each lower corner. `grommetClearance` is
// the gap between each hole edge and the nearest back-plate edges.
struct BackPlate: Shape3D {
    let width: Double
    let thickness: Double
    let height: Double
    let grommetDiameter: Double
    let grommetClearance: Double

    init(
        width: Double,
        thickness: Double,
        height: Double,
        grommetDiameter: Double = 50.0,
        grommetClearance: Double = 25.0
    ) {
        self.width = width
        self.thickness = thickness
        self.height = height
        self.grommetDiameter = grommetDiameter
        self.grommetClearance = grommetClearance
    }

    var body: any Geometry3D {
        let holeZ = grommetClearance + grommetDiameter / 2
        let holeXs = [
            grommetClearance + grommetDiameter / 2,          // lower-left
            width - grommetClearance - grommetDiameter / 2,  // lower-right
        ]
        return Box([width, thickness, height])
            .subtracting {
                for holeX in holeXs {
                    Cylinder(diameter: grommetDiameter, height: thickness + 2)
                        .rotated(x: -90°)
                        .translated(x: holeX, y: -1, z: holeZ)
                }
            }
    }
}
