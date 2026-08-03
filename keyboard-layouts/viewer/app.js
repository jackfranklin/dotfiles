const requestedLayoutId = new URLSearchParams(window.location.search).get(
  'layout',
);
const requestedLayout = window.KEYBOARD_LAYOUTS.find(
  (layout) => layout.id === requestedLayoutId,
);
const requestedLayer = Number.parseInt(
  new URLSearchParams(window.location.search).get('layer') || '0',
  10,
);

const state = {
  layoutId: requestedLayout?.id || window.KEYBOARD_LAYOUTS[0].id,
  layerIndex:
    requestedLayout &&
    requestedLayer >= 0 &&
    requestedLayer < requestedLayout.layers.length
      ? requestedLayer
      : 0,
};

const $ = (selector) => document.querySelector(selector);
const svgNamespace = 'http://www.w3.org/2000/svg';

const aliases = {
  KC_LALT: 'Alt',
  KC_RALT: 'R Alt',
  KC_LCTL: 'Ctrl',
  KC_LCTRL: 'Ctrl',
  KC_RCTL: 'R Ctrl',
  KC_LSFT: 'Shift',
  KC_LSHIFT: 'Shift',
  KC_RSFT: 'R Shift',
  KC_RSHIFT: 'R Shift',
  KC_LGUI: 'Gui',
  KC_RGUI: 'R Gui',
  KC_BSPC: 'Bksp',
  KC_BSPACE: 'Bksp',
  KC_ENT: 'Enter',
  KC_ENTER: 'Enter',
  KC_SPC: 'Space',
  KC_SPACE: 'Space',
  KC_ESC: 'Esc',
  KC_ESCAPE: 'Esc',
  KC_TAB: 'Tab',
  KC_PGUP: 'PgUp',
  KC_PGDN: 'PgDn',
  KC_PGDOWN: 'PgDn',
  KC_LEFT: '←',
  KC_RGHT: '→',
  KC_RIGHT: '→',
  KC_UP: '↑',
  KC_DOWN: '↓',
  KC_COMM: ',',
  KC_COMMA: ',',
  KC_DOT: '.',
  KC_SCLN: ';',
  KC_SCOLON: ';',
  KC_QUOT: "'",
  KC_QUOTE: "'",
  KC_SLSH: '/',
  KC_SLASH: '/',
  KC_BSLS: '\\',
  KC_BSLASH: '\\',
  KC_MINS: '-',
  KC_MINUS: '-',
  KC_EQL: '=',
  KC_EQUAL: '=',
  KC_LBRC: '[',
  KC_LBRACKET: '[',
  KC_RBRC: ']',
  KC_RBRACKET: ']',
  KC_GRV: '`',
  KC_GRAVE: '`',
  KC_MPLY: 'Play',
  KC_MUTE: 'Mute',
  KC_VOLU: 'Vol +',
  KC_VOLD: 'Vol −',
  KC_NO: '',
  KC_TRNS: '▽',
};

function activeLayout() {
  return window.KEYBOARD_LAYOUTS.find((layout) => layout.id === state.layoutId);
}

function makeSvgElement(name, attributes = {}) {
  const element = document.createElementNS(svgNamespace, name);
  for (const [key, value] of Object.entries(attributes)) {
    element.setAttribute(key, value);
  }
  return element;
}

function cleanKeycode(value) {
  if (aliases[value] !== undefined) return aliases[value];
  if (/^KC_[A-Z0-9]$/.test(value)) return value.slice(3);
  if (/^KC_F\d+$/.test(value)) return value.slice(3);
  return value.replace(/^KC_/, '').replaceAll('_', ' ');
}

function describeKey(value) {
  if (value === -1 || value === null || value === undefined) {
    return { kind: 'absent', tap: '' };
  }

  if (value === 'KC_NO') return { kind: 'disabled', tap: '' };
  if (value === 'KC_TRNS') return { kind: 'transparent', tap: '▽' };

  const vialLayerTap = value.match(/^LT(\d+)\((.+)\)$/);
  const qmkLayerTap = value.match(/^LT\((\d+),(.+)\)$/);
  if (vialLayerTap || qmkLayerTap) {
    const [, layer, keycode] = vialLayerTap || qmkLayerTap;
    return {
      kind: 'layer',
      tap: cleanKeycode(keycode),
      hold: `L${layer}`,
      behavior: 'layerTap',
      explanation: `Tap sends ${cleanKeycode(keycode)}; holding temporarily activates Layer ${layer}.`,
    };
  }

  const momentaryLayer = value.match(/^MO\((\d+)\)$/);
  if (momentaryLayer) {
    return {
      kind: 'layer',
      tap: 'Hold',
      hold: `L${momentaryLayer[1]}`,
      behavior: 'momentaryLayer',
      explanation: `Holding temporarily activates Layer ${momentaryLayer[1]}.`,
    };
  }

  const toggleLayer = value.match(/^TG\((\d+)\)$/);
  if (toggleLayer) {
    return {
      kind: 'layer',
      tap: 'Toggle',
      hold: `L${toggleLayer[1]}`,
      behavior: 'toggleLayer',
      explanation: `Pressing toggles Layer ${toggleLayer[1]} on or off.`,
    };
  }

  const tapToggleLayer = value.match(/^TT\((\d+)\)$/);
  if (tapToggleLayer) {
    return {
      kind: 'layer',
      tap: 'Tap toggle',
      hold: `L${tapToggleLayer[1]}`,
      behavior: 'tapToggleLayer',
      explanation: `Holding temporarily activates Layer ${tapToggleLayer[1]}; repeated taps toggle it.`,
    };
  }

  const oneShotLayer = value.match(/^OSL\((\d+)\)$/);
  if (oneShotLayer) {
    return {
      kind: 'layer',
      tap: 'One shot',
      hold: `L${oneShotLayer[1]}`,
      behavior: 'oneShotLayer',
      explanation: `The next keypress uses Layer ${oneShotLayer[1]}, then returns to the current layer.`,
    };
  }

  const modifier = value.match(/^(L?SFT|L?CTL|L?ALT|L?GUI|S|C|A|G)\((.+)\)$/);
  if (modifier) {
    const modifierNames = {
      S: 'Shift',
      LSFT: 'Shift',
      C: 'Ctrl',
      LCTL: 'Ctrl',
      A: 'Alt',
      LALT: 'Alt',
      G: 'Gui',
      LGUI: 'Gui',
    };
    const modifierName = modifierNames[modifier[1]] || modifier[1];
    return {
      kind: 'normal',
      tap: cleanKeycode(modifier[2]),
      hold: `${modifierName} +`,
      behavior: 'modifierChord',
      explanation: `Sends ${modifierName} + ${cleanKeycode(modifier[2])} as a modified keypress; it is not a tap/hold key.`,
    };
  }

  const modTap = value.match(/^MT\((.+),(.+)\)$/);
  if (modTap) {
    return {
      kind: 'normal',
      tap: cleanKeycode(modTap[2].trim()),
      hold: 'Mod-tap',
      behavior: 'modTap',
      explanation:
        'Tap sends the upper action; holding applies the modifiers encoded by the keymap.',
    };
  }

  const behavior = value.match(/^([A-Z_]+)\((.*)\)$/);
  if (behavior) {
    const arguments_ = behavior[2].split(',');
    return {
      kind: 'normal',
      tap: cleanKeycode(arguments_.at(-1).trim()),
      hold: behavior[1],
      explanation: `Custom behavior: ${value}`,
    };
  }

  return { kind: 'normal', tap: cleanKeycode(value) };
}

function cornePositions(layer) {
  const positions = [];
  const rowOffsets = [12, 6, 0, 0];

  layer.forEach((row, rowIndex) => {
    const isRight = rowIndex >= 4;
    const visualRow = rowIndex % 4;
    // Firmware layouts list both halves from their outer edge toward the split.
    const halfStart = isRight ? 893 : 50;
    const direction = isRight ? -1 : 1;

    row.forEach((value, column) => {
      if (value === -1) return;
      const thumb = visualRow === 3;
      positions.push({
        value,
        x: halfStart + (thumb ? (column - 2) * 58 : column * 58) * direction,
        y: thumb
          ? 255 + Math.abs(column - 4) * 9
          : 45 + visualRow * 62 + rowOffsets[visualRow],
      });
    });
  });

  return { width: 1035, height: 335, positions };
}

function irisPositions(layer) {
  const positions = [];
  const keyWidth = 57;
  const keyHeight = 56;

  layer.forEach((value, index) => {
    const right = index >= 30;
    const localIndex = index % 30;
    const row = Math.floor(localIndex / 6);
    const column = localIndex % 6;
    const renderedColumn = right ? 5 - column : column;
    const innerColumnDistance = Math.abs(column - 2.5);

    positions.push({
      value,
      // VIA orders the right-half keys from its outer edge toward the split.
      x: (right ? 545 : 55) + renderedColumn * keyWidth,
      y: 36 + row * keyHeight + innerColumnDistance * 4,
    });
  });

  return { width: 1000, height: 355, positions };
}

function geometryFor(layout) {
  const layer = layout.layers[state.layerIndex];
  return layout.geometry === 'corne'
    ? cornePositions(layer)
    : irisPositions(layer);
}

function drawKey(svg, position) {
  const description = describeKey(position.value);
  if (description.kind === 'absent') return;

  const key = makeSvgElement('g', {
    class: `key ${description.kind}`,
    transform: `translate(${position.x} ${position.y})`,
  });
  const title = makeSvgElement('title');
  title.textContent = description.explanation
    ? `${position.value}\n${description.explanation}`
    : String(position.value);
  key.append(title);
  key.append(makeSvgElement('rect', { width: 52, height: 52, rx: 7 }));

  if (description.tap) {
    const tap = makeSvgElement('text', {
      class: 'tap',
      x: 26,
      y: description.hold ? 27 : 31,
    });
    tap.textContent = description.tap;
    key.append(tap);
  }

  if (description.hold) {
    const hold = makeSvgElement('text', { class: 'hold', x: 26, y: 42 });
    hold.textContent = description.hold;
    key.append(hold);
  }

  svg.append(key);
}

function renderDiagram(layout) {
  const diagram = $('#keyboard-diagram');
  const geometry = geometryFor(layout);
  const svg = makeSvgElement('svg', {
    viewBox: `0 0 ${geometry.width} ${geometry.height}`,
    width: geometry.width,
    height: geometry.height,
    role: 'img',
    'aria-label': `${layout.name}, layer ${state.layerIndex}`,
  });

  geometry.positions.forEach((position) => drawKey(svg, position));
  diagram.replaceChildren(svg);
}

const behaviorGuides = {
  layerTap: {
    title: 'Tap / hold layer',
    text: 'The upper label is sent on tap. “L#” underneath means holding the key temporarily activates that layer.',
  },
  momentaryLayer: {
    title: 'Momentary layer',
    text: '“Hold L#” activates that layer only while the key remains held.',
  },
  toggleLayer: {
    title: 'Toggle layer',
    text: '“Toggle L#” switches that layer on or off when pressed; it does not need to be held.',
  },
  tapToggleLayer: {
    title: 'Tap-toggle layer',
    text: 'Holding temporarily activates the layer; repeated taps toggle it on or off.',
  },
  oneShotLayer: {
    title: 'One-shot layer',
    text: 'The next keypress uses the shown layer, then the keyboard returns to its current layer.',
  },
  modifierChord: {
    title: 'Modifier chord',
    text: 'A lower Shift, Ctrl, Alt, or Gui label means the key sends that modifier with the upper label. It is not a tap/hold key.',
  },
  modTap: {
    title: 'Mod-tap',
    text: 'The upper label is sent on tap; holding applies the modifiers configured by the keymap.',
  },
};

function renderBehaviorGuide(layout) {
  const container = $('#key-behaviors');
  const list = $('#key-behavior-list');
  const behaviors = new Set(
    geometryFor(layout)
      .positions.map((position) => describeKey(position.value).behavior)
      .filter(Boolean),
  );

  if (behaviors.size === 0) {
    container.hidden = true;
    return;
  }

  container.hidden = false;
  list.replaceChildren();
  behaviors.forEach((behavior) => {
    const guide = behaviorGuides[behavior];
    if (!guide) return;

    const explainer = document.createElement('article');
    explainer.className = 'behavior-explainer';
    const title = document.createElement('strong');
    title.textContent = guide.title;
    const text = document.createElement('p');
    text.textContent = guide.text;
    explainer.append(title, text);
    list.append(explainer);
  });
}

function renderKeyboardList() {
  const list = $('#keyboard-list');
  list.replaceChildren();

  window.KEYBOARD_LAYOUTS.forEach((layout) => {
    const button = document.createElement('button');
    button.className = 'keyboard-button';
    button.textContent = layout.name;
    button.setAttribute('aria-current', String(layout.id === state.layoutId));
    button.addEventListener('click', () => {
      state.layoutId = layout.id;
      state.layerIndex = 0;
      render();
    });
    list.append(button);
  });
}

function renderLayerTabs(layout) {
  const tabs = $('#layer-tabs');
  tabs.replaceChildren();

  layout.layers.forEach((_, index) => {
    const button = document.createElement('button');
    button.className = 'layer-button';
    button.textContent = index === 0 ? 'Base' : `Layer ${index}`;
    button.setAttribute('aria-pressed', String(index === state.layerIndex));
    button.addEventListener('click', () => {
      state.layerIndex = index;
      render();
    });
    tabs.append(button);
  });
}

function render() {
  const layout = activeLayout();
  $('#layout-name').textContent = layout.name;
  $('#firmware').textContent = layout.firmware;
  $('#source-link').href = layout.source;
  $('#source-link').textContent = `View ${layout.sourceLabel}`;
  renderKeyboardList();
  renderLayerTabs(layout);
  renderDiagram(layout);
  renderBehaviorGuide(layout);
}

render();
