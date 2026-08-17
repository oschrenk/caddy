import Cadova

/// The waterspout, simplified: a boss on the back wall and a horizontal arm
/// reaching out over the second basin.
///
/// Positioned in global coordinates — it hangs off the building wall, not off
/// the pila, so it does not move when the pila is shuffled around.
///
/// **The measured 53 mm is to the underside of the pipe**, so the axis sits half
/// a diameter higher. The underside is what the lid has to slide beneath.
struct Spout: Geometry3D {
    let dims: PilaDimensions

    var body: any Geometry3D {
        let d = dims.spoutDiameter
        let x = dims.pilaOffsetX + dims.spoutLocalX
        let z = dims.spoutAxisZ

        // Boss where the spout leaves the wall.
        let boss = Cylinder(diameter: d * 1.8, height: 25)
            .rotated(x: 90°)
            .translated(x: x, y: 25, z: z)

        // Arm, running forward from the wall face into -y.
        let arm = Cylinder(diameter: d, height: dims.spoutReach)
            .rotated(x: 90°)
            .translated(x: x, z: z)

        boss
            .adding {
                arm

                // Downturned tip, only if the real spout has one.
                if dims.spoutTipDrop > 0 {
                    Cylinder(diameter: d, height: dims.spoutTipDrop)
                        .translated(
                            x: x, y: -dims.spoutReach, z: z - dims.spoutTipDrop
                        )
                }
            }
    }
}
