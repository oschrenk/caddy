# Couch

Status: **scaffold only.** No brief, no measurements, no design decisions. The
target exists and renders a placeholder envelope so the rest can be built on top
of something that compiles.

```sh
task build:couch    # → Build/Couch/couch.3mf
task clean:couch
```

## What is modelled

Three plain boxes — seat block, back, two arms — at conventional three-seater
proportions. Nothing here is measured and nothing here is joinery.

| | mm |
| --- | --- |
| Overall | 2100 × 900 × 800 |
| Seat height | 420 |
| Seat depth | 550 |
| Arm height | 620 |
| Arm width | 150 |

All **placeholders**, set in `CouchDimensions`.

## Orientation

Front edge of the seat at **y = 0**, running back toward +y. Left arm at
**x = 0**. Floor at **z = 0**.

## Open questions

1. Where it goes, and what the room allows for width and depth.
2. Seat count, and whether the arms are part of the frame or separate.
3. Frame to upholster, or a slatted platform taking loose cushions.
4. Material — sheet goods (see `Docs/Material.md`) or solid lumber.
