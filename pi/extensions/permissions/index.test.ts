import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { after, describe, it } from 'node:test';

// The store captures homedir at import time. Keep this integration test away
// from the user's real permission rules and approval history.
const home = mkdtempSync(join(tmpdir(), 'pi-redirect-permissions-'));
const previousHome = process.env.HOME;
let permissions: typeof import('./index.ts').default;
try {
  process.env.HOME = home;
  permissions = (await import('./index.ts')).default;
} finally {
  if (previousHome === undefined) delete process.env.HOME;
  else process.env.HOME = previousHome;
}
after(() => rmSync(home, { recursive: true, force: true }));

interface ToolCall {
  toolName: string;
  input: { command: string };
}

type ToolCallHandler = (
  event: ToolCall,
  ctx: { cwd: string; hasUI: boolean },
) => Promise<unknown>;

function registerPermissions(worktrees: string | undefined) {
  let handler: ToolCallHandler | undefined;
  const calls: string[][] = [];
  permissions({
    on(event: string, callback: ToolCallHandler) {
      if (event === 'tool_call') handler = callback;
    },
    async exec(command: string, args: string[], options: { cwd: string }) {
      assert.equal(command, 'git');
      assert.equal(options.cwd, '/home/jack/git/jackdaw');
      calls.push(args);
      if (args[0] === 'worktree' && worktrees !== undefined) {
        return { code: 0, stdout: worktrees };
      }
      return { code: 1, stdout: '' };
    },
  } as never);
  assert.ok(handler);
  return { handler, calls };
}

const ctx = { cwd: '/home/jack/git/jackdaw', hasUI: false };

function bash(command: string): ToolCall {
  return { toolName: 'bash', input: { command } };
}

describe('permissions shell redirect integration', () => {
  it('loads registered roots for redirects and permits a sibling worktree without UI', async () => {
    const { handler, calls } = registerPermissions(
      'worktree /home/jack/git/jackdaw\n\nworktree /home/jack/git/jackdaw-issue-6\n',
    );
    assert.equal(
      await handler(
        bash(
          'gh issue view 6 --json body --jq .body > ../jackdaw-issue-6/issue.md',
        ),
        ctx,
      ),
      undefined,
    );
    assert.ok(
      calls.some((args) => args.join(' ') === 'worktree list --porcelain'),
    );
    assert.deepEqual(
      await handler(
        bash('gh issue view 6 --json body --jq .body > ../unrelated/issue.md'),
        ctx,
      ),
      {
        block: true,
        reason: 'Command requires approval and no UI is available to confirm',
      },
    );
  });

  it('keeps local redirects allowed and outside redirects blocked if Git lookup fails', async () => {
    const { handler } = registerPermissions(undefined);
    assert.equal(
      await handler(
        bash(
          'gh issue view 6 --json body --jq .body > .wrangler/issue-6-update.md',
        ),
        ctx,
      ),
      undefined,
    );
    assert.deepEqual(
      await handler(
        bash(
          'gh issue view 6 --json body --jq .body > ../jackdaw-issue-6/issue.md',
        ),
        ctx,
      ),
      {
        block: true,
        reason: 'Command requires approval and no UI is available to confirm',
      },
    );
  });

  it('does not look up worktrees for bash commands without write redirects', async () => {
    const { handler, calls } = registerPermissions(undefined);
    assert.equal(
      await handler(bash('gh issue view 6 --json body'), ctx),
      undefined,
    );
    assert.ok(calls.every((args) => args[0] !== 'worktree'));
  });
});
