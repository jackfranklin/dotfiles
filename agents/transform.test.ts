import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
  BuildError,
  insertHeader,
  parseSubagent,
  renderClaudeSubagent,
  renderPiSubagent,
  renderTemplate,
  validateSkillManifest,
} from './transform.ts';

const render = (text: string, harness: 'claude' | 'pi') =>
  renderTemplate(
    text,
    harness,
    `/home/u/.${harness}/skills`,
    'skills/x/SKILL.md',
  );

const renderError = (text: string, line: number) =>
  assert.throws(
    () => render(text, 'claude'),
    (error: Error) =>
      error instanceof BuildError &&
      error.message.startsWith(`skills/x/SKILL.md:${line}:`),
  );

describe('renderTemplate', () => {
  it('replaces skills_dir with the harness skills directory', () => {
    assert.equal(
      render('run {{skills_dir}}/x/run.sh', 'claude'),
      'run /home/u/.claude/skills/x/run.sh',
    );
    assert.equal(
      render('run {{skills_dir}}/x/run.sh', 'pi'),
      'run /home/u/.pi/skills/x/run.sh',
    );
  });

  it('keeps only the inline block for the current harness', () => {
    const text = 'a {{#claude}}X{{/claude}}{{#pi}}Y{{/pi}} b';
    assert.equal(render(text, 'claude'), 'a X b');
    assert.equal(render(text, 'pi'), 'a Y b');
  });

  it('removes the lines of tags that stand alone, leaving no blank lines', () => {
    const text =
      'before\n{{#claude}}\nclaude only\n{{/claude}}\n  {{#pi}}\npi only\n{{/pi}}\nafter\n';
    assert.equal(render(text, 'claude'), 'before\nclaude only\nafter\n');
    assert.equal(render(text, 'pi'), 'before\npi only\nafter\n');
  });

  it('applies the line rule to each tag independently', () => {
    const text = 'before\n{{#pi}}\npi only{{/pi}} tail\nafter';
    assert.equal(render(text, 'pi'), 'before\npi only tail\nafter');
    assert.equal(render(text, 'claude'), 'before\n tail\nafter');
  });

  it('leaves text that is not template syntax untouched', () => {
    const text = 'token: ${{ secrets.X }} and {{ spaced }} and {{Upper}}';
    assert.equal(render(text, 'claude'), text);
  });

  it('returns text without templates byte-identical', () => {
    const text = '---\nname: x\n---\r\nbody with } and { braces\n';
    assert.equal(render(text, 'pi'), text);
  });

  it('reports the source label and line of unknown variables', () => {
    assert.throws(
      () => render('line one\n{{unknown}}', 'claude'),
      (error: Error) =>
        error instanceof BuildError &&
        error.message.includes('skills/x/SKILL.md:2'),
    );
  });

  it('rejects unknown blocks, nesting, unclosed blocks and stray closers', () => {
    renderError('{{#foo}}x{{/foo}}', 1);
    renderError('{{#claude}}\n{{#pi}}x{{/pi}}{{/claude}}', 2);
    renderError('a\n{{#pi}}\nnever closed', 2);
    renderError('a\nb\nx{{/claude}}', 3);
    renderError('{{#claude}}x{{/pi}}', 1);
  });
});

describe('validateSkillManifest', () => {
  it('accepts a matching name with a folded description', () => {
    validateSkillManifest(
      '---\nname: x\ndescription: >\n  Folded.\n---\nBody',
      'x',
      'label',
    );
  });

  it('rejects a missing frontmatter, a mismatched name and a missing description', () => {
    assert.throws(() => validateSkillManifest('# x', 'x', 'label'), BuildError);
    assert.throws(
      () =>
        validateSkillManifest(
          '---\nname: y\ndescription: d\n---\n',
          'x',
          'label',
        ),
      BuildError,
    );
    assert.throws(
      () => validateSkillManifest('---\nname: x\n---\n', 'x', 'label'),
      BuildError,
    );
  });

  it('rejects skill names that are not lowercase hyphenated words', () => {
    assert.throws(
      () =>
        validateSkillManifest(
          '---\nname: A b\ndescription: d\n---\n',
          'A b',
          'label',
        ),
      BuildError,
    );
  });
});

const fullSubagent = [
  '---',
  'name: helper',
  'description: "Does things: carefully, with \\"quotes\\""',
  'tools: read, grep, find, bash, subagent',
  'skills: code-review',
  '',
  'claude-model: sonnet',
  'pi-model: openai-codex/gpt-5.6-terra',
  'pi-thinking: high',
  'pi-subagent-agents: scout, researcher',
  'pi-retry-after-tools: true',
  '---',
  '',
  'You are a helper.',
  '',
].join('\n');

const subagentWith = (lines: string[]) =>
  ['---', 'name: helper', 'description: d', ...lines, '---', 'Body'].join('\n');

const parseError = (lines: string[]) =>
  assert.throws(
    () => parseSubagent(subagentWith(lines), 'helper', 'label'),
    BuildError,
  );

describe('parseSubagent', () => {
  it('reads every field of a valid source', () => {
    assert.deepEqual(parseSubagent(fullSubagent, 'helper', 'label'), {
      name: 'helper',
      description: 'Does things: carefully, with "quotes"',
      tools: ['read', 'grep', 'find', 'bash', 'subagent'],
      skills: ['code-review'],
      claudeModel: 'sonnet',
      piModel: 'openai-codex/gpt-5.6-terra',
      piThinking: 'high',
      piSubagentAgents: ['scout', 'researcher'],
      piRetryAfterTools: true,
      body: 'You are a helper.\n',
    });
  });

  it('defaults claude-model to inherit and leaves Pi settings unset', () => {
    const agent = parseSubagent(
      subagentWith(['tools: read']),
      'helper',
      'label',
    );
    assert.equal(agent.claudeModel, 'inherit');
    assert.equal(agent.piModel, undefined);
    assert.equal(agent.piRetryAfterTools, undefined);
    assert.deepEqual(agent.skills, []);
  });

  it('requires at least one tool that Claude can use', () => {
    parseError([]);
    parseError(['tools: ']);
    parseError(['tools: subagent']);
  });

  it('rejects tool names inherited from Object.prototype', () => {
    parseError(['tools: constructor']);
    parseError(['tools: read, toString']);
  });

  it('rejects keys without a value', () => {
    parseError(['tools: read', 'pi-subagent-agents:']);
    parseError(['tools: read', 'pi-model: ""']);
  });

  it('rejects invalid keys, values and shapes', () => {
    parseError(['tools: read, teleport']);
    parseError(['tools: read', 'colour: blue']);
    parseError(['tools: read', 'tools: grep']);
    parseError(['tools: read', 'claude-model: gpt']);
    parseError(['tools: read', 'pi-subagent-agents: scout']);
    parseError(['tools: read', 'pi-retry-after-tools: yes']);
    parseError(['tools: read', '  - grep']);
    assert.throws(
      () => parseSubagent(subagentWith(['tools: read']), 'other', 'label'),
      BuildError,
    );
    assert.throws(
      () =>
        parseSubagent(
          '---\nname: Bad_Name\ndescription: d\ntools: read\n---\n',
          'Bad_Name',
          'label',
        ),
      BuildError,
    );
  });
});

describe('renderClaudeSubagent', () => {
  it('maps tools, drops subagent, and lists skills', () => {
    const agent = parseSubagent(fullSubagent, 'helper', 'label');
    const output = renderClaudeSubagent(
      agent,
      agent.body,
      '<!-- generated -->',
    );
    assert.equal(
      output,
      [
        '---',
        'name: helper',
        'description: "Does things: carefully, with \\"quotes\\""',
        'tools: Read, Grep, Glob, Bash',
        'model: sonnet',
        'skills:',
        '  - code-review',
        '---',
        '<!-- generated -->',
        '',
        'You are a helper.\n',
      ].join('\n'),
    );
  });

  it('description is JSON-quoted', () => {
    const agent = parseSubagent(fullSubagent, 'helper', 'label');
    const output = renderClaudeSubagent(agent, agent.body, '<!-- h -->');
    assert.ok(
      output.includes(`\ndescription: ${JSON.stringify(agent.description)}\n`),
    );
  });
});

describe('renderPiSubagent', () => {
  it('maps tools and emits Pi-only settings', () => {
    const agent = parseSubagent(fullSubagent, 'helper', 'label');
    const output = renderPiSubagent(
      agent,
      agent.body,
      '<!-- generated -->',
      '/home/u/.pi/agent/skills',
    );
    assert.equal(
      output,
      [
        '---',
        'name: helper',
        'description: "Does things: carefully, with \\"quotes\\""',
        'tools: "read, grep, find, ls, bash, subagent"',
        'model: "openai-codex/gpt-5.6-terra"',
        'thinking: "high"',
        'skills: "/home/u/.pi/agent/skills/code-review/SKILL.md"',
        'subagent_agents: "scout, researcher"',
        'retry_after_tools: true',
        '---',
        '<!-- generated -->',
        '',
        'You are a helper.\n',
      ].join('\n'),
    );
  });
});

describe('insertHeader', () => {
  it('places the header directly after the frontmatter', () => {
    assert.equal(
      insertHeader('---\nname: x\n---\n# Body\n', '<!-- h -->'),
      '---\nname: x\n---\n<!-- h -->\n# Body\n',
    );
  });
});
