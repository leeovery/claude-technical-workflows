/**
 * Simple Test Example
 *
 * Demonstrates how to use the NLP Skills Test Framework programmatically.
 *
 * Run with: npx tsx tests/examples/simple-test.ts
 */

import * as path from 'path';
import { fileURLToPath } from 'url';
import { ClaudeExecutor } from '../lib/executor.js';
import { FixtureManager } from '../lib/fixture-manager.js';
import { LLMJudge } from '../lib/llm-judge.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  console.log('NLP Skills Test Framework - Simple Example\n');
  console.log('='.repeat(50));

  // Check for API key
  if (!process.env.ANTHROPIC_API_KEY) {
    console.error('\nError: ANTHROPIC_API_KEY environment variable required');
    console.error('Set it with: export ANTHROPIC_API_KEY=your-key-here');
    process.exit(1);
  }

  // Example 1: Direct LLM Judge usage
  console.log('\n1. LLM Judge Example');
  console.log('-'.repeat(30));

  const judge = new LLMJudge({
    model: 'haiku',
    verbose: true,
  });

  const sampleContent = `
# Technical Specification: User Authentication

## Summary
This specification defines OAuth2-based authentication for the API.

## Decisions
1. Use OAuth2 with PKCE flow for security
2. Store tokens in httpOnly cookies
3. Implement automatic token refresh

## Requirements
- Users can authenticate via OAuth2
- Sessions persist across browser restarts
  `;

  const criteria = [
    'Contains a summary section',
    'Documents specific technical decisions',
    'Includes implementation requirements',
  ];

  console.log('\nEvaluating sample specification...\n');

  const judgeResult = await judge.evaluate(sampleContent, criteria, 0.66);

  console.log(`\nResult: ${judgeResult.passed ? 'PASSED' : 'FAILED'}`);
  console.log(`Pass rate: ${Math.round(judgeResult.passRate * 100)}%`);
  console.log(`Cost: $${judgeResult.costUsd.toFixed(4)}`);

  for (const c of judgeResult.criteria) {
    const icon = c.passed ? '✓' : '✗';
    console.log(`  ${icon} ${c.criterion}: ${c.reason}`);
  }

  // Example 2: Fixture Manager usage
  console.log('\n\n2. Fixture Manager Example');
  console.log('-'.repeat(30));

  const fixturesDir = path.join(__dirname, '..', 'fixtures');
  const fixtureManager = new FixtureManager(fixturesDir);

  console.log('\nSetting up fixture: minimal/has-discussion');
  const workDir = await fixtureManager.setup('minimal/has-discussion');
  console.log(`Working directory: ${workDir}`);

  const preState = fixtureManager.captureState(workDir);
  console.log(`Captured state: ${preState.size} files`);

  // Cleanup
  await fixtureManager.teardown(workDir);
  console.log('Fixture cleaned up');

  // Example 3: Full Executor (commented out to avoid costs)
  console.log('\n\n3. Claude Executor Example (commented out)');
  console.log('-'.repeat(30));
  console.log(`
To run a full command execution:

  const executor = new ClaudeExecutor({
    cwd: workDir,
    model: 'claude-opus-4-5-20251101',
    verbose: true,
  });

  const result = await executor.execute(
    '/workflow/start-specification',
    [{ match: 'topic', answer: 'authentication' }]
  );

  console.log('Output:', result.output);
  console.log('Cost:', result.costUsd);
`);

  console.log('\n' + '='.repeat(50));
  console.log('Example complete!');
}

main().catch(console.error);
