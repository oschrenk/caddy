# Pila

A wooden *tapadera* — a lid for the concrete pila outside the house. The pila and
the two building walls it sits against are modelled only as fit-check reference;
the lid is the thing being built.

Status: **design.** Nothing cut. The slat species is still being sourced.

```sh
task build:pila     # → Build/Pila/pila.3mf, tapadera.3mf, tapadera.stl
task clean:pila
```

`pila.3mf` carries the concrete, the wood, and the walls as three separate parts,
so each can be hidden in the viewer.

## The pila

A plain rectangular block, 1000 × 770 mm on plan, with two basins sunk into the
top. No washboard wing, no sloped drain edge.

| | mm |
| --- | --- |
| Outer footprint | 1000 × 770 |
| Outer wall | 35 |
| Central divider | 25 |
| Each basin | 452.5 × 700 |
| Basin depth | 400 — **assumed** |
| Block height | 900 — **assumed** |

Everything except the last two is given. Measure the real pila and correct
`PilaDimensions`; the lid geometry depends only on the outer footprint, so the
two assumptions affect the reference model's looks and nothing you would cut.

## Orientation

The pila sits in a building corner. In the model the two walls occupy the
**x = 0** and **y = 0** planes, and the pila occupies the **+x / −y quadrant** —
so the inside corner where the walls meet is the model origin.

That corner is also the lid's high corner. Runoff therefore always heads toward
+x and −y: away from both walls, and toward whoever is standing at the pila.

## The fall

One tilted plane, high at the wall corner, falling diagonally to the open corner.

```
                    wall  (y = 0)
   w  ┌───────────────────────────────┐
   a  │ 55                         35 │
   l  │                               │
   l  │          ↙  ↙  ↙  ↙           │
      │        fall direction         │   free edge
  x=0 │                               │
      │ 35                         15 │
      └───────────────────────────────┘
              free edge (toward you)
```

Numbers are cleat height in mm at each corner.

- 20 mm drop over the 1000 mm run — 1:50
- 20 mm drop over the 770 mm run — 1:38
- 40 mm across the diagonal

Both are steeper than the 1:60 a smooth surface needs before it sheds rather
than holding a film of water. The 15 mm at the low corner is the minimum, and it
exists to keep wood off wet concrete so the underside can dry.

## Cutlist

**Slats — 10 off, 1000 × 70 × 20 mm.** Gaps come out at 7.8 mm, solved so ten
slats fill the 770 mm exactly rather than leaving a ragged last gap.

**Cleats — 3 off, 770 mm long × 35 mm wide, tapered along their length:**

| Position (x) | Bears on | Height at the wall end | Height at the near end |
| --- | --- | --- | --- |
| 0 | left outer wall | 55.0 | 35.0 |
| 482.5 | central divider | 45.4 | 25.4 |
| 965 | right outer wall | 35.7 | 15.7 |

The cleats are placed to land on something solid — the two 35 mm outer walls and
the 25 mm divider. A cleat over a basin opening would carry nothing.

Every cleat drops the same 20 mm over its 770 mm length, so all three share one
taper angle, about 1.5°. Set the taper once and cut all three; they differ only
in starting thickness.

Three cleats rather than two puts the unsupported slat span at roughly 450 mm,
so the lid does not flex when you lean on it or set a bucket down.

**Stock note:** the tallest cleat needs 55 mm of thickness to cut from. Nominal
2 × 3 pine (roughly 38 × 63 mm actual) covers it. If that is awkward to find,
the alternative is a constant-section batten sitting on tapered packers.

## Rules the design follows

1. **Finish both faces equally.** Paint the top and leave the underside bare and
   it will cup — the two faces take on moisture at different rates. This is the
   most common way a lid like this fails.
2. **Nothing sits flat on the concrete.** The cleats hold the deck clear so air
   moves underneath and the edges stop wicking.
3. **A handle goes on the high edge.** Not yet modelled.

Rain falling through the slat gaps into the basins is fine — they hold water
anyway. The fall exists to protect the wood and to keep runoff off the walls,
not to keep water out.

## Material

Slats need naturally rot- and termite-resistant wood, or a treated equivalent.
Untreated pine outdoors here is termite food. Species and suppliers are still
being sourced.

`Docs/Material.md` covers sheet goods only, so it does not help here — solid
lumber is a separate catalogue.

## Open questions

1. Which species for the slats, and whether anyone sells it near 70 × 20 mm or
   it must be ripped from bigger stock.
2. Handle — one on the high edge, or a grip cut into the end slat.
3. Whether the cleats want a bevel on their bottom arris, to stop water tracking back
   along the timber to the rim.
