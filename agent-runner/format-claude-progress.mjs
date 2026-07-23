#!/usr/bin/env node

import readline from 'node:readline';

const progressByTask = new Map();
const announcedTools = new Set();
let announcedThinking = false;
let lastOutputWasText = false;

function status(message) {
  if (lastOutputWasText) {
    process.stdout.write('\n');
  }
  process.stdout.write(`==> ${message}\n`);
  lastOutputWasText = false;
}

function announceTool(name) {
  const messages = {
    Agent: 'Claude is delegating codebase research…',
    Bash: 'Claude is searching the repository…',
    Read: 'Claude is reading relevant files…',
    Task: 'Claude is delegating codebase research…',
  };
  const message = messages[name];

  if (message && !announcedTools.has(name)) {
    announcedTools.add(name);
    status(message);
  }
}

const input = readline.createInterface({ input: process.stdin });

for await (const line of input) {
  let event;
  try {
    event = JSON.parse(line);
  } catch {
    continue;
  }

  if (event.type === 'system' && event.subtype === 'task_started') {
    status(`Researching: ${event.description}`);
    continue;
  }

  if (event.type === 'system' && event.subtype === 'task_progress') {
    const toolUses = event.usage?.tool_uses ?? 0;
    const previous = progressByTask.get(event.task_id) ?? 0;
    if (toolUses >= previous + 5) {
      progressByTask.set(event.task_id, toolUses);
      status('Research subagent is still exploring…');
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
    status('Claude is assessing the issue…');
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
    event.event.type === 'content_block_delta' &&
    event.event.delta.type === 'text_delta'
  ) {
    process.stdout.write(event.event.delta.text);
    lastOutputWasText = true;
  }
}

if (lastOutputWasText) {
  process.stdout.write('\n');
}
