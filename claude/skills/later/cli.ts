#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-net --allow-ffi
import yargs, { type Argv, type ArgumentsCamelCase } from "yargs";
import {
  addItem,
  editItem,
  getItem,
  listItems,
  listProjects,
  LOCAL_JSON_NAME,
  loadStore,
  saveStore,
  setDone,
} from "./db.ts";
import type { Priority, Status } from "./models.ts";

const SKILL_DIR = new URL(".", import.meta.url).pathname.replace(/\/$/, "");

function resolveDir(raw: string): string {
  return raw.startsWith("/") ? raw : `${Deno.cwd()}/${raw}`;
}

function extractRawDir(args: string[]): string {
  const idx = args.indexOf("--dir");
  return idx !== -1 && idx + 1 < args.length ? args[idx + 1] : Deno.cwd();
}

function validateDir(dir: string, command: string): void {
  const home = Deno.env.get("HOME") ?? "";

  if (dir === home) {
    console.error(
      `Error: Running from your home directory — this is almost certainly wrong.\n` +
        `Pass --dir <absolute-path> to specify the project directory.\n` +
        `Example: later init --dir /home/jack/git/myproject`,
    );
    Deno.exit(1);
  }

  if (dir === SKILL_DIR || dir.startsWith(SKILL_DIR + "/")) {
    console.error(
      `Error: Running from the later skill directory — this is almost certainly wrong.\n` +
        `Pass --dir <absolute-path> to specify the project directory.\n` +
        `Example: later init --dir /home/jack/git/myproject`,
    );
    Deno.exit(1);
  }

  if (command === "init") return;

  if (command === "migrate") {
    try {
      Deno.statSync(`${dir}/.later.db`);
    } catch {
      console.error(
        `Error: No .later.db found in ${dir}.\n` +
          `The migrate command converts an existing .later.db to ${LOCAL_JSON_NAME}.`,
      );
      Deno.exit(1);
    }
    return;
  }

  try {
    Deno.statSync(`${dir}/${LOCAL_JSON_NAME}`);
  } catch {
    console.error(
      `Error: No ${LOCAL_JSON_NAME} found in ${dir}.\n` +
        `To create one: later init --dir ${dir}\n` +
        `Or pass --dir <absolute-path> to point to a different project.`,
    );
    Deno.exit(1);
  }
}

const dir = resolveDir(extractRawDir(Deno.args));
const command = Deno.args[0];
validateDir(dir, command);

const jsonPath = `${dir}/${LOCAL_JSON_NAME}`;

const PRIORITIES = ["low", "medium", "high"] as const;
const STATUSES = ["open", "in-progress", "blocked", "done"] as const;

interface AddArgv {
  project: string;
  title: string;
  detail?: string;
  priority: string;
  status: string;
  category?: string;
}

interface ListArgv {
  project?: string;
  all: boolean;
}

interface IdArgv {
  id: number;
}

interface EditArgv {
  id: number;
  title?: string;
  detail?: string;
  priority?: string;
  status?: string;
  category?: string;
}

await yargs(Deno.args)
  .scriptName("later")
  .strict()
  .option("dir", {
    type: "string",
    description: `Project directory containing ${LOCAL_JSON_NAME} (default: cwd)`,
    global: true,
  })
  .command(
    "init",
    `Create a ${LOCAL_JSON_NAME} in the project directory`,
    () => {},
    () => {
      try {
        Deno.statSync(jsonPath);
        console.error(`${LOCAL_JSON_NAME} already exists in ${dir}.`);
        Deno.exit(1);
      } catch {
        saveStore(jsonPath, []);
        console.log(`Created ${LOCAL_JSON_NAME} in ${dir}`);
        console.log(`Commit it to git to sync items across machines.`);
      }
    },
  )
  .command(
    "migrate",
    "Migrate a .later.db SQLite file to .later.json",
    () => {},
    async () => {
      const { Database } = await import("@db/sqlite");
      const db = new Database(`${dir}/.later.db`, { readonly: true });
      const rows = db
        .prepare("SELECT * FROM feedback ORDER BY id ASC")
        .all<{
          id: number;
          project: string;
          title: string;
          detail: string | null;
          priority: string;
          status: string;
          category: string | null;
          done: number;
          created_at: string;
        }>();
      db.close();

      const items = rows.map(({ done: _done, ...row }) => ({
        ...row,
        priority: row.priority as Priority,
        status: row.status as Status,
      }));

      saveStore(jsonPath, items);
      console.log(`Migrated ${items.length} item(s) to ${LOCAL_JSON_NAME}.`);
      console.log(
        `You can now delete .later.db and commit ${LOCAL_JSON_NAME}.`,
      );
    },
  )
  .command<AddArgv>(
    "add",
    "Add an item",
    (y: Argv): Argv<AddArgv> =>
      y
        .option("project", {
          alias: "p",
          type: "string",
          demandOption: true,
          description: "Project name",
        })
        .option("title", {
          alias: "t",
          type: "string",
          demandOption: true,
          description: "Short summary",
        })
        .option("detail", { alias: "d", type: "string", description: "Full detail" })
        .option("priority", {
          choices: PRIORITIES,
          default: "medium" as Priority,
          description: "Priority level",
        })
        .option("status", {
          choices: STATUSES,
          default: "open" as Status,
          description: "Status",
        })
        .option("category", {
          alias: "c",
          type: "string",
          description: "Category tag (e.g. bug, ux, performance)",
        }) as unknown as Argv<AddArgv>,
    (argv: ArgumentsCamelCase<AddArgv>) => {
      const items = loadStore(jsonPath);
      saveStore(
        jsonPath,
        addItem(items, {
          project: argv.project,
          title: argv.title,
          detail: argv.detail ?? null,
          priority: argv.priority as Priority,
          status: argv.status as Status,
          category: argv.category ?? null,
        }),
      );
      console.log(`Added: ${argv.title}`);
    },
  )
  .command<ListArgv>(
    "list",
    "List items (open/in-progress/blocked by default)",
    (y: Argv): Argv<ListArgv> =>
      y
        .option("project", { alias: "p", type: "string", description: "Filter by project" })
        .option("all", {
          alias: "a",
          type: "boolean",
          default: false,
          description: "Include done items",
        }) as unknown as Argv<ListArgv>,
    (argv: ArgumentsCamelCase<ListArgv>) => {
      const items = listItems(loadStore(jsonPath), argv.project, argv.all);
      if (items.length === 0) {
        console.log("No items found.");
        return;
      }
      for (const item of items) {
        const statusBadge = item.status !== "open" ? ` [${item.status}]` : "";
        const categoryBadge = item.category ? ` {${item.category}}` : "";
        const projectBadge = argv.project ? "" : ` [${item.project}]`;
        console.log(
          `[${item.id}] (${item.priority})${statusBadge}${projectBadge}${categoryBadge} ${item.title}`,
        );
      }
    },
  )
  .command<IdArgv>(
    "show <id>",
    "Show full detail for an item",
    (y: Argv): Argv<IdArgv> =>
      y.positional("id", {
        type: "number",
        demandOption: true,
      }) as unknown as Argv<IdArgv>,
    (argv: ArgumentsCamelCase<IdArgv>) => {
      const item = getItem(loadStore(jsonPath), argv.id);
      if (!item) {
        console.error(`No item with id ${argv.id}`);
        Deno.exit(1);
      }
      console.log(`[${item.id}] ${item.title}`);
      console.log(`Project:  ${item.project}`);
      console.log(`Priority: ${item.priority}`);
      console.log(`Status:   ${item.status}`);
      if (item.category) console.log(`Category: ${item.category}`);
      console.log(`Created:  ${item.created_at}`);
      if (item.detail) {
        console.log(`---`);
        console.log(item.detail);
      }
    },
  )
  .command<IdArgv>(
    "done <id>",
    "Mark an item as done",
    (y: Argv): Argv<IdArgv> =>
      y.positional("id", {
        type: "number",
        demandOption: true,
      }) as unknown as Argv<IdArgv>,
    (argv: ArgumentsCamelCase<IdArgv>) => {
      saveStore(jsonPath, setDone(loadStore(jsonPath), argv.id));
      console.log(`Marked ${argv.id} as done.`);
    },
  )
  .command<EditArgv>(
    "edit <id>",
    "Edit an item",
    (y: Argv): Argv<EditArgv> =>
      y
        .positional("id", { type: "number", demandOption: true })
        .option("title", { alias: "t", type: "string" })
        .option("detail", { alias: "d", type: "string" })
        .option("priority", { choices: PRIORITIES })
        .option("status", { choices: STATUSES })
        .option("category", {
          alias: "c",
          type: "string",
        }) as unknown as Argv<EditArgv>,
    (argv: ArgumentsCamelCase<EditArgv>) => {
      saveStore(
        jsonPath,
        editItem(loadStore(jsonPath), argv.id, {
          title: argv.title,
          detail: argv.detail,
          priority: argv.priority as Priority | undefined,
          status: argv.status as Status | undefined,
          category: argv.category,
        }),
      );
      console.log(`Updated ${argv.id}.`);
    },
  )
  .command(
    "projects",
    "List all projects",
    () => {},
    () => {
      const projects = listProjects(loadStore(jsonPath));
      if (projects.length === 0) {
        console.log("No projects yet.");
        return;
      }
      for (const p of projects) {
        console.log(p);
      }
    },
  )
  .command(
    "archive",
    "Remove done items from .later.json (appends them to .later.archive.json)",
    () => {},
    () => {
      const items = loadStore(jsonPath);
      const done = items.filter((i) => i.status === "done");
      if (done.length === 0) {
        console.log("No done items to archive.");
        return;
      }
      const archivePath = `${dir}/.later.archive.json`;
      saveStore(archivePath, [...loadStore(archivePath), ...done]);
      saveStore(jsonPath, items.filter((i) => i.status !== "done"));
      console.log(`Archived ${done.length} item(s) to .later.archive.json.`);
    },
  )
  .demandCommand(1, "Please specify a command.")
  .help()
  .parseAsync();
