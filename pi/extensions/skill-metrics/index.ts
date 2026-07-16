import { DatabaseSync } from 'node:sqlite';
import { mkdirSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, resolve } from 'node:path';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

interface SkillMetric {
  project: string;
  skill: string;
  invocations: number;
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
			invocations INTEGER NOT NULL DEFAULT 0,
			PRIMARY KEY (project, skill)
		)
	`);
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
  const countWidth = Math.max(
    'Invocations'.length,
    ...metrics.map((metric) => String(metric.invocations).length),
  );
  const header = `${'Project'.padEnd(projectWidth)}  ${'Skill'.padEnd(skillWidth)}  ${'Invocations'.padStart(countWidth)}`;
  const divider = `${'-'.repeat(projectWidth)}  ${'-'.repeat(skillWidth)}  ${'-'.repeat(countWidth)}`;
  const rows = metrics.map(
    (metric) =>
      `${metric.project.padEnd(projectWidth)}  ${metric.skill.padEnd(skillWidth)}  ${String(metric.invocations).padStart(countWidth)}`,
  );

  return [header, divider, ...rows].join('\n');
}

export default function skillMetricsExtension(pi: ExtensionAPI) {
  const database = openDatabase();
  const increment = database.prepare(`
		INSERT INTO skill_invocations (project, skill, invocations)
		VALUES (?, ?, 1)
		ON CONFLICT(project, skill)
		DO UPDATE SET invocations = invocations + 1
	`);
  const forProject = database.prepare(`
		SELECT project, skill, invocations
		FROM skill_invocations
		WHERE project = ?
		ORDER BY invocations DESC, skill ASC
	`);
  const allProjects = database.prepare(`
		SELECT project, skill, invocations
		FROM skill_invocations
		ORDER BY project ASC, invocations DESC, skill ASC
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
    if (exists) increment.run(resolve(ctx.cwd), skill);
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
