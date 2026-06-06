import { Database } from "@db/sqlite";
import type { Item, ItemSummary, Priority, Status } from "./models.ts";

const GLOBAL_DB_PATH = new URL("./feedback.db", import.meta.url).pathname;
const OLD_DB_PATH = new URL("../feedback/feedback.db", import.meta.url).pathname;
export const LOCAL_DB_NAME = ".later.db";

export function resolveDbPath(): string {
  const localPath = `${Deno.cwd()}/${LOCAL_DB_NAME}`;
  try {
    Deno.statSync(localPath);
    return localPath;
  } catch {
    return GLOBAL_DB_PATH;
  }
}

export function getDb(dbPath: string): Database {
  if (dbPath === GLOBAL_DB_PATH) {
    try {
      Deno.statSync(dbPath);
    } catch {
      try {
        Deno.statSync(OLD_DB_PATH);
        Deno.renameSync(OLD_DB_PATH, dbPath);
        console.error(`Note: migrated database from skills/feedback/feedback.db to skills/later/feedback.db`);
      } catch {
        // no old DB either — fresh install, let SQLite create it
      }
    }
  }
  return new Database(dbPath);
}

export function initSchema(db: Database): void {
  db.exec(`
    CREATE TABLE IF NOT EXISTS feedback (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      project     TEXT    NOT NULL,
      title       TEXT    NOT NULL,
      detail      TEXT,
      priority    TEXT    NOT NULL DEFAULT 'medium',
      status      TEXT    NOT NULL DEFAULT 'open',
      category    TEXT,
      done        INTEGER NOT NULL DEFAULT 0,
      created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
    )
  `);

  const cols = db
    .prepare("PRAGMA table_info(feedback)")
    .all<{ name: string }>()
    .map((c) => c.name);

  if (!cols.includes("status")) {
    db.exec("ALTER TABLE feedback ADD COLUMN status TEXT NOT NULL DEFAULT 'open'");
    db.exec("UPDATE feedback SET status = 'done' WHERE done = 1");
  }
  if (!cols.includes("category")) {
    db.exec("ALTER TABLE feedback ADD COLUMN category TEXT");
  }
}

export function addFeedback(
  db: Database,
  item: Omit<Item, "id" | "created_at">,
): void {
  db.prepare(
    "INSERT INTO feedback (project, title, detail, priority, status, category, done) VALUES (?, ?, ?, ?, ?, ?, ?)",
  ).run(
    item.project,
    item.title,
    item.detail ?? null,
    item.priority,
    item.status,
    item.category ?? null,
    item.status === "done" ? 1 : 0,
  );
}

export function listFeedback(
  db: Database,
  project?: string,
  includeAll = false,
): ItemSummary[] {
  const conditions: string[] = [];
  const params: unknown[] = [];

  if (!includeAll) {
    conditions.push("status != 'done'");
  }
  if (project) {
    conditions.push("project = ?");
    params.push(project);
  }

  const where = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const sql = `SELECT id, project, title, priority, status, category FROM feedback ${where} ORDER BY
    CASE priority WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
    created_at ASC`;

  return db.prepare(sql).all<ItemSummary>(...params);
}

export function showFeedback(db: Database, id: number): Item | null {
  return (
    db.prepare("SELECT * FROM feedback WHERE id = ?").get<Item>(id) ?? null
  );
}

export function markDone(db: Database, id: number): void {
  db.prepare("UPDATE feedback SET status = 'done', done = 1 WHERE id = ?").run(id);
}

export function editFeedback(
  db: Database,
  id: number,
  fields: { title?: string; detail?: string; priority?: Priority; status?: Status; category?: string },
): void {
  const updates: string[] = [];
  const params: unknown[] = [];

  if (fields.title !== undefined) {
    updates.push("title = ?");
    params.push(fields.title);
  }
  if (fields.detail !== undefined) {
    updates.push("detail = ?");
    params.push(fields.detail);
  }
  if (fields.priority !== undefined) {
    updates.push("priority = ?");
    params.push(fields.priority);
  }
  if (fields.status !== undefined) {
    updates.push("status = ?");
    params.push(fields.status);
    updates.push("done = ?");
    params.push(fields.status === "done" ? 1 : 0);
  }
  if (fields.category !== undefined) {
    updates.push("category = ?");
    params.push(fields.category);
  }

  if (updates.length === 0) return;

  params.push(id);
  db.prepare(`UPDATE feedback SET ${updates.join(", ")} WHERE id = ?`).run(
    ...params,
  );
}

export function listProjects(db: Database): string[] {
  return db
    .prepare("SELECT DISTINCT project FROM feedback ORDER BY project ASC")
    .all<{ project: string }>()
    .map((r) => r.project);
}

export function migrateProjectToLocal(localDbPath: string, project: string): number {
  const count = new Database(GLOBAL_DB_PATH)
    .prepare("SELECT COUNT(*) as n FROM feedback WHERE project = ?")
    .get<{ n: number }>(project)?.n ?? 0;
  if (count === 0) return 0;

  const globalDb = new Database(GLOBAL_DB_PATH);
  globalDb.exec(`ATTACH DATABASE '${localDbPath}' AS local`);
  globalDb.exec("BEGIN");
  globalDb.prepare("INSERT INTO local.feedback SELECT * FROM feedback WHERE project = ?").run(project);
  globalDb.prepare("DELETE FROM feedback WHERE project = ?").run(project);
  globalDb.exec("COMMIT");
  globalDb.close();

  return count;
}
