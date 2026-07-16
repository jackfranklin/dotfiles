import assert from "node:assert/strict";
import {
	existsSync,
	lstatSync,
	mkdtempSync,
	readFileSync,
	readlinkSync,
	rmSync,
	symlinkSync,
	writeFileSync,
} from "node:fs";
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
		assert.deepEqual(store.safe, []);
		assert.ok(store.prompt.includes("Bash(rm *)"));
		assert.ok(store.block.includes("Bash(sudo*)"));
	});

	it("reads existing data", () => {
		writeFileSync(path, JSON.stringify({ safe: ["Bash(git *)"], prompt: ["Bash(rm *)"], block: ["Bash(sudo*)"] }));
		const store = new PermissionStore(path);
		assert.deepEqual(store.safe, ["Bash(git *)"]);
		assert.deepEqual(store.prompt, ["Bash(rm *)"]);
		assert.deepEqual(store.block, ["Bash(sudo*)"]);
	});

	it("persists safe/prompt/block additions to disk", () => {
		const store = new PermissionStore(path);
		store.addSafe("Bash(git *)");
		store.addPrompt("Bash(rm *)");
		store.addBlock("Bash(sudo*)");

		const onDisk = JSON.parse(readFileSync(path, "utf8"));
		assert.ok(onDisk.safe.includes("Bash(git *)"));
		assert.ok(onDisk.prompt.includes("Bash(rm *)"));
		assert.ok(onDisk.block.includes("Bash(sudo*)"));
	});

	it("does not duplicate entries", () => {
		const store = new PermissionStore(path);
		store.addSafe("Bash(git *)");
		store.addSafe("Bash(git *)");
		assert.equal(store.safe.filter((e) => e === "Bash(git *)").length, 1);
	});

	it("hot-reloads external edits to the file", () => {
		const store = new PermissionStore(path);
		assert.ok(!store.safe.includes("Bash(ls*)"));

		writeFileSync(path, JSON.stringify({ safe: ["Bash(ls*)"], prompt: [], block: [] }));

		assert.deepEqual(store.safe, ["Bash(ls*)"]);
	});

	it("preserves a symlink when saving (writes through to the real file)", () => {
		const real = join(dir, "real-permissions.json");
		writeFileSync(real, JSON.stringify({ safe: [], prompt: [], block: [] }));
		symlinkSync(real, path);

		const store = new PermissionStore(path);
		store.addSafe("Bash(git *)");

		assert.ok(lstatSync(path).isSymbolicLink(), "path should remain a symlink");
		assert.equal(readlinkSync(path), real);
		const onDisk = JSON.parse(readFileSync(real, "utf8"));
		assert.ok(onDisk.safe.includes("Bash(git *)"));
	});

	it("tolerates malformed JSON without throwing", () => {
		writeFileSync(path, JSON.stringify({ safe: ["Bash(git *)"], prompt: [], block: [] }));
		const store = new PermissionStore(path);
		assert.deepEqual(store.safe, ["Bash(git *)"]);

		writeFileSync(path, "{ not valid json");
		assert.deepEqual(store.safe, ["Bash(git *)"]);
	});
});
