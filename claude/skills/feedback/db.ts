import { Database } from "@db/sqlite";
import type { Feedback, FeedbackSummary, Priority, Status } from "./models.ts";

const DB_PATH = new URL("./feedback.db", import.meta.url).pathname;

export function getDb(): Database {
  return new Database(DB_PATH);
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
  item: Omit<Feedback, "id" | "created_at">,
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
): FeedbackSummary[] {
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

  return db.prepare(sql).all<FeedbackSummary>(...params);
}

export function showFeedback(db: Database, id: number): Feedback | null {
  return (
    db.prepare("SELECT * FROM feedback WHERE id = ?").get<Feedback>(id) ?? null
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
