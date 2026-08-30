import Foundation

// Nesting for projects whose parts are all rectangles. Unlike `NestingPlan`,
// which hands 2D geometry to Cadova and post-processes the SVG it emits, this
// writes the SVG itself. That is what buys per-piece fill colour: Cadova merges
// every contour into one `<path>`, so a colour per piece cannot survive the
// round trip.
//
// Pieces are packed by shelf: lay them out in rows, each row as tall as its
// tallest piece, and let smaller pieces backfill the width left over. Ordering
// decides how well that goes and no one ordering wins on every mix, so
// `packSheets` runs several and keeps the best result.
//
// It is a heuristic, not an optimiser, and shelf packing has a ceiling worth
// knowing: parts whose short side is s leave a dead strip whenever the sheet
// height is not a multiple of s. With 350 mm parts on a 2440 mm sheet that is
// ~300 mm per sheet no matter how the rows are ordered. `Sheet.utilisation`
// reports the outcome so a bad layout is visible rather than silent.

public struct SheetPiece: Sendable {
    public let name: String
    public let group: String // pieces sharing a group share a fill colour
    public let width: Double
    public let height: Double

    public init(name: String, group: String, width: Double, height: Double) {
        self.name = name
        self.group = group
        self.width = width
        self.height = height
    }

    /// Area of one piece, in mm².
    var area: Double { width * height }
}

public struct PlacedPiece: Sendable {
    public let piece: SheetPiece
    public let number: Int
    public let x: Double // top-left, SVG coordinates (y down)
    public let y: Double
    public let width: Double // as placed, so swapped when `rotated`
    public let height: Double
    public let rotated: Bool
}

public struct Sheet: Sendable {
    public let pieces: [PlacedPiece]
    public let width: Double
    public let height: Double

    /// Fraction of the sheet covered by parts, 0...1.
    public var utilisation: Double {
        pieces.reduce(0) { $0 + $1.width * $1.height } / (width * height)
    }
}

// MARK: - Packing

private struct Shelf {
    let y: Double // top edge, SVG coordinates
    let height: Double
    var used: Double // width consumed so far, from the left margin
}

/// How pieces are ordered before packing. Shelf packing is sensitive to it,
/// and which order wins depends on the mix, so `packSheets` tries them all.
private enum SortKey: CaseIterable {
    case height, area, width, longestSide

    func value(_ p: SheetPiece) -> Double {
        switch self {
        case .height: p.height
        case .area: p.area
        case .width: p.width
        case .longestSide: max(p.width, p.height)
        }
    }
}

/// Lays `pieces` out on sheets with first-fit decreasing height: normalise each
/// piece's orientation, take the largest first, put them on shelves, and let
/// smaller ones backfill the width left over on earlier shelves. `bestFit`
/// picks the shelf that ends up tightest rather than the first that will do.
private func packOnce(
    _ pieces: [SheetPiece],
    landscape: Bool,
    sortKey: SortKey,
    bestFit: Bool,
    sheetWidth: Double,
    sheetHeight: Double,
    kerf: Double,
    margin: Double
) -> [Sheet] {
    let usableWidth = sheetWidth - 2 * margin
    let usableHeight = sheetHeight - 2 * margin

    let sorted = pieces
        .map { p -> SheetPiece in
            let long = max(p.width, p.height), short = min(p.width, p.height)
            return SheetPiece(
                name: p.name, group: p.group,
                width: landscape ? long : short,
                height: landscape ? short : long
            )
        }
        .sorted { (sortKey.value($0), $0.width) > (sortKey.value($1), $1.width) }

    var sheets: [[PlacedPiece]] = []
    var shelvesPerSheet: [[Shelf]] = []
    var nextY: [Double] = [] // top edge of the next new shelf, per sheet
    var number = 0

    for piece in sorted {
        number += 1
        // Both orientations are candidates, so a tall-but-narrow piece can
        // still slot into a short row.
        let options: [(w: Double, h: Double, rotated: Bool)] = [
            (piece.width, piece.height, false),
            (piece.height, piece.width, true),
        ]

        // Find the shelf this piece fits with the least width left over.
        var best: (sheet: Int, shelf: Int, option: (w: Double, h: Double, rotated: Bool), gap: Double, slack: Double)?
        search: for s in sheets.indices {
            for shelfIndex in shelvesPerSheet[s].indices {
                let shelf = shelvesPerSheet[s][shelfIndex]
                let gap = shelf.used > 0 ? kerf : 0
                for option in options where option.h <= shelf.height {
                    let slack = usableWidth - (shelf.used + gap + option.w)
                    guard slack >= 0 else { continue }
                    if best == nil || slack < best!.slack {
                        best = (s, shelfIndex, option, gap, slack)
                    }
                    if !bestFit { break search }
                }
            }
        }

        if let hit = best {
            let shelf = shelvesPerSheet[hit.sheet][hit.shelf]
            sheets[hit.sheet].append(PlacedPiece(
                piece: piece, number: number,
                x: margin + shelf.used + hit.gap, y: shelf.y,
                width: hit.option.w, height: hit.option.h, rotated: hit.option.rotated
            ))
            shelvesPerSheet[hit.sheet][hit.shelf].used = shelf.used + hit.gap + hit.option.w
            continue
        }

        // No shelf took it — open a new one on the first sheet with room.
        var opened = false
        for s in sheets.indices {
            let gap = nextY[s] > margin ? kerf : 0
            let top = nextY[s] + gap
            guard let option = options.first(where: {
                $0.w <= usableWidth && top + $0.h <= margin + usableHeight
            }) else { continue }

            shelvesPerSheet[s].append(Shelf(y: top, height: option.h, used: option.w))
            sheets[s].append(PlacedPiece(
                piece: piece, number: number,
                x: margin, y: top,
                width: option.w, height: option.h, rotated: option.rotated
            ))
            nextY[s] = top + option.h
            opened = true
            break
        }
        if opened { continue }

        // Every sheet is full; start a fresh one.
        let option = options[0]
        sheets.append([PlacedPiece(
            piece: piece, number: number,
            x: margin, y: margin,
            width: option.w, height: option.h, rotated: option.rotated
        )])
        shelvesPerSheet.append([Shelf(y: margin, height: option.h, used: option.w)])
        nextY.append(margin + option.h)
    }

    return sheets.map { Sheet(pieces: $0, width: sheetWidth, height: sheetHeight) }
}

/// Packs `pieces` onto as many sheets as it takes. `kerf` is left between
/// neighbours so a single saw pass down the middle separates both at size;
/// `margin` keeps parts off the sheet's own ragged edge.
///
/// Shelf packing is a heuristic and no single ordering wins on every mix, so
/// this runs the lot and keeps the best: fewest sheets first, then the emptiest
/// final sheet, which gathers the waste into one offcut worth keeping rather
/// than scattering it. `Sheet.utilisation` reports the result so a bad layout
/// is visible rather than silent.
public func packSheets(
    _ pieces: [SheetPiece],
    sheetWidth: Double = 1220,
    sheetHeight: Double = 2440,
    kerf: Double = 3,
    margin: Double = 10
) -> [Sheet] {
    var best: [Sheet]?

    for landscape in [true, false] {
        for sortKey in SortKey.allCases {
            for bestFit in [true, false] {
                let candidate = packOnce(
                    pieces, landscape: landscape, sortKey: sortKey, bestFit: bestFit,
                    sheetWidth: sheetWidth, sheetHeight: sheetHeight, kerf: kerf, margin: margin
                )
                guard let incumbent = best else { best = candidate; continue }
                let score = (candidate.count, candidate.last?.utilisation ?? 0)
                let bestScore = (incumbent.count, incumbent.last?.utilisation ?? 0)
                if score < bestScore { best = candidate }
            }
        }
    }

    return best ?? []
}

// MARK: - SVG

/// Fill colours, assigned to groups in the order given. Light enough that the
/// black piece labels stay readable on top.
private let groupFills = ["#e8d5b0", "#c3d7e8", "#d9c9e0", "#cfe3cf", "#f0d6cf"]
private let groupStrokes = ["#8a6d3b", "#376b8f", "#6b4c86", "#3f6b3f", "#a2564a"]

/// Writes one sheet as a standalone SVG: the sheet outline, every piece filled
/// in its group's colour with its name and cut size on it, and a legend keying
/// the colours and listing what is on this sheet.
public func writeSheetSVG(
    _ sheet: Sheet,
    index: Int,
    of total: Int,
    groups: [String],
    title: String,
    to path: String
) throws {
    func fmt(_ v: Double) -> String { String(format: "%g", (v * 100).rounded() / 100) }
    func esc(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
    func colour(_ group: String, _ table: [String]) -> String {
        guard let i = groups.firstIndex(of: group) else { return table[0] }
        return table[i % table.count]
    }

    let legendHeight = 40.0 + Double(groups.count) * 30.0
    let headerHeight = 60.0
    let totalHeight = headerHeight + sheet.height + legendHeight

    var svg = """
    <svg xmlns="http://www.w3.org/2000/svg" width="\(fmt(sheet.width))mm" height="\(fmt(totalHeight))mm" \
    viewBox="0 0 \(fmt(sheet.width)) \(fmt(totalHeight))">
      <rect width="100%" height="100%" fill="white"/>
      <text x="10" y="34" font-family="sans-serif" font-size="30" font-weight="bold" fill="black">\
    \(esc(title)) — sheet \(index) of \(total)</text>
      <text x="10" y="54" font-family="sans-serif" font-size="18" fill="#555">\
    \(fmt(sheet.width)) × \(fmt(sheet.height)) mm · \(sheet.pieces.count) pieces · \
    \(Int((sheet.utilisation * 100).rounded()))% used</text>
      <g transform="translate(0 \(fmt(headerHeight)))">
        <rect x="0" y="0" width="\(fmt(sheet.width))" height="\(fmt(sheet.height))" \
    fill="none" stroke="black" stroke-width="2"/>

    """

    for p in sheet.pieces.sorted(by: { $0.number < $1.number }) {
        let fill = colour(p.piece.group, groupFills)
        let stroke = colour(p.piece.group, groupStrokes)
        let cx = p.x + p.width / 2
        let cy = p.y + p.height / 2
        let label = min(30.0, max(9.0, min(p.width, p.height) * 0.18))
        let dims = "\(fmt(p.piece.width)) × \(fmt(p.piece.height))" + (p.rotated ? " ⟳" : "")

        svg += """
            <rect x="\(fmt(p.x))" y="\(fmt(p.y))" width="\(fmt(p.width))" height="\(fmt(p.height))" \
        fill="\(fill)" stroke="\(stroke)" stroke-width="1.5"/>
            <text x="\(fmt(cx))" y="\(fmt(cy - label * 0.35))" font-family="sans-serif" \
        font-size="\(fmt(label))" font-weight="bold" text-anchor="middle" fill="#222">\
        \(p.number). \(esc(p.piece.name))</text>
            <text x="\(fmt(cx))" y="\(fmt(cy + label * 0.9))" font-family="sans-serif" \
        font-size="\(fmt(label * 0.8))" text-anchor="middle" fill="#444">\(dims)</text>

        """
    }

    svg += "  </g>\n"

    var ly = headerHeight + sheet.height + 30.0
    for group in groups {
        let count = sheet.pieces.filter { $0.piece.group == group }.count
        guard count > 0 else { continue }
        svg += """
          <rect x="10" y="\(fmt(ly - 14))" width="24" height="18" fill="\(colour(group, groupFills))" \
        stroke="\(colour(group, groupStrokes))" stroke-width="1.5"/>
          <text x="44" y="\(fmt(ly))" font-family="sans-serif" font-size="20" fill="black">\
        \(esc(group)) — \(count) piece\(count == 1 ? "" : "s") on this sheet</text>

        """
        ly += 30
    }
    svg += "  <text x=\"10\" y=\"\(fmt(ly))\" font-family=\"sans-serif\" font-size=\"16\" fill=\"#555\">"
    svg += "⟳ marks a piece laid across the sheet rather than along it — check grain before cutting.</text>\n"
    svg += "</svg>\n"

    try svg.write(toFile: path, atomically: true, encoding: .utf8)
}
