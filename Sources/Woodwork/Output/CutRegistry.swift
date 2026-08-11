import Cadova
import Foundation

// Thread-safe registry that collects `CutPart` entries from bounding boxes
// measured during the Cadova build phase. Each `.record(...)` call sorts the
// bbox axes so the smallest becomes thickness, the middle is depth and the
// largest is width. Entries with the same `name` are merged — qty sums,
// dimensions and notes from the first-seen entry win.
public final class CutRegistry: @unchecked Sendable {
    private let lock = NSLock()
    private var entries: [String: CutPart] = [:]

    public init() {}

    public func record(name: String, size: Vector3D, qty: Int = 1, notes: String = "") {
        let s = [size.x, size.y, size.z].sorted()
        lock.lock()
        defer { lock.unlock() }
        if let existing = entries[name] {
            entries[name] = CutPart(
                name: existing.name,
                width: existing.width,
                depth: existing.depth,
                thickness: existing.thickness,
                qty: existing.qty + qty,
                notes: existing.notes
            )
        } else {
            entries[name] = CutPart(
                name: name,
                width: s[2],
                depth: s[1],
                thickness: s[0],
                qty: qty,
                notes: notes
            )
        }
    }

    public var all: [CutPart] {
        lock.lock()
        defer { lock.unlock() }
        return entries.values.sorted { $0.name < $1.name }
    }
}

public extension Geometry3D {
    // Records this geometry's measured bounding box in `registry` as a cut part and
    // passes the geometry through unchanged, so it drops into a modifier chain:
    //
    //     Shelf(...)
    //         .recordingCut(in: cutReg, name: "Shelf 1")
    //         .withMaterial(...)
    //
    // Wrapping `measuringBounds` here rather than inline at each call site also keeps
    // the closure out of the enclosing `Model { }` result builder, where the nested
    // `return` trips up type inference.
    func recordingCut(
        in registry: CutRegistry,
        name: String,
        qty: Int = 1,
        notes: String = ""
    ) -> any Geometry3D {
        measuringBounds { geom, box in
            registry.record(name: name, size: box.size, qty: qty, notes: notes)
            return geom
        }
    }
}
