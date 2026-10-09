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

## Go60 and Iris layering

The Go60 layout (v7) was reworked to stop layer keys misfiring when a thumb is released late, e.g. typing "let's" sent Left Arrow instead of `s`. The fix is that the symbol layers hold only symbols, with every other key transparent, and navigation lives on its own layer.

What changed on the Go60:

- **Layer 2 (left thumb, symbols):** the arrow, Alt+arrow and Shift+arrow blocks on the left hand were removed and made transparent.
- **Layer 1 (right thumb, symbols):** Alt+1–4 and Ctrl+1–4 on the right hand were removed and made transparent.
- **New Nav layer**, held with the bottom-left key (previously the Magic key; Magic moved to the top-left):
  - Y U I O: Ctrl+1 2 3 4
  - H J K L: Left Down Up Right
  - N M , .: Alt+1 2 3 4
  - S: Alt, D: Ctrl (held as modifiers for Alt/Ctrl+arrows, because the pinky is busy holding Nav)
  - everything else transparent
- **Backspace** on the innermost left-hand bottom-row key became Alt+Backspace (delete word).

### Iris equivalent

The Iris mirrors this arrangement. Positions are given as keys, with the `iris_rev__7.layout.json` index in brackets.

- **Layer 3 is the Nav layer**, held with bottom-left `MO(3)` [18], which replaced the unused Hyper key. It has the same contents as the Go60 Nav layer. The VIA firmware allows only 4 layers, so layer 3 was repurposed rather than added. `LSA(KC_B)` [54] and `G(KC_D)` [55] remain on its right thumbs because Nav does not use those keys.
- **F-keys moved to layer 1's number row**, in the Go60 positions: F1–F5 on 1–5, F6–F10 on 6–0, F11 on PgUp [30] and F12 on PgDn [36]. The top-left key [0] was the F-key layer key.
- **Media keys moved to layer 2's right outer column**, in the Go60 positions: Play/Pause on PgUp [30], Vol+ on PgDn [36], Vol− on `:` [42] and Mute on Esc [48]. Layer 1's left outer column is `KC_TRNS`.
- **Layer 2** has no arrows; every left-hand key except the thumb keys is `KC_TRNS`.
- **Layer 1** has no Ctrl+1–4; every right-hand key except the F-keys and the thumb keys is `KC_TRNS`.
- **Alt+Backspace** is on the left thumb key [26], `A(KC_BSPC)`, which was Meh. Meh moved to the top-left key [0]. Both are `KC_TRNS` on every other layer, so they work on all layers.

Use `KC_TRNS`, not `KC_NO`, on the same hand as the thumb holding the layer. The symbol is typed with the other hand, and the next letter often comes from the thumb's hand; for example, in "let's" the `s` follows `'`. If the thumb is released late, `KC_TRNS` falls through to the base layer and types the letter instead of a layer key or nothing.
