import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import test from 'node:test';
import { DatabaseSync } from 'node:sqlite';

const tempDir = mkdtempSync(join(tmpdir(), 'skill-metrics-'));
const databasePath = join(tempDir, 'metrics.sqlite');
const project = resolve(tempDir, 'project');
const skillPath = resolve(
  tempDir,
  'skills',
  'diagnose-and-propose',
  'SKILL.md',
);

const legacyDatabase = new DatabaseSync(databasePath);
legacyDatabase.exec(`
  CREATE TABLE skill_invocations (
    project TEXT NOT NULL,
    skill TEXT NOT NULL,
    invocations INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (project, skill)
  );
  INSERT INTO skill_invocations (project, skill, invocations)
  VALUES ('${project}', 'diagnose-and-propose', 2);
`);
legacyDatabase.close();

process.env.PI_SKILL_METRICS_DB = databasePath;
const { default: skillMetricsExtension } = await import('./index.ts');

test('separates migrated user and model skill invocations', async () => {
  const handlers = new Map<string, (...args: any[]) => unknown>();
  let metricsCommand:
    | { handler: (...args: any[]) => Promise<void> }
    | undefined;
  const pi = {
    on(event: string, handler: (...args: any[]) => unknown) {
      handlers.set(event, handler);
    },
    getCommands() {
      return [
        {
          name: 'skill:diagnose-and-propose',
          source: 'skill',
          sourceInfo: { path: skillPath },
        },
      ];
    },
    registerCommand(
      name: string,
      command: { handler: (...args: any[]) => Promise<void> },
    ) {
      if (name === 'skill-metrics') metricsCommand = command;
    },
  };

  skillMetricsExtension(pi as never);

  await handlers.get('input')?.(
    { source: 'interactive', text: '/skill:diagnose-and-propose' },
    { cwd: project },
  );
  await handlers.get('tool_call')?.(
    { toolName: 'read', input: { path: `@${skillPath}` } },
    { cwd: project },
  );
  await handlers.get('tool_call')?.(
    { toolName: 'read', input: { path: join(tempDir, 'not-a-skill.md') } },
    { cwd: project },
  );

  const database = new DatabaseSync(databasePath, { readOnly: true });
  const metric = database
    .prepare(
      `
      SELECT user_invocations, model_invocations
      FROM skill_invocations
      WHERE project = ? AND skill = ?
    `,
    )
    .get(project, 'diagnose-and-propose') as {
    user_invocations: number;
    model_invocations: number;
  };
  database.close();

  assert.equal(metric.user_invocations, 3);
  assert.equal(metric.model_invocations, 1);

  let output = '';
  await metricsCommand?.handler('all', {
    ui: { notify: (message: string) => (output = message) },
  });
  assert.match(output, /User\s+Model/);
  assert.match(output, /diagnose-and-propose\s+3\s+1/);

  await handlers.get('session_shutdown')?.({}, {});
  rmSync(tempDir, { recursive: true, force: true });
});
