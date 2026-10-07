# Keyboard layouts

`viewer/index.html` is an offline, read-only visual reference for the layouts in this directory. Open it directly in a browser; it does not make network requests or require a local server.

The browser receives embedded data from `viewer/layout-data.js`. This derived file is gitignored, so generate it before first opening the viewer and after changing a supported source layout:

```sh
make keyboard_layouts
```

## Current sources

- `corne-v4.vil` — Vial backup. This is the canonical Corne source; `corne-v4.json` is an older export retained for history.
- `iris_rev__7.layout.json` — VIA backup for the Iris Rev. 7.
- `Jack's Go60 layout.json` — Go60 Layout Editor export. This is the canonical Go60 source; regenerate the ZMK `.keymap` from the Layout Editor when needed.

Future keyboard profiles will add their source format and physical-layout mapping to `scripts/build-keyboard-layouts.mjs`.

## Iris is out of sync with the Go60

The Go60 layout (v7) was reworked to stop layer keys misfiring when a thumb is released late, e.g. typing "let's" sent Left Arrow instead of `s`. The fix is that the symbol layers hold only symbols, with every other key transparent, and navigation lives on its own layer. The Iris still has the old arrangement, so it has the same problem: on the Iris, a late thumb release after `'` sends Down instead of `s`.

What changed on the Go60:

- **Layer 2 (left thumb, symbols):** the arrow, Alt+arrow and Shift+arrow blocks on the left hand were removed and made transparent.
- **Layer 1 (right thumb, symbols):** Alt+1–4 and Ctrl+1–4 on the right hand were removed and made transparent.
- **New Nav layer**, held with the bottom-left key (previously the Magic key; Magic moved to the top-left):
  - Y U I O: Ctrl+1 2 3 4
  - H J K L: Left Down Up Right
  - N M , .: Alt+1 2 3 4
  - S: Alt, D: Ctrl (held as modifiers for Alt/Ctrl+arrows, because the pinky is busy holding Nav)
  - everything else transparent
- **Sticky Backspace (`&kt BSPC`)** became Alt+Backspace (delete word).

### To bring the Iris in line (not yet done)

Positions are given as keys, with the `iris_rev__7.layout.json` index in brackets.

1. **Find space for a Nav layer.** The VIA backup has 4 layers (0–3), and VIA firmware usually allows only 4. Either:
   - build QMK firmware with a higher `DYNAMIC_KEYMAP_LAYER_COUNT`, or
   - (preferred) do what the Go60 does and move the F-keys from layer 3 onto layer 1's number row, then use layer 3 as Nav. The top-left `MO(3)` [0] is then no longer needed for F-keys. Layer 3 also has `LSA(KC_B)` [54] and `G(KC_D)` [55]; find them a new home or drop them.
2. **Nav key:** change bottom-left `HYPR(KC_NO)` [18] to `MO(<nav layer>)`.
3. **Nav layer contents** (everything not listed is `KC_TRNS`):
   - Y [41] U [40] I [39] O [38]: `C(KC_1)` … `C(KC_4)`
   - H [47] J [46] K [45] L [44]: `KC_LEFT` `KC_DOWN` `KC_UP` `KC_RGHT`
   - N [53] M [52] , [51] . [50]: `A(KC_1)` … `A(KC_4)`
   - S [14]: `KC_LALT`, D [15]: `KC_LCTL`
4. **Layer 2:** set the left-hand arrow blocks to `KC_TRNS`: Alt+arrows on Q W E R [7–10], arrows on A S D F [13–16], Shift+arrows on Z X C V [19–22]. Use `KC_TRNS`, not `KC_NO`, so a late thumb release types the base letter instead of dropping it.
5. **Layer 1:** set the right-hand Ctrl+1–4 on N M , . [50–53] to `KC_TRNS`. The Iris has no Alt+1–4 on layer 1, so there is nothing else to remove. Consider changing the other right-hand `KC_NO` keys on layers 1 and 2 to `KC_TRNS` for the same reason.
6. **Alt+Backspace (optional):** the Iris has no sticky-Backspace key. If wanted, put `A(KC_BSPC)` on one of the spare `KC_NO` keys, e.g. [24] or [25].
