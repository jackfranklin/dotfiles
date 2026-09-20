import { DatabaseSync } from 'node:sqlite';
import { mkdirSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, resolve } from 'node:path';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

interface SkillMetric {
  project: string;
  skill: string;
  userInvocations: number;
  modelInvocations: number;
}

const databasePath =
  process.env.PI_SKILL_METRICS_DB ??
  resolve(homedir(), '.pi', 'agent', 'skill-metrics.sqlite');

function openDatabase(): DatabaseSync {
  mkdirSync(dirname(databasePath), { recursive: true });
  const database = new DatabaseSync(databasePath);
  database.exec('PRAGMA journal_mode = WAL; PRAGMA busy_timeout = 5000;');
  database.exec(`
		CREATE TABLE IF NOT EXISTS skill_invocations (
			project TEXT NOT NULL,
			skill TEXT NOT NULL,
			user_invocations INTEGER NOT NULL DEFAULT 0,
			model_invocations INTEGER NOT NULL DEFAULT 0,
			PRIMARY KEY (project, skill)
		)
	`);

  const columns = database
    .prepare('PRAGMA table_info(skill_invocations)')
    .all() as Array<{ name: string }>;
  if (!columns.some((column) => column.name === 'user_invocations')) {
    database.exec(`
			ALTER TABLE skill_invocations
			ADD COLUMN user_invocations INTEGER NOT NULL DEFAULT 0;
			UPDATE skill_invocations SET user_invocations = invocations;
		`);
  }
  if (!columns.some((column) => column.name === 'model_invocations')) {
    database.exec(`
			ALTER TABLE skill_invocations
			ADD COLUMN model_invocations INTEGER NOT NULL DEFAULT 0;
		`);
  }

  return database;
}

function formatMetrics(metrics: SkillMetric[]): string {
  if (metrics.length === 0) return 'No skill invocations recorded.';

  const projectWidth = Math.max(
    'Project'.length,
    ...metrics.map((metric) => metric.project.length),
  );
  const skillWidth = Math.max(
    'Skill'.length,
    ...metrics.map((metric) => metric.skill.length),
  );
  const userWidth = Math.max(
    'User'.length,
    ...metrics.map((metric) => String(metric.userInvocations).length),
  );
  const modelWidth = Math.max(
    'Model'.length,
    ...metrics.map((metric) => String(metric.modelInvocations).length),
  );
  const header = `${'Project'.padEnd(projectWidth)}  ${'Skill'.padEnd(skillWidth)}  ${'User'.padStart(userWidth)}  ${'Model'.padStart(modelWidth)}`;
  const divider = `${'-'.repeat(projectWidth)}  ${'-'.repeat(skillWidth)}  ${'-'.repeat(userWidth)}  ${'-'.repeat(modelWidth)}`;
  const rows = metrics.map(
    (metric) =>
      `${metric.project.padEnd(projectWidth)}  ${metric.skill.padEnd(skillWidth)}  ${String(metric.userInvocations).padStart(userWidth)}  ${String(metric.modelInvocations).padStart(modelWidth)}`,
  );

  return [header, divider, ...rows].join('\n');
}

export default function skillMetricsExtension(pi: ExtensionAPI) {
  const database = openDatabase();
  const incrementUser = database.prepare(`
		INSERT INTO skill_invocations (project, skill, user_invocations)
		VALUES (?, ?, 1)
		ON CONFLICT(project, skill)
		DO UPDATE SET user_invocations = user_invocations + 1
	`);
  const incrementModel = database.prepare(`
		INSERT INTO skill_invocations (project, skill, model_invocations)
		VALUES (?, ?, 1)
		ON CONFLICT(project, skill)
		DO UPDATE SET model_invocations = model_invocations + 1
	`);
  const forProject = database.prepare(`
		SELECT
			project,
			skill,
			user_invocations AS userInvocations,
			model_invocations AS modelInvocations
		FROM skill_invocations
		WHERE project = ?
		ORDER BY (user_invocations + model_invocations) DESC, skill ASC
	`);
  const allProjects = database.prepare(`
		SELECT
			project,
			skill,
			user_invocations AS userInvocations,
			model_invocations AS modelInvocations
		FROM skill_invocations
		ORDER BY project ASC, (user_invocations + model_invocations) DESC, skill ASC
	`);

  pi.on('input', (event, ctx) => {
    // Pi expands only a leading /skill:name command. Ignore messages injected by
    // extensions so this measures skills explicitly invoked by a user or RPC client.
    if (event.source === 'extension' || !event.text.startsWith('/skill:'))
      return;

    const spaceIndex = event.text.indexOf(' ');
    const skill =
      spaceIndex === -1 ? event.text.slice(7) : event.text.slice(7, spaceIndex);
    if (!skill) return;

    const commandName = `skill:${skill}`;
    const exists = pi
      .getCommands()
      .some(
        (command) => command.source === 'skill' && command.name === commandName,
      );
    if (exists) incrementUser.run(resolve(ctx.cwd), skill);
  });

  pi.on('tool_call', (event, ctx) => {
    if (event.toolName !== 'read') return;

    const input = event.input as { path: string };
    const readPath = input.path.startsWith('@')
      ? input.path.slice(1)
      : input.path;
    const skillPath = resolve(ctx.cwd, readPath);
    const command = pi
      .getCommands()
      .find(
        (candidate) =>
          candidate.source === 'skill' &&
          resolve(candidate.sourceInfo.path) === skillPath,
      );
    if (command) {
      incrementModel.run(resolve(ctx.cwd), command.name.slice('skill:'.length));
    }
  });

  pi.registerCommand('skill-metrics', {
    description:
      "Show skill invocation counts for this project; use 'all' for every project",
    handler: async (args, ctx) => {
      const scope = args.trim();
      if (scope && scope !== 'all') {
        ctx.ui.notify('Usage: /skill-metrics [all]', 'warning');
        return;
      }

      const metrics = (
        scope === 'all' ? allProjects.all() : forProject.all(resolve(ctx.cwd))
      ) as SkillMetric[];
      ctx.ui.notify(formatMetrics(metrics), 'info');
    },
  });

  pi.on('session_shutdown', () => database.close());
}
