# Shoerack

A wall-standing shoe cabinet with tip-out fronts — the fronts pivot forward from
their bottom edge and carry the shoe tray with them, so the cabinet stays
shallow instead of needing door swing.

Status: **design, not started.** The carcass model generates; the fronts, the
rattan panels, and the pivot bores are all still open. Nothing has been cut.

```sh
task build:shoerack   # → Build/Shoerack/shoerack.3mf (+ .stl)
task clean:shoerack
```

## The constraint that drives everything

The tip-out fitting is not adjustable, so it fixes the cabinet's depth and the
height of each opening. Design around the hardware, not the other way round.

| | mm | Where it lands |
|---|---|---|
| Hinge frame depth | 235 | Interior depth, + 15 mm slack = **250 mm** |
| Hinge frame height | 260 | One tier's opening height, + slack = **275 mm** |
| Pivot shaft | 12 / 18 Ø | Bores through the side panels |
| Pivot mounting hole | 8.5 / 12 Ø | Screw fixing into the front |

The listing gives **two numbers per axis** and does not say which pairs with
which — it likely covers two frame sizes. Measure the fitting in hand before
cutting anything. `ShoerackDimensions` currently assumes the larger of each.

Two tiers, 600 mm wide, on a 60 mm recessed plinth → roughly 600 × 262 × 610 mm
overall. Every one of those is provisional.

## Hardware

**Tip-out fitting** — *herraje para zapatera abatible, 2 capas*. Note it is not
a *bisagra*; asking for one gets a normal door hinge. *Capas* means rows of
shoes on the tilting front, not the number of hinges supplied.

- **Chosen:** [Unique Bargains 2-Layer Steel, black][lowes-hinge] — $39.49 for
  4 pieces, i.e. two fronts. Cold-rolled steel frame on steel shafts. Box holds
  4 hinges, 8 shafts, 4 mounting buckles, 4 × M4×6 screws.
- **Why not local:** [Mega Herrajes][mega-hinge] stocks a triple-layer version
  at Q25, but it is moulded plastic and only comes in 3 capas.
- **Why not Häfele:** their [P-00926101][hafele-hinge] covers 1, 2, and 3
  compartments, so the size exists — but it is plastic too. [Distribuidora
  Hernández][hafele-gt] (5a Avenida 1-28 zona 9, 2417 2929) is the Guatemala
  partner if that changes.
- **Getting it here:** Lowe's does not ship to Guatemala. Needs a casillero —
  [Aeropost][aeropost] or [TransExpress][transexpress]. Budget $20–30 freight
  and duty on top, so ~Q450–550 landed for two fronts, two to three weeks.
  Shipping is close to a fixed cost, so order spares in the same package.

**Still to source:** a push latch (*sistema push*) so the fronts open without a
handle — [Mega Herrajes carries these][mega-push].

## Materials

### Carcass

Plywood, painted. Prices from San Miguel, 4' × 8' sheets:

| Family | English | 1/2" | Note |
|---|---|---|---|
| Plywood sangre | Red tropical hardwood ply | Q199.00 | Smooth face, takes paint well |
| Plywood fenólico pino | Phenolic-bonded pine ply | Q219.50 | Waterproof glue, knotty face |

Leaning **sangre 1/2"** — the face is smoother, and this cabinet lives indoors
so the phenolic glue line buys nothing. See the plywood note in `Shopping.md`
once that exists.

### Fronts — woven rattan

The tip-out fronts get **woven rattan** panels set into a plywood or solid-wood
frame. Shoes want airflow, and a solid front traps damp; the weave solves the
ventilation problem and the appearance problem at once.

Spanish, in rough order of usefulness at a Guatemalan counter:

- **rejilla de ratán** — the general term, woven rattan cane webbing
- **rejilla de viena** — specifically the open hexagonal weave, the classic
  bentwood-chair pattern. This is the one to ask for.
- **malla de ratán** — same thing, used interchangeably in some shops
- **mimbre** — wicker. Related but *not* the same: usually a coarser,
  thicker weave. Say *rejilla* if the fine cane webbing is what you want.

Sold by the running metre off a roll, typically 450–900 mm wide. It arrives
stiff; soak it in warm water before fitting so it tightens as it dries.

Fixing method still open — a groove in the frame with a spline (*junquillo*) is
the traditional way and reads cleanest, but it commits the frame to a router
setup. Stapling to a rebate from behind is the fallback.

**Not yet checked:** whether anyone in Guatemala City stocks cane webbing by the
metre. The wicker workshops are the likely source rather than the hardware
chains.

## Open questions

1. Do the hinge specs pair as 235×260 or 90×210? Blocks the cutlist.
2. Where to buy *rejilla de viena* locally, and in what widths.
3. Two tiers or three — three needs ~885 mm of height, which may crowd the
   entryway wall.
4. Spline groove or rear rebate for the rattan.

[lowes-hinge]: https://www.lowes.com/pd/Unique-Bargains-4pcs-Shoes-Drawer-Cabinet-Hinges-2-Layers-Steel-Furniture-Hinge-Flip-Plate-Frame-Turning-Rack-Replacement-Fittings-for-Home-Black/7890012
[mega-hinge]: https://www.megaherrajes.com.gt/product/herraje-para-zapatera-triple-negra/
[mega-push]: https://www.megaherrajes.com.gt/product-category/carpinteria/accesorios/sistema-push/
[hafele-hinge]: https://www.hafele.com.mx/es/product/herraje-basculante-con-1-2-o-3-compartimentos/P-00926101/
[hafele-gt]: https://partnerportal.hafele.com/partner/distribuidora-hernandez-s-a-ciudad-de-guatemala/
[aeropost]: https://aeropost.com/GUA/es/casillero
[transexpress]: https://www.transexpress.com.gt/
