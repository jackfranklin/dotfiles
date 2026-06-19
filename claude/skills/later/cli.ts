#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-net --allow-ffi
import yargs, { type Argv, type ArgumentsCamelCase } from "yargs";
import {
  addFeedback,
  editFeedback,
  getDb,
  initSchema,
  listFeedback,
  listProjects,
  LOCAL_DB_NAME,
  markDone,
  showFeedback,
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

function validateDir(dir: string, isInit: boolean): void {
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

  if (!isInit) {
    try {
      Deno.statSync(`${dir}/${LOCAL_DB_NAME}`);
    } catch {
      console.error(
        `Error: No ${LOCAL_DB_NAME} found in ${dir}.\n` +
        `To create one: later init --dir ${dir}\n` +
        `Or pass --dir <absolute-path> to point to a different project.`,
      );
      Deno.exit(1);
    }
  }
}

const dir = resolveDir(extractRawDir(Deno.args));
const isInit = Deno.args[0] === "init";
validateDir(dir, isInit);

const dbPath = `${dir}/${LOCAL_DB_NAME}`;
const db = getDb(dbPath);
initSchema(db);

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

yargs(Deno.args)
  .scriptName("later")
  .strict()
  .option("dir", {
    type: "string",
    description: "Project directory containing .later.db (default: cwd)",
    global: true,
  })
  .command(
    "init",
    `Create a local ${LOCAL_DB_NAME} in the project directory`,
    () => {},
    () => {
      const localPath = `${dir}/${LOCAL_DB_NAME}`;
      try {
        Deno.statSync(localPath);
        console.error(`${LOCAL_DB_NAME} already exists in ${dir}.`);
        Deno.exit(1);
      } catch {
        const localDb = getDb(localPath);
        initSchema(localDb);
        localDb.close();
        console.log(`Created ${LOCAL_DB_NAME} in ${dir}`);
        console.log(`Commit it to git to sync items across machines.`);
      }
    },
  )
  .command<AddArgv>(
    "add",
    "Add an item",
    (y: Argv): Argv<AddArgv> =>
      y
        .option("project", { alias: "p", type: "string", demandOption: true, description: "Project name" })
        .option("title", { alias: "t", type: "string", demandOption: true, description: "Short summary" })
        .option("detail", { alias: "d", type: "string", description: "Full detail" })
        .option("priority", { choices: PRIORITIES, default: "medium" as Priority, description: "Priority level" })
        .option("status", { choices: STATUSES, default: "open" as Status, description: "Status" })
        .option("category", { alias: "c", type: "string", description: "Category tag (e.g. bug, ux, performance)" }) as unknown as Argv<AddArgv>,
    (argv: ArgumentsCamelCase<AddArgv>) => {
      addFeedback(db, {
        project: argv.project,
        title: argv.title,
        detail: argv.detail ?? null,
        priority: argv.priority as Priority,
        status: argv.status as Status,
        category: argv.category ?? null,
        done: false,
      });
      console.log(`Added: ${argv.title}`);
    },
  )
  .command<ListArgv>(
    "list",
    "List items (open/in-progress/blocked by default)",
    (y: Argv): Argv<ListArgv> =>
      y
        .option("project", { alias: "p", type: "string", description: "Filter by project" })
        .option("all", { alias: "a", type: "boolean", default: false, description: "Include done items" }) as unknown as Argv<ListArgv>,
    (argv: ArgumentsCamelCase<ListArgv>) => {
      const items = listFeedback(db, argv.project, argv.all);
      if (items.length === 0) {
        console.log("No items found.");
        return;
      }
      for (const item of items) {
        const statusBadge = item.status !== "open" ? ` [${item.status}]` : "";
        const categoryBadge = item.category ? ` {${item.category}}` : "";
        const projectBadge = argv.project ? "" : ` [${item.project}]`;
        console.log(`[${item.id}] (${item.priority})${statusBadge}${projectBadge}${categoryBadge} ${item.title}`);
      }
    },
  )
  .command<IdArgv>(
    "show <id>",
    "Show full detail for an item",
    (y: Argv): Argv<IdArgv> => y.positional("id", { type: "number", demandOption: true }) as unknown as Argv<IdArgv>,
    (argv: ArgumentsCamelCase<IdArgv>) => {
      const item = showFeedback(db, argv.id);
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
    (y: Argv): Argv<IdArgv> => y.positional("id", { type: "number", demandOption: true }) as unknown as Argv<IdArgv>,
    (argv: ArgumentsCamelCase<IdArgv>) => {
      markDone(db, argv.id);
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
        .option("category", { alias: "c", type: "string" }) as unknown as Argv<EditArgv>,
    (argv: ArgumentsCamelCase<EditArgv>) => {
      editFeedback(db, argv.id, {
        title: argv.title,
        detail: argv.detail,
        priority: argv.priority as Priority | undefined,
        status: argv.status as Status | undefined,
        category: argv.category,
      });
      console.log(`Updated ${argv.id}.`);
    },
  )
  .command(
    "projects",
    "List all projects",
    () => {},
    () => {
      const projects = listProjects(db);
      if (projects.length === 0) {
        console.log("No projects yet.");
        return;
      }
      for (const p of projects) {
        console.log(p);
      }
    },
  )
  .demandCommand(1, "Please specify a command.")
  .help()
  .parse();
