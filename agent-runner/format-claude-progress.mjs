#!/usr/bin/env node

import readline from 'node:readline';

const color = {
  reset: '\u001B[0m',
  blue: '\u001B[1;34m',
  cyan: '\u001B[1;36m',
  magenta: '\u001B[1;35m',
  yellow: '\u001B[1;33m',
  dimYellow: '\u001B[2;33m',
};

const statusOnly = process.argv.includes('--status-only');
const progressByTask = new Map();
const announcedTools = new Set();
let announcedThinking = false;
let lastOutputWasText = false;
let lastActivityAt = Date.now();

function status(message, statusColor) {
  if (lastOutputWasText) {
    process.stdout.write('\n');
  }
  process.stdout.write(`${statusColor}==> ${message}${color.reset}\n`);
  lastOutputWasText = false;
}

function announceTool(name) {
  const messages = {
    Agent: ['Claude is delegating codebase research…', color.magenta],
    Bash: ['Claude is searching the repository…', color.cyan],
    Read: ['Claude is reading relevant files…', color.blue],
    Task: ['Claude is delegating codebase research…', color.magenta],
  };
  const [message, statusColor] = messages[name] ?? [];

  if (message && !announcedTools.has(name)) {
    announcedTools.add(name);
    status(message, statusColor);
  }
}

const heartbeat = setInterval(() => {
  if (Date.now() - lastActivityAt >= 15_000) {
    status('Claude is still working…', color.dimYellow);
    lastActivityAt = Date.now();
  }
}, 1_000);

const input = readline.createInterface({ input: process.stdin });

for await (const line of input) {
  lastActivityAt = Date.now();
  let event;
  try {
    event = JSON.parse(line);
  } catch {
    continue;
  }

  if (event.type === 'system' && event.subtype === 'task_started') {
    status(`Researching: ${event.description}`, color.magenta);
    continue;
  }

  if (event.type === 'system' && event.subtype === 'task_progress') {
    const toolUses = event.usage?.tool_uses ?? 0;
    const previous = progressByTask.get(event.task_id) ?? 0;
    if (toolUses >= previous + 5) {
      progressByTask.set(event.task_id, toolUses);
      status('Research subagent is still exploring…', color.dimYellow);
    }
    continue;
  }

  if (event.type !== 'stream_event') {
    continue;
  }

  if (
    event.event.type === 'content_block_delta' &&
    event.event.delta.type === 'thinking_delta' &&
    !announcedThinking
  ) {
    announcedThinking = true;
    status('Claude is assessing the issue…', color.yellow);
    continue;
  }

  if (
    event.event.type === 'content_block_start' &&
    event.event.content_block.type === 'tool_use'
  ) {
    announceTool(event.event.content_block.name);
    continue;
  }

  if (
    !statusOnly &&
    event.event.type === 'content_block_delta' &&
    event.event.delta.type === 'text_delta'
  ) {
    process.stdout.write(event.event.delta.text);
    lastOutputWasText = true;
  }
}

clearInterval(heartbeat);

if (lastOutputWasText) {
  process.stdout.write('\n');
}
