import Cadova
import Woodwork

let dims = CouchDimensions()

// Placeholder massing only — see Docs/Couch/README.md. The dimensions are
// conventional three-seater proportions, not measurements.
print(
    String(
        format: "Couch envelope: %.0f × %.0f × %.0f mm, seat %.0f mm high",
        dims.overallWidth,
        dims.overallDepth,
        dims.overallHeight,
        dims.seatHeight
    )
)

await Project(root: "Build/Couch") {

    await Model("couch") {
        Envelope(dims: dims)
            .finished(CouchFinishes.pine)
    }

} // end Project
