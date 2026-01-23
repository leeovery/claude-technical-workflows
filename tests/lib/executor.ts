/**
 * NLP Skills Test Framework - Claude Agent SDK Executor
 *
 * Executes commands via the Claude Agent SDK and captures outputs.
 * Handles tool interception for scripted test scenarios.
 */

import { query, type Message } from '@anthropic-ai/claude-agent-sdk';
import type { ScriptedChoice } from './schema.js';
import { ChoiceInterceptor } from './choice-interceptor.js';

// =============================================================================
// Types
// =============================================================================

export interface ExecutorConfig {
  /** Model to use for execution */
  model?: 'claude-opus-4-5-20251101' | 'claude-sonnet-4-20250514' | 'claude-haiku-3-5-20241022';

  /** Working directory for the test */
  cwd: string;

  /** Timeout in milliseconds */
  timeout?: number;

  /** Maximum turns before stopping */
  maxTurns?: number;

  /** Maximum budget in USD (only applies to API key auth) */
  maxBudgetUsd?: number;

  /** Enable verbose logging */
  verbose?: boolean;

  /** Permission mode */
  permissionMode?: 'default' | 'acceptEdits' | 'bypassPermissions';
}

// Note: Authentication is automatic via Claude Code:
// - ANTHROPIC_API_KEY env var if set
// - Otherwise uses Claude Code's existing OAuth auth

export interface ExecutionResult {
  /** All text output from Claude */
  output: string;

  /** Whether execution completed successfully */
  success: boolean;

  /** Error message if failed */
  error?: string;

  /** Total cost in USD */
  costUsd: number;

  /** Number of turns taken */
  turns: number;

  /** Tool calls made during execution */
  toolCalls: ToolCallRecord[];

  /** Questions asked via AskUserQuestion */
  questionsAsked: QuestionRecord[];

  /** Final result status */
  status: string;
}

export interface ToolCallRecord {
  tool: string;
  input: unknown;
  output?: unknown;
  approved: boolean;
}

export interface QuestionRecord {
  questions: Array<{
    question: string;
    header: string;
    options: Array<{ label: string; description: string }>;
  }>;
  answers: Record<string, string>;
}

// =============================================================================
// Executor Class
// =============================================================================

export class ClaudeExecutor {
  private config: ExecutorConfig;

  constructor(config: ExecutorConfig) {
    this.config = {
      model: 'claude-opus-4-5-20251101',
      timeout: 120000,
      maxTurns: 50,
      maxBudgetUsd: 1.0,
      verbose: false,
      permissionMode: 'acceptEdits',
      ...config,
    };
  }

  /**
   * Execute a command with scripted choices
   */
  async execute(
    command: string,
    choices: ScriptedChoice[] = []
  ): Promise<ExecutionResult> {
    const interceptor = new ChoiceInterceptor(choices);
    const toolCalls: ToolCallRecord[] = [];
    const questionsAsked: QuestionRecord[] = [];
    const outputParts: string[] = [];

    let success = false;
    let error: string | undefined;
    let costUsd = 0;
    let turns = 0;
    let status = 'unknown';

    try {
      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(() => reject(new Error('Execution timeout')), this.config.timeout);
      });

      const executionPromise = this.runQuery(
        command,
        interceptor,
        toolCalls,
        questionsAsked,
        outputParts
      );

      const result = await Promise.race([executionPromise, timeoutPromise]);

      success = result.success;
      costUsd = result.costUsd;
      turns = result.turns;
      status = result.status;

    } catch (err) {
      error = err instanceof Error ? err.message : String(err);
      success = false;
      status = 'error';
    }

    // Check for unused choices (potential test configuration issue)
    const unusedChoices = interceptor.getUnusedChoices();
    if (unusedChoices.length > 0 && this.config.verbose) {
      console.warn(
        `[Executor] Unused scripted choices: ${unusedChoices.map(c => c.match).join(', ')}`
      );
    }

    return {
      output: outputParts.join('\n'),
      success,
      error,
      costUsd,
      turns,
      toolCalls,
      questionsAsked,
      status,
    };
  }

  /**
   * Run the actual query against Claude Agent SDK
   */
  private async runQuery(
    command: string,
    interceptor: ChoiceInterceptor,
    toolCalls: ToolCallRecord[],
    questionsAsked: QuestionRecord[],
    outputParts: string[]
  ): Promise<{ success: boolean; costUsd: number; turns: number; status: string }> {
    let costUsd = 0;
    let turns = 0;
    let status = 'unknown';

    // Build query options based on auth mode
    const queryOptions: Record<string, unknown> = {
      model: this.config.model,
      cwd: this.config.cwd,
      maxTurns: this.config.maxTurns,
      permissionMode: this.config.permissionMode,

      // Load project settings (CLAUDE.md, skills, commands)
      settingSources: ['project'],

      // Tool interception for AskUserQuestion and recording
      canUseTool: async (toolName: string, input: unknown) => {
        return this.handleToolCall(
          toolName,
          input,
          interceptor,
          toolCalls,
          questionsAsked
        );
      },
    };

    // Add budget limit (applies when using API key, ignored for subscriptions)
    if (this.config.maxBudgetUsd) {
      queryOptions.maxBudgetUsd = this.config.maxBudgetUsd;
    }

    // Note: Authentication is handled automatically by the SDK:
    // - Uses ANTHROPIC_API_KEY from environment if available
    // - Otherwise uses Claude Code's existing auth (OAuth/subscription)
    // The SDK spawns a Claude Code process that inherits auth from the environment

    for await (const message of query({
      prompt: command,
      options: queryOptions as any,
    })) {
      this.processMessage(message, outputParts);

      // Extract final result info
      if (message.type === 'result') {
        costUsd = (message as any).total_cost_usd || 0;
        status = (message as any).subtype || 'completed';
        turns = (message as any).num_turns || turns;
      }
    }

    return {
      success: status === 'success' || status === 'completed',
      costUsd,
      turns,
      status,
    };
  }

  /**
   * Handle tool calls - intercept AskUserQuestion, record all calls
   */
  private async handleToolCall(
    toolName: string,
    input: unknown,
    interceptor: ChoiceInterceptor,
    toolCalls: ToolCallRecord[],
    questionsAsked: QuestionRecord[]
  ): Promise<{ behavior: 'allow' | 'deny'; updatedInput: unknown }> {
    if (this.config.verbose) {
      console.log(`[Executor] Tool call: ${toolName}`);
    }

    // Handle AskUserQuestion with scripted responses
    if (toolName === 'AskUserQuestion') {
      const askInput = input as {
        questions: Array<{
          question: string;
          header: string;
          options: Array<{ label: string; description: string }>;
          multiSelect: boolean;
        }>;
      };

      // Use interceptor to get scripted answers
      const response = interceptor.handle(askInput);

      // Record the question and answer
      questionsAsked.push({
        questions: askInput.questions,
        answers: response.answers,
      });

      // Record tool call
      toolCalls.push({
        tool: toolName,
        input,
        output: response,
        approved: true,
      });

      return {
        behavior: 'allow',
        updatedInput: {
          questions: askInput.questions,
          answers: response.answers,
        },
      };
    }

    // Record other tool calls
    toolCalls.push({
      tool: toolName,
      input,
      approved: true,
    });

    // Allow all other tools (permissionMode handles most cases)
    return { behavior: 'allow', updatedInput: input };
  }

  /**
   * Process messages from the query stream
   */
  private processMessage(message: Message, outputParts: string[]): void {
    if (message.type === 'assistant' && message.message?.content) {
      for (const block of message.message.content) {
        if ('text' in block && typeof block.text === 'string') {
          outputParts.push(block.text);

          if (this.config.verbose) {
            console.log(`[Claude] ${block.text.substring(0, 100)}...`);
          }
        }
      }
    }

    if (message.type === 'system' && this.config.verbose) {
      console.log(`[System] Session: ${(message as any).session_id}`);
    }
  }
}

// =============================================================================
// Convenience Function
// =============================================================================

/**
 * Execute a command with default settings
 */
export async function executeCommand(
  command: string,
  choices: ScriptedChoice[],
  cwd: string,
  options: Partial<ExecutorConfig> = {}
): Promise<ExecutionResult> {
  const executor = new ClaudeExecutor({ cwd, ...options });
  return executor.execute(command, choices);
}
