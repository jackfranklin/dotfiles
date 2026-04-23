---
name: new-deno-app
description: Scaffold a new Deno 2 + Hono + Deno KV + Eta + HTMX app with password auth and PWA support. Use when the user wants to create a new personal web app following this stack.
disable-model-invocation: true
user-invocable: true
---

You are scaffolding a new personal web app. These apps follow a strict set of conventions:
- Deno 2 runtime, no build step — TypeScript runs natively
- Hono for routing (from JSR: `jsr:@hono/hono@^4`)
- Deno KV for the database (built-in to Deno)
- Eta for server-side HTML templates (from JSR: `jsr:@eta-dev/eta@^3`)
- HTMX 2 for frontend interactivity (CDN, no npm)
- PicoCSS classless for styling (CDN, no npm)
- Single shared `APP_PASSWORD` env var for auth — SHA-256 hash in a session cookie
- PWA: `manifest.json` + minimal pass-through service worker
- Deployed to Deno Deploy via GitHub push to `main`

## Step 1: Gather information

Always ask the user for all of the following interactively — do not attempt to parse `$ARGUMENTS`:

1. **app-name** — kebab-case, used for directory name and GitHub repo name
2. **Display Name** — full title shown in browser tab and manifest (e.g. "Book Tracker")
3. **Short name** — ≤12 characters, shown on Android home screen under the icon (e.g. "Books")
4. **Description** — one sentence describing what the app does
5. **Theme color** — hex color for PWA theme/background (default: `#ffffff`)
6. **Emoji** — single emoji used as the app logo in the header (default: `📋`)
7. **Data model** — what are the main things this app stores? Describe the entity name(s) and their fields briefly.

Confirm all values with the user before proceeding.

## Step 2: Determine project directory

Check whether the current working directory is empty (contains no files or subdirectories, ignoring dotfiles like `.git`).

- **If the current directory is empty:** use it as the project root. All files will be created here.
- **If the current directory is not empty:** tell the user: "The current directory isn't empty. Please create and switch to a new empty directory for the project, then run `/new-deno-app` again." Stop here — do not proceed.

## Step 3: Create project

Create all files in the project root determined in Step 2. All files below use the exact patterns from the reference app.

### `deno.json`

```json
{
  "imports": {
    "hono": "jsr:@hono/hono@^4",
    "hono/cookie": "jsr:@hono/hono@^4/cookie",
    "hono/deno": "jsr:@hono/hono@^4/deno",
    "@eta-dev/eta": "jsr:@eta-dev/eta@^3",
    "@std/assert": "jsr:@std/assert@^1"
  },
  "tasks": {
    "dev": "deno run --watch --allow-net --allow-env --allow-read --unstable-kv main.ts",
    "start": "deno run --allow-net --allow-env --allow-read --unstable-kv main.ts",
    "test": "DENO_TLS_CA_STORE=system deno test --allow-env --unstable-kv",
    "fmt": "deno fmt",
    "lint": "deno lint",
    "check": "deno fmt --check && deno lint && deno check main.ts src/**/*.ts"
  },
  "fmt": {
    "lineWidth": 100,
    "semiColons": false,
    "singleQuote": false
  },
  "lint": {
    "rules": {
      "exclude": ["no-explicit-any"]
    }
  }
}
```

### `src/auth.ts`

This is the exact auth pattern. Copy it verbatim — only the dev default password can be changed.

```typescript
import type { Context, Next } from "hono"
import { getCookie, setCookie } from "hono/cookie"

async function hashPassword(password: string): Promise<string> {
  const data = new TextEncoder().encode(password)
  const buf = await crypto.subtle.digest("SHA-256", data)
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("")
}

export function getSessionToken(): Promise<string> {
  return hashPassword(Deno.env.get("APP_PASSWORD") ?? "changeme")
}

export function verifyPassword(submitted: string): boolean {
  const expected = Deno.env.get("APP_PASSWORD") ?? "changeme"
  return submitted === expected
}

export async function setSessionCookie(c: Context): Promise<void> {
  const token = await getSessionToken()
  const isProd = Deno.env.get("DENO_DEPLOYMENT_ID") !== undefined
  setCookie(c, "session", token, {
    httpOnly: true,
    sameSite: "Strict",
    secure: isProd,
    path: "/",
    maxAge: 60 * 60 * 24 * 30,
  })
}

export async function authMiddleware(c: Context, next: Next) {
  if (c.req.path === "/login") {
    return next()
  }

  const session = getCookie(c, "session")
  const expected = await getSessionToken()

  if (session !== expected) {
    if (c.req.header("HX-Request")) {
      c.header("HX-Redirect", "/login")
      return c.text("", 401)
    }
    return c.redirect("/login")
  }

  return next()
}
```

### `src/db.ts`

Generate this based on the user's described data model. The KV singleton **must** store a `Promise<Deno.Kv>` (not the resolved instance) to prevent races when concurrent calls arrive before the first open resolves. Always export `closeKv()` for tests.

Template — replace `Item` / `["items", id]` with the actual entities:

```typescript
import type { Item } from "./types.ts"

let _kv: Promise<Deno.Kv> | null = null

function kv(): Promise<Deno.Kv> {
  if (!_kv) _kv = Deno.openKv()
  return _kv
}

export async function getItem(id: string): Promise<Item | null> {
  const db = await kv()
  return (await db.get<Item>(["items", id])).value
}

export async function listItems(): Promise<Item[]> {
  const db = await kv()
  const items: Item[] = []
  for await (const entry of db.list<Item>({ prefix: ["items"] })) {
    items.push(entry.value)
  }
  return items.sort((a, b) => a.name.localeCompare(b.name))
}

export async function saveItem(item: Item): Promise<void> {
  const db = await kv()
  await db.set(["items", item.id], item)
}

export async function deleteItem(id: string): Promise<void> {
  const db = await kv()
  await db.delete(["items", id])
}

export function closeKv(): void {
  _kv?.then((db) => db.close())
  _kv = null
}
```

### `src/types.ts`

Define TypeScript interfaces based on the user's data model. Every entity must have:
- `id: string` — use `crypto.randomUUID()` when creating
- `createdAt: string` — ISO date string

### `src/views/eta.ts`

```typescript
import { Eta } from "@eta-dev/eta"

const isProd = Deno.env.get("DENO_DEPLOYMENT_ID") !== undefined
export const deploymentId = Deno.env.get("DENO_DEPLOY_BUILD_ID") ?? "dev"

// Resolve template directory relative to this file so it works on Deno Deploy
const templatesDir = new URL("../templates", import.meta.url).pathname

export const eta = new Eta({
  views: templatesDir,
  cache: isProd,
})
```

### `src/templates/layout.eta`

Fill in Display Name, emoji, short_name, and theme color. Keep all PWA meta tags.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= it.title %> – <Display Name></title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.classless.min.css">
  <link rel="stylesheet" href="/static/styles.css">
  <link rel="manifest" href="/static/manifest.json">
  <link rel="apple-touch-icon" href="/static/apple-touch-icon.png">
  <link rel="icon" href="/static/favicon.ico">
  <meta name="theme-color" content="<theme-color>">
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-title" content="<Display Name>">
  <script src="https://cdn.jsdelivr.net/npm/htmx.org@2.0.4/dist/htmx.min.js"></script>
  <script src="/static/app.js" defer></script>
</head>
<body>
  <header>
    <nav>
      <a class="brand" href="/"><emoji> <Display Name></a>
    </nav>
  </header>
  <main>
    <%~ it.body %>
  </main>
  <footer>
    <small>Build: <%= it.deploymentId %></small>
  </footer>
</body>
</html>
```

If the app has multiple sections, add nav links inside `<ul>` in the `<nav>`. Use `it.active` to mark the current section with `class="active"`.

### `src/templates/login.eta`

Fill in emoji and Display Name.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><Display Name></title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.classless.min.css">
  <link rel="stylesheet" href="/static/styles.css">
</head>
<body>
  <main>
    <div class="login-wrap">
      <h1><emoji></h1>
      <h2><Display Name></h2>
      <p>Enter the password to continue.</p>
      <form method="POST" action="/login">
        <input
          type="password"
          name="password"
          placeholder="Password"
          autocomplete="current-password"
          autofocus
          required>
        <button type="submit">Enter</button>
        <% if (it.error) { %>
          <p class="login-error">Incorrect password. Try again.</p>
        <% } %>
      </form>
    </div>
  </main>
</body>
</html>
```

### `src/templates/index.eta`

Generate a sensible main page template for the app's primary entity. Use HTMX attributes (`hx-get`, `hx-post`, `hx-delete`, `hx-target`, `hx-swap`) for dynamic interactions. Keep it simple — a list view and a form to add new items.

### `static/manifest.json`

```json
{
  "name": "<Display Name>",
  "short_name": "<Short name>",
  "start_url": "/",
  "display": "standalone",
  "background_color": "<theme-color>",
  "theme_color": "<theme-color>",
  "icons": [
    { "src": "/static/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/static/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

### `static/sw.js`

```javascript
// Minimal service worker — required for PWA install prompt on Chrome/Android.
// No caching: all requests go to the network (app requires auth anyway).
self.addEventListener("fetch", (e) => e.respondWith(fetch(e.request)))
```

### `static/styles.css`

```css
.login-wrap {
  max-width: 360px;
  margin: 4rem auto;
  text-align: center;
}

.login-error {
  color: var(--pico-color-red-500);
}
```

Add any additional app-specific styles here. Keep it minimal — PicoCSS handles most things.

### `static/app.js`

```javascript
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/static/sw.js")
}
```

Add any additional client-side JS below the service worker registration.

### `main.ts`

Wire up the Hono router. Follow this exact pattern for route organization:

```typescript
import { Hono } from "hono"
import { setCookie } from "hono/cookie"
import { serveStatic } from "hono/deno"
import { authMiddleware, setSessionCookie, verifyPassword } from "./src/auth.ts"
import { deploymentId, eta } from "./src/views/eta.ts"
// import your db functions and view helpers here

const app = new Hono()

// ── Static files ───────────────────────────────────────────────────────────

app.use("/static/*", serveStatic({ root: "./" }))

// ── Auth ───────────────────────────────────────────────────────────────────

app.get("/login", async (c) => {
  const error = c.req.query("error")
  return c.html(await eta.renderAsync("login", { error: !!error }))
})

app.post("/login", async (c) => {
  const body = await c.req.formData()
  const password = body.get("password")?.toString() ?? ""
  if (!verifyPassword(password)) {
    return c.redirect("/login?error=1")
  }
  await setSessionCookie(c)
  return c.redirect("/")
})

app.get("/logout", (c) => c.redirect("/login"))

app.post("/logout", (c) => {
  setCookie(c, "session", "", { maxAge: 0, path: "/" })
  return c.redirect("/login")
})

// ── All other routes require auth ──────────────────────────────────────────

app.use("/*", authMiddleware)

app.get("/", async (c) => {
  // render main page
  const body = await eta.renderAsync("index", { /* data */ })
  return c.html(
    await eta.renderAsync("layout", { title: "Home", active: "home", body, deploymentId }),
  )
})

// add CRUD API routes for each entity here

// ── Start ──────────────────────────────────────────────────────────────────

Deno.serve(app.fetch)
```

For HTMX partial responses: check `c.req.header("HX-Request")` and return only the fragment HTML, not the full layout.

### `.gitignore`

```
.env
*.db
```

### `CLAUDE.md`

Generate a CLAUDE.md tailored to this app using this template:

```markdown
# CLAUDE.md

## Commands

\`\`\`bash
deno task dev     # Start dev server with file watching
deno task test    # Run all tests
deno task fmt     # Format TypeScript files
deno task lint    # Lint TypeScript files
deno task check   # fmt check + lint + type check (run before committing)
\`\`\`

Formatting rules (from \`deno.json\`): 100-char line width, no semicolons, no single quotes enforced.
The \`no-explicit-any\` lint rule is disabled.

## Testing

Test files live alongside source files as \`src/*_test.ts\`. Run with \`deno task test\`.

**SSL certificates:** \`DENO_TLS_CA_STORE=system\` is set automatically by \`deno task test\` so Deno
uses the OS cert store for JSR imports.

**KV in tests:** \`src/db.ts\` exports \`closeKv()\` — call it in \`afterEach\` to release the KV
handle so Deno's leak sanitizer stays happy.

## Deployment

Pushing to \`main\` on GitHub automatically deploys to Deno Deploy.

## Architecture

**Stack:** Deno 2 + Hono + Deno KV + Eta + HTMX 2 + PicoCSS. No build step.

**Entry point:** \`main.ts\` — Hono router and all route handlers.

**Auth:** Single \`APP_PASSWORD\` env var. SHA-256 hash stored in session cookie. Dev default: \`changeme\`.

### KV Schema

\`\`\`
<describe the KV keys for each entity>
\`\`\`
```

## Step 4: Create placeholder icon files

Create empty placeholder files for:
- `static/icon-192.png`
- `static/icon-512.png`
- `static/apple-touch-icon.png`
- `static/favicon.ico`

Tell the user: "You'll need to replace the placeholder icons in `static/` with real ones before installing as a PWA."

## Step 5: Initialize git and create GitHub repo

Run these commands in order:

```bash
git init
git add .
git commit -m "Initial scaffold"
gh repo create <app-name> --private --source=. --remote=origin --push
```

## Step 6: Final instructions

Tell the user:
1. **Run locally:** `deno task dev` — opens on `http://localhost:8000`
2. **Dev password:** `changeme` (set `APP_PASSWORD` env var for production)
3. **Deploy to Deno Deploy:** Go to dash.deno.com → "New Project" → connect the GitHub repo `<app-name>`. Set the `APP_PASSWORD` env var in project settings.
4. **Replace icons** in `static/` with real PNG/ICO files at the correct sizes.
5. **Data model** is in `src/types.ts` and `src/db.ts` — adjust as needed.
