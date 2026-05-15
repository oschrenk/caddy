import Cadova

struct SwitchFlex: Shape3D {
    let width = 212.9
    let depth = 99.4
    let height = 33.5

    var body: any Geometry3D {
        Rectangle([width, depth])
            .rounded(radius: 6)
            .extruded(
                height: height,
                topEdge: .fillet(depth: 18, height: 6),
                bottomEdge: .fillet(depth: 18, height: 6)
            )
    }
}
