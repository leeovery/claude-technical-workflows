// Knowledge CLI entry point.
//
// Dispatches commands to their handlers, resolving config and provider
// once at startup. Phase 3 implements: index, query, check. Other
// commands dispatch with a "not yet implemented" error until Phase 4.

'use strict';

const store = require('./store');
const chunker = require('./chunker');
const { StubProvider } = require('./embeddings');
const config = require('./config');

// ---------------------------------------------------------------------------
// Flag parsing
// ---------------------------------------------------------------------------

/**
 * Parse argv-style args into { positional: string[], flags: object }.
 * Handles --flag value and --flag=value forms.
 */
function parseArgs(argv) {
  const positional = [];
  const flags = {};
  let i = 0;
  while (i < argv.length) {
    const arg = argv[i];
    if (arg.startsWith('--')) {
      const eqIdx = arg.indexOf('=');
      if (eqIdx !== -1) {
        const key = arg.slice(2, eqIdx);
        flags[key] = arg.slice(eqIdx + 1);
      } else {
        const key = arg.slice(2);
        // Peek next arg — if it exists and is not a flag, it's the value.
        if (i + 1 < argv.length && !argv[i + 1].startsWith('--')) {
          flags[key] = argv[i + 1];
          i++;
        } else {
          flags[key] = true;
        }
      }
    } else {
      positional.push(arg);
    }
    i++;
  }
  return { positional, flags };
}

/**
 * Build an options object from parsed flags for command handlers.
 */
function buildOptions(flags) {
  return {
    workType: flags['work-type'] || null,
    phase: flags['phase'] || null,
    workUnit: flags['work-unit'] || null,
    topic: flags['topic'] || null,
    limit: flags['limit'] ? parseInt(flags['limit'], 10) : null,
    dryRun: flags['dry-run'] === true || flags['dry-run'] === 'true',
  };
}

// ---------------------------------------------------------------------------
// Usage
// ---------------------------------------------------------------------------

const USAGE = `Usage: knowledge <command> [options]

Commands:
  index     Index a file or all pending artifacts
  query     Search the knowledge base
  check     Check if the knowledge base is ready
  status    Show knowledge base status
  remove    Remove indexed content
  compact   Compact the knowledge base
  rebuild   Rebuild the knowledge base from scratch
  setup     Interactive setup wizard

Options:
  --work-type <type>   Filter by work type
  --work-unit <unit>   Filter by work unit
  --phase <phase>      Filter by phase
  --topic <topic>      Filter by topic
  --limit <n>          Limit number of results
  --dry-run            Preview without making changes`;

// ---------------------------------------------------------------------------
// Command stubs — Phase 3 implements index, query, check.
// The rest error with "not yet implemented" until Phase 4.
// ---------------------------------------------------------------------------

function notYetImplemented(name) {
  process.stderr.write(`Command "${name}" is not yet implemented.\n`);
  process.exit(1);
}

// Placeholder handlers — replaced when their implementing tasks land.
async function cmdIndex(/* args, options, cfg, provider */) {
  notYetImplemented('index');
}

async function cmdQuery(/* args, options, cfg, provider */) {
  notYetImplemented('query');
}

async function cmdCheck(/* args, options, cfg, provider */) {
  notYetImplemented('check');
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const rawArgs = process.argv.slice(2);
  const { positional, flags } = parseArgs(rawArgs);
  const command = positional[0];
  const commandArgs = positional.slice(1);
  const options = buildOptions(flags);

  if (!command) {
    process.stderr.write(USAGE + '\n');
    process.exit(1);
  }

  switch (command) {
    case 'index':   await cmdIndex(commandArgs, options, null, null); break;
    case 'query':   await cmdQuery(commandArgs, options, null, null); break;
    case 'check':   await cmdCheck(commandArgs, options, null, null); break;
    case 'status':  notYetImplemented('status'); break;
    case 'remove':  notYetImplemented('remove'); break;
    case 'compact': notYetImplemented('compact'); break;
    case 'rebuild': notYetImplemented('rebuild'); break;
    case 'setup':   notYetImplemented('setup'); break;
    default:
      process.stderr.write(`Unknown command "${command}".\n\n${USAGE}\n`);
      process.exit(1);
  }
}

module.exports = { parseArgs, buildOptions, main, StubProvider, store, chunker, config };

if (require.main === module) {
  main().catch((err) => {
    process.stderr.write(String(err && err.stack ? err.stack : err) + '\n');
    process.exit(1);
  });
}
