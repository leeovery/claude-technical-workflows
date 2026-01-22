/**
 * NLP Skills Test Framework - Choice Interceptor
 *
 * Handles scripted responses to AskUserQuestion tool calls,
 * enabling automated testing of interactive commands.
 */

import type { ScriptedChoice } from './schema.js';

/**
 * Question structure from AskUserQuestion tool
 */
interface AskUserQuestionCall {
  questions: Array<{
    question: string;
    header: string;
    options: Array<{
      label: string;
      description: string;
    }>;
    multiSelect: boolean;
  }>;
}

/**
 * Response structure for AskUserQuestion
 */
interface AskUserQuestionResponse {
  answers: Record<string, string>;
}

/**
 * Interceptor for scripting user choices in tests
 */
export class ChoiceInterceptor {
  private choices: ScriptedChoice[];
  private usedChoices: Set<number> = new Set();
  private callHistory: Array<{
    call: AskUserQuestionCall;
    response: AskUserQuestionResponse;
  }> = [];

  constructor(choices: ScriptedChoice[]) {
    this.choices = choices;
  }

  /**
   * Handle an AskUserQuestion tool call
   *
   * Matches the question against scripted choices and returns
   * the appropriate answer.
   */
  handle(call: AskUserQuestionCall): AskUserQuestionResponse {
    const answers: Record<string, string> = {};

    for (let i = 0; i < call.questions.length; i++) {
      const question = call.questions[i];
      const answer = this.findAnswer(question.question, i);

      // Use the question header as the answer key
      answers[question.header] = answer;
    }

    const response = { answers };
    this.callHistory.push({ call, response });

    return response;
  }

  /**
   * Find a matching scripted answer for a question
   */
  private findAnswer(questionText: string, questionIndex: number): string {
    const questionLower = questionText.toLowerCase();

    for (let i = 0; i < this.choices.length; i++) {
      const choice = this.choices[i];

      // Skip already-used choices (each choice matches once)
      if (this.usedChoices.has(i)) continue;

      // Check index filter if specified
      if (choice.questionIndex !== undefined && choice.questionIndex !== questionIndex) {
        continue;
      }

      // Fuzzy match on question text
      if (questionLower.includes(choice.match.toLowerCase())) {
        this.usedChoices.add(i);

        // Handle array answers (for multiSelect)
        if (Array.isArray(choice.answer)) {
          return choice.answer.join(', ');
        }

        return choice.answer;
      }
    }

    // No match found - return empty string (skip/default)
    console.warn(`[ChoiceInterceptor] No scripted answer for: "${questionText}"`);
    return '';
  }

  /**
   * Get history of all intercepted calls
   */
  getHistory(): typeof this.callHistory {
    return [...this.callHistory];
  }

  /**
   * Get unused choices (helps identify test configuration issues)
   */
  getUnusedChoices(): ScriptedChoice[] {
    return this.choices.filter((_, i) => !this.usedChoices.has(i));
  }

  /**
   * Reset state for reuse
   */
  reset(): void {
    this.usedChoices.clear();
    this.callHistory = [];
  }
}

/**
 * Factory function for creating interceptors with common patterns
 */
export function createInterceptor(choices: ScriptedChoice[]): ChoiceInterceptor {
  return new ChoiceInterceptor(choices);
}

/**
 * Utility to generate choices from a simple map
 *
 * @example
 * const choices = choicesFromMap({
 *   'which topic': 'authentication',
 *   'include all': 'yes',
 * });
 */
export function choicesFromMap(map: Record<string, string | string[]>): ScriptedChoice[] {
  return Object.entries(map).map(([match, answer]) => ({ match, answer }));
}
