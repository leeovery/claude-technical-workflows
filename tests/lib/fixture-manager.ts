/**
 * NLP Skills Test Framework - Fixture Manager
 *
 * Handles fixture setup, teardown, and state capture for tests.
 */

import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';
import { glob } from 'glob';

export class FixtureManager {
  public readonly fixturesDir: string;
  private tempDirs: Set<string> = new Set();

  constructor(fixturesDir: string) {
    this.fixturesDir = fixturesDir;
  }

  /**
   * Setup a fixture for testing
   *
   * Creates a temporary copy of the fixture directory that tests can modify
   * without affecting the original fixture.
   *
   * @param fixturePath Path relative to fixtures directory
   * @returns Path to temporary working directory
   */
  async setup(fixturePath: string): Promise<string> {
    const sourceDir = path.join(this.fixturesDir, fixturePath);

    if (!fs.existsSync(sourceDir)) {
      throw new Error(`Fixture not found: ${fixturePath}`);
    }

    // Create temp directory
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'nlp-test-'));
    this.tempDirs.add(tempDir);

    // Copy fixture to temp directory
    await this.copyDirectory(sourceDir, tempDir);

    // Initialize git if needed (some commands may expect a git repo)
    const gitDir = path.join(tempDir, '.git');
    if (!fs.existsSync(gitDir)) {
      fs.mkdirSync(gitDir, { recursive: true });
      fs.writeFileSync(path.join(gitDir, 'config'), '[core]\n\tbare = false\n');
    }

    return tempDir;
  }

  /**
   * Teardown a test working directory
   */
  async teardown(workDir: string): Promise<void> {
    if (this.tempDirs.has(workDir)) {
      await this.removeDirectory(workDir);
      this.tempDirs.delete(workDir);
    }
  }

  /**
   * Cleanup all temporary directories (call on process exit)
   */
  async cleanupAll(): Promise<void> {
    for (const dir of this.tempDirs) {
      try {
        await this.removeDirectory(dir);
      } catch {
        // Ignore cleanup errors
      }
    }
    this.tempDirs.clear();
  }

  /**
   * Capture current state of all files in directory
   *
   * Used for "unchanged" assertions to compare before/after state.
   */
  captureState(dir: string): Map<string, string> {
    const state = new Map<string, string>();
    const files = glob.sync('**/*', { cwd: dir, nodir: true, dot: true });

    for (const file of files) {
      // Skip git internals
      if (file.startsWith('.git/')) continue;

      const fullPath = path.join(dir, file);
      try {
        const content = fs.readFileSync(fullPath, 'utf-8');
        state.set(file, content);
      } catch {
        // Skip files that can't be read as text
      }
    }

    return state;
  }

  /**
   * Compare current state to captured state
   *
   * @returns Object with added, modified, and removed files
   */
  compareState(
    dir: string,
    previousState: Map<string, string>
  ): { added: string[]; modified: string[]; removed: string[] } {
    const currentState = this.captureState(dir);
    const added: string[] = [];
    const modified: string[] = [];
    const removed: string[] = [];

    // Check for added or modified files
    for (const [file, content] of currentState) {
      const previous = previousState.get(file);
      if (previous === undefined) {
        added.push(file);
      } else if (previous !== content) {
        modified.push(file);
      }
    }

    // Check for removed files
    for (const file of previousState.keys()) {
      if (!currentState.has(file)) {
        removed.push(file);
      }
    }

    return { added, modified, removed };
  }

  /**
   * Copy directory recursively
   */
  private async copyDirectory(src: string, dest: string): Promise<void> {
    const entries = fs.readdirSync(src, { withFileTypes: true });

    for (const entry of entries) {
      const srcPath = path.join(src, entry.name);
      const destPath = path.join(dest, entry.name);

      if (entry.isDirectory()) {
        fs.mkdirSync(destPath, { recursive: true });
        await this.copyDirectory(srcPath, destPath);
      } else {
        fs.copyFileSync(srcPath, destPath);
      }
    }
  }

  /**
   * Remove directory recursively
   */
  private async removeDirectory(dir: string): Promise<void> {
    fs.rmSync(dir, { recursive: true, force: true });
  }
}

// Note: For multi-manager cleanup, call fixtureManager.cleanupAll() explicitly
// in your process exit handlers.
