import assert from "node:assert/strict";
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, it } from "node:test";
import { PermissionStore } from "./store.ts";

describe("PermissionStore", () => {
	let dir: string;
	let path: string;

	beforeEach(() => {
		dir = mkdtempSync(join(tmpdir(), "pi-perms-"));
		path = join(dir, "permissions.json");
	});

	afterEach(() => {
		rmSync(dir, { recursive: true, force: true });
	});

	it("seeds defaults when the file does not exist", () => {
		const store = new PermissionStore(path);
		assert.ok(existsSync(path), "file should be created");
		assert.deepEqual(store.allow, ["Read(*)", "Write(*)", "Edit(*)"]);
		assert.deepEqual(store.deny, []);
	});

	it("reads existing data", () => {
		writeFileSync(path, JSON.stringify({ allow: ["Bash(git *)"], deny: ["Bash(sudo *)"] }));
		const store = new PermissionStore(path);
		assert.deepEqual(store.allow, ["Bash(git *)"]);
		assert.deepEqual(store.deny, ["Bash(sudo *)"]);
	});

	it("persists allow/deny additions to disk", () => {
		const store = new PermissionStore(path);
		store.addAllow("Bash(git *)");
		store.addDeny("Bash(rm -rf *)");

		const onDisk = JSON.parse(readFileSync(path, "utf8"));
		assert.ok(onDisk.allow.includes("Bash(git *)"));
		assert.ok(onDisk.deny.includes("Bash(rm -rf *)"));
	});

	it("does not duplicate entries", () => {
		const store = new PermissionStore(path);
		store.addAllow("Bash(git *)");
		store.addAllow("Bash(git *)");
		assert.equal(store.allow.filter((e) => e === "Bash(git *)").length, 1);
	});

	it("hot-reloads external edits to the file", () => {
		const store = new PermissionStore(path);
		assert.ok(!store.allow.includes("Bash(ls*)"));

		// Simulate a manual edit of the file after the store loaded it.
		writeFileSync(path, JSON.stringify({ allow: ["Bash(ls*)"], deny: [] }));

		assert.deepEqual(store.allow, ["Bash(ls*)"]);
	});

	it("tolerates malformed JSON without throwing", () => {
		writeFileSync(path, JSON.stringify({ allow: ["Bash(git *)"], deny: [] }));
		const store = new PermissionStore(path);
		assert.deepEqual(store.allow, ["Bash(git *)"]);

		writeFileSync(path, "{ not valid json");
		// Keeps the last good data rather than crashing.
		assert.deepEqual(store.allow, ["Bash(git *)"]);
	});
});
