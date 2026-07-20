import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { planGitTrackedRm, type GitProbe } from './git-rm.ts';
import { decide } from './matcher.ts';

function probe(tracked: string[] | undefined): GitProbe {
	const trackedSet = new Set(tracked ?? []);
	return {
		async findRepositoryRoot() {
			return tracked ? '/repo' : undefined;
		},
		async isTracked(_repositoryRoot: string, _cwd: string, path: string) {
			return trackedSet.has(path);
		},
	};
}

describe('planGitTrackedRm', () => {
	it('rewrites a tracked literal file path to git rm', async () => {
		assert.deepEqual(
			await planGitTrackedRm('rm tracked.txt', '/repo', probe(['tracked.txt'])),
			{
				action: 'rewrite',
				command: 'git rm -- tracked.txt',
			},
		);
	});

	it('rewrites multiple tracked literal file paths to git rm', async () => {
		assert.deepEqual(
			await planGitTrackedRm(
				"/bin/rm 'one file.txt' two.txt",
				'/repo',
				probe(['one file.txt', 'two.txt']),
			),
			{
				action: 'rewrite',
				command: "git rm -- 'one file.txt' two.txt",
			},
		);
	});

	it('leaves untracked paths unchanged so normal permissions policy applies', async () => {
		assert.deepEqual(
			await planGitTrackedRm('rm scratch.txt', '/repo', probe([])),
			{ action: 'unchanged' },
		);
		assert.equal(
			decide('bash', 'rm scratch.txt', [], ['Bash(rm *)'], []),
			'prompt',
		);
	});

	it('blocks mixed tracked and untracked target lists', async () => {
		const result = await planGitTrackedRm(
			'rm tracked.txt scratch.txt',
			'/repo',
			probe(['tracked.txt']),
		);
		assert.equal(result.action, 'block');
		assert.match(
			result.action === 'block' ? result.reason : '',
			/Git-tracked file/,
		);
		assert.match(
			result.action === 'block' ? result.reason : '',
			/tracked\.txt/,
		);
		assert.match(result.action === 'block' ? result.reason : '', /git rm/);
	});

	it('blocks complex rm when a tracked literal target is known', async () => {
		const result = await planGitTrackedRm(
			'rm tracked.txt && echo done',
			'/repo',
			probe(['tracked.txt']),
		);
		assert.equal(result.action, 'block');
		assert.match(result.action === 'block' ? result.reason : '', /Use git rm/);
	});

	it('leaves non-Git directories unchanged', async () => {
		assert.deepEqual(
			await planGitTrackedRm('rm tracked.txt', '/tmp', probe(undefined)),
			{
				action: 'unchanged',
			},
		);
	});

	it('leaves bare no-argument rm unchanged', async () => {
		assert.deepEqual(
			await planGitTrackedRm('rm', '/repo', probe(['tracked.txt'])),
			{ action: 'unchanged' },
		);
	});

	it('does not apply to git rm itself', async () => {
		assert.deepEqual(
			await planGitTrackedRm(
				'git rm tracked.txt',
				'/repo',
				probe(['tracked.txt']),
			),
			{
				action: 'unchanged',
			},
		);
	});

	it('blocks unsupported rm options when a tracked target is known', async () => {
		const result = await planGitTrackedRm(
			'rm -f tracked.txt',
			'/repo',
			probe(['tracked.txt']),
		);
		assert.equal(result.action, 'block');
		assert.match(result.action === 'block' ? result.reason : '', /git rm/);
	});

	it('blocks redirected rm when a tracked target is known', async () => {
		const result = await planGitTrackedRm(
			'rm tracked.txt > log',
			'/repo',
			probe(['tracked.txt']),
		);
		assert.equal(result.action, 'block');
		assert.match(result.action === 'block' ? result.reason : '', /git rm/);
	});
});
