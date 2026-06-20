export type Priority = "low" | "medium" | "high";
export type Status = "open" | "in-progress" | "blocked" | "done";

export interface Item {
  id: number;
  project: string;
  title: string;
  detail: string | null;
  priority: Priority;
  status: Status;
  category: string | null;
  created_at: string;
}

export type ItemSummary = Pick<
  Item,
  "id" | "project" | "title" | "priority" | "status" | "category"
>;
