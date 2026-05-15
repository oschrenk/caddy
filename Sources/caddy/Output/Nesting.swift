import Cadova

// 2D nesting layout for cutting all 9 frame pieces from a single 12mm plywood
// sheet. Pieces are arranged in two columns starting from the top edge of the
// sheet, with a `kerf` gap between adjacent pieces (typical 3mm table-saw
// blade — adjust if your saw is different).
//
// Sheet: 1220 × 2440mm (standard 4'×8'). Origin at the sheet's bottom-left,
// pieces filled from the top down so the waste is at the bottom.
//   Column A (x: 0 .. innerWidth):       Back plate, Bottom plate, Shelf 1,
//                                        Shelf 2, both Kick plates, Front lip
//   Column B (x: innerWidth+kerf .. ):   Side panel × 2, Cross-brace
//
// Side panel uses its polygon profile (with the sloped top) rather than just
// its bounding rectangle, so the diagram shows the actual cut shape.
func nestingLayout(dims: CaddyDimensions) -> any Geometry2D {
    let kerf = 3.0
    let sheetW = 1220.0
    let sheetH = 2440.0
    let frameThickness = 2.0
    let edgeMargin = 5.0  // gap between frame's inner edge and pieces, so CSG keeps them as separate contours

    let t1 = dims.t1
    let iw = dims.innerWidth
    let od = dims.outerDepth
    let id = dims.innerDepth
    let bh = dims.backHeight
    let sk = dims.skirtHeight

    let sidePanel = SidePanel(
        thickness: t1,
        depth: od,
        backHeight: bh,
        frontHeight: dims.frontHeight,
        flatRunback: dims.flatRun,
        flatRunfront: dims.flatRun,
        skirtHeight: sk
    )

    // Pieces are inset from the sheet's edges so they don't touch the frame
    // (CSG would otherwise merge them into one contour, hiding kerf gaps).
    let xA = frameThickness + edgeMargin
    let xB = xA + iw + kerf
    let yTop = sheetH - frameThickness - edgeMargin

    // Column A — bottom-left y for each rectangle, stacked top-down.
    var topA = yTop
    let yLip    = topA - sk;        topA = yLip - kerf
    let yKickB  = topA - sk;        topA = yKickB - kerf
    let yKickF  = topA - sk;        topA = yKickF - kerf
    let yShelf2 = topA - id;        topA = yShelf2 - kerf
    let yShelf1 = topA - id;        topA = yShelf1 - kerf
    let yBottom = topA - od;        topA = yBottom - kerf
    let yBack   = topA - (bh - t1)

    // Column B — side panels (polygon) + cross-brace (rect), stacked top-down.
    // The polygon's natural y range is -sk..bh, so a translate of `bbox_top - bh`
    // puts the polygon's bbox top at `bbox_top`.
    var topB = yTop
    let sp1Translate = topB - bh
    let sp1Bottom    = topB - (bh + sk);  topB = sp1Bottom - kerf
    let sp2Translate = topB - bh
    let sp2Bottom    = topB - (bh + sk);  topB = sp2Bottom - kerf
    let yBrace       = topB - sk

    return Union {
        // Sheet outline as a frame
        Rectangle([sheetW, sheetH])
            .subtracting {
                Rectangle([sheetW - 2 * frameThickness, sheetH - 2 * frameThickness])
                    .translated(x: frameThickness, y: frameThickness)
            }

        // Column A
        Rectangle([iw, bh - t1]).translated(x: xA, y: yBack)
        Rectangle([iw, od]).translated(x: xA, y: yBottom)
        Rectangle([iw, id]).translated(x: xA, y: yShelf1)
        Rectangle([iw, id]).translated(x: xA, y: yShelf2)
        Rectangle([iw, sk]).translated(x: xA, y: yKickF)
        Rectangle([iw, sk]).translated(x: xA, y: yKickB)
        Rectangle([iw, sk]).translated(x: xA, y: yLip)

        // Column B
        sidePanel.profile.translated(x: xB, y: sp1Translate)
        sidePanel.profile.translated(x: xB, y: sp2Translate)
        Rectangle([od, sk]).translated(x: xB, y: yBrace)
    }
}
