import Cadova

// A single caster: a sphere with its top at z = 0, centered at the origin in x/y.
func caster(diameter: Double = 25) -> any Geometry3D {
    Sphere(diameter: diameter).translated(z: -diameter / 2)
}

// Four casters, one at each corner of a width × depth footprint, inset from the edges.
func casters(width: Double, depth: Double, inset: Double = 50, diameter: Double = 25) -> any Geometry3D {
    Union {
        caster(diameter: diameter).translated(x: inset, y: inset)
        caster(diameter: diameter).translated(x: width - inset, y: inset)
        caster(diameter: diameter).translated(x: inset, y: depth - inset)
        caster(diameter: diameter).translated(x: width - inset, y: depth - inset)
    }
}
