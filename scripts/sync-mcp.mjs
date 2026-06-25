#!/usr/bin/env node
import { execSync, spawnSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const mcpConfigPath = resolve(__dirname, '../claude/mcp.json');
const claudeJsonPath = resolve(process.env.HOME, '.claude.json');

const desired = JSON.parse(readFileSync(mcpConfigPath, 'utf-8'));

let current = {};
try {
  const claudeJson = JSON.parse(readFileSync(claudeJsonPath, 'utf-8'));
  current = claudeJson.mcpServers ?? {};
} catch {
  // ~/.claude.json doesn't exist yet, treat as empty
}

function configsMatch(want, have) {
  if (want.transport === 'http' || want.transport === 'sse') {
    return have.type === want.transport && have.url === want.url;
  }
  if (want.transport === 'stdio') {
    return have.type === 'stdio' && have.command === want.command;
  }
  return false;
}

function addServer(name, config) {
  const { transport, url, command, args = [], env = {} } = config;

  const envArgs = Object.entries(env).flatMap(([k, v]) => ['-e', `${k}=${v}`]);
  const scopeArgs = ['--scope', 'user'];

  let result;
  if (transport === 'http' || transport === 'sse') {
    result = spawnSync(
      'claude',
      ['mcp', 'add', '--transport', transport, ...scopeArgs, name, url],
      { stdio: 'inherit' },
    );
  } else if (transport === 'stdio') {
    result = spawnSync(
      'claude',
      ['mcp', 'add', ...envArgs, ...scopeArgs, name, '--', command, ...args],
      { stdio: 'inherit' },
    );
  } else {
    console.error(`  Unknown transport "${transport}" for ${name}, skipping`);
    return;
  }

  if (result.status !== 0) {
    console.error(`  Failed to add ${name}`);
    process.exitCode = 1;
  }
}

function removeServer(name) {
  const result = spawnSync('claude', ['mcp', 'remove', name, '--scope', 'user'], {
    stdio: 'inherit',
  });
  if (result.status !== 0) {
    console.error(`  Failed to remove ${name}`);
    process.exitCode = 1;
  }
}

for (const [name, config] of Object.entries(desired)) {
  if (name in current) {
    if (configsMatch(config, current[name])) {
      console.log(`✓ ${name}`);
    } else {
      console.log(`~ ${name} (config changed, updating)`);
      removeServer(name);
      addServer(name, config);
    }
  } else {
    console.log(`+ ${name} (adding)`);
    addServer(name, config);
  }
}

for (const name of Object.keys(current)) {
  if (!(name in desired)) {
    console.log(`? ${name} is configured but not in claude/mcp.json`);
    console.log(`  To remove: claude mcp remove ${name} -s user`);
  }
}
