/**
 * Permission store: reads/writes ~/.pi/agent/permissions.json and hot-reloads
 * it when the file changes on disk.
 *
 * File shape:
 *   {
 *     "safe": ["Bash(project-local command *)"],
 *     "prompt": ["Bash(rm *)", "Write(/outside/repo/*)"],
 *     "block": ["Bash(sudo*)", "Bash(mkfs *)"]
 *   }
 *
 * Entries are `Tool(glob)` where Tool is one of Bash | Read | Write | Edit
 * and glob uses `*` / `?` wildcards (see glob.ts).
 */
import {
	existsSync,
	mkdirSync,
	readFileSync,
	realpathSync,
	renameSync,
	statSync,
	writeFileSync,
} from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

export interface PermissionData {
	/** Legacy allowlist for compatibility with already-running old extension code. */
	allow?: string[];
	/** Legacy denylist for compatibility with already-running old extension code. */
	deny?: string[];
	/** Explicit safe overrides for commands that would otherwise prompt. */
	safe: string[];
	/** Prompt in interactive sessions; block in headless/subagent sessions. */
	prompt: string[];
	/** Local always-block list. Hardcoded blocks in matcher.ts also apply. */
	block: string[];
}

const DEFAULT_DATA: PermissionData = {
	allow: ["Read(*)", "Write(*)", "Edit(*)", "Bash(node --test *)"],
	deny: [],
	safe: [],
	prompt: [
		"Bash(rm *)",
		"Bash(rmdir *)",
		"Bash(mv *)",
		"Bash(cp *)",
		"Bash(chmod *)",
		"Bash(chown *)",
		"Bash(ln -sf *)",
		"Bash(git clean *)",
		"Bash(git reset --hard*)",
		"Bash(git checkout -- *)",
		"Bash(git restore *)",
		"Bash(git push --force*)",
		"Bash(git push --delete*)",
		"Bash(git branch -D *)",
		"Bash(npm install*)",
		"Bash(pnpm install*)",
		"Bash(yarn install*)",
		"Bash(bun install*)",
		"Bash(pip install*)",
		"Bash(cargo install*)",
		"Bash(brew install*)",
		"Bash(apt install*)",
		"Bash(apt remove*)",
		"Bash(make install*)",
	],
	block: [
		"Bash(sudo*)",
		"Bash(su *)",
		"Bash(doas*)",
		"Bash(pkexec*)",
		"Bash(mkfs*)",
		"Bash(fdisk*)",
		"Bash(parted*)",
		"Bash(wipefs*)",
		"Bash(shutdown*)",
		"Bash(reboot*)",
		"Bash(poweroff*)",
		"Bash(halt*)",
	],
};

export const PERMISSIONS_PATH = join(homedir(), ".pi", "agent", "permissions.json");

export class PermissionStore {
	private readonly path: string;
	private data: PermissionData = { safe: [], prompt: [], block: [] };
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
				allow: Array.isArray(parsed.allow) ? parsed.allow : undefined,
				deny: Array.isArray(parsed.deny) ? parsed.deny : undefined,
				safe: Array.isArray(parsed.safe) ? parsed.safe : [],
				prompt: Array.isArray(parsed.prompt) ? parsed.prompt : [],
				block: Array.isArray(parsed.block) ? parsed.block : [],
			};
			this.mtimeMs = stat.mtimeMs;
			this.size = stat.size;
		} catch {
			// Malformed file: keep whatever we last had rather than crashing.
		}
	}

	private seedDefaults(): void {
		this.data = {
			allow: [...(DEFAULT_DATA.allow ?? [])],
			deny: [...(DEFAULT_DATA.deny ?? [])],
			safe: [...DEFAULT_DATA.safe],
			prompt: [...DEFAULT_DATA.prompt],
			block: [...DEFAULT_DATA.block],
		};
		this.save();
	}

	get safe(): string[] {
		this.reloadIfChanged();
		return this.data.safe;
	}

	get prompt(): string[] {
		this.reloadIfChanged();
		return this.data.prompt;
	}

	get block(): string[] {
		this.reloadIfChanged();
		return this.data.block;
	}

	addSafe(entry: string): void {
		this.reloadIfChanged();
		if (!this.data.safe.includes(entry)) this.data.safe.push(entry);
		this.save();
	}

	addPrompt(entry: string): void {
		this.reloadIfChanged();
		if (!this.data.prompt.includes(entry)) this.data.prompt.push(entry);
		this.save();
	}

	addBlock(entry: string): void {
		this.reloadIfChanged();
		if (!this.data.block.includes(entry)) this.data.block.push(entry);
		this.save();
	}

	/**
	 * Atomic write (temp file + rename) so a crash can't corrupt the file.
	 * Resolves symlinks first so renaming targets the real file rather than
	 * replacing the symlink itself (the store may be symlinked into a dotfiles
	 * repo).
	 */
	private save(): void {
		const target = existsSync(this.path) ? realpathSync(this.path) : this.path;
		mkdirSync(dirname(target), { recursive: true });
		const tmp = `${target}.tmp-${process.pid}`;
		writeFileSync(tmp, `${JSON.stringify(this.data, null, 2)}\n`, "utf8");
		renameSync(tmp, target);
		const stat = statSync(this.path);
		this.mtimeMs = stat.mtimeMs;
		this.size = stat.size;
	}
}
