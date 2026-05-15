import Foundation

// Cadova's SVG provider emits a single `<path>` element containing every
// closed contour as a sub-path (joined `M ... Z M ... Z` ...). SVG editors
// like Inkscape treat that one element as one object, so you can't select
// individual pieces.
//
// This rewrites the file in place, replacing the single path with one path
// element per closed sub-path, preserving the original element's attributes
// (fill, fill-rule). Each piece is then independently selectable.
func splitSVGPaths(at filePath: String) throws {
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
