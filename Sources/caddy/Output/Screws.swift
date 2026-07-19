import Foundation

// One Confirmat clearance hole on a side panel. `y`/`z` are the geometry
// coordinates used to cut the hole (cabinet-box frame). `front`/`back`/`height`
// are the human-facing measurements written to Screws.md — from the panel's
// outer edges (front/back) and up from its bottom edge (height).
struct ScrewHole {
    let group: String
    let label: String
    let y: Double
    let z: Double
    let front: Double
    let back: Double
    let height: Double
}

// Ordered collector for screw holes, populated during the Cadova build.
final class ScrewRegistry: @unchecked Sendable {
    private let lock = NSLock()
    private var holes: [ScrewHole] = []

    func record(_ hole: ScrewHole) {
        lock.lock()
        defer { lock.unlock() }
        holes.append(hole)
    }

    var all: [ScrewHole] {
        lock.lock()
        defer { lock.unlock() }
        return holes
    }
}

// Write the per-side-panel Confirmat positions as grouped Markdown tables.
func writeScrews(_ holes: [ScrewHole], to path: String = "Screws.md") throws {
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
        md += "| Hole | Front | Back | Height |\n"
        md += "|---|---|---|---|\n"
        for h in grouped[group]! {
            md += "| \(h.label) | \(fmt(h.front)) | \(fmt(h.back)) | \(fmt(h.height)) |\n"
        }
        md += "\n"
    }

    md += "**\(holes.count) Confirmats per side panel — \(holes.count * 2) total.**\n"

    try md.write(toFile: path, atomically: true, encoding: .utf8)
}
