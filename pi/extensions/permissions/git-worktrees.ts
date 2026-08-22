import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

interface ExecResult {
	stdout: string;
	code: number;
}

/**
 * Return absolute roots of worktrees registered to the repository containing
 * `cwd`. Git itself establishes that relationship, so sibling repositories and
 * arbitrary directories are not trusted.
 */
export async function registeredGitWorktreeRoots(
	pi: Pick<ExtensionAPI, 'exec'>,
	cwd: string,
): Promise<string[]> {
	try {
		const result = (await pi.exec('git', ['worktree', 'list', '--porcelain'], {
			cwd,
			timeout: 3000,
		})) as ExecResult;
		if (result.code !== 0) return [];
		return parseGitWorktreeRoots(result.stdout);
	} catch {
		// A non-Git cwd or a Git failure must preserve the normal outside-cwd gate.
		return [];
	}
}

/** Parse the `worktree <path>` records emitted by `git worktree list --porcelain`. */
export function parseGitWorktreeRoots(output: string): string[] {
	return output
		.split(/\r?\n/)
		.filter((line) => line.startsWith('worktree '))
		.map((line) => line.slice('worktree '.length))
		.filter((path) => path.length > 0);
}
