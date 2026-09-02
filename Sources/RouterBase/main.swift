import Cadova
import Woodwork

// The plate prints face down, so it is modelled with its bottom face on z = 0
// and needs no reorientation before slicing.

await Project(root: "Build/RouterBase") {

    await Model("router-square-base") {
        RouterSquareBase()
    }

    await Model("router-square-base", options: .format3D(.stl)) {
        RouterSquareBase()
    }

} // end Project
