#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-net --allow-ffi
import yargs from "yargs";
import {
  addFeedback,
  editFeedback,
  getDb,
  initSchema,
  listFeedback,
  listProjects,
  markDone,
  showFeedback,
} from "./db.ts";
import type { Priority } from "./models.ts";

const db = getDb();
initSchema(db);

const PRIORITIES = ["low", "medium", "high"] as const;

yargs(Deno.args)
  .scriptName("feedback")
  .strict()
  .command(
    "add",
    "Add a feedback item",
    (y) =>
      y
        .option("project", { alias: "p", type: "string", demandOption: true, description: "Project name" })
        .option("title", { alias: "t", type: "string", demandOption: true, description: "Short summary" })
        .option("detail", { alias: "d", type: "string", description: "Full detail" })
        .option("priority", { choices: PRIORITIES, default: "medium" as Priority, description: "Priority level" }),
    (argv) => {
      addFeedback(db, {
        project: argv.project,
        title: argv.title,
        detail: argv.detail ?? null,
        priority: argv.priority as Priority,
        done: false,
      });
      console.log(`Added: ${argv.title}`);
    },
  )
  .command(
    "list",
    "List feedback items (open only by default)",
    (y) =>
      y
        .option("project", { alias: "p", type: "string", description: "Filter by project" })
        .option("all", { alias: "a", type: "boolean", default: false, description: "Include done items" }),
    (argv) => {
      const items = listFeedback(db, argv.project, argv.all);
      if (items.length === 0) {
        console.log("No items found.");
        return;
      }
      for (const item of items) {
        console.log(`[${item.id}] (${item.priority}) [${item.project}] ${item.title}`);
      }
    },
  )
  .command(
    "show <id>",
    "Show full detail for an item",
    (y) => y.positional("id", { type: "number", demandOption: true }),
    (argv) => {
      const item = showFeedback(db, argv.id as number);
      if (!item) {
        console.error(`No item with id ${argv.id}`);
        Deno.exit(1);
      }
      console.log(`[${item.id}] ${item.title}`);
      console.log(`Project:  ${item.project}`);
      console.log(`Priority: ${item.priority}`);
      console.log(`Status:   ${item.done ? "done" : "open"}`);
      console.log(`Created:  ${item.created_at}`);
      if (item.detail) {
        console.log(`---`);
        console.log(item.detail);
      }
    },
  )
  .command(
    "done <id>",
    "Mark an item as done",
    (y) => y.positional("id", { type: "number", demandOption: true }),
    (argv) => {
      markDone(db, argv.id as number);
      console.log(`Marked ${argv.id} as done.`);
    },
  )
  .command(
    "edit <id>",
    "Edit an item",
    (y) =>
      y
        .positional("id", { type: "number", demandOption: true })
        .option("title", { alias: "t", type: "string" })
        .option("detail", { alias: "d", type: "string" })
        .option("priority", { choices: PRIORITIES }),
    (argv) => {
      editFeedback(db, argv.id as number, {
        title: argv.title,
        detail: argv.detail,
        priority: argv.priority as Priority | undefined,
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
