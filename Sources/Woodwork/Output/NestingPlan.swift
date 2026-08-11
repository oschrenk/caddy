import Cadova

// A nesting layout: the 2D geometry of all pieces arranged on a sheet, plus the
// per-piece label positions so the SVG post-processor can stamp a number on each
// piece and print a matching legend. Each project builds its own plan; see
// `annotateNestingSVG(at:plan:)` for the consumer.

public struct NestLabel: Sendable {
    public let number: Int
    public let name: String    // English part name (matches Cutlist.md)
    public let nameES: String  // Spanish part name
    public let dims: String    // cut size as drawn, e.g. "688 × 272 × 12 mm"
    public let cx: Double  // piece centre, Cadova coords (origin bottom-left, y up)
    public let cy: Double
    public let minDim: Double  // smaller of width/height — bounds the label font size

    public init(
        number: Int,
        name: String,
        nameES: String,
        dims: String,
        cx: Double,
        cy: Double,
        minDim: Double
    ) {
        self.number = number
        self.name = name
        self.nameES = nameES
        self.dims = dims
        self.cx = cx
        self.cy = cy
        self.minDim = minDim
    }
}

public struct NestingPlan: Sendable {
    public let geometry: any Geometry2D
    public let labels: [NestLabel]
    public let sheetWidth: Double
    public let sheetHeight: Double
    public let legendX: Double      // legend top-left, Cadova coords
    public let legendTopY: Double

    public init(
        geometry: any Geometry2D,
        labels: [NestLabel],
        sheetWidth: Double,
        sheetHeight: Double,
        legendX: Double,
        legendTopY: Double
    ) {
        self.geometry = geometry
        self.labels = labels
        self.sheetWidth = sheetWidth
        self.sheetHeight = sheetHeight
        self.legendX = legendX
        self.legendTopY = legendTopY
    }
}
