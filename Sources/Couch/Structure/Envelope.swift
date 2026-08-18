import Cadova

/// The overall volume the couch may occupy — arms, seat block and back, as
/// three plain boxes.
///
/// This is a massing study, not the thing to build. It exists so the target
/// renders something while the real brief is settled, and so the footprint can
/// be checked against the room before any joinery is designed.
struct Envelope: Geometry3D {
    let dims: CouchDimensions

    var body: any Geometry3D {
        // Seat block — front edge at y = 0, running back to the seat depth.
        Box([dims.seatWidth, dims.seatDepth, dims.seatHeight])
            .translated(x: dims.armWidth)

        // Back — fills the depth left behind the seat.
        Box([
            dims.seatWidth,
            dims.overallDepth - dims.seatDepth,
            dims.overallHeight,
        ])
        .translated(x: dims.armWidth, y: dims.seatDepth)

        // Arms — full depth, one at each end.
        for x in [0.0, dims.overallWidth - dims.armWidth] {
            Box([dims.armWidth, dims.overallDepth, dims.armHeight])
                .translated(x: x)
        }
    }
}
