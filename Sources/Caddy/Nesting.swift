import Cadova
import Woodwork

// 2D nesting layout for cutting all 11 frame pieces from a single 12mm plywood
// sheet. Pieces are arranged in two columns from the top edge of the sheet,
// with a `kerf` gap between adjacent pieces (typical 3mm table-saw blade — a
// single pass down the centre of the gap separates two pieces at exact size).
//
// Sheet: 1220 × 2440mm (standard 4'×8'). Cadova origin at the bottom-left,
// pieces filled from the top down so the waste collects at the bottom.
//   Column A: Front lip, both Kick plates, Shelf 4/3/2, Shelf 1 (bottom plate,
//             full outer depth), Back plate.
//   Column B: Side panel × 2 (polygon profile, with the sloped top), Cross-brace.
//
// Names match Cutlist.md. `nestingPlan` returns the geometry plus per-piece
// label positions so the SVG post-processor can stamp a number on each piece
// and print a matching legend.

func nestingPlan(dims: CaddyDimensions) -> NestingPlan {
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

    var geometries: [any Geometry2D] = []
    var labels: [NestLabel] = []
    var n = 0

    func dimStr(_ w: Double, _ h: Double) -> String {
        String(format: "%g × %g × %g mm", w, h, t1)
    }

    func addRect(_ name: String, es: String, w: Double, h: Double, x: Double, bottomY: Double) {
        n += 1
        geometries.append(Rectangle([w, h]).translated(x: x, y: bottomY))
        labels.append(NestLabel(number: n, name: name, nameES: es, dims: dimStr(w, h),
                                cx: x + w / 2, cy: bottomY + h / 2, minDim: min(w, h)))
    }

    // Column A — full-width pieces stacked top-down.
    var topA = yTop
    @discardableResult
    func placeColA(_ name: String, es: String, h: Double) -> Double {
        let bottom = topA - h
        addRect(name, es: es, w: iw, h: h, x: xA, bottomY: bottom)
        topA = bottom - kerf
        return bottom
    }
    placeColA("Front lip", es: "Listón frontal", h: sk)
    placeColA("Kick plate (back)", es: "Zócalo (trasero)", h: sk)
    placeColA("Kick plate (front)", es: "Zócalo (frontal)", h: sk)
    placeColA("Shelf 4", es: "Entrepaño 4", h: id)
    placeColA("Shelf 3", es: "Entrepaño 3", h: id)
    placeColA("Shelf 2", es: "Entrepaño 2", h: id)
    placeColA("Shelf 1", es: "Entrepaño 1", h: od)  // bottom plate — full outer depth, tucks under back plate
    let backBottom = placeColA("Back plate", es: "Panel trasero", h: bh - t1)

    // Column B — side panels (polygon) then cross-brace, stacked top-down.
    // The profile's natural y range is -sk..bh; translating by `top - bh` puts
    // its bbox top at `top`. bbox is od wide × (bh + sk) tall.
    var topB = yTop
    func placeSide(_ name: String, es: String) {
        n += 1
        let translate = topB - bh
        geometries.append(sidePanel.profile.translated(x: xB, y: translate))
        labels.append(NestLabel(number: n, name: name, nameES: es, dims: dimStr(od, bh + sk),
                                cx: xB + od / 2, cy: translate + (bh - sk) / 2, minDim: od))
        topB = (translate - sk) - kerf
    }
    placeSide("Side panel", es: "Panel lateral")
    placeSide("Side panel", es: "Panel lateral")
    addRect("Cross-brace", es: "Travesaño", w: od, h: sk, x: xB, bottomY: topB - sk)

    let pieces = geometries
    let geometry = Union {
        // Sheet outline as a frame.
        Rectangle([sheetW, sheetH])
            .subtracting {
                Rectangle([sheetW - 2 * frameThickness, sheetH - 2 * frameThickness])
                    .translated(x: frameThickness, y: frameThickness)
            }
        for g in pieces { g }
    }

    return NestingPlan(
        geometry: geometry,
        labels: labels,
        sheetWidth: sheetW,
        sheetHeight: sheetH,
        legendX: xA,
        legendTopY: backBottom - kerf - 30  // waste area below column A's last piece
    )
}
