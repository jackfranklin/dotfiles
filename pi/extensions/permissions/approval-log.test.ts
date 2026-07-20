import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, it } from "node:test";
import { PermissionApprovalLog } from "./approval-log.ts";

describe("PermissionApprovalLog", () => {
	let dir: string;
	let path: string;

	beforeEach(() => {
		dir = mkdtempSync(join(tmpdir(), "pi-approval-log-"));
		path = join(dir, "permission-approvals.jsonl");
	});

	afterEach(() => {
		rmSync(dir, { recursive: true, force: true });
	});

	it("records an approval request and its decision in a private local log", () => {
		const log = new PermissionApprovalLog(path);
		const id = log.request({
			tool: "bash",
			cwd: "/project",
			subject: "rm important-file",
			rationale: 'This removes the obsolete tracked fixture required by the requested cleanup.',
			unmatchedSegments: ["rm important-file"],
			riskyRedirectTargets: [],
			reasons: [],
		});
		log.decision(id, "Allow once");

		const entries = readFileSync(path, "utf8")
			.trim()
			.split("\n")
			.map((line) => JSON.parse(line));
		assert.deepEqual(entries[0], {
			event: "approval-request",
			id,
			timestamp: entries[0].timestamp,
			tool: "bash",
			cwd: "/project",
			subject: "rm important-file",
			rationale: 'This removes the obsolete tracked fixture required by the requested cleanup.',
			unmatchedSegments: ["rm important-file"],
			riskyRedirectTargets: [],
			reasons: [],
		});
		assert.deepEqual(entries[1], {
			event: "approval-decision",
			id,
			timestamp: entries[1].timestamp,
			choice: "Allow once",
		});
		assert.equal(statSync(path).mode & 0o777, 0o600);
	});

	it("records a dismissed dialog as a decision", () => {
		const log = new PermissionApprovalLog(path);
		const id = log.request({
			tool: "bash",
			cwd: "/project",
			subject: "rm file",
			rationale: 'This removes the requested temporary file.',
			unmatchedSegments: ["rm file"],
			riskyRedirectTargets: [],
			reasons: [],
		});
		log.decision(id, undefined);

		const decision = JSON.parse(readFileSync(path, "utf8").trim().split("\n")[1]);
		assert.equal(decision.id, id);
		assert.equal(decision.choice, "Dismissed");
	});
});
