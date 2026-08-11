import Foundation

// Cadova's SVG provider emits a single `<path>` element containing every
// closed contour as a sub-path (joined `M ... Z M ... Z` ...). SVG editors
// like Inkscape treat that one element as one object, so you can't select
// individual pieces.
//
// This rewrites the file in place, replacing the single path with one path
// element per closed sub-path, preserving the original element's attributes
// (fill, fill-rule). Each piece is then independently selectable.
public func splitSVGPaths(at filePath: String) throws {
    let url = URL(fileURLWithPath: filePath)
    let original = try String(contentsOf: url, encoding: .utf8)

    guard let pathStart = original.range(of: "<path"),
          let pathEnd = original.range(of: "/>", range: pathStart.upperBound..<original.endIndex)
    else { return }

    let oldElement = String(original[pathStart.lowerBound..<pathEnd.upperBound])

    // Extract the d="..." attribute value.
    guard let dPrefix = oldElement.range(of: "d=\""),
          let dCloseQuote = oldElement.range(of: "\"", range: dPrefix.upperBound..<oldElement.endIndex)
    else { return }
    let dValue = String(oldElement[dPrefix.upperBound..<dCloseQuote.lowerBound])

    // Split the d attribute into sub-paths. Every sub-path starts with "M ".
    let parts = dValue.components(separatedBy: " M ")
    let subpaths = parts.enumerated().map { i, p in i == 0 ? p : "M " + p }

    // Rebuild as one `<path>` per sub-path. Swap solid-black fill for an
    // outline stroke so pieces are visible (with fill="black", overlapping
    // paths would hide each other) and the result is trace-friendly for
    // cutting.
    let newPaths = subpaths.map { subpath in
        oldElement
            .replacingOccurrences(of: "d=\"\(dValue)\"", with: "d=\"\(subpath)\"")
            .replacingOccurrences(of: "fill=\"black\"", with: "fill=\"none\" stroke=\"black\" stroke-width=\"1\"")
    }.joined(separator: "\n    ")

    let rewritten = original.replacingOccurrences(of: oldElement, with: newPaths)
    try rewritten.write(to: url, atomically: true, encoding: .utf8)
}

// Stamps a number in the centre of each nested piece and prints a matching
// legend (number → part name) in the sheet's waste area. Cadova's 2D output
// has its origin at the bottom-left (y up); SVG's is at the top-left (y down),
// so each y is flipped via `sheetHeight - y`.
public func annotateNestingSVG(at filePath: String, plan: NestingPlan) throws {
    let url = URL(fileURLWithPath: filePath)
    var svg = try String(contentsOf: url, encoding: .utf8)

    func fmt(_ v: Double) -> String { String(format: "%g", v) }
    let h = plan.sheetHeight
    var out = ""

    for label in plan.labels {
        let fontSize = min(48, max(12, label.minDim * 0.6))
        out += "\n    <text x=\"\(fmt(label.cx))\" y=\"\(fmt(h - label.cy))\""
            + " font-family=\"sans-serif\" font-size=\"\(fmt(fontSize))\""
            + " text-anchor=\"middle\" dominant-baseline=\"central\" fill=\"black\">\(label.number)</text>"
    }

    var ly = h - plan.legendTopY
    out += "\n    <text x=\"\(fmt(plan.legendX))\" y=\"\(fmt(ly))\""
        + " font-family=\"sans-serif\" font-size=\"28\" font-weight=\"bold\" fill=\"black\">Legend / Leyenda</text>"
    ly += 40
    for label in plan.labels {
        let line = "\(label.number).  \(label.name) / \(label.nameES) — \(label.dims)"
        out += "\n    <text x=\"\(fmt(plan.legendX))\" y=\"\(fmt(ly))\""
            + " font-family=\"sans-serif\" font-size=\"24\" fill=\"black\">\(line)</text>"
        ly += 34
    }

    svg = svg.replacingOccurrences(of: "</svg>", with: out + "\n</svg>")
    try svg.write(to: url, atomically: true, encoding: .utf8)
}
