export type Priority = "low" | "medium" | "high";

export interface Feedback {
  id: number;
  project: string;
  title: string;
  detail: string | null;
  priority: Priority;
  done: boolean;
  created_at: string;
}

export type FeedbackSummary = Pick<
  Feedback,
  "id" | "project" | "title" | "priority"
>;
