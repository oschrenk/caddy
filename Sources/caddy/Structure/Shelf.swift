import Cadova

/// A horizontal shelf
/// Optionally shortened at the front by `frontTrim` to make room for a lip.
struct Shelf: Shape3D {
    let width: Double
    let depth: Double
    let thickness: Double
    let frontTrim: Double

    init(width: Double, depth: Double, thickness: Double, frontTrim: Double = 0) {
        self.width = width
        self.depth = depth
        self.thickness = thickness
        self.frontTrim = frontTrim
    }

    var body: any Geometry3D {
        Box([width, depth - frontTrim, thickness])
            .translated(y: frontTrim)
    }
}
