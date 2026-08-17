import Cadova
import Woodwork

await Project(root: "Build/Shoerack") {

    // The tip-out fronts, the woven-rattan panels, and the pivot bores wait on
    // the hinges arriving — the listed frame sizes are ambiguous (two numbers
    // per axis) and need measuring in hand.
    await Model("shoerack") {
        Carcass(dims: ShoerackDimensions())
    }

    // Merged single mesh, for scale mock-ups and for viewers without 3MF.
    await Model("shoerack", options: .format3D(.stl)) {
        Carcass(dims: ShoerackDimensions())
    }

} // end Project
