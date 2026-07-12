import Cadova

// Vertical laptop/tablet stand modeled after the UGREEN 3-slot aluminum stand.
// A flat base plate carries four upright aluminum fins; the gaps between
// adjacent fins are the device slots. Each fin's body has 3 arched cutouts
// giving the open colonnade look seen from the side. Black silicone pads line
// the slot floors and the inner fin faces (where laptops touch).
//
// Coordinate convention (stand-local):
//   x — slot length (laptop hinge axis); the stand's long dimension
//   y — slot arrangement (4 fins, 3 slots between them)
//   z — vertical; z=0 is the underside of the rubber feet
//
// Slot order along +y, low to high: MacBook Pro 16", MacBook Neo, iPad.
struct LaptopStand: Shape3D {
    // 5.9 in (~150 mm) — the actual UGREEN footprint. Laptops overhang the
    // stand on both sides; the stand only supports them in the middle.
    let slotLength = 150.0

    // Fin geometry (profile in xz, extruded along y).
    let finHeight = 92.0
    let finThickness = 8.0
    let finTopFillet = 8.0

    // Arch cutout in each fin (only one fits at this length).
    let archCount = 1
    let archHeight = 50.0
    let footWidth = 25.0

    // Base plate.
    let baseThickness = 7.0
    let baseOverhang = 10.0       // base extends past fins along x and y
    let baseCornerRadius = 14.0
    let baseTopChamfer = 1.5

    // Slot widths driven by device thicknesses + clearance.
    let slotClearance = 2.0
    let mbpThickness = 16.8
    let mbnThickness = 12.7
    let ipadThickness = 5.3

    // Silicone pads (slot floors + inner fin faces).
    let padThickness = 1.5
    let padLength = 110.0
    let padFaceHeight = 34.0
    let padFloorInset = 1.0

    // Rubber feet.
    let footSize = 12.0
    let footHeight = 2.0
    let footInset = 10.0

    // ---- Derived dimensions ----
    var mbpSlotWidth: Double { mbpThickness + 2 * slotClearance }
    var mbnSlotWidth: Double { mbnThickness + 2 * slotClearance }
    var ipadSlotWidth: Double { ipadThickness + 2 * slotClearance }

    var width: Double { slotLength + 2 * baseOverhang }
    var depth: Double {
        2 * baseOverhang + 4 * finThickness + mbpSlotWidth + mbnSlotWidth + ipadSlotWidth
    }
    var height: Double { footHeight + baseThickness + finHeight }

    private var fin0Y: Double { baseOverhang + finThickness / 2 }
    private var fin1Y: Double { fin0Y + finThickness + mbpSlotWidth }
    private var fin2Y: Double { fin1Y + finThickness + mbnSlotWidth }
    private var fin3Y: Double { fin2Y + finThickness + ipadSlotWidth }

    var mbpSlotY: Double { (fin0Y + fin1Y) / 2 }
    var mbnSlotY: Double { (fin1Y + fin2Y) / 2 }
    var ipadSlotY: Double { (fin2Y + fin3Y) / 2 }

    var slotBottomZ: Double { footHeight + baseThickness }

    private var archWidth: Double {
        (slotLength - Double(archCount + 1) * footWidth) / Double(archCount)
    }

    // ---- Geometry ----
    var body: any Geometry3D {
        let aluminum = Color(hex: "8E929A")  // space-gray brushed aluminum
        let silicone = Color(hex: "2A2A2A")  // black silicone pad

        let slots: [(centerY: Double, width: Double)] = [
            (mbpSlotY, mbpSlotWidth),
            (mbnSlotY, mbnSlotWidth),
            (ipadSlotY, ipadSlotWidth),
        ]

        return Union {
            // Base plate: rounded corners, gentle top chamfer.
            Rectangle([width, depth])
                .rounded(insideRadius: baseCornerRadius)
                .extruded(
                    height: baseThickness,
                    topEdge: .chamfer(depth: baseTopChamfer, height: baseTopChamfer)
                )
                .translated(z: footHeight)
                .withMaterial(color: aluminum, metallicness: 0.3, roughness: 0.55)

            // Four upright fins.
            for finY in [fin0Y, fin1Y, fin2Y, fin3Y] {
                fin3D
                    .translated(x: baseOverhang, y: finY - finThickness / 2, z: footHeight + baseThickness)
                    .withMaterial(color: aluminum, metallicness: 0.3, roughness: 0.55)
            }

            // Silicone pads inside each slot.
            for slot in slots {
                let padX = (width - padLength) / 2
                let padZ = footHeight + baseThickness

                // Floor pad.
                Box([padLength, slot.width - 2 * padFloorInset, padThickness])
                    .translated(
                        x: padX,
                        y: slot.centerY - (slot.width - 2 * padFloorInset) / 2,
                        z: padZ
                    )
                    .withMaterial(color: silicone, metallicness: 0, roughness: 0.85)

                // Side pads on the inner fin faces.
                for yFace in [
                    slot.centerY - slot.width / 2,
                    slot.centerY + slot.width / 2 - padThickness,
                ] {
                    Box([padLength, padThickness, padFaceHeight])
                        .translated(x: padX, y: yFace, z: padZ + padThickness + 1)
                        .withMaterial(color: silicone, metallicness: 0, roughness: 0.85)
                }
            }

            // Rubber feet at the 4 base-plate corners.
            for (fx, fy) in [
                (footInset, footInset),
                (width - footInset - footSize, footInset),
                (footInset, depth - footInset - footSize),
                (width - footInset - footSize, depth - footInset - footSize),
            ] {
                Box([footSize, footSize, footHeight])
                    .translated(x: fx, y: fy)
                    .withMaterial(color: silicone, metallicness: 0, roughness: 0.85)
            }
        }
    }

    // 3D fin: extrude the 2D xy profile by finThickness, then rotate so the
    // profile lies in xz and the thickness runs along +y.
    private var fin3D: any Geometry3D {
        finProfile
            .extruded(height: finThickness)
            .rotated(x: 90°)
            .aligned(at: .min)
    }

    // 2D fin profile in xy: a rectangle with rounded top corners and
    // `archCount` evenly-spaced arched cutouts at the bottom.
    private var finProfile: any Geometry2D {
        let r = finTopFillet
        let outer = Union {
            Rectangle([slotLength, finHeight - r])
            Rectangle([slotLength - 2 * r, finHeight])
                .translated(x: r)
            Circle(radius: r).translated(x: r, y: finHeight - r)
            Circle(radius: r).translated(x: slotLength - r, y: finHeight - r)
        }

        let archStepX = footWidth + archWidth
        let archRadius = archWidth / 2

        return outer.subtracting {
            for i in 0 ..< archCount {
                let x0 = footWidth + Double(i) * archStepX
                Union {
                    Rectangle([archWidth, archHeight - archRadius])
                    Circle(radius: archRadius)
                        .translated(x: archRadius, y: archHeight - archRadius)
                }
                .translated(x: x0)
            }
        }
    }
}
