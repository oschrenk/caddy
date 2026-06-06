/// Primary and derived dimensions for the caddy in millimeters.
struct CaddyDimensions {
    // Inputs
    // ---------------
    let t1: Double // plywood thickness (single thickness throughout)
    let wiggleRoom: Double // slack
    let backHeight: Double // overall height excluding casters
    let outerWidth: Double // overall footprint in x
    let shelf2Z: Double // top surface of shelf 2 (tray level)
    let shelf4Z: Double // top surface of shelf 4 (top, wooden box / iPad level)
    let shelf3TopGap: Double // vertical clearance between shelf 3 top and shelf 4 underside
    let skirtHeight: Double // foot height; matches kick plate + cross-brace
    let casterDiameter: Double // overall caster height
    let frontInset: Double // gear stand-off from front edge
    let topShelfDepth: Double // depth of top shelf

    init(
        topShelfDepth: Double = 254.0, // same as wooden box from cemaco
        t1: Double = 12.0,
        wiggleRoom: Double = 3.0,
        backHeight: Double = 712.0,
        outerWidth: Double = 712.0,
        shelf2Z: Double = 287.0,
        shelf4Z: Double = 600.0,
        shelf3TopGap: Double = 110.0, // clearance for wooden box (105 mm) + 5 mm slack
        skirtHeight: Double = 25.0,
        casterDiameter: Double = 45.7,
        frontInset: Double = 25.0
    ) {
        self.topShelfDepth = topShelfDepth
        self.t1 = t1
        self.wiggleRoom = wiggleRoom
        self.backHeight = backHeight
        self.outerWidth = outerWidth
        self.shelf2Z = shelf2Z
        self.shelf4Z = shelf4Z
        self.shelf3TopGap = shelf3TopGap
        self.skirtHeight = skirtHeight
        self.casterDiameter = casterDiameter
        self.frontInset = frontInset
    }

    // Derived
    // ---------------

    var outerDepth: Double {
        topShelfDepth + 2 * wiggleRoom + 2 * t1
    }

    var innerWidth: Double {
        outerWidth - 2 * t1
    }

    var innerDepth: Double {
        outerDepth - t1
    }

    /// Top surface of shelf 1 (the cabinet's bottom plate; UPS / Pi rack level).
    var shelf1Z: Double {
        t1
    }

    /// Top surface of shelf 3 — sits below shelf 4 with `shelf3TopGap` of clearance.
    var shelf3Z: Double {
        shelf4Z - t1 - shelf3TopGap
    }

    var lipHeight: Double {
        skirtHeight
    } // lip = same cut as kick
    var frontHeight: Double {
        shelf4Z + lipHeight
    } // lip sits on top of shelf 4
    var flatRun: Double {
        t1 + 10
    } // flat top run at back and front
}
