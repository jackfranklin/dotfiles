/**
 * Pure rendering and validation for harness-agnostic skills and subagents.
 * Source formats and template syntax are documented in agents/README.md.
 */

export type Harness = 'claude' | 'pi';
export const HARNESSES: readonly Harness[] = ['claude', 'pi'];

export type CanonicalTool =
  | 'read'
  | 'write'
  | 'edit'
  | 'grep'
  | 'find'
  | 'bash'
  | 'web_search'
  | 'web_fetch'
  | 'subagent';

// Claude subagents cannot spawn subagents, so `subagent` maps to nothing there.
const TOOL_NAMES: Record<CanonicalTool, Record<Harness, string[]>> = {
  read: { claude: ['Read'], pi: ['read'] },
  write: { claude: ['Write'], pi: ['write'] },
  edit: { claude: ['Edit'], pi: ['edit'] },
  grep: { claude: ['Grep'], pi: ['grep'] },
  find: { claude: ['Glob'], pi: ['find', 'ls'] },
  bash: { claude: ['Bash'], pi: ['bash'] },
  web_search: { claude: ['WebSearch'], pi: ['web_search'] },
  web_fetch: { claude: ['WebFetch'], pi: ['web_fetch'] },
  subagent: { claude: [], pi: ['subagent'] },
};

const CLAUDE_MODELS = ['sonnet', 'opus', 'haiku', 'inherit'] as const;
type ClaudeModel = (typeof CLAUDE_MODELS)[number];

export class BuildError extends Error {
  constructor(sourceLabel: string, message: string) {
    super(`${sourceLabel}: ${message}`);
    this.name = 'BuildError';
  }
}

const TOKEN = /\{\{([#/]?)([a-z_]+)\}\}/g;

function lineNumberAt(text: string, index: number): number {
  let line = 1;
  for (let i = 0; i < index; i++) if (text[i] === '\n') line++;
  return line;
}

/** The span a tag removes: its whole line when it stands alone there, otherwise just the tag. */
function removalSpan(
  text: string,
  start: number,
  end: number,
): [number, number] {
  const lineStart = text.lastIndexOf('\n', start - 1) + 1;
  const newline = text.indexOf('\n', end);
  const lineEnd = newline === -1 ? text.length : newline;
  const standalone =
    text.slice(lineStart, start).trim() === '' &&
    text.slice(end, lineEnd).trim() === '';
  if (!standalone) return [start, end];
  return [lineStart, newline === -1 ? text.length : newline + 1];
}

export function renderTemplate(
  text: string,
  harness: Harness,
  skillsDir: string,
  sourceLabel: string,
): string {
  let output = '';
  let cursor = 0;
  let openBlock: { name: Harness; line: number } | undefined;

  for (const match of text.matchAll(TOKEN)) {
    const [token, sigil, name] = match;
    const index = match.index;
    const line = lineNumberAt(text, index);
    const fail = (message: string) => {
      throw new BuildError(`${sourceLabel}:${line}`, `${message} (${token})`);
    };
    const [spanStart, spanEnd] =
      sigil === ''
        ? [index, index + token.length]
        : removalSpan(text, index, index + token.length);
    const visible = openBlock === undefined || openBlock.name === harness;

    if (sigil === '') {
      if (name !== 'skills_dir') fail('unknown template variable');
      if (visible) output += text.slice(cursor, spanStart) + skillsDir;
    } else {
      if (name !== 'claude' && name !== 'pi') fail('unknown template block');
      if (sigil === '#') {
        if (openBlock)
          fail(`blocks cannot nest; {{#${openBlock.name}}} is still open`);
      } else if (openBlock?.name !== name) {
        fail('closing tag without a matching opening tag');
      }
      if (visible) output += text.slice(cursor, spanStart);
      openBlock = sigil === '#' ? { name: name as Harness, line } : undefined;
    }
    cursor = spanEnd;
  }

  if (openBlock) {
    throw new BuildError(
      `${sourceLabel}:${openBlock.line}`,
      `unclosed block ({{#${openBlock.name}}})`,
    );
  }
  return output + text.slice(cursor);
}

// The Agent Skills naming rule; also keeps names safe as bare YAML scalars.
const NAME = /^[a-z0-9]+(-[a-z0-9]+)*$/;

const FRONTMATTER = /^---\r?\n([\s\S]*?)\r?\n---[ \t]*(?:\r?\n|$)/;

function splitFrontmatter(
  text: string,
  sourceLabel: string,
): { frontmatter: string; end: number } {
  const match = FRONTMATTER.exec(text);
  if (!match)
    throw new BuildError(sourceLabel, 'missing --- frontmatter block');
  return { frontmatter: match[1], end: match[0].length };
}

function unquote(value: string): string {
  return value.length >= 2 && /^(["']).*\1$/.test(value)
    ? value.slice(1, -1)
    : value;
}

export function validateSkillManifest(
  text: string,
  dirName: string,
  sourceLabel: string,
): void {
  const { frontmatter } = splitFrontmatter(text, sourceLabel);
  if (!NAME.test(dirName)) {
    throw new BuildError(
      sourceLabel,
      'skill names must be lowercase words joined by hyphens',
    );
  }
  const name = /^name:[ \t]*(.*)$/m.exec(frontmatter);
  if (!name) throw new BuildError(sourceLabel, 'frontmatter has no name');
  if (unquote(name[1].trim()) !== dirName) {
    throw new BuildError(
      sourceLabel,
      `name must match its directory "${dirName}"`,
    );
  }
  if (!/^description:/m.test(frontmatter)) {
    throw new BuildError(sourceLabel, 'frontmatter has no description');
  }
}

export interface SubagentSource {
  name: string;
  description: string;
  tools: CanonicalTool[];
  skills: string[];
  claudeModel: ClaudeModel;
  piModel?: string;
  piThinking?: string;
  piSubagentAgents?: string[];
  piRetryAfterTools?: boolean;
  body: string;
}

const SUBAGENT_KEYS = new Set([
  'name',
  'description',
  'tools',
  'skills',
  'claude-model',
  'pi-model',
  'pi-thinking',
  'pi-subagent-agents',
  'pi-retry-after-tools',
]);

function parseList(value: string): string[] {
  return value
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
}

function mapTools(tools: CanonicalTool[], harness: Harness): string[] {
  return [...new Set(tools.flatMap((tool) => TOOL_NAMES[tool][harness]))];
}

export function parseSubagent(
  text: string,
  fileStem: string,
  sourceLabel: string,
): SubagentSource {
  function fail(message: string): never {
    throw new BuildError(sourceLabel, message);
  }
  const { frontmatter, end } = splitFrontmatter(text, sourceLabel);

  const fields = new Map<string, string>();
  for (const line of frontmatter.split(/\r?\n/)) {
    if (line.trim() === '') continue;
    const match = /^([a-z-]+):[ \t]*(.*)$/.exec(line);
    if (!match)
      fail(
        `frontmatter lines must be flat "key: value" pairs: ${JSON.stringify(line)}`,
      );
    const [, key, rawValue] = match;
    if (!SUBAGENT_KEYS.has(key)) fail(`unknown frontmatter key "${key}"`);
    if (fields.has(key)) fail(`duplicate frontmatter key "${key}"`);
    let value = rawValue.trim();
    if (value.startsWith('"')) {
      try {
        value = JSON.parse(value);
      } catch {
        fail(`invalid quoted value for "${key}"`);
      }
    }
    if (value === '') fail(`"${key}" has no value`);
    fields.set(key, value);
  }

  const name = fields.get('name') ?? fail('frontmatter has no name');
  if (name !== fileStem) fail(`name must match its file name "${fileStem}"`);
  if (!NAME.test(name)) fail(`name must be lowercase words joined by hyphens`);
  const description =
    fields.get('description') || fail('frontmatter has no description');

  const tools = parseList(fields.get('tools') ?? '');
  if (tools.length === 0) fail('tools must list at least one tool');
  for (const tool of tools) {
    if (!Object.hasOwn(TOOL_NAMES, tool)) fail(`unknown tool "${tool}"`);
  }
  const canonicalTools = tools as CanonicalTool[];
  if (mapTools(canonicalTools, 'claude').length === 0) {
    // Claude treats an empty tool list as "all tools".
    fail('tools must include at least one tool available to Claude');
  }

  const claudeModel = fields.get('claude-model') ?? 'inherit';
  if (!(CLAUDE_MODELS as readonly string[]).includes(claudeModel)) {
    fail(`claude-model must be one of ${CLAUDE_MODELS.join(', ')}`);
  }

  const rawSubagentAgents = fields.get('pi-subagent-agents');
  const piSubagentAgents =
    rawSubagentAgents === undefined ? undefined : parseList(rawSubagentAgents);
  if (piSubagentAgents && !canonicalTools.includes('subagent')) {
    fail('pi-subagent-agents requires the subagent tool');
  }

  const retry = fields.get('pi-retry-after-tools');
  if (retry !== undefined && retry !== 'true' && retry !== 'false') {
    fail('pi-retry-after-tools must be true or false');
  }

  return {
    name,
    description,
    tools: canonicalTools,
    skills: parseList(fields.get('skills') ?? ''),
    claudeModel: claudeModel as ClaudeModel,
    piModel: fields.get('pi-model'),
    piThinking: fields.get('pi-thinking'),
    piSubagentAgents,
    piRetryAfterTools: retry === undefined ? undefined : retry === 'true',
    body: text.slice(end).replace(/^(\r?\n)+/, ''),
  };
}

function document(
  frontmatterLines: string[],
  header: string,
  body: string,
): string {
  return ['---', ...frontmatterLines, '---', header, '', body].join('\n');
}

export function renderClaudeSubagent(
  agent: SubagentSource,
  renderedBody: string,
  header: string,
): string {
  const lines = [
    `name: ${agent.name}`,
    `description: ${JSON.stringify(agent.description)}`,
    `tools: ${mapTools(agent.tools, 'claude').join(', ')}`,
    `model: ${agent.claudeModel}`,
  ];
  if (agent.skills.length > 0) {
    lines.push('skills:', ...agent.skills.map((skill) => `  - ${skill}`));
  }
  return document(lines, header, renderedBody);
}

export function renderPiSubagent(
  agent: SubagentSource,
  renderedBody: string,
  header: string,
  piSkillsDir: string,
): string {
  const lines = [
    `name: ${agent.name}`,
    `description: ${JSON.stringify(agent.description)}`,
    `tools: ${JSON.stringify(mapTools(agent.tools, 'pi').join(', '))}`,
  ];
  if (agent.piModel) lines.push(`model: ${JSON.stringify(agent.piModel)}`);
  if (agent.piThinking)
    lines.push(`thinking: ${JSON.stringify(agent.piThinking)}`);
  if (agent.skills.length > 0) {
    const paths = agent.skills.map(
      (skill) => `${piSkillsDir}/${skill}/SKILL.md`,
    );
    lines.push(`skills: ${JSON.stringify(paths.join(', '))}`);
  }
  if (agent.piSubagentAgents) {
    lines.push(
      `subagent_agents: ${JSON.stringify(agent.piSubagentAgents.join(', '))}`,
    );
  }
  if (agent.piRetryAfterTools !== undefined) {
    lines.push(`retry_after_tools: ${agent.piRetryAfterTools}`);
  }
  return document(lines, header, renderedBody);
}

/** Callers validate the frontmatter first, so its error label is never user-facing. */
export function insertHeader(markdown: string, header: string): string {
  const { end } = splitFrontmatter(markdown, 'insertHeader');
  const head = markdown.slice(0, end);
  return `${head.endsWith('\n') ? head : `${head}\n`}${header}\n${markdown.slice(end)}`;
}
