import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { globMatches, globToRegExp } from "./glob.ts";
import { normalizeEntry } from "./index.ts";
import { decide, splitCommand, suggestPattern } from "./matcher.ts";

describe("globToRegExp / globMatches", () => {
	it("matches * as any run of characters", () => {
		assert.ok(globMatches("git *", "git status"));
		assert.ok(globMatches("git *", "git push origin main"));
		assert.ok(globMatches("ls*", "ls"));
		assert.ok(globMatches("ls*", "ls -la"));
	});

	it("anchors the pattern (no partial matches)", () => {
		assert.ok(!globMatches("git *", "sudo git status"));
		assert.ok(!globMatches("git", "git status"));
	});

	it("matches ? as exactly one character", () => {
		assert.ok(globMatches("ca?", "cat"));
		assert.ok(!globMatches("ca?", "ca"));
		assert.ok(!globMatches("ca?", "cats"));
	});

	it("treats regex metacharacters literally", () => {
		assert.ok(globMatches("a.b(c)", "a.b(c)"));
		assert.ok(!globMatches("a.b(c)", "axb(c)"));
		assert.equal(globToRegExp("a+b").source, "^a\\+b$");
	});
});

describe("splitCommand", () => {
	it("splits on shell control operators", () => {
		assert.deepEqual(splitCommand("a && b || c ; d | e & f"), ["a", "b", "c", "d", "e", "f"]);
	});

	it("splits on newlines and trims", () => {
		assert.deepEqual(splitCommand("  git status \n npm test "), ["git status", "npm test"]);
	});

	it("drops empty segments", () => {
		assert.deepEqual(splitCommand("git status &&"), ["git status"]);
		assert.deepEqual(splitCommand(""), []);
	});
});

describe("decide", () => {
	const allow = ["Read(*)", "Write(*)", "Edit(*)", "Bash(git *)", "Bash(ls*)"];
	const deny = ["Bash(rm -rf *)", "Bash(sudo *)"];

	it("allows a single matching bash command", () => {
		assert.equal(decide("bash", "git status", allow, deny), "allow");
		assert.equal(decide("bash", "ls -la", allow, deny), "allow");
	});

	it("allows only when every chained segment is allowed", () => {
		assert.equal(decide("bash", "git status && git push", allow, deny), "allow");
		assert.equal(decide("bash", "git status && npm test", allow, deny), "prompt");
	});

	it("denies when any segment matches a deny glob (deny beats allow)", () => {
		assert.equal(decide("bash", "git status && rm -rf /", allow, deny), "deny");
		assert.equal(decide("bash", "sudo apt update", allow, deny), "deny");
	});

	it("prompts for unlisted commands", () => {
		assert.equal(decide("bash", "npm install", allow, deny), "prompt");
	});

	it("matches file tools against the path subject", () => {
		assert.equal(decide("read", "/etc/hosts", allow, deny), "allow");
		assert.equal(decide("write", "/tmp/x", allow, deny), "allow");
		assert.equal(decide("edit", "/home/jack/foo.ts", allow, deny), "allow");
	});

	it("respects tool-scoped denials", () => {
		const wallow = ["Write(*)"];
		const wdeny = ["Write(/etc/*)"];
		assert.equal(decide("write", "/tmp/x", wallow, wdeny), "allow");
		assert.equal(decide("write", "/etc/passwd", wallow, wdeny), "deny");
	});

	it("passes through ungated tools", () => {
		assert.equal(decide("some_custom_tool", "anything", allow, deny), "allow");
	});

	it("prompts on an empty command", () => {
		assert.equal(decide("bash", "   ", allow, deny), "prompt");
	});
});

describe("suggestPattern", () => {
	it("suggests a first-word glob for bash", () => {
		assert.equal(suggestPattern("bash", "git push origin main"), "Bash(git *)");
		assert.equal(suggestPattern("bash", "npm run build && npm test"), "Bash(npm *)");
	});

	it("suggests the exact path for file tools", () => {
		assert.equal(suggestPattern("write", "/tmp/x"), "Write(/tmp/x)");
		assert.equal(suggestPattern("read", "/etc/hosts"), "Read(/etc/hosts)");
	});
});

describe("normalizeEntry", () => {
	it("keeps a well-formed Tool(glob) entry as-is", () => {
		assert.equal(normalizeEntry("Bash(ls *)", "bash"), "Bash(ls *)");
		assert.equal(normalizeEntry("  Write(/tmp/*)  ", "write"), "Write(/tmp/*)");
	});

	it("wraps a bare glob with the current tool label", () => {
		assert.equal(normalizeEntry("ls *", "bash"), "Bash(ls *)");
		assert.equal(normalizeEntry("/tmp/*", "write"), "Write(/tmp/*)");
	});

	it("returns undefined for empty or cancelled input", () => {
		assert.equal(normalizeEntry(undefined, "bash"), undefined);
		assert.equal(normalizeEntry("", "bash"), undefined);
		assert.equal(normalizeEntry("   ", "bash"), undefined);
	});
});
