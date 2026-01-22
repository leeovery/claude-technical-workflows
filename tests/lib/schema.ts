/**
 * NLP Skills Test Framework - Schema Definitions
 *
 * TypeScript interfaces defining the structure of test scenarios,
 * fixtures, and assertions.
 */

// =============================================================================
// Test Scenario Schema
// =============================================================================

export interface TestScenarioFile {
  name: string;
  description?: string;
  type: 'contract' | 'integration';
  scenarios: TestScenario[];
}

export interface TestScenario {
  name: string;
  description?: string;

  /** Fixture path relative to tests/fixtures/ */
  fixture: string;

  /** Command to execute (e.g., "/workflow/start-specification") */
  command: string;

  /** Optional command arguments */
  args?: string;

  /** Scripted answers to AskUserQuestion prompts */
  choices?: ScriptedChoice[];

  /** Preconditions that must be true before test runs */
  preconditions?: Assertion[];

  /** Postconditions that must be true after test completes */
  assertions: Assertion[];

  /** Files/patterns that must not change during test */
  invariants?: string[];

  /** Test configuration overrides */
  config?: TestConfig;
}

export interface ScriptedChoice {
  /** Fuzzy match string for the question (case-insensitive) */
  match: string;

  /** Answer to provide (string for single-select, array for multi-select) */
  answer: string | string[];

  /** Optional: which question index if multiple questions in one prompt */
  questionIndex?: number;
}

export interface TestConfig {
  /** Timeout in milliseconds */
  timeout?: number;

  /** Model override for this test */
  model?: 'opus' | 'sonnet' | 'haiku';

  /** Number of times to run (for flakiness detection) */
  runs?: number;

  /** Pass threshold when runs > 1 (e.g., "2/3") */
  passThreshold?: string;

  /** Skip this test */
  skip?: boolean;

  /** Only run this test */
  only?: boolean;
}

// =============================================================================
// Assertion Types
// =============================================================================

export type Assertion =
  | ExistsAssertion
  | NotExistsAssertion
  | UnchangedAssertion
  | HasFrontmatterAssertion
  | HasSectionsAssertion
  | ContentMatchesAssertion
  | OutputContainsAssertion
  | FileCountAssertion
  | SemanticAssertion
  | CustomAssertion;

export interface ExistsAssertion {
  exists: string; // File path or glob pattern
}

export interface NotExistsAssertion {
  not_exists: string;
}

export interface UnchangedAssertion {
  unchanged: string; // Glob pattern
}

export interface HasFrontmatterAssertion {
  has_frontmatter: {
    path: string;
    required?: string[];
    values?: Record<string, unknown>;
  };
}

export interface HasSectionsAssertion {
  has_sections: {
    path: string;
    sections: string[]; // Heading text to match (e.g., "## Summary")
  };
}

export interface ContentMatchesAssertion {
  content_matches: {
    path: string;
    pattern: string; // Regex pattern
    flags?: string;  // Regex flags (e.g., "i" for case-insensitive)
  };
}

export interface OutputContainsAssertion {
  output_contains: string | string[];
}

export interface FileCountAssertion {
  file_count: {
    pattern: string; // Glob pattern
    count?: number;  // Exact count
    min?: number;    // Minimum count
    max?: number;    // Maximum count
  };
}

export interface SemanticAssertion {
  semantic: {
    /** Model to use for judging */
    judge_model?: 'haiku' | 'sonnet' | 'opus';

    /** File to evaluate (if not specified, evaluates command output) */
    path?: string;

    /** Criteria the content must satisfy */
    criteria: string[];

    /** Confidence threshold (0-1, default 0.8) */
    threshold?: number;
  };
}

export interface CustomAssertion {
  custom: {
    /** Path to custom validator function */
    validator: string;

    /** Arguments to pass to validator */
    args?: Record<string, unknown>;
  };
}

// =============================================================================
// Fixture Seed Schema
// =============================================================================

export interface FixtureSeed {
  name: string;
  description?: string;

  /** Phases to generate fixtures for */
  phases: {
    research?: PhaseConfig;
    discussion?: PhaseConfig;
    specification?: PhaseConfig;
    planning?: PhaseConfig;
  };
}

export interface PhaseConfig {
  /** Command to run for this phase */
  command: string;

  /** Initial inputs (for research phase or inline context) */
  inputs?: Record<string, string>;

  /** Scripted choices for this phase */
  choices?: ScriptedChoice[];

  /** Skip fixture generation for this phase */
  skip?: boolean;
}

// =============================================================================
// Test Result Schema
// =============================================================================

export interface TestResult {
  scenario: string;
  status: 'passed' | 'failed' | 'skipped' | 'error';
  duration: number;
  assertions: AssertionResult[];
  error?: string;
  output?: string;
}

export interface AssertionResult {
  assertion: Assertion;
  passed: boolean;
  message?: string;
  actual?: unknown;
  expected?: unknown;
}

export interface TestSuiteResult {
  name: string;
  file: string;
  timestamp: string;
  duration: number;
  results: TestResult[];
  summary: {
    total: number;
    passed: number;
    failed: number;
    skipped: number;
  };
}
