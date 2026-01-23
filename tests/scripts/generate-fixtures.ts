/**
 * NLP Skills Test Framework - Fixture Generator
 *
 * Generates test fixtures by running workflow commands with canonical seed inputs.
 * Creates realistic fixtures that reflect actual skill/command behavior.
 *
 * Run with: npx tsx tests/scripts/generate-fixtures.ts [options]
 */

import * as fs from 'fs';
import * as path from 'path';
import { fileURLToPath } from 'url';
import * as yaml from 'yaml';

import { ClaudeExecutor } from '../lib/executor.js';
import type { FixtureSeed, PhaseConfig, ScriptedChoice } from '../lib/schema.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// =============================================================================
// Configuration
// =============================================================================

interface GeneratorConfig {
  seedsDir: string;
  fixturesDir: string;
  specificSeed?: string;
  dryRun: boolean;
  verbose: boolean;
  model: 'opus' | 'sonnet' | 'haiku';
  maxBudgetPerPhase: number;
}

const PHASES = ['research', 'discussion', 'specification', 'planning'] as const;
type Phase = typeof PHASES[number];

// =============================================================================
// Fixture Generator
// =============================================================================

class FixtureGenerator {
  private config: GeneratorConfig;

  constructor(config: GeneratorConfig) {
    this.config = config;
  }

  async generate(): Promise<void> {
    const seedFiles = this.findSeeds();
    console.log(`Found ${seedFiles.length} seed file(s)\n`);

    for (const seedFile of seedFiles) {
      await this.processSeed(seedFile);
    }

    console.log('\nFixture generation complete.');
  }

  private findSeeds(): string[] {
    if (this.config.specificSeed) {
      const seedPath = path.join(this.config.seedsDir, `${this.config.specificSeed}.yml`);
      if (!fs.existsSync(seedPath)) {
        throw new Error(`Seed not found: ${this.config.specificSeed}`);
      }
      return [seedPath];
    }

    const files = fs.readdirSync(this.config.seedsDir)
      .filter(f => f.endsWith('.yml'))
      .map(f => path.join(this.config.seedsDir, f));

    return files;
  }

  private async processSeed(seedPath: string): Promise<void> {
    const seedName = path.basename(seedPath, '.yml');
    console.log(`\n${'='.repeat(60)}`);
    console.log(`Processing seed: ${seedName}`);
    console.log('='.repeat(60));

    const seedContent = fs.readFileSync(seedPath, 'utf-8');
    const seed = yaml.parse(seedContent) as FixtureSeed;

    const outputDir = path.join(this.config.fixturesDir, seedName);

    if (this.config.dryRun) {
      console.log(`\n[DRY RUN] Would generate fixtures in: ${outputDir}`);
      console.log(`Phases to generate: ${Object.keys(seed.phases || {}).join(', ')}`);
      return;
    }

    // Clean and create output directory
    if (fs.existsSync(outputDir)) {
      fs.rmSync(outputDir, { recursive: true });
    }
    fs.mkdirSync(outputDir, { recursive: true });

    // Create workspace for progressive generation
    const workspace = fs.mkdtempSync(path.join(require('os').tmpdir(), 'fixture-gen-'));

    try {
      // Initialize workspace
      this.initializeWorkspace(workspace);

      // Generate each phase progressively
      for (const phase of PHASES) {
        const phaseConfig = seed.phases?.[phase];

        if (!phaseConfig || phaseConfig.skip) {
          console.log(`\n[${phase}] Skipped`);
          continue;
        }

        console.log(`\n[${phase}] Generating...`);

        await this.generatePhase(workspace, phase, phaseConfig);

        // Save snapshot as fixture
        const snapshotDir = path.join(outputDir, `post-${phase}`);
        this.copyDirectory(workspace, snapshotDir);
        console.log(`  Saved: post-${phase}/`);
      }

      // Create metadata file
      this.createMetadata(outputDir, seed);

    } finally {
      // Cleanup workspace
      fs.rmSync(workspace, { recursive: true, force: true });
    }

    console.log(`\nCompleted: ${seedName}`);
  }

  private initializeWorkspace(workspace: string): void {
    // Create standard directory structure
    const dirs = [
      'docs/workflow/research',
      'docs/workflow/discussion',
      'docs/workflow/specification',
      'docs/workflow/planning',
    ];

    for (const dir of dirs) {
      fs.mkdirSync(path.join(workspace, dir), { recursive: true });
    }

    // Initialize minimal git (some commands may check for it)
    const gitDir = path.join(workspace, '.git');
    fs.mkdirSync(gitDir);
    fs.writeFileSync(path.join(gitDir, 'config'), '[core]\n\tbare = false\n');
  }

  private async generatePhase(
    workspace: string,
    phase: Phase,
    config: PhaseConfig
  ): Promise<void> {
    const executor = new ClaudeExecutor({
      cwd: workspace,
      model: this.config.model === 'opus'
        ? 'claude-opus-4-5-20251101'
        : this.config.model === 'sonnet'
          ? 'claude-sonnet-4-20250514'
          : 'claude-haiku-3-5-20241022',
      maxBudgetUsd: this.config.maxBudgetPerPhase,
      maxTurns: 30,
      verbose: this.config.verbose,
      permissionMode: 'acceptEdits',
    });

    // Build command with inputs if provided
    let command = config.command;
    if (config.inputs) {
      // For research phase, inputs are provided as context
      const inputContext = Object.entries(config.inputs)
        .map(([key, value]) => `${key}: ${value}`)
        .join('\n\n');
      command = `${config.command}\n\nContext:\n${inputContext}`;
    }

    const result = await executor.execute(command, config.choices || []);

    if (!result.success) {
      console.warn(`  Warning: Phase ${phase} may not have completed successfully`);
      console.warn(`  Status: ${result.status}`);
      if (result.error) {
        console.warn(`  Error: ${result.error}`);
      }
    }

    console.log(`  Cost: $${result.costUsd.toFixed(4)}`);
    console.log(`  Turns: ${result.turns}`);
  }

  private copyDirectory(src: string, dest: string): void {
    fs.mkdirSync(dest, { recursive: true });
    const entries = fs.readdirSync(src, { withFileTypes: true });

    for (const entry of entries) {
      const srcPath = path.join(src, entry.name);
      const destPath = path.join(dest, entry.name);

      if (entry.isDirectory()) {
        this.copyDirectory(srcPath, destPath);
      } else {
        fs.copyFileSync(srcPath, destPath);
      }
    }
  }

  private createMetadata(outputDir: string, seed: FixtureSeed): void {
    const metadata = {
      seed: seed.name,
      description: seed.description,
      generatedAt: new Date().toISOString(),
      phases: Object.keys(seed.phases || {}),
    };

    fs.writeFileSync(
      path.join(outputDir, 'metadata.json'),
      JSON.stringify(metadata, null, 2)
    );

    // Also create a README
    const readme = `# Generated Fixtures: ${seed.name}

${seed.description || ''}

## Generated: ${metadata.generatedAt}

## Phases

${metadata.phases.map(p => `- \`post-${p}/\`: State after ${p} phase`).join('\n')}

## Regeneration

\`\`\`bash
npx tsx tests/scripts/generate-fixtures.ts --seed ${seed.name}
\`\`\`

## Usage in Tests

\`\`\`yaml
scenarios:
  - name: "test from post-discussion state"
    fixture: generated/${seed.name}/post-discussion
    command: /workflow/start-specification
    # ...
\`\`\`
`;

    fs.writeFileSync(path.join(outputDir, 'README.md'), readme);
  }
}

// =============================================================================
// CLI
// =============================================================================

async function main(): Promise<void> {
  const testsDir = path.join(__dirname, '..');

  const config: GeneratorConfig = {
    seedsDir: path.join(testsDir, 'seeds'),
    fixturesDir: path.join(testsDir, 'fixtures', 'generated'),
    dryRun: false,
    verbose: false,
    model: 'opus',
    maxBudgetPerPhase: 2.0,
  };

  // Parse CLI arguments
  const args = process.argv.slice(2);
  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--seed':
        config.specificSeed = args[++i];
        break;
      case '--dry-run':
        config.dryRun = true;
        break;
      case '--verbose':
      case '-v':
        config.verbose = true;
        break;
      case '--model':
        config.model = args[++i] as 'opus' | 'sonnet' | 'haiku';
        break;
      case '--max-budget':
        config.maxBudgetPerPhase = parseFloat(args[++i]);
        break;
      case '--help':
        printHelp();
        process.exit(0);
    }
  }

  // Check for API key (unless dry run)
  if (!config.dryRun && !process.env.ANTHROPIC_API_KEY) {
    console.error('Error: ANTHROPIC_API_KEY environment variable is required');
    console.error('Set it with: export ANTHROPIC_API_KEY=your-key-here');
    console.error('\nOr run with --dry-run to see what would be generated.');
    process.exit(1);
  }

  console.log('NLP Skills Fixture Generator');
  console.log('============================\n');

  if (!config.dryRun) {
    console.log(`Model: ${config.model}`);
    console.log(`Max budget per phase: $${config.maxBudgetPerPhase}`);
  }

  const generator = new FixtureGenerator(config);
  await generator.generate();
}

function printHelp(): void {
  console.log(`
NLP Skills Fixture Generator

Generates test fixtures by running workflow commands with canonical seed inputs.

Usage: npx tsx tests/scripts/generate-fixtures.ts [options]

Options:
  --seed <name>       Generate fixtures for specific seed only
  --dry-run           Show what would be generated without executing
  --verbose, -v       Enable verbose output
  --model <name>      Model for execution (opus, sonnet, haiku)
  --max-budget <usd>  Maximum budget per phase (default: 2.0)
  --help              Show this help

Environment:
  ANTHROPIC_API_KEY   Required for fixture generation (not needed for --dry-run)

Examples:
  npx tsx tests/scripts/generate-fixtures.ts --dry-run
  npx tsx tests/scripts/generate-fixtures.ts --seed auth-feature
  npx tsx tests/scripts/generate-fixtures.ts --model sonnet --max-budget 1.0
`);
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
