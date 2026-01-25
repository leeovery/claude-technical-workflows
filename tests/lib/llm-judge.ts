/**
 * NLP Skills Test Framework - LLM Judge
 *
 * Uses Claude to evaluate content against semantic criteria.
 * Provides deterministic-ish validation for content quality.
 */

import Anthropic from '@anthropic-ai/sdk';

// =============================================================================
// Types
// =============================================================================

export interface JudgeConfig {
  /** Model to use for judging */
  model?: 'haiku' | 'sonnet' | 'opus';

  /** Temperature (lower = more deterministic) */
  temperature?: number;

  /** Maximum tokens for response */
  maxTokens?: number;

  /** Enable verbose logging */
  verbose?: boolean;
}

export interface CriterionResult {
  criterion: string;
  passed: boolean;
  confidence: number;
  reason: string;
}

export interface JudgeResult {
  passed: boolean;
  passRate: number;
  threshold: number;
  criteria: CriterionResult[];
  costUsd: number;
}

// Model mapping
const MODEL_MAP: Record<string, string> = {
  haiku: 'claude-haiku-4-20250514',
  sonnet: 'claude-sonnet-4-20250514',
  opus: 'claude-opus-4-5-20251101',
};

// Approximate costs per 1K tokens (input/output)
const COST_PER_1K: Record<string, { input: number; output: number }> = {
  haiku: { input: 0.00025, output: 0.00125 },
  sonnet: { input: 0.003, output: 0.015 },
  opus: { input: 0.015, output: 0.075 },
};

// =============================================================================
// LLM Judge Class
// =============================================================================

export class LLMJudge {
  private client: Anthropic;
  private config: Required<JudgeConfig>;

  constructor(config: JudgeConfig = {}) {
    this.client = new Anthropic();
    this.config = {
      model: 'haiku',
      temperature: 0,
      maxTokens: 1024,
      verbose: false,
      ...config,
    };
  }

  /**
   * Evaluate content against a list of criteria
   */
  async evaluate(
    content: string,
    criteria: string[],
    threshold: number = 0.8
  ): Promise<JudgeResult> {
    const prompt = this.buildPrompt(content, criteria);

    if (this.config.verbose) {
      console.log(`[LLM Judge] Evaluating ${criteria.length} criteria with ${this.config.model}`);
    }

    const response = await this.client.messages.create({
      model: MODEL_MAP[this.config.model],
      max_tokens: this.config.maxTokens,
      temperature: this.config.temperature,
      messages: [{ role: 'user', content: prompt }],
    });

    // Extract text from response
    const responseText = response.content
      .filter((block): block is Anthropic.TextBlock => block.type === 'text')
      .map(block => block.text)
      .join('');

    // Parse the evaluation results
    const criteriaResults = this.parseResponse(responseText, criteria);

    // Calculate cost
    const inputTokens = response.usage.input_tokens;
    const outputTokens = response.usage.output_tokens;
    const costs = COST_PER_1K[this.config.model];
    const costUsd = (inputTokens * costs.input + outputTokens * costs.output) / 1000;

    // Calculate pass rate
    const passedCount = criteriaResults.filter(r => r.passed).length;
    const passRate = passedCount / criteria.length;
    const passed = passRate >= threshold;

    if (this.config.verbose) {
      console.log(`[LLM Judge] Result: ${passedCount}/${criteria.length} passed (${(passRate * 100).toFixed(0)}%)`);
      console.log(`[LLM Judge] Cost: $${costUsd.toFixed(4)}`);
    }

    return {
      passed,
      passRate,
      threshold,
      criteria: criteriaResults,
      costUsd,
    };
  }

  /**
   * Build the evaluation prompt
   */
  private buildPrompt(content: string, criteria: string[]): string {
    return `You are a strict evaluator assessing content against specific criteria. Be objective and consistent.

<content>
${content}
</content>

<criteria>
${criteria.map((c, i) => `${i + 1}. ${c}`).join('\n')}
</criteria>

For each criterion, evaluate whether the content satisfies it. Be strict but fair.

Respond with a JSON object in this exact format:
{
  "evaluations": [
    {
      "criterion": 1,
      "passed": true,
      "confidence": 0.95,
      "reason": "Brief explanation of why this passes or fails"
    },
    {
      "criterion": 2,
      "passed": false,
      "confidence": 0.85,
      "reason": "Brief explanation of why this passes or fails"
    }
  ]
}

Important:
- "passed" should be true only if the content clearly satisfies the criterion
- "confidence" should be 0.0-1.0 indicating how certain you are
- "reason" should be 1-2 sentences max
- Evaluate each criterion independently
- Do not be lenient - if something is missing or unclear, mark it as failed`;
  }

  /**
   * Parse the LLM response into structured results
   */
  private parseResponse(response: string, criteria: string[]): CriterionResult[] {
    try {
      // Extract JSON from response (handle markdown code blocks)
      const jsonMatch = response.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        console.warn('[LLM Judge] No JSON found in response');
        return criteria.map(c => ({
          criterion: c,
          passed: false,
          confidence: 0,
          reason: 'Failed to parse response',
        }));
      }

      const parsed = JSON.parse(jsonMatch[0]);
      const evaluations = parsed.evaluations || [];

      return criteria.map((criterion, index) => {
        const evaluation = evaluations.find(
          (e: any) => e.criterion === index + 1
        );

        if (!evaluation) {
          return {
            criterion,
            passed: false,
            confidence: 0,
            reason: 'No evaluation returned',
          };
        }

        return {
          criterion,
          passed: Boolean(evaluation.passed),
          confidence: Number(evaluation.confidence) || 0,
          reason: String(evaluation.reason || ''),
        };
      });
    } catch (error) {
      console.warn('[LLM Judge] Failed to parse response:', error);
      return criteria.map(c => ({
        criterion: c,
        passed: false,
        confidence: 0,
        reason: `Parse error: ${error instanceof Error ? error.message : 'Unknown'}`,
      }));
    }
  }
}

