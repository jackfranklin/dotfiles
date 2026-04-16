---
name: new-lit-pwa
description: Scaffold a new Vite + LitElement + IDB PWA app hosted on Netlify with a private GitHub repo. Use when the user wants to create a new personal web app following this stack.
disable-model-invocation: true
user-invocable: true
---

You are scaffolding a new personal PWA app. These apps follow a strict set of conventions:
- Vite build tool
- LitElement web components (TypeScript)
- Data stored locally in IndexedDB via the `idb` library
- PWA wrapper via `vite-plugin-pwa` (installable on phone)
- Hosted on Netlify
- A "Export backup" button that downloads all data as a JSON file
- Private GitHub repo created with the `gh` CLI
- Dark theme with CSS custom properties

## Step 1: Gather information

If `$ARGUMENTS` is not empty, parse it as: `<app-name> "<Display Name>" "<Short Name>" "<description>" "<theme-color>"`

Otherwise, ask the user for:
1. **app-name** — kebab-case, used for directory name, package name, and GitHub repo name
2. **Display Name** — full title shown in browser tab and manifest (e.g. "Train Controller")
3. **Short Name** — short name for home screen icon label (e.g. "Trains")
4. **Description** — one sentence describing what the app does
5. **Theme color** — hex color for PWA theme/background (default: `#1a1a2e`)
6. **Data model** — what are the main things this app stores? Describe the fields/types briefly.

Confirm all values with the user before proceeding.

## Step 2: Create project

Create the project at `~/git/<app-name>/`.

### `package.json`
```json
{
  "name": "<app-name>",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "idb": "^8.0.0",
    "lit": "^3.0.0"
  },
  "devDependencies": {
    "typescript": "^5.4.0",
    "vite": "^5.0.0",
    "vite-plugin-pwa": "^0.20.0"
  }
}
```

### `tsconfig.json`
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "useDefineForClassFields": false,
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "strict": true,
    "experimentalDecorators": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"]
}
```

### `vite.config.ts`
Fill in Display Name, Short Name, Description, and theme color from user input.
```typescript
import { defineConfig } from 'vite';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['icons/*.png'],
      manifest: {
        name: '<Display Name>',
        short_name: '<Short Name>',
        description: '<Description>',
        theme_color: '<theme-color>',
        background_color: '<theme-color>',
        display: 'standalone',
        orientation: 'portrait',
        start_url: '/',
        icons: [
          { src: 'icons/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: 'icons/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg}'],
        runtimeCaching: [],
      },
    }),
  ],
});
```

### `netlify.toml`
```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### `index.html`
Fill in Display Name, Short Name, and theme color.
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
    <meta name="apple-mobile-web-app-title" content="<Short Name>" />
    <meta name="theme-color" content="<theme-color>" />
    <title><Display Name></title>
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
    <link rel="stylesheet" href="/src/styles/tokens.css" />
    <script type="module" src="/src/main.ts"></script>
  </head>
  <body>
    <app-root></app-root>
  </body>
</html>
```

### `.gitignore`
```
node_modules
dist
.netlify
```

### `src/main.ts`
```typescript
import './components/app-root.js';
```

### `src/styles/tokens.css`
Use the user's theme color as `--color-bg` and `--color-surface`. Derive a slightly lighter shade for `--color-surface-raised`. Use a contrasting accent color. Include the full design token set from the reference app:
- Color tokens: `--color-bg`, `--color-surface`, `--color-surface-raised`, `--color-accent`, `--color-accent-dim`, `--color-text`, `--color-text-muted`, `--color-border`, `--color-success`, `--color-warning`, `--color-danger`
- Spacing scale: `--space-xs` (4px) through `--space-xl` (32px)
- Border radius: `--radius-sm` (6px), `--radius-md` (12px), `--radius-lg` (20px)
- Typography: system font stack, size scale from 0.85rem to 1.4rem
- Safe area vars using `env(safe-area-inset-*)` for mobile notch support
- `--tap-target: 44px` minimum touch target

### `src/types.ts`
Define TypeScript interfaces based on the user's described data model. Each record should have:
- `id: string` (UUID)
- `createdAt: string` (ISO date)
- `updatedAt: string` (ISO date)
- All user-specified fields with appropriate types

### `src/services/db.ts`
IDB service using the `idb` library. Database name: `<app-name>`. Version 1.
- One object store per main entity (keyPath: `id`)
- Add indexes for any fields the user will search/filter on
- Functions: `getAll<Entity>()`, `save<Entity>(item)`, `get<Entity>(id)`, `delete<Entity>(id)`
- `exportData()` — serializes all stores to JSON and triggers a file download via a temporary `<a>` element
- `importData(json)` — parses JSON and bulk-writes all records

### `src/components/app-root.ts`
LitElement root component. Should include:
- A header with the app title and an "Export" button that calls `exportData()`
- A FAB or primary button to add a new item
- The main list/grid view
- Modal pattern for add/edit forms (show/hide based on state property)
- Load all data on `connectedCallback`

### Additional components
Generate sensible LitElement components for the data model — at minimum:
- A list component showing all items
- A card/row component for a single item
- A form component (modal) for add/edit

Keep components focused. Use `@property()` for public props, `@state()` for internal state. Emit custom events (`this.dispatchEvent(new CustomEvent(...))`) to communicate up to the root.

All components should:
- Use the CSS tokens from `tokens.css` via `:host { }` and standard CSS custom property references
- Have `static styles` defined with `css\`...\`` (imported from `lit`)
- Be mobile-first, touch-friendly (44px tap targets)

## Step 3: Create placeholder icons

In `public/icons/`, create placeholder files named `icon-192.png` and `icon-512.png`. Also create placeholder `favicon.ico`, `favicon-16x16.png`, `favicon-32x32.png`, and `apple-touch-icon.png` in `public/`.

Tell the user: "You'll need to replace the placeholder icons in `public/` with real ones before deploying."

## Step 4: Install dependencies

Run `npm install` in the project directory.

## Step 5: Initialize git and create GitHub repo

Run these commands in order:
```bash
cd ~/git/<app-name>
git init
git add .
git commit -m "Initial scaffold"
gh repo create <app-name> --private --source=. --remote=origin --push
```

## Step 6: Final instructions for the user

Tell the user:
1. **Run locally:** `cd ~/git/<app-name> && npm run dev`
2. **Deploy to Netlify:** Go to app.netlify.com → "Add new site" → "Import an existing project" → connect the GitHub repo `<app-name>`. Build command is `npm run build`, publish directory is `dist`.
3. **Replace icons** in `public/` with real PNG files at the correct sizes.
4. **Customize the data model** in `src/types.ts` and `src/services/db.ts` if the generated schema needs adjusting.
