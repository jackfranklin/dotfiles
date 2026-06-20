import type { Item, ItemSummary, Priority, Status } from "./models.ts";

export const LOCAL_JSON_NAME = ".later.json";

export function loadStore(path: string): Item[] {
  let content: string;
  try {
    content = Deno.readTextFileSync(path);
  } catch {
    return [];
  }
  if (content.includes("<<<<<<<")) {
    console.error(
      `Error: ${path} has git merge conflicts.\n` +
        `Resolve the conflict markers (<<<<<<<, =======, >>>>>>>) then re-run.`,
    );
    Deno.exit(1);
  }
  try {
    return JSON.parse(content) as Item[];
  } catch {
    return [];
  }
}

export function saveStore(path: string, items: Item[]): void {
  Deno.writeTextFileSync(path, JSON.stringify(items, null, 2) + "\n");
}

function nextId(items: Item[]): number {
  return items.length === 0 ? 1 : Math.max(...items.map((i) => i.id)) + 1;
}

export function addItem(
  items: Item[],
  item: Omit<Item, "id" | "created_at">,
): Item[] {
  return [
    ...items,
    { ...item, id: nextId(items), created_at: new Date().toISOString() },
  ];
}

export function listItems(
  items: Item[],
  project?: string,
  includeAll = false,
): ItemSummary[] {
  const priorityOrder = { high: 1, medium: 2, low: 3 } as const;
  return items
    .filter(
      (i) =>
        (includeAll || i.status !== "done") &&
        (!project || i.project === project),
    )
    .sort(
      (a, b) =>
        priorityOrder[a.priority] - priorityOrder[b.priority] ||
        a.created_at.localeCompare(b.created_at),
    )
    .map(({ id, project, title, priority, status, category }) => ({
      id,
      project,
      title,
      priority,
      status,
      category,
    }));
}

export function getItem(items: Item[], id: number): Item | null {
  return items.find((i) => i.id === id) ?? null;
}

export function setDone(items: Item[], id: number): Item[] {
  return items.map((i) =>
    i.id === id ? { ...i, status: "done" as Status } : i
  );
}

export function editItem(
  items: Item[],
  id: number,
  fields: {
    title?: string;
    detail?: string;
    priority?: Priority;
    status?: Status;
    category?: string;
  },
): Item[] {
  return items.map((i) => (i.id === id ? { ...i, ...fields } : i));
}

export function listProjects(items: Item[]): string[] {
  return [...new Set(items.map((i) => i.project))].sort();
}
