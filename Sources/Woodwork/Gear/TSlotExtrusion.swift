import Cadova

/// Aluminium T-slot profile (defaults: item Profile 5, 20x20, natural anodised).
///
/// Cross-section: a square with rounded corners, a T-slot centred on each of the
/// four faces, and a central self-tapping core bore. Fully parametric — feed it
/// another profile's datasheet numbers and it rebuilds the section.
///
/// The four slot dimensions map to the item datasheet letters:
/// - `a` = slot opening (mouth width)            — 5.0
/// - `b` = widest internal point of the slot      — 11.5
/// - `c` = slot depth (face to chamber floor)     — 6.35
/// - `d` = lip thickness (face to undercut ledge) — 1.8
///
/// Everything else in the slot (the chamber walls, the floor half-width, the
/// tangent points) is *derived* from a–d, the fillet radii, and the chamber wall
/// angle — so changing the datasheet numbers reshapes the slot correctly.
///
/// Local frame: the cross-section is centred on the origin in (x, y); the bar is
/// extruded along +z by `length`.
public struct TSlotExtrusion: Shape3D {
    public var length: Double

    public let width: Double          // across flats
    public let cornerRadius: Double   // outer corner fillet (R2)
    public let boreDiameter: Double   // central self-tapping core bore

    public let slotOpening: Double    // a — mouth width ("5" in Profile 5)
    public let slotWidest: Double     // b — widest internal point
    public let slotDepth: Double      // c — face to chamber floor
    public let lipThickness: Double   // d — face to undercut ledge

    public let lipRadius: Double           // mouth-edge lip fillet
    public let mouthRadius: Double         // mouth-to-ledge fillet
    public let chamberCornerRadius: Double // outer chamber corner fillet
    public let chamberFloorRadius: Double  // chamber floor fillet
    public let chamberWallAngle: Angle     // chamber side wall, measured from horizontal

    public init(
        length: Double = 200,
        width: Double = 20,
        a slotOpening: Double = 5.0,
        b slotWidest: Double = 11.5,
        c slotDepth: Double = 6.35,
        d lipThickness: Double = 1.8,
        boreDiameter: Double = 4.3,
        cornerRadius: Double = 2.0,
        lipRadius: Double = 0.8,
        mouthRadius: Double = 0.3,
        chamberCornerRadius: Double = 0.8324,
        chamberFloorRadius: Double = 3.0,
        chamberWallAngle: Angle = 45°
    ) {
        self.length = length
        self.width = width
        self.slotOpening = slotOpening
        self.slotWidest = slotWidest
        self.slotDepth = slotDepth
        self.lipThickness = lipThickness
        self.boreDiameter = boreDiameter
        self.cornerRadius = cornerRadius
        self.lipRadius = lipRadius
        self.mouthRadius = mouthRadius
        self.chamberCornerRadius = chamberCornerRadius
        self.chamberFloorRadius = chamberFloorRadius
        self.chamberWallAngle = chamberWallAngle
    }

    /// One T-slot's negative space, centred on the +y face and opening upward.
    /// The mouth is capped just above the face (in open air) so it subtracts
    /// cleanly. The four real slots come from rotating this in 90° steps.
    private var slotVoid: any Geometry2D {
        let faceY = width / 2
        let mouthHalf = slotOpening / 2     // a/2
        let widestHalf = slotWidest / 2     // b/2
        let floorY = faceY - slotDepth      // c
        let ledgeY = faceY - lipThickness   // d

        let rLip = lipRadius, rMouth = mouthRadius
        let rCorner = chamberCornerRadius, rFloor = chamberFloorRadius
        let phi = chamberWallAngle

        // Chamber outer corner arc, then the straight side wall at `phi`, then
        // the floor fillet. The floor half-width is solved so the wall is the
        // common tangent of both fillets.
        let oc = Vector2D(x: widestHalf - rCorner, y: ledgeY - rCorner) // corner arc centre
        let f = oc + Vector2D(x: rCorner * sin(phi), y: -rCorner * cos(phi)) // wall start
        let m = tan(phi)
        let k0 = f.y - m * f.x
        let floorHalf = ((floorY + rFloor) - k0 - rFloor * (m * m + 1).squareRoot()) / m
        let of = Vector2D(x: floorHalf, y: floorY + rFloor) // floor fillet centre
        let g = of + Vector2D(x: m, y: -1) * (rFloor / (m * m + 1).squareRoot()) // wall end

        // Right-half boundary points (face → floor centre).
        let lipC = Vector2D(x: mouthHalf + rLip, y: faceY - rLip)
        let b0 = Vector2D(x: mouthHalf, y: faceY - rLip)
        let c0 = Vector2D(x: mouthHalf, y: ledgeY + rMouth)
        let mouthC = Vector2D(x: mouthHalf + rMouth, y: ledgeY + rMouth)
        let d0 = Vector2D(x: mouthHalf + rMouth, y: ledgeY)
        let e0 = Vector2D(x: oc.x, y: ledgeY)
        let hR = Vector2D(x: floorHalf, y: floorY)
        let start = Vector2D(x: mouthHalf + rLip, y: faceY)

        let capY = faceY + 2
        func mx(_ v: Vector2D) -> Vector2D { Vector2D(x: -v.x, y: v.y) } // mirror across x=0

        return Polygon(BezierPath2D(from: start) {
            counterclockwiseArc(center: lipC, angle: atan2(b0 - lipC))         // lip
            line(x: c0.x, y: c0.y)                                            // mouth wall
            counterclockwiseArc(center: mouthC, angle: atan2(d0 - mouthC))     // mouth fillet
            line(x: e0.x, y: e0.y)                                            // undercut ledge
            clockwiseArc(center: oc, angle: atan2(f - oc))                     // chamber corner
            line(x: g.x, y: g.y)                                              // chamber wall
            clockwiseArc(center: of, angle: atan2(hR - of))                    // floor fillet
            line(x: -hR.x, y: hR.y)                                           // floor across centre
            clockwiseArc(center: mx(of), angle: atan2(mx(g) - mx(of)))         // (mirror)
            line(x: mx(f).x, y: mx(f).y)
            clockwiseArc(center: mx(oc), angle: atan2(mx(e0) - mx(oc)))
            line(x: mx(d0).x, y: mx(d0).y)
            counterclockwiseArc(center: mx(mouthC), angle: atan2(mx(c0) - mx(mouthC)))
            line(x: mx(b0).x, y: mx(b0).y)
            counterclockwiseArc(center: mx(lipC), angle: atan2(mx(start) - mx(lipC)))
            line(x: -start.x, y: capY)                                        // cap up into air
            line(x: start.x, y: capY)                                         // cap across the mouth
        })
    }

    /// 2D cross-section, centred on the origin. Extruded along z for the bar.
    public var section: any Geometry2D {
        Rectangle([width, width])
            .rounded(radius: cornerRadius)
            .translated(x: -width / 2, y: -width / 2)
            .subtracting {
                slotVoid
                slotVoid.rotated(90°)
                slotVoid.rotated(180°)
                slotVoid.rotated(270°)
                Circle(diameter: boreDiameter)
            }
    }

    public var body: any Geometry3D {
        section
            .extruded(height: length)
            .colored(Color(hex: "C8CDD1")) // natural anodised aluminium
    }
}
