import { readFile, stat, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { stdin as input, stdout as output } from 'node:process';
import { createInterface } from 'node:readline/promises';

const root = resolve(import.meta.dirname, '..');

async function readJson(path) {
  return JSON.parse(await readFile(resolve(root, path), 'utf8'));
}

function formatIrisLayout(iris) {
  const macros = JSON.stringify(iris.macros).replaceAll(',', ', ');
  const layers = JSON.stringify(iris.layers)
    .replaceAll('[[', '[\n    [\n      ')
    .replaceAll('],[', '\n    ],\n    [\n      ')
    .replaceAll(']]', '\n    ]\n  ]')
    .replaceAll('","', '",\n      "');
  const encoders = iris.encoders
    .map(
      (layer) =>
        `    [\n${layer
          .map((pair) => `      ${JSON.stringify(pair).replaceAll(',', ', ')}`)
          .join(',\n')}\n    ]`,
    )
    .join(',\n');

  return `{\n  "name": ${JSON.stringify(iris.name)},\n  "vendorProductId": ${iris.vendorProductId},\n  "macros": ${macros},\n  "layers": ${layers},\n  "encoders": [\n${encoders}\n  ]\n}\n`;
}

function diffLayers(fromLayers, toLayers) {
  const changes = [];
  const layerCount = Math.max(fromLayers.length, toLayers.length);
  for (let layerIndex = 0; layerIndex < layerCount; layerIndex += 1) {
    const sourceLayer = fromLayers[layerIndex] || [];
    const targetLayer = toLayers[layerIndex] || [];
    const keyCount = Math.max(sourceLayer.length, targetLayer.length);
    for (let keyIndex = 0; keyIndex < keyCount; keyIndex += 1) {
      const nextKey = sourceLayer[keyIndex];
      const prevKey = targetLayer[keyIndex];
      if (nextKey !== prevKey) {
        changes.push(
          `  Layer ${layerIndex} [${keyIndex}]: ${prevKey ?? '(none)'} -> ${nextKey ?? '(none)'}`,
        );
      }
    }
  }
  return changes;
}

async function syncIrisLayouts() {
  const iris7Path = 'keyboard-layouts/iris_rev__7.layout.json';
  const iris8Path = 'keyboard-layouts/iris_rev__8.layout.json';

  const [iris7, iris8, iris7Stat, iris8Stat] = await Promise.all([
    readJson(iris7Path),
    readJson(iris8Path),
    stat(resolve(root, iris7Path)),
    stat(resolve(root, iris8Path)),
  ]);

  if (JSON.stringify(iris7.layers) === JSON.stringify(iris8.layers)) {
    return iris7;
  }

  const iris7IsNewer = iris7Stat.mtimeMs >= iris8Stat.mtimeMs;
  const source = iris7IsNewer
    ? { path: iris7Path, data: iris7, mtime: iris7Stat.mtime }
    : { path: iris8Path, data: iris8, mtime: iris8Stat.mtime };
  const target = iris7IsNewer
    ? { path: iris8Path, data: iris8, mtime: iris8Stat.mtime }
    : { path: iris7Path, data: iris7, mtime: iris7Stat.mtime };

  const changes = diffLayers(source.data.layers, target.data.layers);
  console.log(
    `Iris layouts differ. Newer file is ${source.path} (${source.mtime.toISOString()}):\n` +
      `Syncing layers ${source.path} -> ${target.path} (${target.mtime.toISOString()}):\n` +
      `${changes.join('\n')}`,
  );

  const rl = createInterface({ input, output });
  try {
    const answer = await rl.question(
      `Update ${target.path} with these layer changes? [y/N] `,
    );
    if (!/^y(es)?$/i.test(answer.trim())) {
      console.log('Aborted without modifying layout files.');
      process.exit(1);
    }
  } finally {
    rl.close();
  }

  target.data.layers = source.data.layers;
  await writeFile(resolve(root, target.path), formatIrisLayout(target.data));
  console.log(`Updated ${target.path}.`);
  return iris7;
}

const zmkKeycodes = {
  BSLH: 'KC_BSLS',
  BSPC: 'KC_BSPC',
  C_MUTE: 'KC_MUTE',
  C_PP: 'KC_MPLY',
  C_VOL_DN: 'KC_VOLD',
  C_VOL_UP: 'KC_VOLU',
  COMMA: 'KC_COMM',
  DOT: 'KC_DOT',
  EQUAL: 'KC_EQL',
  FSLH: 'KC_SLSH',
  GRAVE: 'KC_GRV',
  LALT: 'KC_LALT',
  LBKT: 'KC_LBRC',
  LCTRL: 'KC_LCTRL',
  LGUI: 'KC_LGUI',
  LSHFT: 'KC_LSFT',
  MINUS: 'KC_MINS',
  PG_DN: 'KC_PGDN',
  PG_UP: 'KC_PGUP',
  RBKT: 'KC_RBRC',
  RET: 'KC_ENT',
  SEMI: 'KC_SCLN',
  SPACE: 'KC_SPC',
  SQT: 'KC_QUOT',
};

const zmkModifiers = { LA: 'A', LC: 'C', LS: 'S' };

function zmkKeycode(value) {
  if (typeof value !== 'string') return String(value);
  if (/^N\d$/.test(value)) return `KC_${value.slice(1)}`;
  return zmkKeycodes[value] || value;
}

function zmkParameter(parameter) {
  const { value, params = [] } = parameter;
  const name = zmkModifiers[value] || value;
  return params.length === 0
    ? zmkKeycode(name)
    : `${name}(${params.map(zmkParameter).join(',')})`;
}

function zmkBindingToKeycode(binding) {
  const { value, params = [] } = binding;
  if (value === '&trans') return 'KC_TRNS';
  if (value === '&none') return 'KC_NO';
  if (value === '&kp') return zmkParameter(params[0]);
  if (value === '&lt') return `LT(${params.map(zmkParameter).join(',')})`;
  if (value === '&mo') return `MO(${params[0].value})`;
  if (value === '&to') return `TO(${params[0].value})`;

  const behavior = value.slice(1).toUpperCase();
  return params.length === 0
    ? behavior
    : `${behavior}(${params.map(zmkParameter).join(',')})`;
}

const [corne, iris, go60] = await Promise.all([
  readJson('keyboard-layouts/corne-v4.vil'),
  syncIrisLayouts(),
  readJson("keyboard-layouts/Jack's Go60 layout.json"),
]);

const layouts = [
  {
    id: 'corne-v4',
    name: 'Corne v4',
    firmware: 'Vial / QMK',
    source: '../corne-v4.vil',
    sourceLabel: 'Vial backup',
    geometry: 'corne',
    layers: corne.layout,
  },
  {
    id: 'iris-rev7',
    name: iris.name,
    firmware: 'VIA / QMK',
    source: '../iris_rev__7.layout.json',
    sourceLabel: 'VIA backup',
    geometry: 'iris',
    layers: iris.layers,
  },
  {
    id: 'go60',
    name: go60.title,
    firmware: 'ZMK',
    source: "../Jack's Go60 layout.json",
    sourceLabel: 'Layout Editor export',
    geometry: 'go60',
    layerNames: go60.layer_names,
    layers: go60.layers.map((layer) => layer.map(zmkBindingToKeycode)),
  },
];

const viewerOutput = `// Generated by scripts/build-keyboard-layouts.mjs; do not edit.\nwindow.KEYBOARD_LAYOUTS = ${JSON.stringify(
  layouts,
  null,
  2,
)};\n`;

await writeFile(
  resolve(root, 'keyboard-layouts/viewer/layout-data.js'),
  viewerOutput,
);
