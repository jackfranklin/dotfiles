import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { parseGitWorktreeRoots, registeredGitWorktreeRoots } from './git-worktrees.ts';

describe('Git worktree discovery', () => {
	it('parses only worktree roots from porcelain output', () => {
		const output = [
			'worktree /home/jack/git/routemaster',
			'HEAD abcdef',
			'branch refs/heads/main',
			'',
			'worktree /home/jack/git/routemaster-issue-234',
			'HEAD 012345',
			'detached',
			'',
		].join('\n');
		assert.deepEqual(parseGitWorktreeRoots(output), [
			'/home/jack/git/routemaster',
			'/home/jack/git/routemaster-issue-234',
		]);
	});

	it('returns no additional roots when Git cannot identify a repository', async () => {
		const pi = {
			exec: async () => ({ stdout: '', code: 128, stderr: '', killed: false }),
		};
		assert.deepEqual(await registeredGitWorktreeRoots(pi, '/not/a/repository'), []);
	});
});
