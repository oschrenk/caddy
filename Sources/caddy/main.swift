import Cadova

let cutReg = CutRegistry()

await Project {

await Model("caddy") {
    // *************************
    // * VARIABLES
    // *************************
    let dims = CaddyDimensions()

    // Bind the most-used fields locally so the rest of this file reads
    // unchanged. Anything not bound here is referenced as `dims.X` below.
    let t1 = dims.t1
    let wiggleRoom = dims.wiggleRoom
    let backHeight = dims.backHeight
    let outerWidth = dims.outerWidth
    let outerDepth = dims.outerDepth
    let innerWidth = dims.innerWidth
    let innerDepth = dims.innerDepth
    let shelf2Z = dims.shelf2Z
    let shelf4Z = dims.shelf4Z
    let shelf3Z = dims.shelf3Z
    let shelf1Z = dims.shelf1Z
    let frontInset = dims.frontInset
    let skirtHeight = dims.skirtHeight
    let casterDiameter = dims.casterDiameter
    let lipHeight = dims.lipHeight
    let frontHeight = dims.frontHeight
    let flatRun = dims.flatRun

    // Parts (toggleable in CadovaViewer)
    let leftPanelPart  = Part("Side panel (L)")
    let rightPanelPart = Part("Side panel (R)")
    let backPlatePart  = Part("Back plate")
    let shelf1Part     = Part("Shelf 1")
    let shelf2Part     = Part("Shelf 2")
    let shelf4Part     = Part("Shelf 4")
    let shelf3Part     = Part("Shelf 3")
    let castersPart    = Part("Casters")
    let skirtPart      = Part("Skirt") // front + back kick, cross-brace, front lip
    let woodScrewsPart = Part("Wood screws")
    let confirmatsPart = Part("Confirmats")
    let gearPart       = Part("Gear")
    let standingDeskPart = Part("Standing desk")
    let monitorPart = Part("Monitor")
    let macbookPart = Part("MacBook Pro 16\"")
    let macbookNeoPart = Part("MacBook Neo")
    let ipadPart = Part("iPad")
    let laptopStandPart = Part("Laptop stand")

    // Colors
    let ral1003 = Color(hex: "F7BA0B") // signal yellow
    let ral3015 = Color(hex: "E5A4B2") // light pink
    let ral240_80_15 = Color(hex: "AACDDD") // RAL Design 240 80 15, light pastel blue

    // *************************
    // * FRAME
    // *************************

    // objects
    let sidePanel = SidePanel(
        thickness: t1,
        depth: outerDepth,
        backHeight: backHeight,
        frontHeight: frontHeight,
        flatRunback: flatRun,
        flatRunfront: flatRun,
        skirtHeight: skirtHeight
    )

    // Confirmat clearance holes on the side panels — one set of (y, z) positions
    // per panel, mirrored in x for left vs right. Layout per Assembly.md:
    //
    //   • Shelf 1 (bottom plate): 4 per side panel
    //   • Shelf 2:         3 per side panel
    //   • Shelf 3:         2 per side panel
    //   • Shelf 4:         2 per side panel
    //   • Front kick:      1 per side panel
    //   • Back kick:       1 per side panel
    //   • Back plate:      4 per side panel (top one close to the peak)
    //   • Front lip:       1 per side (into the lip's ends) + 2 hidden screws
    //                       driven up from under shelf 4 into the lip's bottom
    //
    let screw = ConfirmatScrew()
    let edgeMargin = 25.0

    let shelf1ZMid = t1 / 2
    let shelf1Ys = (0 ..< 4).map { edgeMargin + Double($0) * (outerDepth - 2 * edgeMargin) / 3 }

    let shelf2ZMid = shelf2Z - t1 / 2
    let shelf2Ys = (0 ..< 3).map { edgeMargin + Double($0) * (innerDepth - 2 * edgeMargin) / 2 }

    let shelf4ZMid = shelf4Z - t1 / 2
    let shelf4Ys = [t1 + edgeMargin, innerDepth - edgeMargin]

    let shelf3ZMid = shelf3Z - t1 / 2
    let shelf3Ys = [t1 + edgeMargin, innerDepth - edgeMargin]

    let kickZ = -skirtHeight / 2
    let frontKickY = t1 / 2
    let backKickY = outerDepth - t1 / 2

    let backPlateY = outerDepth - t1 / 2
    let backPlateZTop = backHeight - 30
    let backPlateZBottom = t1 + 30
    let backPlateZs = (0 ..< 4).map {
        backPlateZBottom + Double($0) * (backPlateZTop - backPlateZBottom) / 3
    }

    let lipY = t1 / 2
    let lipZ = shelf4Z + lipHeight / 2

    let holes: [(y: Double, z: Double)] = {
        var out: [(y: Double, z: Double)] = []
        for y in shelf1Ys {
            out.append((y, shelf1ZMid))
        }
        for y in shelf2Ys {
            out.append((y, shelf2ZMid))
        }
        for y in shelf4Ys {
            out.append((y, shelf4ZMid))
        }
        for y in shelf3Ys {
            out.append((y, shelf3ZMid))
        }
        out.append((frontKickY, kickZ))
        out.append((backKickY, kickZ))
        for z in backPlateZs {
            out.append((backPlateY, z))
        }
        out.append((lipY, lipZ))
        return out
    }()

    // Left side — clearance holes enter at x = 0 (outside) and extend in +x.
    sidePanel
        .subtracting {
            for hole in holes {
                screw.clearanceHole(depth: t1 + 4)
                    .rotated(y: 90°)
                    .translated(x: -1, y: hole.y, z: hole.z)
            }
        }
        .measuringBounds { geom, box in
            cutReg.record(name: "Side panel", size: box.size, notes: "Polygon profile")
            return geom
        }
        .withMaterial(color: ral1003, metallicness: 0, roughness: 0.85)
        .inPart(leftPanelPart)

    // Right side — clearance holes enter at x = t1 (outside) and extend in -x.
    sidePanel
        .subtracting {
            for hole in holes {
                screw.clearanceHole(depth: t1 + 4)
                    .rotated(y: -90°)
                    .translated(x: t1 + 1, y: hole.y, z: hole.z)
            }
        }
        .measuringBounds { geom, box in
            cutReg.record(name: "Side panel", size: box.size, notes: "Polygon profile")
            return geom
        }
        .withMaterial(color: ral1003, metallicness: 0, roughness: 0.85)
        .translated(x: outerWidth - t1)
        .inPart(rightPanelPart)

    // Confirmat screw bodies — one per clearance hole on each side panel,
    // head flush with the panel's outer face, threads driven into the cabinet.
    for hole in holes {
        screw
            .rotated(y: 90°)
            .translated(x: 0, y: hole.y, z: hole.z)
            .inPart(confirmatsPart)
        screw
            .rotated(y: -90°)
            .translated(x: outerWidth, y: hole.y, z: hole.z)
            .inPart(confirmatsPart)
    }

    // Back plate (between sides). Sits on top of the bottom plate.
    BackPlate(width: innerWidth, thickness: t1, height: backHeight - t1)
        .measuringBounds { geom, box in
            cutReg.record(name: "Back plate", size: box.size)
            return geom
        }
        .withMaterial(color: ral240_80_15, metallicness: 0, roughness: 0.85)
        .translated(x: t1, y: innerDepth, z: t1)
        .inPart(backPlatePart)

    // Shelf 1 (the cabinet's bottom plate) — full outer depth so it tucks under the back plate.
    Shelf(width: innerWidth, depth: outerDepth, thickness: t1)
        .measuringBounds { geom, box in
            cutReg.record(name: "Shelf 1", size: box.size, notes: "Full outer depth, tucks under back plate")
            return geom
        }
        .withMaterial(color: ral3015, metallicness: 0, roughness: 0.85)
        .translated(x: t1)
        .inPart(shelf1Part)

    // Front kick plate — sits between the side-panel feet at z=[-skirtHeight, 0].
    // Hides the front casters and stiffens the front edge of the bottom plate.
    KickPlate(width: innerWidth, thickness: t1, height: skirtHeight)
        .measuringBounds { geom, box in
            cutReg.record(name: "Kick plate", size: box.size, notes: "Front and back; hides casters")
            return geom
        }
        .withMaterial(color: ral1003, metallicness: 0, roughness: 0.85)
        .translated(x: t1, z: -skirtHeight)
        .inPart(skirtPart)

    // Back kick plate — mirrors the front. Hides the back casters.
    KickPlate(width: innerWidth, thickness: t1, height: skirtHeight)
        .measuringBounds { geom, box in
            cutReg.record(name: "Kick plate", size: box.size, notes: "Front and back; hides casters")
            return geom
        }
        .withMaterial(color: ral1003, metallicness: 0, roughness: 0.85)
        .translated(x: t1, y: outerDepth - t1, z: -skirtHeight)
        .inPart(skirtPart)

    // Cross-brace centered in x, under the bottom plate.
    CrossBrace(thickness: t1, depth: outerDepth, height: skirtHeight)
        .measuringBounds { geom, box in
            cutReg.record(name: "Cross-brace", size: box.size, notes: "Under bottom plate, centered in x")
            return geom
        }
        .withMaterial(color: ral1003, metallicness: 0, roughness: 0.85)
        .translated(x: t1 + (innerWidth - t1) / 2, z: -skirtHeight)
        .inPart(skirtPart)

    // Shelf 2 — top surface at shelf2Z (tray level)
    Shelf(width: innerWidth, depth: innerDepth, thickness: t1)
        .measuringBounds { geom, box in
            cutReg.record(name: "Shelf 2", size: box.size)
            return geom
        }
        .withMaterial(color: ral3015, metallicness: 0, roughness: 0.85)
        .translated(x: t1, z: shelf2Z - t1)
        .inPart(shelf2Part)

    // Shelf 3 — sits just under shelf 4 with `shelf3TopGap` of headroom above.
    Shelf(width: innerWidth, depth: innerDepth, thickness: t1)
        .measuringBounds { geom, box in
            cutReg.record(name: "Shelf 3", size: box.size)
            return geom
        }
        .withMaterial(color: ral3015, metallicness: 0, roughness: 0.85)
        .translated(x: t1, z: shelf3Z - t1)
        .inPart(shelf3Part)

    // 2 hidden wood screws (25mm) driven up from below shelf 4 into the lip.
    // Countersunk head sits flush in the shelf's underside.
    let underScrew = WoodScrew(length: 25)
    let underScrewXs = [innerWidth / 4, 3 * innerWidth / 4] // local-shelf2 frame

    // Shelf 4 — top surface at shelf4Z (top, with front lip). Full depth.
    // Countersunk clearance holes for the underside screws.
    Shelf(width: innerWidth, depth: innerDepth, thickness: t1)
        .subtracting {
            for ux in underScrewXs {
                underScrew.clearanceHole(depth: t1 + 1)
                    .translated(x: ux, y: lipY, z: 0)
            }
        }
        .measuringBounds { geom, box in
            cutReg.record(name: "Shelf 4", size: box.size)
            return geom
        }
        .withMaterial(color: ral3015, metallicness: 0, roughness: 0.85)
        .translated(x: t1, z: shelf4Z - t1)
        .inPart(shelf4Part)

    // Top-shelf front lip — same cut as a kick plate, used as a tray edge.
    // Sits ON TOP of shelf 4, front edge flush with the side panels' front.
    KickPlate(width: innerWidth, thickness: t1, height: lipHeight)
        .measuringBounds { geom, box in
            cutReg.record(name: "Front lip", size: box.size, notes: "Same cut as kick plates.")
            return geom
        }
        .withMaterial(color: ral1003, metallicness: 0, roughness: 0.85)
        .translated(x: t1, z: shelf4Z)
        .inPart(skirtPart)

    // The 2 underside screws themselves — head's wide top flush with shelf 4's
    // underside; threads continue up through the shelf and into the lip.
    for ux in underScrewXs {
        underScrew
            .translated(x: t1 + ux, y: lipY, z: shelf4Z - t1)
            .inPart(woodScrewsPart)
    }

    // Casters: 4 × casterDiameter spheres beneath the bottom plate
    casters(width: outerWidth, depth: outerDepth, diameter: casterDiameter)
        .colored(.darkGray)
        .inPart(castersPart)

    // *************************
    // * Layout
    // *************************

    // front row: unas + pi-rack + ups: four equal gaps (left | unas | pi | ups | right).
    let unas = Unas()
    let pi = PiRack()
    let ups = Ups()

    let frontGap = (innerWidth - unas.width - pi.width - ups.width) / 4
    let unasX = t1 + frontGap
    let piX = unasX + unas.width + frontGap
    let upsX = piX + pi.width + frontGap

    unas.translated(x: unasX, y: frontInset, z: shelf1Z).inPart(gearPart)
    pi.translated(x: piX, y: frontInset, z: shelf1Z).inPart(gearPart)
    ups.withMaterial(color: Color(hex: "2A2A2A"), metallicness: 0, roughness: 0.3)
        .translated(x: upsX, y: frontInset, z: shelf1Z).inPart(gearPart)

    // Power cable: exits the right side of the UPS, runs back along the
    // shelf, then up and out through the grommet in the back plate.
    let cableX0 = upsX + ups.width
    let cableY0 = frontInset + 70
    let cableZ0 = shelf1Z + 20
    // Grommet center in world coords (uses BackPlate's default grommet
    // diameter 50 + clearance 25 in the lower-right corner).
    let grommetX = t1 + innerWidth - 25 - 25
    let grommetZ = t1 + 25 + 25
    let backPlateInnerY = innerDepth
    Circle(diameter: 6)
        .swept(along: BezierPath3D(from: [cableX0, cableY0, cableZ0]) {
            // 1. Drop down to the shelf, sliding slightly toward the grommet x.
            curve(
                controlX: cableX0 + 15, controlY: cableY0, controlZ: cableZ0 - 8,
                endX: grommetX, endY: cableY0, endZ: shelf1Z + 3
            )
            // 2. Run back along the shelf toward the back plate.
            curve(
                controlX: grommetX, controlY: cableY0 + 80, controlZ: shelf1Z + 3,
                endX: grommetX, endY: backPlateInnerY - 30, endZ: shelf1Z + 3
            )
            // 3. Rise up and through the grommet hole.
            curve(
                controlX: grommetX, controlY: backPlateInnerY - 10, controlZ: grommetZ - 5,
                endX: grommetX, endY: backPlateInnerY + t1 + 15, endZ: grommetZ
            )
        })
        .withMaterial(color: .black, metallicness: 0, roughness: 0.4)
        .inPart(gearPart)

    // ac-adapter:
    // rotated so the long (width) side is vertical (z). Then +90° around z
    // so the depth runs along x and the height along y. Placed against the backplate,
    // centered in the gap between unas and ups, and vertically centered between the
    // shelf 1 (top at z = t1) and the underside of shelf 2.
    let adapter = AcAdapter210w()

    let bayBottom = t1 // top of bottom plate
    let bayTop = shelf2Z - t1 // underside of shelf 2
    let adapterY = innerDepth - adapter.height // back face at backplate
    let adapterX = upsX + (ups.width - adapter.depth) / 2
    let adapterZ = bayBottom + (bayTop - bayBottom - adapter.width) / 2
    adapter
        .withMaterial(color: Color(hex: "F5F5F5"), metallicness: 0, roughness: 0.35)
        .rotated(y: 90°)
        .rotated(z: 90°)
        .aligned(at: .min)
        .translated(x: adapterX, y: adapterY, z: adapterZ)
        .inPart(gearPart)

    // C13 plug body inserted into the C14 inlet on the bottom of the adapter.
    // Pentagonal "house" shape matching the C14 cutout, slightly smaller for fit.
    let c13W   = 26.5  // ~0.5 mm smaller than the 27 mm cutout
    let c13H   = 20.5
    let c13Cx  = 2.5
    let c13Cy  = 3.0
    let c13Len = 30.0  // visible body length below the adapter
    // C14 hole center in world coords (computed from adapter post-rotation mapping).
    let c14X = adapterX + adapter.depth / 2   // adapter local y=depth/2 → world x
    let c14Y = adapterY + adapter.height / 2  // adapter local z=height/2 → world y
    let c14Z = adapterZ
    Polygon([
        Vector2D(x: c13Cx,         y: 0),
        Vector2D(x: c13W - c13Cx,  y: 0),
        Vector2D(x: c13W,          y: c13Cy),
        Vector2D(x: c13W,          y: c13H),
        Vector2D(x: 0,             y: c13H),
        Vector2D(x: 0,             y: c13Cy),
    ])
    .extruded(height: c13Len)
    .translated(
        x: c14X - c13W / 2,
        y: c14Y - c13H / 2,
        z: c14Z - c13Len + 2  // top 2 mm inside the recess, rest sticking down
    )
    .withMaterial(color: Color(hex: "F5F5F5"), metallicness: 0, roughness: 0.35)
    .inPart(gearPart)

    // Short power cable exiting the bottom of the C13 plug.
    let c13CableX0 = c14X
    let c13CableY0 = c14Y
    let c13CableZ0 = c14Z - c13Len + 2  // bottom of plug body
    Circle(diameter: 6)
        .swept(along: BezierPath3D(from: [c13CableX0, c13CableY0, c13CableZ0]) {
            // Drop straight down then curve forward
            curve(
                controlX: c13CableX0, controlY: c13CableY0, controlZ: c13CableZ0 - 10,
                endX: c13CableX0, endY: c13CableY0 - 15, endZ: shelf1Z + 3
            )
        })
        .withMaterial(color: Color(hex: "F5F5F5"), metallicness: 0, roughness: 0.4)
        .inPart(gearPart)

    // Simple NEMA 5-15P plug body sitting on top of one of the UPS outlets.
    // Outlet xC values are 66.5 / 106.5 / 146.5 / 186.5 in UPS local frame;
    // use the 2nd outlet.
    let plugW = 38.0
    let plugD = 35.0
    let plugH = 25.0
    let plugCX = upsX + 106.5
    let plugCY = frontInset + 75
    let plugZ  = shelf1Z + 140  // top of UPS
    Rectangle([plugW, plugD])
        .rounded(radius: 3)
        .extruded(height: plugH, topEdge: .fillet(radius: 3))
        .translated(
            x: plugCX - plugW / 2,
            y: plugCY - plugD / 2,
            z: plugZ
        )
        .withMaterial(color: Color(hex: "F5F5F5"), metallicness: 0, roughness: 0.3)
        .inPart(gearPart)

    // Little white cable exiting the top of the NEMA plug, draping back
    // and down toward the AC adapter area.
    let nemaCableStartZ = plugZ + plugH
    Circle(diameter: 5)
        .swept(along: BezierPath3D(from: [plugCX, plugCY, nemaCableStartZ]) {
            // Arc up and back over the rear of the UPS
            curve(
                controlX: plugCX, controlY: plugCY + 20, controlZ: nemaCableStartZ + 8,
                endX: plugCX, endY: plugCY + 35, endZ: nemaCableStartZ
            )
            // Drape down behind the UPS toward the AC adapter
            curve(
                controlX: plugCX, controlY: plugCY + 45, controlZ: 100,
                endX: plugCX, endY: plugCY + 60, endZ: 35
            )
        })
        .withMaterial(color: Color(hex: "F5F5F5"), metallicness: 0, roughness: 0.4)
        .inPart(gearPart)

    // Second NEMA plug — black — on the 3rd outlet, cable dropping toward the back plate.
    let plug2CX = upsX + 146.5
    let plug2CY = frontInset + 75
    Rectangle([plugW, plugD])
        .rounded(radius: 3)
        .extruded(height: plugH, topEdge: .fillet(radius: 3))
        .translated(
            x: plug2CX - plugW / 2,
            y: plug2CY - plugD / 2,
            z: plugZ
        )
        .withMaterial(color: Color(hex: "2A2A2A"), metallicness: 0, roughness: 0.3)
        .inPart(gearPart)

    let plug2CableStartZ = plugZ + plugH
    Circle(diameter: 5)
        .swept(along: BezierPath3D(from: [plug2CX, plug2CY, plug2CableStartZ]) {
            curve(
                controlX: plug2CX, controlY: plug2CY + 20, controlZ: plug2CableStartZ + 8,
                endX: plug2CX, endY: plug2CY + 35, endZ: plug2CableStartZ
            )
            curve(
                controlX: plug2CX, controlY: plug2CY + 45, controlZ: 100,
                endX: plug2CX, endY: plug2CY + 60, endZ: 35
            )
        })
        .withMaterial(color: Color(hex: "2A2A2A"), metallicness: 0, roughness: 0.4)
        .inPart(gearPart)

    // switch-flex:
    // mounted to the underside of shelf 2, centered on the ups in x.
    let sw = SwitchFlex()
    let switchX = upsX + (ups.width - sw.width) / 2
    let switchZ = (shelf2Z - t1) - sw.height
    sw.withMaterial(color: Color(hex: "F5F5F5"), metallicness: 0, roughness: 0.35)
        .translated(x: switchX, y: frontInset, z: switchZ).inPart(gearPart)

    // AC adapter DC cable: from the strain relief at the top of the AC,
    // down to the base shelf, then forward and right along the base, and
    // up into the right side of the SwitchFlex near the back.
    let acDcStartX = adapterX + adapter.depth / 2
    let acDcStartY = adapterY + adapter.height / 2
    let acDcStartZ = adapterZ + adapter.width + 18  // strain relief tip (3 boss + 15 cone)
    let acDcBaseZ  = shelf1Z + 3
    let acDcEndX   = switchX + sw.width - 2          // 2mm into right face
    let acDcEndY   = frontInset + sw.depth - 10      // toward the back of the right side
    let acDcEndZ   = switchZ + sw.height / 2

    Circle(diameter: 3)
        .swept(along: BezierPath3D(from: [acDcStartX, acDcStartY, acDcStartZ]) {
            // 1. Curve forward and right out of the strain relief, drop to base.
            curve(
                controlX: acDcStartX + 50, controlY: acDcStartY - 60, controlZ: acDcStartZ,
                endX: acDcStartX + 80, endY: acDcStartY - 80, endZ: acDcBaseZ
            )
            // 2. Along the base, forward and right to behind the switch's right side.
            curve(
                controlX: acDcEndX, controlY: acDcStartY - 80, controlZ: acDcBaseZ,
                endX: acDcEndX, endY: acDcEndY + 25, endZ: acDcBaseZ
            )
            // 3. Up the back-right corner and into the right side of the switch.
            curve(
                controlX: acDcEndX, controlY: acDcEndY + 25, controlZ: acDcEndZ,
                endX: acDcEndX, endY: acDcEndY, endZ: acDcEndZ
            )
        })
        .withMaterial(color: .white, metallicness: 0, roughness: 0.4)
        .inPart(gearPart)

    // White 3mm cable: saddle (back-bottom of Unas) → straight back to the
    // backplate → along the backplate to Pi rack center → up to just under
    // shelf 2 → across to the SwitchFlex → into its back face.
    // Built as straight runs joined by quadratic Beziers whose control point
    // sits at the sharp corner — that gives a rounded corner with matching
    // tangents on both sides (no kinks).
    let cornerR = 25.0
    let backplateY = innerDepth - 8.0          // 8mm clearance off backplate

    let cStartX = unasX + unas.width / 2
    let cStartZ = shelf1Z + 5             // mid-height of saddle
    let cPiX    = piX + pi.width / 2
    let cTopZ   = shelf2Z - t1 - 10            // 10mm below shelf 2
    let cEndX   = switchX + sw.width / 2
    let cEndY   = frontInset + sw.depth        // back face of SwitchFlex
    let cEndZ   = switchZ + sw.height / 2

    Circle(diameter: 3)
        .swept(along: BezierPath3D(from: [cStartX, frontInset + unas.depth, cStartZ]) {
            // Straight back toward the backplate, stop one corner-radius short.
            line(y: backplateY - cornerR)
            // Round corner: +Y → +X
            curve(
                controlX: cStartX, controlY: backplateY, controlZ: cStartZ,
                endX: cStartX + cornerR, endY: backplateY, endZ: cStartZ
            )
            // Along the backplate to one corner-radius before the Pi center x.
            line(x: cPiX - cornerR)
            // Round corner: +X → +Z (turn upward)
            curve(
                controlX: cPiX, controlY: backplateY, controlZ: cStartZ,
                endX: cPiX, endY: backplateY, endZ: cStartZ + cornerR
            )
            // Straight up to one corner-radius below the under-shelf height.
            line(z: cTopZ - cornerR)
            // Round corner: +Z → +X (turn toward the flex)
            curve(
                controlX: cPiX, controlY: backplateY, controlZ: cTopZ,
                endX: cPiX + cornerR, endY: backplateY, endZ: cTopZ
            )
            // Across to one corner-radius before the flex center x.
            line(x: cEndX - cornerR)
            // Final corner sweeping down/forward into the back of the SwitchFlex.
            curve(
                controlX: cEndX, controlY: backplateY, controlZ: cTopZ,
                endX: cEndX, endY: cEndY, endZ: cEndZ
            )
        })
        .withSegmentation(count: 32)
        .withMaterial(color: .white, metallicness: 0, roughness: 0.4)
        .inPart(gearPart)

    // White 3mm cables — one per Pi: out the back, into the backplate, up to
    // 10mm under shelf 2, across to the flex, into its back face. Same
    // routing pattern as the Unas cable, just starting at each Pi's back.
    // Use a non-axis-aligned target direction for the swept frame to avoid a
    // Cadova frame-angle singularity when the path tangent is parallel to the
    // default `.negativeZ` target (the +Z climb section).
    let cableTarget: ReferenceTarget = .direction(Direction3D(Vector3D(1, -1, -1)))
    // Fan the 3 Pi cables out in x so they don't visually merge: each cable
    // exits its Pi back, climbs the backplate, and plugs into the flex back
    // at its own offset.
    let piCableOffsets = [-7.0, 0.0, 7.0]
    for (i, piCenterZ) in pi.piCenterZs.map({ shelf1Z + $0 }).enumerated() {
        let xOff = piCableOffsets[i]
        let pX = cPiX + xOff
        let eX = cEndX + xOff
        Circle(diameter: 3)
            .swept(
                along: BezierPath3D(from: [pX, frontInset + pi.piBackY, piCenterZ]) {
                    // Straight back to the backplate (minus cornerR).
                    line(y: backplateY - cornerR)
                    // Round corner: +Y → +Z (turn upward against the backplate).
                    curve(
                        controlX: pX, controlY: backplateY, controlZ: piCenterZ,
                        endX: pX, endY: backplateY, endZ: piCenterZ + cornerR
                    )
                    // Climb to one corner-radius below the under-shelf height.
                    line(z: cTopZ - cornerR)
                    // Round corner: +Z → +X (turn toward the flex).
                    curve(
                        controlX: pX, controlY: backplateY, controlZ: cTopZ,
                        endX: pX + cornerR, endY: backplateY, endZ: cTopZ
                    )
                    // Across to one corner-radius before this cable's flex x.
                    line(x: eX - cornerR)
                    // Sweep down/forward into the back of the SwitchFlex.
                    curve(
                        controlX: eX, controlY: backplateY, controlZ: cTopZ,
                        endX: eX, endY: cEndY, endZ: cEndZ
                    )
                },
                toward: cableTarget
            )
            .withSegmentation(count: 32)
            .withMaterial(color: .white, metallicness: 0, roughness: 0.4)
            .inPart(gearPart)
    }

    // tray on shelf 2, centered in both x and y.
    let tray = Tray()
    let trayShiftRight = 80.0
    let trayX = t1 + (innerWidth - tray.width) / 2 + trayShiftRight
    let trayY = (innerDepth - tray.depth) / 2
    tray.colored(Color(hex: "C9A982")) // bamboo
        .translated(x: trayX, y: trayY, z: shelf2Z).inPart(gearPart)

    // One Confirmat screw laid inside the tray for visual inspection (demo only).
    // Lying along x, head end at low x, resting on the tray's inner floor.
    screw
        .rotated(y: 90°)
        .translated(
            x: trayX + 40, // 40mm in from the tray's left wall
            y: trayY + tray.depth / 2, // centered front-to-back
            z: shelf2Z + tray.wall + screw.headDiameter / 2
        )
        .inPart(gearPart)

    // *************************
    // * STANDING DESK (visual reference, not part of the cutlist)
    // *************************
    // Rotated 90° around z so the long side runs along y, then placed behind
    // the caddy (positive y), x-aligned with the caddy footprint, sitting on
    // the same floor as the casters (z = -casterDiameter at the bottom of the feet).
    let standingDesk = StandingDesk()
    let standingDeskGap = 50.0
    let deskTx = (outerWidth - standingDesk.topDepth) / 2
    let deskTy = outerDepth + standingDeskGap
    let deskTz = -casterDiameter
    let deskTopZ = deskTz + standingDesk.deskHeight  // world z of top surface of desktop
    standingDesk
        .rotated(z: 90°)
        .aligned(at: .min)
        .translated(x: deskTx, y: deskTy, z: deskTz)
        .inPart(standingDeskPart)

    // *************************
    // * MONITOR on the standing desk
    // *************************
    // Centered on the desktop. Rotated 180° around z so the screen faces +y
    // (away from the caddy), i.e. toward a viewer standing at the far end.
    let monitor = Monitor()
    // Back of the monitor against the high-x long edge of the desk
    // (small inset from the edge). Y-centered on the desk's long axis.
    // After 270° rotation the screen normal points -x.
    let monitorRotated = monitor.rotated(z: 270°).aligned(at: .min)
    let monitorEdgeInset = 30.0
    monitorRotated
        .measuringBounds { geom, box in
            let deskXMax = deskTx + standingDesk.topDepth
            let mx = deskXMax - monitorEdgeInset - box.size.x
            let my = deskTy + (standingDesk.topWidth - box.size.y) / 2
            return geom.translated(x: mx, y: my, z: deskTopZ)
        }
        .inPart(monitorPart)

    // *************************
    // * LAPTOP STAND on shelf 4 (left). Holds MBP 16, MBN, iPad hinge-down.
    // *************************
    let stand = LaptopStand()
    let standX = t1 + innerWidth - stand.width - wiggleRoom
    let standY = (innerDepth - stand.depth) / 2
    let standZ = shelf4Z

    stand
        .translated(x: standX, y: standY, z: standZ)
        .inPart(laptopStandPart)

    // Devices placed vertically: rotate +90° around x so the depth axis points
    // up and the thickness axis sits across the slot. Aligned(.min) so the
    // device sits with hinge at z = 0 of its local frame.
    let macbook = MacBookPro16()
    let macbookNeo = MacBookNeo()
    let ipad = Ipad()
    let boxCount = 5

    macbook
        .rotated(x: 90°)
        .aligned(at: .min)
        .translated(
            x: standX + (stand.width - macbook.width) / 2,
            y: standY + stand.mbpSlotY - macbook.thickness / 2,
            z: standZ + stand.slotBottomZ
        )
        .inPart(macbookPart)

    macbookNeo
        .rotated(x: 90°)
        .aligned(at: .min)
        .translated(
            x: standX + (stand.width - macbookNeo.width) / 2,
            y: standY + stand.mbnSlotY - macbookNeo.thickness / 2,
            z: standZ + stand.slotBottomZ
        )
        .inPart(macbookNeoPart)

    ipad
        .rotated(x: 90°)
        .aligned(at: .min)
        .translated(
            x: standX + (stand.width - ipad.width) / 2,
            y: standY + stand.ipadSlotY - ipad.thickness / 2,
            z: standZ + stand.slotBottomZ
        )
        .inPart(ipadPart)

    // Wooden boxes on shelf 3 — a row spaced evenly across innerWidth,
    // rotated 90° around z. Centered in y.
    let box1 = WoodenBox() // box from cemaco
    let box1Y = (t1 + innerDepth - box1.width) / 2
    let boxGap = (innerWidth - Double(boxCount) * box1.depth) / Double(boxCount + 1)
    for i in 0 ..< boxCount {
        let x = t1 + boxGap + Double(i) * (box1.depth + boxGap)
        box1
            .colored(Color(hex: "E8D5B0")) // light wood (birch/maple)
            .rotated(z: 90°)
            .aligned(at: .min)
            .translated(x: x, y: box1Y, z: shelf3Z)
            .inPart(gearPart)
    }

    // One additional wooden box on shelf 2, left of the tray.
    box1
        .colored(Color(hex: "E8D5B0"))
        .rotated(z: 90°)
        .aligned(at: .min)
        .translated(x: t1 + wiggleRoom, y: box1Y, z: shelf2Z)
        .inPart(gearPart)

    // Headphones on shelf 4, parked on the left side. Z 90° orients them,
    // Y 115° tilts them toward the laptop stand.
    let headphones = Headphones()
    headphones
        .rotated(z: 90°)
        .rotated(y: 145°)
        .aligned(at: .min)
        .translated(
            x: t1 + wiggleRoom,
            y: (t1 + innerDepth - headphones.width) / 2,
            z: shelf4Z
        )
        .inPart(gearPart)
}

// 2D nesting layout for the plywood sheet, written as SVG alongside caddy.3mf.
await Model("Nesting", options: .format2D(.svg)) {
    nestingLayout(dims: CaddyDimensions())
}

} // end Project

// Cadova emits Nesting.svg as one merged <path>; split it so each piece
// becomes an independently selectable SVG element.
try splitSVGPaths(at: "Nesting.svg")

// Frame cutlist, derived from the bounding boxes measured during the build.
try writeCutlist(cutReg.all)
