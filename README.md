# claude-technical-workflows

Claude Code skills for structured discussion and planning workflows.

## Installation

```bash
composer require --dev leeovery/claude-technical-workflows
```

## Skills

### discussion-documentation

Documents technical discussions as a high-level meeting assistant. Captures context, decisions, edge cases, competing solutions, and rationale without jumping to planning or implementation.

**Use when:**
- Discussing architecture/design decisions
- Exploring multiple approaches
- Working through edge cases before planning
- Capturing back-and-forth debates and why certain choices won

**Output:** Creates documentation in `plan/discussion/` that enables planning teams to build solid architectural plans.

### Coming Soon

**planning** - Creates implementation plans from discussion documentation
