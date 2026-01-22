/**
 * NLP Skills Test Framework - Validators
 *
 * Implements assertion validation logic for both deterministic
 * structural checks and LLM-based semantic validation.
 */

import * as fs from 'fs';
import * as path from 'path';
import { glob } from 'glob';
import * as yaml from 'yaml';

import type {
  Assertion,
  AssertionResult,
  ExistsAssertion,
  NotExistsAssertion,
  UnchangedAssertion,
  HasFrontmatterAssertion,
  HasSectionsAssertion,
  ContentMatchesAssertion,
  OutputContainsAssertion,
  FileCountAssertion,
  SemanticAssertion,
} from './schema';

// =============================================================================
// Validator Interface
// =============================================================================

export interface ValidationContext {
  /** Working directory (fixture copy) */
  workDir: string;

  /** Original fixture directory (for unchanged checks) */
  fixtureDir: string;

  /** Claude's output from command execution */
  output: string;

  /** File state before test ran */
  preTestState: Map<string, string>;
}

// =============================================================================
// Main Validation Function
// =============================================================================

export async function validateAssertion(
  assertion: Assertion,
  context: ValidationContext
): Promise<AssertionResult> {
  try {
    if ('exists' in assertion) {
      return validateExists(assertion, context);
    }
    if ('not_exists' in assertion) {
      return validateNotExists(assertion, context);
    }
    if ('unchanged' in assertion) {
      return validateUnchanged(assertion, context);
    }
    if ('has_frontmatter' in assertion) {
      return validateHasFrontmatter(assertion, context);
    }
    if ('has_sections' in assertion) {
      return validateHasSections(assertion, context);
    }
    if ('content_matches' in assertion) {
      return validateContentMatches(assertion, context);
    }
    if ('output_contains' in assertion) {
      return validateOutputContains(assertion, context);
    }
    if ('file_count' in assertion) {
      return validateFileCount(assertion, context);
    }
    if ('semantic' in assertion) {
      return await validateSemantic(assertion, context);
    }
    if ('custom' in assertion) {
      return { assertion, passed: false, message: 'Custom validators not yet implemented' };
    }

    return { assertion, passed: false, message: 'Unknown assertion type' };
  } catch (error) {
    return {
      assertion,
      passed: false,
      message: `Validator error: ${error instanceof Error ? error.message : String(error)}`,
    };
  }
}

// =============================================================================
// Deterministic Validators
// =============================================================================

function validateExists(
  assertion: ExistsAssertion,
  context: ValidationContext
): AssertionResult {
  const pattern = assertion.exists;
  const fullPattern = path.join(context.workDir, pattern);

  // Check if it's a glob pattern or direct path
  if (pattern.includes('*')) {
    const matches = glob.sync(fullPattern);
    const passed = matches.length > 0;
    return {
      assertion,
      passed,
      message: passed
        ? `Found ${matches.length} file(s) matching ${pattern}`
        : `No files found matching ${pattern}`,
      actual: matches.length,
    };
  }

  const exists = fs.existsSync(fullPattern);
  return {
    assertion,
    passed: exists,
    message: exists ? `File exists: ${pattern}` : `File not found: ${pattern}`,
  };
}

function validateNotExists(
  assertion: NotExistsAssertion,
  context: ValidationContext
): AssertionResult {
  const pattern = assertion.not_exists;
  const fullPattern = path.join(context.workDir, pattern);

  if (pattern.includes('*')) {
    const matches = glob.sync(fullPattern);
    const passed = matches.length === 0;
    return {
      assertion,
      passed,
      message: passed
        ? `No files matching ${pattern} (expected)`
        : `Found ${matches.length} file(s) matching ${pattern} (unexpected)`,
      actual: matches.length,
    };
  }

  const exists = fs.existsSync(fullPattern);
  return {
    assertion,
    passed: !exists,
    message: exists ? `File exists (unexpected): ${pattern}` : `File does not exist (expected): ${pattern}`,
  };
}

function validateUnchanged(
  assertion: UnchangedAssertion,
  context: ValidationContext
): AssertionResult {
  const pattern = assertion.unchanged;
  const fullPattern = path.join(context.workDir, pattern);
  const matches = glob.sync(fullPattern);

  const changedFiles: string[] = [];

  for (const filePath of matches) {
    const relativePath = path.relative(context.workDir, filePath);
    const currentContent = fs.readFileSync(filePath, 'utf-8');
    const originalContent = context.preTestState.get(relativePath);

    if (originalContent === undefined) {
      // File was created during test - this counts as changed
      changedFiles.push(`${relativePath} (new file)`);
    } else if (currentContent !== originalContent) {
      changedFiles.push(relativePath);
    }
  }

  const passed = changedFiles.length === 0;
  return {
    assertion,
    passed,
    message: passed
      ? `All files matching ${pattern} unchanged`
      : `Changed files: ${changedFiles.join(', ')}`,
    actual: changedFiles,
  };
}

function validateHasFrontmatter(
  assertion: HasFrontmatterAssertion,
  context: ValidationContext
): AssertionResult {
  const { path: filePath, required, values } = assertion.has_frontmatter;
  const fullPath = path.join(context.workDir, filePath);

  if (!fs.existsSync(fullPath)) {
    return { assertion, passed: false, message: `File not found: ${filePath}` };
  }

  const content = fs.readFileSync(fullPath, 'utf-8');
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);

  if (!frontmatterMatch) {
    return { assertion, passed: false, message: `No frontmatter found in ${filePath}` };
  }

  try {
    const frontmatter = yaml.parse(frontmatterMatch[1]);
    const errors: string[] = [];

    // Check required fields
    if (required) {
      for (const field of required) {
        if (!(field in frontmatter)) {
          errors.push(`Missing required field: ${field}`);
        }
      }
    }

    // Check specific values
    if (values) {
      for (const [key, expectedValue] of Object.entries(values)) {
        if (frontmatter[key] !== expectedValue) {
          errors.push(`Field ${key}: expected ${expectedValue}, got ${frontmatter[key]}`);
        }
      }
    }

    const passed = errors.length === 0;
    return {
      assertion,
      passed,
      message: passed ? 'Frontmatter valid' : errors.join('; '),
      actual: frontmatter,
      expected: { required, values },
    };
  } catch (e) {
    return { assertion, passed: false, message: `Invalid YAML frontmatter: ${e}` };
  }
}

function validateHasSections(
  assertion: HasSectionsAssertion,
  context: ValidationContext
): AssertionResult {
  const { path: filePath, sections } = assertion.has_sections;
  const fullPath = path.join(context.workDir, filePath);

  if (!fs.existsSync(fullPath)) {
    return { assertion, passed: false, message: `File not found: ${filePath}` };
  }

  const content = fs.readFileSync(fullPath, 'utf-8');
  const missingSections: string[] = [];

  for (const section of sections) {
    // Match heading exactly or as prefix (e.g., "## Summary" matches "## Summary of Changes")
    const pattern = new RegExp(`^${escapeRegex(section)}`, 'm');
    if (!pattern.test(content)) {
      missingSections.push(section);
    }
  }

  const passed = missingSections.length === 0;
  return {
    assertion,
    passed,
    message: passed
      ? `All sections found: ${sections.join(', ')}`
      : `Missing sections: ${missingSections.join(', ')}`,
    actual: missingSections,
    expected: sections,
  };
}

function validateContentMatches(
  assertion: ContentMatchesAssertion,
  context: ValidationContext
): AssertionResult {
  const { path: filePath, pattern, flags } = assertion.content_matches;
  const fullPath = path.join(context.workDir, filePath);

  if (!fs.existsSync(fullPath)) {
    return { assertion, passed: false, message: `File not found: ${filePath}` };
  }

  const content = fs.readFileSync(fullPath, 'utf-8');
  const regex = new RegExp(pattern, flags);
  const passed = regex.test(content);

  return {
    assertion,
    passed,
    message: passed
      ? `Content matches pattern: ${pattern}`
      : `Content does not match pattern: ${pattern}`,
  };
}

function validateOutputContains(
  assertion: OutputContainsAssertion,
  context: ValidationContext
): AssertionResult {
  const needles = Array.isArray(assertion.output_contains)
    ? assertion.output_contains
    : [assertion.output_contains];

  const missing: string[] = [];
  const outputLower = context.output.toLowerCase();

  for (const needle of needles) {
    if (!outputLower.includes(needle.toLowerCase())) {
      missing.push(needle);
    }
  }

  const passed = missing.length === 0;
  return {
    assertion,
    passed,
    message: passed
      ? `Output contains all expected text`
      : `Output missing: ${missing.join(', ')}`,
    actual: missing,
    expected: needles,
  };
}

function validateFileCount(
  assertion: FileCountAssertion,
  context: ValidationContext
): AssertionResult {
  const { pattern, count, min, max } = assertion.file_count;
  const fullPattern = path.join(context.workDir, pattern);
  const matches = glob.sync(fullPattern);
  const actual = matches.length;

  let passed = true;
  const checks: string[] = [];

  if (count !== undefined) {
    passed = passed && actual === count;
    checks.push(`count=${count}`);
  }
  if (min !== undefined) {
    passed = passed && actual >= min;
    checks.push(`min=${min}`);
  }
  if (max !== undefined) {
    passed = passed && actual <= max;
    checks.push(`max=${max}`);
  }

  return {
    assertion,
    passed,
    message: passed
      ? `File count ${actual} satisfies ${checks.join(', ')}`
      : `File count ${actual} does not satisfy ${checks.join(', ')}`,
    actual,
    expected: { count, min, max },
  };
}

// =============================================================================
// Semantic Validator (LLM-based)
// =============================================================================

async function validateSemantic(
  assertion: SemanticAssertion,
  context: ValidationContext
): Promise<AssertionResult> {
  const { judge_model = 'haiku', path: filePath, criteria, threshold = 0.8 } = assertion.semantic;

  // Get content to evaluate
  let content: string;
  if (filePath) {
    const fullPath = path.join(context.workDir, filePath);
    if (!fs.existsSync(fullPath)) {
      return { assertion, passed: false, message: `File not found: ${filePath}` };
    }
    content = fs.readFileSync(fullPath, 'utf-8');
  } else {
    content = context.output;
  }

  // Build judge prompt
  const judgePrompt = buildJudgePrompt(content, criteria);

  // Call LLM judge
  // Note: This is a placeholder - actual implementation needs Anthropic SDK
  const judgeResult = await callLLMJudge(judge_model, judgePrompt);

  const passedCriteria = judgeResult.filter((r) => r.passed).length;
  const totalCriteria = criteria.length;
  const passRate = passedCriteria / totalCriteria;
  const passed = passRate >= threshold;

  return {
    assertion,
    passed,
    message: passed
      ? `Semantic check passed (${passedCriteria}/${totalCriteria} criteria met)`
      : `Semantic check failed (${passedCriteria}/${totalCriteria} criteria met, need ${Math.ceil(threshold * totalCriteria)})`,
    actual: judgeResult,
    expected: { criteria, threshold },
  };
}

function buildJudgePrompt(content: string, criteria: string[]): string {
  return `You are evaluating content against specific criteria. For each criterion, determine if the content satisfies it.

<content>
${content}
</content>

<criteria>
${criteria.map((c, i) => `${i + 1}. ${c}`).join('\n')}
</criteria>

For each criterion, respond with a JSON object:
{
  "evaluations": [
    {"criterion": 1, "passed": true/false, "reason": "brief explanation"},
    {"criterion": 2, "passed": true/false, "reason": "brief explanation"},
    ...
  ]
}

Be strict but fair. The content must clearly satisfy the criterion to pass.`;
}

interface CriterionResult {
  criterion: number;
  passed: boolean;
  reason: string;
}

async function callLLMJudge(
  model: 'haiku' | 'sonnet' | 'opus',
  prompt: string
): Promise<CriterionResult[]> {
  // Placeholder implementation
  // In production, this would use @anthropic-ai/sdk

  console.log(`[LLM Judge] Would call ${model} with prompt length: ${prompt.length}`);

  // For now, return a placeholder that indicates LLM judging is needed
  throw new Error(
    'LLM judge not implemented. Install @anthropic-ai/sdk and set ANTHROPIC_API_KEY.'
  );
}

// =============================================================================
// Utilities
// =============================================================================

function escapeRegex(string: string): string {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// =============================================================================
// Exports
// =============================================================================

export {
  validateExists,
  validateNotExists,
  validateUnchanged,
  validateHasFrontmatter,
  validateHasSections,
  validateContentMatches,
  validateOutputContains,
  validateFileCount,
  validateSemantic,
};
