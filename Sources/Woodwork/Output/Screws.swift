import Foundation

// One Confirmat clearance hole on a side panel. `y`/`z` are the geometry
// coordinates used to cut the hole (cabinet-box frame). `front`/`back`/`height`
// are the human-facing measurements written to Screws.md — from the panel's
// outer edges (front/back) and up from its bottom edge (height).
public struct ScrewHole: Sendable {
    public let group: String
    public let label: String
    public let y: Double
    public let z: Double
    public let front: Double
    public let back: Double
    public let height: Double

    public init(
        group: String,
        label: String,
        y: Double,
        z: Double,
        front: Double,
        back: Double,
        height: Double
    ) {
        self.group = group
        self.label = label
        self.y = y
        self.z = z
        self.front = front
        self.back = back
        self.height = height
    }
}

// Ordered collector for screw holes, populated during the Cadova build.
public final class ScrewRegistry: @unchecked Sendable {
    private let lock = NSLock()
    private var holes: [ScrewHole] = []

    public init() {}

    public func record(_ hole: ScrewHole) {
        lock.lock()
        defer { lock.unlock() }
        holes.append(hole)
    }

    public var all: [ScrewHole] {
        lock.lock()
        defer { lock.unlock() }
        return holes
    }
}

// Write the per-side-panel Confirmat positions as grouped Markdown tables.
public func writeScrews(_ holes: [ScrewHole], to path: String = "Screws.md") throws {
    func fmt(_ d: Double) -> String {
        d.rounded() == d ? String(Int(d)) : String(format: "%g", d)
    }

    var md = "# Screws\n\n"
    md += "Confirmat clearance-hole positions, per side panel (both panels are\n"
    md += "mirror-identical). All measurements in mm — Front/Back from the panel's\n"
    md += "front and back outer edges, Height up from the bottom edge.\n\n"
    md += "_Generated from the model by `task run` — do not edit by hand._\n\n"

    // Group in first-seen order.
    var order: [String] = []
    var grouped: [String: [ScrewHole]] = [:]
    for h in holes {
        if grouped[h.group] == nil { order.append(h.group) }
        grouped[h.group, default: []].append(h)
    }

    md += "## Side panel\n\n"
    md += "Both side panels are mirror-identical; every Confirmat below is\n"
    md += "driven through the panel into the part named by each subsection.\n\n"

    for group in order {
        md += "### \(group)\n\n"
        md += "| Hole | Front | Back | Height | 1000−Height |\n"
        md += "|---|---|---|---|---|\n"
        for h in grouped[group]! {
            md += "| \(h.label) | \(fmt(h.front)) | \(fmt(h.back)) | \(fmt(h.height)) | \(fmt(1000 - h.height)) |\n"
        }
        md += "\n"
    }

    md += "**\(holes.count) Confirmats per side panel — \(holes.count * 2) total.**\n"

    try md.write(toFile: path, atomically: true, encoding: .utf8)
}
