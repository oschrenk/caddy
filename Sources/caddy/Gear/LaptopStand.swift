import Cadova

// Vertical laptop/tablet stand modeled after the UGREEN aluminum stand.
// A flat base plate carries a row of upright aluminum fins; the gaps between
// adjacent fins are the device slots (openings). Each fin's body has an arched
// cutout giving the open colonnade look seen from the side. Black silicone
// pads line the slot floors and the inner fin faces (where devices touch).
//
// The number of openings is driven entirely by `slotThicknesses`: one entry
// per slot, low-y to high-y. N entries → N openings and N+1 fins. Add or
// remove an entry to change how many openings the stand has; everything else
// (fin positions, depth, pads) derives from it.
//
// Coordinate convention (stand-local):
//   x — slot length (laptop hinge axis); the stand's long dimension
//   y — slot arrangement (fins and the slots between them)
//   z — vertical; z=0 is the underside of the rubber feet
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

    // One entry per opening, low-y to high-y — the device thickness the slot is
    // sized for. THE NUMBER OF OPENINGS IS THIS ARRAY'S COUNT: add/remove an
    // entry to change it. Sized from the device models it holds.
    let slotThicknesses = [MacBookPro16().thickness, MacBookNeo().thickness]
    let slotClearance = 2.0

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
    var slotWidths: [Double] { slotThicknesses.map { $0 + 2 * slotClearance } }
    var finCount: Int { slotThicknesses.count + 1 }

    // Fin center-Y positions (finCount of them), accumulated across the slots.
    var finYs: [Double] {
        var ys = [baseOverhang + finThickness / 2]
        for w in slotWidths {
            ys.append(ys.last! + finThickness + w)
        }
        return ys
    }

    // Slot center-Y positions (one per opening), midway between adjacent fins.
    var slotCenterYs: [Double] {
        zip(finYs, finYs.dropFirst()).map { ($0 + $1) / 2 }
    }

    var width: Double { slotLength + 2 * baseOverhang }
    var depth: Double {
        2 * baseOverhang + Double(finCount) * finThickness + slotWidths.reduce(0, +)
    }
    var height: Double { footHeight + baseThickness + finHeight }

    var slotBottomZ: Double { footHeight + baseThickness }

    private var archWidth: Double {
        (slotLength - Double(archCount + 1) * footWidth) / Double(archCount)
    }

    // ---- Geometry ----
    var body: any Geometry3D {
        let aluminum = Color(hex: "8E929A")  // space-gray brushed aluminum
        let silicone = Color(hex: "2A2A2A")  // black silicone pad

        let slots = zip(slotCenterYs, slotWidths).map { (centerY: $0.0, width: $0.1) }

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

            // Upright fins — one more than the number of openings.
            for finY in finYs {
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
