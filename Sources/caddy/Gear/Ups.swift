import Cadova

// A symmetric trapezoidal prism: top is `topInset`mm smaller than the bottom in
// both x and y, with all corners (vertical and horizontal) rounded by `cornerRadius`.
// Built as the convex hull of 8 corner spheres.
struct Ups: Shape3D {
    let width = 253.0
    let depth = 105.0
    let height = 140.0
    let topInset = 20.0
    let cornerRadius = 10.0

    var body: any Geometry3D {
        let r = cornerRadius
        let m = topInset / 2

        Union {
            // Bottom 4 corner spheres (inset by r from bottom rectangle's edges).
            Sphere(radius: r).translated(x: r,         y: r,         z: r)
            Sphere(radius: r).translated(x: width - r, y: r,         z: r)
            Sphere(radius: r).translated(x: r,         y: depth - r, z: r)
            Sphere(radius: r).translated(x: width - r, y: depth - r, z: r)

            // Top 4 corner spheres (inset by m + r so the top is topInset smaller).
            Sphere(radius: r).translated(x: m + r,         y: m + r,         z: height - r)
            Sphere(radius: r).translated(x: width - m - r, y: m + r,         z: height - r)
            Sphere(radius: r).translated(x: m + r,         y: depth - m - r, z: height - r)
            Sphere(radius: r).translated(x: width - m - r, y: depth - m - r, z: height - r)
        }
        .convexHull()
        .subtracting {
            // 4× NEMA 5-15R outlets cut into the top face.
            // Per outlet: 2 slots (hot 1.5×6.3, neutral 1.5×7.9, 12.7mm apart)
            // and a 5mm ground hole 12.7mm below the slot midpoint.
            let outletXs = [66.5, 106.5, 146.5, 186.5]
            let yC = 75.0   // outlet slots toward the back of the UPS top
            let cutH = 8.0  // cutter height (overshoots the top surface for clean CSG)
            let zBase = height - 3  // recess depth into the top surface

            for xC in outletXs {
                // Neutral slot (left, longer)
                Box([1.5, 7.9, cutH])
                    .translated(x: xC - 6.35 - 0.75, y: yC - 3.95, z: zBase)
                // Hot slot (right, shorter)
                Box([1.5, 6.3, cutH])
                    .translated(x: xC + 6.35 - 0.75, y: yC - 3.15, z: zBase)
                // Ground hole (round, 12.7mm in front of slot midpoint)
                Cylinder(diameter: 5, height: cutH)
                    .translated(x: xC, y: yC - 12.7, z: zBase)
            }
        }
    }
}
