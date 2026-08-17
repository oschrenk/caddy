import Cadova
import Woodwork

let dims = PilaDimensions()

// The pila sits in the +x / -y quadrant, in the corner where the two building
// walls meet at the origin, standing off each wall by a small gap. The corner
// nearest that origin is the lid's high corner, so runoff runs toward +x and
// -y — away from both walls, toward whoever is standing at the pila.

// Self-check: the lid has to slide under the spout. Printed every build so a
// change to the falls or the slat thickness cannot silently reintroduce a clash.
print(
    String(
        format: "Spout headroom: deck top %.1f mm, spout underside %.1f mm → %.1f mm clear%@",
        dims.deckTopUnderSpout,
        dims.spoutHeightAboveBlock,
        dims.spoutHeadroom,
        dims.needsSpoutNotch ? "  ** COLLIDES — lid will be notched **" : ""
    )
)

await Project(root: "Build/Pila") {

    // The whole scene, as separate parts so each can be hidden in the viewer.
    await Model("pila") {
        let concrete = Part("Pila (concrete)")
        let lid = Part("Tapadera (wood)")
        let wallLower = Part("Wall — concrete")
        let wallUpper = Part("Wall — stained wood")
        let plumbing = Part("Waterspout")

        Basin(dims: dims)
            .translated(x: dims.pilaOffsetX, y: dims.pilaOffsetY)
            .finished(PilaFinishes.stone)
            .inPart(concrete)

        // The lid covers the whole block, so it shares the block's footprint.
        Tapadera(dims: dims)
            .translated(x: dims.pilaOffsetX, y: dims.pilaOffsetY, z: dims.blockHeight)
            .finished(PilaFinishes.pine)
            .inPart(lid)

        Walls(dims: dims, band: .lower)
            .finished(PilaFinishes.concrete)
            .inPart(wallLower)

        Walls(dims: dims, band: .upper)
            .finished(PilaFinishes.stainedWood)
            .inPart(wallUpper)

        Spout(dims: dims)
            .finished(PilaFinishes.chrome)
            .inPart(plumbing)
    }

    // The lid on its own, for working on the woodwork.
    await Model("tapadera") {
        Tapadera(dims: dims)
            .finished(PilaFinishes.pine)
    }

    await Model("tapadera", options: .format3D(.stl)) {
        Tapadera(dims: dims)
    }

} // end Project
