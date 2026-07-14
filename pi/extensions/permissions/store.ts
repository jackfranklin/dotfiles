/**
 * Permission store: reads/writes ~/.pi/agent/permissions.json and hot-reloads
 * it when the file changes on disk.
 *
 * File shape:
 *   {
 *     "allow": ["Read(*)", "Write(*)", "Edit(*)", "Bash(git *)"],
 *     "deny":  ["Bash(rm -rf *)"]
 *   }
 *
 * Each entry is `Tool(glob)` where Tool is one of Bash | Read | Write | Edit
 * and glob uses `*` / `?` wildcards (see glob.ts).
 */
import { existsSync, mkdirSync, readFileSync, renameSync, statSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

export interface PermissionData {
	allow: string[];
	deny: string[];
}

const DEFAULT_DATA: PermissionData = {
	// Allow all file operations by default; bash is gated.
	allow: ["Read(*)", "Write(*)", "Edit(*)"],
	deny: [],
};

export const PERMISSIONS_PATH = join(homedir(), ".pi", "agent", "permissions.json");

export class PermissionStore {
	private readonly path: string;
	private data: PermissionData = { allow: [], deny: [] };
	private mtimeMs = -1;
	private size = -1;

	constructor(path: string = PERMISSIONS_PATH) {
		this.path = path;
		this.reloadIfChanged();
	}

	/** Re-read the file if it has changed (or doesn't exist yet). */
	private reloadIfChanged(): void {
		if (!existsSync(this.path)) {
			this.seedDefaults();
			return;
		}
		const stat = statSync(this.path);
		if (stat.mtimeMs === this.mtimeMs && stat.size === this.size) return;
		try {
			const parsed = JSON.parse(readFileSync(this.path, "utf8")) as Partial<PermissionData>;
			this.data = {
				allow: Array.isArray(parsed.allow) ? parsed.allow : [],
				deny: Array.isArray(parsed.deny) ? parsed.deny : [],
			};
			this.mtimeMs = stat.mtimeMs;
			this.size = stat.size;
		} catch {
			// Malformed file: keep whatever we last had rather than crashing.
		}
	}

	private seedDefaults(): void {
		this.data = { allow: [...DEFAULT_DATA.allow], deny: [...DEFAULT_DATA.deny] };
		this.save();
	}

	get allow(): string[] {
		this.reloadIfChanged();
		return this.data.allow;
	}

	get deny(): string[] {
		this.reloadIfChanged();
		return this.data.deny;
	}

	addAllow(entry: string): void {
		this.reloadIfChanged();
		if (!this.data.allow.includes(entry)) this.data.allow.push(entry);
		this.save();
	}

	addDeny(entry: string): void {
		this.reloadIfChanged();
		if (!this.data.deny.includes(entry)) this.data.deny.push(entry);
		this.save();
	}

	/** Atomic write (temp file + rename) so a crash can't corrupt the file. */
	private save(): void {
		mkdirSync(dirname(this.path), { recursive: true });
		const tmp = `${this.path}.tmp-${process.pid}`;
		writeFileSync(tmp, `${JSON.stringify(this.data, null, 2)}\n`, "utf8");
		renameSync(tmp, this.path);
		const stat = statSync(this.path);
		this.mtimeMs = stat.mtimeMs;
		this.size = stat.size;
	}
}
