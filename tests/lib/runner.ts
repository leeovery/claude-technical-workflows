/**
 * NLP Skills Test Framework - Test Runner
 *
 * Orchestrates test execution: loads scenarios, sets up fixtures,
 * executes commands via Claude, and validates assertions.
 */

import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'yaml';
import { glob } from 'glob';

import type {
  TestScenarioFile,
  TestScenario,
  TestResult,
  TestSuiteResult,
  ScriptedChoice,
} from './schema';
import { validateAssertion, ValidationContext } from './validators';
import { FixtureManager } from './fixture-manager';
import { ChoiceInterceptor } from './choice-interceptor';

// =============================================================================
// Configuration
// =============================================================================

export interface RunnerConfig {
  /** Base directory for tests */
  testsDir: string;

  /** Filter to specific suite (contracts, integration) */
  suite?: 'contracts' | 'integration';

  /** Filter to specific scenario file */
  file?: string;

  /** Filter to specific scenario name */
  scenario?: string;

  /** Enable verbose output */
  verbose?: boolean;

  /** Timeout per test in ms */
  timeout?: number;

  /** Model to use for test execution */
  model?: 'opus' | 'sonnet' | 'haiku';

  /** Dry run - don't execute, just validate scenarios */
  dryRun?: boolean;
}

const DEFAULT_CONFIG: Required<RunnerConfig> = {
  testsDir: path.join(__dirname, '..'),
  suite: undefined as any,
  file: undefined as any,
  scenario: undefined as any,
  verbose: false,
  timeout: 120000, // 2 minutes
  model: 'opus',
  dryRun: false,
};

// =============================================================================
// Test Runner
// =============================================================================

export class TestRunner {
  private config: Required<RunnerConfig>;
  private fixtureManager: FixtureManager;
  private results: TestSuiteResult[] = [];

  constructor(config: RunnerConfig) {
    this.config = { ...DEFAULT_CONFIG, ...config };
    this.fixtureManager = new FixtureManager(
      path.join(this.config.testsDir, 'fixtures')
    );
  }

  /**
   * Run all matching tests and return results
   */
  async run(): Promise<TestSuiteResult[]> {
    const scenarioFiles = this.findScenarioFiles();

    this.log(`Found ${scenarioFiles.length} scenario file(s)`);

    for (const file of scenarioFiles) {
      const suiteResult = await this.runScenarioFile(file);
      this.results.push(suiteResult);
    }

    this.printSummary();
    return this.results;
  }

  /**
   * Find scenario files matching filters
   */
  private findScenarioFiles(): string[] {
    const scenariosDir = path.join(this.config.testsDir, 'scenarios');

    if (this.config.file) {
      const filePath = path.join(scenariosDir, this.config.file);
      if (!fs.existsSync(filePath)) {
        throw new Error(`Scenario file not found: ${this.config.file}`);
      }
      return [filePath];
    }

    let pattern: string;
    if (this.config.suite) {
      pattern = path.join(scenariosDir, this.config.suite, '**/*.yml');
    } else {
      pattern = path.join(scenariosDir, '**/*.yml');
    }

    return glob.sync(pattern);
  }

  /**
   * Run all scenarios in a file
   */
  private async runScenarioFile(filePath: string): Promise<TestSuiteResult> {
    const relativePath = path.relative(this.config.testsDir, filePath);
    this.log(`\nRunning: ${relativePath}`);

    const content = fs.readFileSync(filePath, 'utf-8');
    const scenarioFile = yaml.parse(content) as TestScenarioFile;

    const startTime = Date.now();
    const results: TestResult[] = [];

    for (const scenario of scenarioFile.scenarios) {
      // Apply filters
      if (this.config.scenario && scenario.name !== this.config.scenario) {
        continue;
      }
      if (scenario.config?.skip) {
        results.push({
          scenario: scenario.name,
          status: 'skipped',
          duration: 0,
          assertions: [],
        });
        continue;
      }

      const result = await this.runScenario(scenario, scenarioFile.type);
      results.push(result);

      // Print result immediately
      const icon = result.status === 'passed' ? '✓' : result.status === 'failed' ? '✗' : '○';
      const color = result.status === 'passed' ? '\x1b[32m' : result.status === 'failed' ? '\x1b[31m' : '\x1b[33m';
      console.log(`  ${color}${icon}\x1b[0m ${scenario.name} (${result.duration}ms)`);

      if (result.status === 'failed' && this.config.verbose) {
        for (const assertion of result.assertions.filter(a => !a.passed)) {
          console.log(`    → ${assertion.message}`);
        }
      }
    }

    const duration = Date.now() - startTime;

    return {
      name: scenarioFile.name,
      file: relativePath,
      timestamp: new Date().toISOString(),
      duration,
      results,
      summary: {
        total: results.length,
        passed: results.filter(r => r.status === 'passed').length,
        failed: results.filter(r => r.status === 'failed').length,
        skipped: results.filter(r => r.status === 'skipped').length,
      },
    };
  }

  /**
   * Run a single scenario
   */
  private async runScenario(
    scenario: TestScenario,
    type: 'contract' | 'integration'
  ): Promise<TestResult> {
    const startTime = Date.now();

    try {
      // Setup fixture
      const workDir = await this.fixtureManager.setup(scenario.fixture);
      const preTestState = this.fixtureManager.captureState(workDir);

      // Dry run - just validate scenario structure
      if (this.config.dryRun) {
        return {
          scenario: scenario.name,
          status: 'passed',
          duration: Date.now() - startTime,
          assertions: [],
          output: '[dry run]',
        };
      }

      // Execute command
      const output = await this.executeCommand(
        scenario.command,
        scenario.args,
        scenario.choices || [],
        workDir,
        scenario.config?.timeout || this.config.timeout
      );

      // Create validation context
      const context: ValidationContext = {
        workDir,
        fixtureDir: path.join(this.fixtureManager.fixturesDir, scenario.fixture),
        output,
        preTestState,
      };

      // Run assertions
      const assertionResults = await Promise.all(
        scenario.assertions.map(a => validateAssertion(a, context))
      );

      // Check invariants
      if (scenario.invariants) {
        for (const pattern of scenario.invariants) {
          const result = await validateAssertion({ unchanged: pattern }, context);
          assertionResults.push(result);
        }
      }

      // Cleanup
      await this.fixtureManager.teardown(workDir);

      const allPassed = assertionResults.every(r => r.passed);

      return {
        scenario: scenario.name,
        status: allPassed ? 'passed' : 'failed',
        duration: Date.now() - startTime,
        assertions: assertionResults,
        output,
      };
    } catch (error) {
      return {
        scenario: scenario.name,
        status: 'error',
        duration: Date.now() - startTime,
        assertions: [],
        error: error instanceof Error ? error.message : String(error),
      };
    }
  }

  /**
   * Execute a command via Claude
   *
   * This is the integration point with Claude Agent SDK.
   * Currently a placeholder that needs SDK implementation.
   */
  private async executeCommand(
    command: string,
    args: string | undefined,
    choices: ScriptedChoice[],
    workDir: string,
    timeout: number
  ): Promise<string> {
    const fullCommand = args ? `${command} ${args}` : command;

    this.logVerbose(`Executing: ${fullCommand}`);
    this.logVerbose(`Working directory: ${workDir}`);
    this.logVerbose(`Scripted choices: ${JSON.stringify(choices)}`);

    // Placeholder for Claude Agent SDK integration
    //
    // The actual implementation would:
    // 1. Create an Agent instance with skills/commands loaded
    // 2. Set workDir as the working directory
    // 3. Register a tool interceptor for AskUserQuestion
    // 4. Send the command as a message
    // 5. Capture and return the output
    //
    // Example with Agent SDK (conceptual):
    //
    // const agent = new Agent({
    //   model: this.config.model,
    //   workingDirectory: workDir,
    //   tools: loadSkillsAndCommands(),
    // });
    //
    // const interceptor = new ChoiceInterceptor(choices);
    // agent.onToolCall('AskUserQuestion', interceptor.handle.bind(interceptor));
    //
    // const result = await agent.run(fullCommand, { timeout });
    // return result.output;

    throw new Error(
      'Command execution requires Claude Agent SDK. ' +
      'See tests/lib/README.md for integration instructions.'
    );
  }

  /**
   * Print final summary
   */
  private printSummary(): void {
    console.log('\n' + '='.repeat(60));
    console.log('Test Summary');
    console.log('='.repeat(60));

    let totalPassed = 0;
    let totalFailed = 0;
    let totalSkipped = 0;

    for (const suite of this.results) {
      totalPassed += suite.summary.passed;
      totalFailed += suite.summary.failed;
      totalSkipped += suite.summary.skipped;
    }

    const total = totalPassed + totalFailed + totalSkipped;

    console.log(`\nTotal: ${total} tests`);
    console.log(`  \x1b[32m✓ Passed: ${totalPassed}\x1b[0m`);
    if (totalFailed > 0) {
      console.log(`  \x1b[31m✗ Failed: ${totalFailed}\x1b[0m`);
    }
    if (totalSkipped > 0) {
      console.log(`  \x1b[33m○ Skipped: ${totalSkipped}\x1b[0m`);
    }

    console.log('');
  }

  private log(message: string): void {
    console.log(message);
  }

  private logVerbose(message: string): void {
    if (this.config.verbose) {
      console.log(`  [verbose] ${message}`);
    }
  }
}

// =============================================================================
// CLI Entry Point
// =============================================================================

export async function runCLI(args: string[]): Promise<void> {
  const config: RunnerConfig = {
    testsDir: path.join(__dirname, '..'),
  };

  // Parse CLI arguments
  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--suite':
        config.suite = args[++i] as 'contracts' | 'integration';
        break;
      case '--file':
        config.file = args[++i];
        break;
      case '--scenario':
        config.scenario = args[++i];
        break;
      case '--verbose':
      case '-v':
        config.verbose = true;
        break;
      case '--dry-run':
        config.dryRun = true;
        break;
      case '--timeout':
        config.timeout = parseInt(args[++i], 10);
        break;
      case '--model':
        config.model = args[++i] as 'opus' | 'sonnet' | 'haiku';
        break;
      case '--help':
        printHelp();
        process.exit(0);
    }
  }

  const runner = new TestRunner(config);
  const results = await runner.run();

  // Exit with error code if any tests failed
  const anyFailed = results.some(r => r.summary.failed > 0);
  process.exit(anyFailed ? 1 : 0);
}

function printHelp(): void {
  console.log(`
NLP Skills Test Runner

Usage: npx ts-node tests/lib/runner.ts [options]

Options:
  --suite <name>      Run specific suite (contracts, integration)
  --file <path>       Run specific scenario file
  --scenario <name>   Run specific scenario by name
  --verbose, -v       Enable verbose output
  --dry-run           Validate scenarios without executing
  --timeout <ms>      Timeout per test (default: 120000)
  --model <name>      Model for execution (opus, sonnet, haiku)
  --help              Show this help

Examples:
  npx ts-node tests/lib/runner.ts --suite contracts
  npx ts-node tests/lib/runner.ts --file contracts/start-specification.yml
  npx ts-node tests/lib/runner.ts --verbose --dry-run
`);
}

// Run if called directly
if (require.main === module) {
  runCLI(process.argv.slice(2)).catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
  });
}
