import { appendFileSync, chmodSync, existsSync, mkdirSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { randomUUID } from "node:crypto";

export const PERMISSION_APPROVALS_PATH = join(
	homedir(),
	".pi",
	"agent",
	"permission-approvals.jsonl",
);

export interface ApprovalRequest {
	tool: string;
	cwd: string;
	subject: string;
	unmatchedSegments: string[];
	riskyRedirectTargets: string[];
	reasons: string[];
}

interface ApprovalRequestEntry extends ApprovalRequest {
	event: "approval-request";
	id: string;
	timestamp: string;
}

interface ApprovalDecisionEntry {
	event: "approval-decision";
	id: string;
	timestamp: string;
	choice: string;
}

/**
 * Append-only local audit log for interactive approval dialogs. Request and
 * decision entries share an id, so an interrupted dialog still leaves evidence
 * that it was shown. This is audit-only: a failure to write must not weaken or
 * prevent the permission gate from operating.
 */
export class PermissionApprovalLog {
	private readonly path: string;

	constructor(path: string = PERMISSION_APPROVALS_PATH) {
		this.path = path;
	}

	request(request: ApprovalRequest): string {
		const id = randomUUID();
		this.append({ event: "approval-request", id, timestamp: new Date().toISOString(), ...request });
		return id;
	}

	decision(id: string, choice: string | undefined): void {
		this.append({
			event: "approval-decision",
			id,
			timestamp: new Date().toISOString(),
			choice: choice ?? "Dismissed",
		});
	}

	private append(entry: ApprovalRequestEntry | ApprovalDecisionEntry): void {
		try {
			mkdirSync(dirname(this.path), { recursive: true });
			appendFileSync(this.path, `${JSON.stringify(entry)}\n`, { encoding: "utf8", mode: 0o600 });
			if (existsSync(this.path)) chmodSync(this.path, 0o600);
		} catch {
			// Audit logging is best-effort and must never change approval behaviour.
		}
	}
}
