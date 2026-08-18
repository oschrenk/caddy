import Cadova

/// A surface appearance. Rendering only — carries no meaning for the build.
struct Finish {
    let name: String
    let color: Color
    let metallicness: Double
    let roughness: Double
}

extension Geometry3D {
    func finished(_ f: Finish) -> any Geometry3D {
        withMaterial(
            color: f.color, metallicness: f.metallicness, roughness: f.roughness, name: f.name
        )
    }
}

enum CouchFinishes {
    /// Pale pine, for the frame timber.
    static let pine = Finish(
        name: "Pine", color: Color(hex: "D9B382"), metallicness: 0, roughness: 0.75
    )

    /// Fabric, for the cushions.
    static let upholstery = Finish(
        name: "Upholstery", color: Color(hex: "7E8B7A"), metallicness: 0, roughness: 0.95
    )
}

/// Dimensions for the couch, in millimeters.
///
/// **Everything here is a placeholder.** The numbers are conventional
/// three-seater proportions, not measurements — they exist so the envelope
/// renders and the target builds. Replace them once the real brief is settled
/// (room it goes in, seat count, whether it is a frame to upholster or a
/// slatted daybed).
struct CouchDimensions {
    // Overall envelope
    let overallWidth: Double // x
    let overallDepth: Double // y
    let overallHeight: Double // z — to the top of the back

    // Seating
    let seatHeight: Double // finished cushion top above the floor
    let seatDepth: Double // front edge to the face of the back cushion
    let armHeight: Double
    let armWidth: Double

    init(
        overallWidth: Double = 2100.0,
        overallDepth: Double = 900.0,
        overallHeight: Double = 800.0,
        seatHeight: Double = 420.0,
        seatDepth: Double = 550.0,
        armHeight: Double = 620.0,
        armWidth: Double = 150.0
    ) {
        self.overallWidth = overallWidth
        self.overallDepth = overallDepth
        self.overallHeight = overallHeight
        self.seatHeight = seatHeight
        self.seatDepth = seatDepth
        self.armHeight = armHeight
        self.armWidth = armWidth
    }

    // Derived
    // ---------------

    /// Clear seating width between the two arms.
    var seatWidth: Double { overallWidth - 2 * armWidth }
}
