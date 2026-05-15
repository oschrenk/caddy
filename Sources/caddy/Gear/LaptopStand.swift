import Cadova

// Vertical laptop/tablet stand — a rectangular block with three slots cut
// into the top. Slot order (left to right along x): MacBook Pro 16",
// MacBook Neo, iPad. Devices stand hinge-down.
//
// Local frame: front-left at origin. Slot length along x, slots arranged in y,
// height along z. Each slot is sized for the device's thickness + clearance
// per side. The slot length matches the longest hinge edge (MBP 16, 355.7 mm).
struct LaptopStand: Shape3D {
    let slotLength: Double = 360.0       // along x — fits MBP 16's 355.7 mm hinge
    let slotDepth: Double = 50.0          // along z — how deep the slot cuts
    let height: Double = 60.0
    let wallThickness: Double = 10.0      // outer walls and between slots
    let slotClearance: Double = 2.0       // per side along slot width

    let mbpThickness: Double = 16.8
    let mbnThickness: Double = 12.7
    let ipadThickness: Double = 5.3

    var mbpSlotWidth: Double { mbpThickness + 2 * slotClearance }
    var mbnSlotWidth: Double { mbnThickness + 2 * slotClearance }
    var ipadSlotWidth: Double { ipadThickness + 2 * slotClearance }

    var width: Double { slotLength + 2 * wallThickness }
    var depth: Double {
        4 * wallThickness + mbpSlotWidth + mbnSlotWidth + ipadSlotWidth
    }

    /// Y center of each slot in stand-local coordinates.
    var mbpSlotY: Double {
        wallThickness + mbpSlotWidth / 2
    }
    var mbnSlotY: Double {
        wallThickness + mbpSlotWidth + wallThickness + mbnSlotWidth / 2
    }
    var ipadSlotY: Double {
        wallThickness + mbpSlotWidth + wallThickness + mbnSlotWidth + wallThickness + ipadSlotWidth / 2
    }

    /// Z of the bottom of every slot in stand-local coordinates.
    var slotBottomZ: Double { height - slotDepth }

    var body: any Geometry3D {
        Box([width, depth, height])
            .subtracting {
                let slots: [(y: Double, w: Double)] = [
                    (mbpSlotY, mbpSlotWidth),
                    (mbnSlotY, mbnSlotWidth),
                    (ipadSlotY, ipadSlotWidth),
                ]
                for s in slots {
                    Box([slotLength, s.w, slotDepth + 1])
                        .translated(
                            x: wallThickness,
                            y: s.y - s.w / 2,
                            z: slotBottomZ
                        )
                }
            }
            .withMaterial(color: Color(hex: "4A4A4A"), metallicness: 0.3, roughness: 0.55)
    }
}
