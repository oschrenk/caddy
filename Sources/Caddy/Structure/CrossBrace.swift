import Cadova

// Vertical brace under the bottom plate, oriented along the depth (y) axis
// and centered in x. Halves the bottom plate's x-span and reduces center
// deflection under load by roughly 8×.
struct CrossBrace: Shape3D {
    let thickness: Double
    let depth: Double
    let height: Double

    var body: any Geometry3D {
        Box([thickness, depth, height])
    }
}
