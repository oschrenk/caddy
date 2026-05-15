import Cadova

// A kick plate spanning between the side-panel feet. Used at both the front
// (hides front casters, stiffens the bottom plate's front edge) and the back
// (mirrors the front, hides back casters). Same cut as the front lip.
struct KickPlate: Shape3D {
    let width: Double
    let thickness: Double
    let height: Double

    var body: any Geometry3D {
        Box([width, thickness, height])
    }
}
