# Test Framework Implementation

This directory contains the TypeScript implementation of the NLP Skills Test Framework.

## Architecture

```
lib/
├── schema.ts           # TypeScript interfaces for scenarios, assertions
├── runner.ts           # Main test orchestrator
├── validators.ts       # Assertion validation implementations
├── fixture-manager.ts  # Fixture setup/teardown
├── choice-interceptor.ts   # Script user choices for AskUserQuestion
└── README.md           # This file
```

## Integration with Claude Agent SDK

The test runner requires integration with Claude to execute commands. The key integration point is in `runner.ts`:

```typescript
private async executeCommand(
  command: string,
  args: string | undefined,
  choices: ScriptedChoice[],
  workDir: string,
  timeout: number
): Promise<string> {
  // TODO: Implement with Claude Agent SDK
}
```

### Option 1: Claude Agent SDK (Recommended)

```typescript
import Anthropic from '@anthropic-ai/sdk';

async executeCommand(...) {
  const client = new Anthropic();

  // Create conversation with skills loaded
  const messages = [];

  // Add system context with skills
  const systemPrompt = loadSkillsAsSystemPrompt();

  // Execute command
  const response = await client.messages.create({
    model: 'claude-opus-4-5-20251101',
    max_tokens: 8192,
    system: systemPrompt,
    messages: [{ role: 'user', content: command }],
    // Handle tool calls...
  });

  return extractOutput(response);
}
```

### Option 2: Claude Code CLI Wrapper

For simpler integration, wrap the Claude Code CLI:

```typescript
import { spawn } from 'child_process';

async executeCommand(command, args, choices, workDir, timeout) {
  return new Promise((resolve, reject) => {
    const proc = spawn('claude', ['--print', command], {
      cwd: workDir,
      timeout,
      // Pipe scripted choices to stdin
    });

    let output = '';
    proc.stdout.on('data', (data) => output += data);
    proc.on('close', () => resolve(output));
  });
}
```

### Option 3: Mock Mode (For CI)

For fast CI runs, use a mock mode that validates scenario structure without executing:

```bash
./tests/scripts/run-tests.sh --dry-run
```

## Adding New Validators

1. Add the assertion type to `schema.ts`:

```typescript
export interface MyNewAssertion {
  my_new_check: {
    param1: string;
    param2: number;
  };
}

// Add to Assertion union type
export type Assertion = ... | MyNewAssertion;
```

2. Implement the validator in `validators.ts`:

```typescript
function validateMyNewCheck(
  assertion: MyNewAssertion,
  context: ValidationContext
): AssertionResult {
  const { param1, param2 } = assertion.my_new_check;

  // Validation logic...

  return {
    assertion,
    passed: true,
    message: 'Check passed',
  };
}
```

3. Add case to `validateAssertion()`:

```typescript
if ('my_new_check' in assertion) {
  return validateMyNewCheck(assertion, context);
}
```

## LLM Judge Configuration

The semantic validator requires an Anthropic API key:

```bash
export ANTHROPIC_API_KEY=your-key-here
./tests/scripts/run-tests.sh --suite integration
```

For cost control:
- Contract tests don't use LLM (free, fast)
- Integration tests use Haiku by default (cheap)
- Use `judge_model: sonnet` only for complex consistency checks

## Development

```bash
# Install dependencies
npm install

# Run type check
npx tsc --noEmit

# Run tests in dry-run mode
./tests/scripts/run-tests.sh --dry-run --verbose

# Run specific scenario
./tests/scripts/run-tests.sh --file contracts/start-specification.yml
```
