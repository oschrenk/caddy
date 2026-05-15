import Foundation

struct CutPart {
    let name: String
    let width: Double      // longest in-plane dimension
    let depth: Double      // other in-plane dimension
    let thickness: Double  // plywood thickness
    let qty: Int
    let notes: String
}

func writeCutlist(_ parts: [CutPart], to path: String = "Cutlist.md") throws {
    func fmt(_ d: Double) -> String {
        d.rounded() == d ? String(Int(d)) : String(format: "%g", d)
    }

    var md = "# Cutlist\n\n"
    md += "| Part | W × D × T (mm) | Qty | Notes |\n"
    md += "|---|---|---|---|\n"
    for p in parts {
        let dims = "\(fmt(p.width)) × \(fmt(p.depth)) × \(fmt(p.thickness))"
        md += "| \(p.name) | \(dims) | \(p.qty) | \(p.notes) |\n"
    }

    try md.write(toFile: path, atomically: true, encoding: .utf8)
}
