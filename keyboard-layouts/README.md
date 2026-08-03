# Keyboard layouts

`viewer/index.html` is an offline, read-only visual reference for the layouts in this directory. Open it directly in a browser; it does not make network requests or require a local server.

The browser receives embedded data from `viewer/layout-data.js`. This derived file is gitignored, so generate it before first opening the viewer and after changing a supported source layout:

```sh
make keyboard_layouts
```

## Current sources

- `corne-v4.vil` — Vial backup. This is the canonical Corne source; `corne-v4.json` is an older export retained for history.
- `iris_rev__7.layout.json` — VIA backup for the Iris Rev. 7.
- `Jack's Go60 layout.json` — Go60 Layout Editor export used to generate the viewer data; its accompanying `.keymap` is the generated ZMK source linked from the viewer.

Future keyboard profiles will add their source format and physical-layout mapping to `scripts/build-keyboard-layouts.mjs`.
