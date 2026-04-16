export type Priority = "low" | "medium" | "high";
export type Status = "open" | "in-progress" | "blocked" | "done";

export interface Feedback {
  id: number;
  project: string;
  title: string;
  detail: string | null;
  priority: Priority;
  status: Status;
  category: string | null;
  done: boolean;
  created_at: string;
}

export type FeedbackSummary = Pick<
  Feedback,
  "id" | "project" | "title" | "priority" | "status" | "category"
>;
