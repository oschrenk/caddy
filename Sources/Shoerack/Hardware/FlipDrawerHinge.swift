import Cadova

/// One steel side plate of the tip-out fitting, recreated from the vendor's
/// STEP file (`shoe_rack_flip_drawer_hinge.STEP`). A hinge takes two of these,
/// mirrored, one per side of the front.
///
/// The plate is a 4 mm laser-cut blank with four lightening webs, a pressed rim
/// standing up from every edge to stiffen it, and three formed brackets along
/// the bottom that bolt to the cabinet side. Its whole geometry hangs off the
/// main pivot: the curved back is an arc concentric with that pivot, and the
/// webs are cut back to a smaller concentric radius, leaving a constant-width
/// arc rail between them.
///
/// Local frame: **the main pivot sits at the origin** in x/y and the plate's
/// underside at z = 0, so the plate lies flat and the front swings about the
/// z axis. In the cabinet the plate stands vertically against a side panel, so
/// rotate it onto its edge before placing. Overall 296.1 × 198.5 × 24.8 mm.
///
/// Faithful: the outline, the four webs, every hole position and diameter, the
/// two pivot centres, the rail radii, and the plate thickness. The flat profile
/// is within 0.4 % of the STEP's section by area, and the bounding box matches
/// the STEP mesh exactly on all three axes.
///
/// Approximated: the pressed rim is a constant-width lip on every edge rather
/// than the real varying flange, and the brackets are solid tapered upstands
/// rather than folded sheet. Together those put the model 10 % over the STEP's
/// 118.6 cm³ — a look-and-clearance difference, not a fit one.
struct FlipDrawerHinge: Geometry3D {
    // Sheet
    let plateThickness = 4.0
    let rimHeight = 9.5 // top of the pressed rim, above the plate underside
    let rimWidth = 2.2

    // The two pivots
    let pivotBore = 15.0 // main pivot, at the origin
    let hubRadius = 28.0 // boss around it
    let upperPivot: Vector2D = [-50.57, 152.98]
    let upperBossRadius = 19.88

    /// The arc rail. Both radii are measured from the main pivot: the plate's
    /// back edge, and the line the webs are cut back to.
    let railOuterRadius = 170.0
    let railInnerRadius = 149.5

    // Corner fillets — 1.5 all round the outline, 10 in the webs.
    let outlineFillet = 1.5
    let webFillet = 10.0

    // Outline datums
    let tip: Vector2D = [115.95, 59.35] // the far corner, where both diagonals meet
    let mountEdgeY = -25.65 // the straight edge that faces the cabinet side
    let bottomRight: Vector2D = [78.95, -25.65]

    /// Where the long top edge runs tangent into the upper pivot boss.
    let topTangent: Vector2D = [-39.07, 169.20]

    /// The flat cut across the top of the boss, at the apex of the arc.
    let notchBase: Vector2D = [-53.54, 161.35]
    let notchTip: Vector2D = [-56.52, 170.32]

    /// The three formed brackets, and the bolt holes through the plate under
    /// them. The originals measure 6.29 / 6.94 / 6.50 Ø — nominally M6.
    let bracketX = [-165.66, -133.66, 26.34]
    let boltHoleY = -20.15
    let boltHoleDiameter = 6.5
    let bracketBase: Vector2D = [19.53, 9.44]
    let bracketTop: Vector2D = [12.74, 6.96]
    let bracketTopZ = 24.5

    // Envelope, measured off the STEP mesh. `frontReach` is pivot → tip end,
    // `backReach` is pivot → ear end; together they give the 296.07 mm length.
    // Whoever places the plate needs these to find the front edge.
    let frontReach = 115.59
    let backReach = 180.48

    /// Overall length of the plate, front edge to back edge.
    var overallLength: Double { frontReach + backReach }

    /// Overall height, mounting edge to apex.
    var overallHeight: Double { 172.86 - mountEdgeY }

    /// How far the plate stands off the panel it is screwed to — the brackets
    /// are the deepest thing on it.
    var standoff: Double { bracketTopZ }

    /// Countersunk rivet holes through the plate.
    let rivetHoleDiameter = 4.9
    let rivetHoles: [Vector2D] = [
        [89.20, 16.55],
        [-124.27, 61.81], [-121.56, 74.88], [-117.92, 87.73],
        [-30.49, 153.99],
    ]

    var body: any Geometry3D {
        Union {
            // The plate itself, plus the rim standing up from every one of its
            // edges — outer boundary and web openings alike.
            Union {
                webbedPlate.extruded(height: plateThickness)
                rim.extruded(height: rimHeight - plateThickness)
                    .translated(z: plateThickness)
            }
            .subtracting { holes }

            for x in bracketX {
                bracket.translated(x: x, y: mountEdgeY, z: rimHeight)
            }
        }
        .colored(Color(red: 0.28, green: 0.29, blue: 0.31)) // black-coated steel
    }

    // MARK: - Profile

    /// The plate with its four webs cut out, but before the holes are drilled.
    /// The rim is derived from this, so the holes must not be in it yet.
    private var webbedPlate: any Geometry2D {
        outline.subtracting {
            upperWeb
            lowerWeb
            rightWeb
            lowerRightWeb
        }
    }

    /// A straight-sided wedge whose back is trimmed away by the rail arc, plus
    /// the boss around the upper pivot and the ear at the bottom-left corner.
    private var outline: any Geometry2D {
        Union {
            Intersection {
                Polygon(wedgeCorners)
                Circle(radius: railOuterRadius)
            }
            Circle(radius: upperBossRadius).translated(upperPivot)
            // The bottom-left ear, which reaches past the arc.
            Polygon([[-169.51, -12.82], [-180.48, -13.65],
                     [-180.48, mountEdgeY], [-150.0, mountEdgeY]])
        }
        .subtracting { Polygon(apexNotch) }
        .rounded(outsideRadius: outlineFillet)
    }

    /// Only the tip, the two diagonals and the bottom edge are real geometry.
    /// The left side runs well outside `railOuterRadius` and the arc cuts it.
    private var wedgeCorners: [Vector2D] {
        let beyondBoss = tip + (topTangent - tip) * 1.3
        return [tip, beyondBoss, [-260, beyondBoss.y], [-260, mountEdgeY], bottomRight]
    }

    /// The apex flat, as a slab lying on the far side of that edge. It reaches
    /// only as deep as the boss, so it bites nothing else.
    private var apexNotch: [Vector2D] {
        let along = (notchTip - notchBase).normalized
        let outward = Vector2D(x: -along.y, y: along.x) * 35.0 // left of base→tip, away from the plate
        return [notchBase, notchTip, notchTip + outward, notchBase + outward]
    }

    // MARK: - Webs
    //
    // Each web is drawn from its real straight edges. Corners that fall on the
    // rail or the hub are left long and trimmed by those circles; the fillets
    // go on last so every corner picks one up, arc junctions included.

    private var upperWeb: any Geometry2D {
        Intersection {
            Polygon([[-15.02, 64.55], [-90.45, 287.33], [-330, 330], [-310.61, 170.10]])
            Circle(radius: railInnerRadius)
        }
        .rounded(outsideRadius: webFillet)
    }

    private var lowerWeb: any Geometry2D {
        Intersection {
            Polygon([[-262.57, 68.03], [0, 31.75], [0, -5.15], [-261.48, -5.15]])
            Circle(radius: railInnerRadius)
        }
        .subtracting { Circle(radius: hubRadius) }
        .rounded(outsideRadius: webFillet)
    }

    private var rightWeb: any Geometry2D {
        Polygon([[87.59, 54.32], [10.08, 54.32], [-14.38, 126.58]])
            .rounded(outsideRadius: webFillet)
    }

    private var lowerRightWeb: any Geometry2D {
        Polygon([[65.52, -5.15], [82.48, 33.82], [0, 33.82], [0, -5.15]])
            .subtracting { Circle(radius: hubRadius) }
            .rounded(outsideRadius: webFillet)
    }

    // MARK: - Rim, holes, brackets

    /// A constant-width lip along every edge of the webbed plate: the profile
    /// less the same profile eaten in by `rimWidth`.
    private var rim: any Geometry2D {
        webbedPlate.subtracting {
            webbedPlate.offset(amount: -rimWidth, style: .round)
        }
    }

    @GeometryBuilder3D
    private var holes: any Geometry3D {
        let depth = rimHeight + 2.0

        Cylinder(diameter: pivotBore, height: depth).translated(z: -1)

        for hole in rivetHoles {
            Cylinder(diameter: rivetHoleDiameter, height: depth)
                .translated(hole, z: -1)
        }

        for x in bracketX {
            Cylinder(diameter: boltHoleDiameter, height: depth)
                .translated(x: x, y: boltHoleY, z: -1)
        }
    }

    /// One formed bracket: a tapered upstand rising off the mounting edge,
    /// with its back face flush with that edge.
    private var bracket: any Geometry3D {
        Rectangle(bracketBase)
            .translated(x: -bracketBase.x / 2)
            .extruded(height: bracketTopZ - rimHeight,
                      topScale: bracketTop / bracketBase)
    }
}
