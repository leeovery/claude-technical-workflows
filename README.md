<h1 align="center">Claude Technical Workflows</h1>

<p align="center">
  <strong>Structured Discussion & Planning Skills for Claude Code</strong>
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#the-four-phase-workflow">Workflow</a> •
  <a href="#skills">Skills</a> •
  <a href="#commands">Commands</a> •
  <a href="#how-it-works">How It Works</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## About

A structured approach to technical discussions and implementation planning with Claude Code. These skills enforce a deliberate **discuss-then-plan-then-implement-then-review** workflow that captures context, decisions, and rationale before any code is written—then validates the work against those artifacts.

**Why this matters:** Complex features benefit from thorough discussion before implementation. These skills help you document the *what* and *why* before diving into the *how*—preserving architectural decisions, edge cases, and the reasoning behind choices that would otherwise be lost.

**This is a work in progress.** The workflow is being refined through real-world usage. Expect updates as patterns evolve.

## Installation

```bash
composer require --dev leeovery/claude-technical-workflows
```

That's it. The [Claude Manager](https://github.com/leeovery/claude-manager) handles everything else automatically.

## The Four-Phase Workflow

This package enforces a deliberate progression through four distinct phases:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Discussion    │ ──▶ │    Planning     │ ──▶ │ Implementation  │ ──▶ │     Review      │
│   (Phase 1)     │     │    (Phase 2)    │     │    (Phase 3)    │     │    (Phase 4)    │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ WHAT and WHY    │     │ HOW             │     │ DOING           │     │ VALIDATING      │
│                 │     │                 │     │                 │     │                 │
│ • Architecture  │     │ • Phases        │     │ • Tests first   │     │ • Plan check    │
│ • Decisions     │     │ • Tasks         │     │ • Then code     │     │ • Decision check│
│ • Edge cases    │     │ • Acceptance    │     │ • Commit often  │     │ • Test quality  │
│ • Debates       │     │   criteria      │     │ • Phase gates   │     │ • Code quality  │
│ • Rationale     │     │ • Output format │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘     └─────────────────┘
         ▲                       ▲                       ▲                       ▲
         │                       │                       │                       │
  technical-discussion    technical-planning    technical-implementation  technical-review
```

**Phase 1 - Discussion:** Captures the back-and-forth exploration of a problem. Documents competing solutions, why certain approaches won or lost, edge cases discovered, and the journey to decisions—not just the decisions themselves.

**Phase 2 - Planning:** Transforms discussion documentation into actionable implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats (local markdown, Linear, Backlog.md).

**Phase 3 - Implementation:** Executes the plan using strict TDD. Writes tests first, implements to pass, commits frequently, and stops for user approval between phases.

**Phase 4 - Review:** Validates completed work against discussion decisions and plan acceptance criteria. Provides structured feedback without fixing code directly.

## How It Works

This package depends on [`leeovery/claude-manager`](https://github.com/leeovery/claude-manager), which:

1. **Symlinks skills** into your project's `.claude/skills/` directory
2. **Symlinks commands** into your project's `.claude/commands/` directory
3. **Manages your `.gitignore`** with a deterministic list of linked skills and commands
4. **Handles installation/removal** automatically via Composer hooks

You don't need to configure anything—just install and start discussing.

### Output Structure

Discussion and planning documents are stored in your project:

```
docs/specs/
├── discussions/
│   └── <topic-name>/
│       └── discussion.md      # Phase 1 output
└── plans/
    └── <topic-name>/
        └── plan.md            # Phase 2 output
```

## Skills

| Skill | Phase | Description |
|-------|-------|-------------|
| [**technical-discussion**](skills/technical-discussion/) | 1 | Document technical discussions as expert architect and meeting assistant. Captures context, decisions, edge cases, competing solutions, debates, and rationale. |
| [**technical-planning**](skills/technical-planning/) | 2 | Transform discussion documents into actionable implementation plans with phases, tasks, and acceptance criteria. Supports draft and formal planning paths. |
| [**technical-implementation**](skills/technical-implementation/) | 3 | Execute implementation plans using strict TDD workflow. Writes tests first, implements to pass, commits frequently, and gates phases on user approval. |
| [**technical-review**](skills/technical-review/) | 4 | Review completed implementation against discussion decisions and plan acceptance criteria. Produces structured feedback without fixing code. |

### technical-discussion

Acts as both **expert software architect** (participating in discussions) and **documentation assistant** (capturing them) simultaneously.

**Use when:**
- Discussing or exploring architecture and design decisions
- Working through edge cases before planning
- Documenting technical decisions and their rationale
- Capturing competing solutions and why certain choices were made

**What it captures:**
- Back-and-forth debates showing how decisions were reached
- Small details and edge cases that were discussed
- Competing solutions and why some won over others
- The journey—false paths, "aha" moments, course corrections

### technical-planning

Converts discussion documentation into structured implementation plans. Offers two paths: draft planning (collaborative specification building) or formal planning (direct to phases and tasks).

**Use when:**
- Ready to plan implementation after discussions
- Need to structure how to build something with phases and concrete steps
- Converting discussion insights into actionable developer guidance

**What it produces:**
- Phased implementation plans with specific tasks
- Acceptance criteria at phase and task levels
- Multiple output formats: local markdown, Linear, or Backlog.md

### technical-implementation

Executes plans through strict TDD. Acts as an expert senior developer who builds quality software through disciplined test-driven development.

**Use when:**
- Implementing a plan from `docs/specs/plans/`
- Ad hoc coding that should follow TDD and quality standards
- Bug fixes or features benefiting from structured implementation

**Hard rules:**
- No code before tests—write the failing test first
- No test changes to pass—fix the code, not the tests
- No scope expansion—if it's not in the plan, don't build it
- Commit after green—every passing test is a commit point

### technical-review

Reviews completed work with fresh perspective. Validates implementation against prior workflow artifacts without fixing code directly.

**Use when:**
- Implementation phase is complete
- User wants validation before merging/shipping
- Quality gate check needed after implementation

**What it checks:**
- Were discussion decisions followed?
- Were all plan acceptance criteria met?
- Do tests actually verify requirements?
- Does code follow project conventions?

## Commands

Slash commands to quickly invoke the workflow.

| Command | Description |
|---------|-------------|
| [**/start-discussion**](commands/start-discussion.md) | Begin a new technical discussion. Gathers topic, context, background information, and relevant codebase areas before starting documentation. |
| [**/start-planning**](commands/start-planning.md) | Start a planning session from an existing discussion. Discovers available discussions, offers draft vs formal planning paths, and supports multiple output formats (markdown, Linear, Backlog.md). |

## Requirements

- PHP ^8.2
- [leeovery/claude-manager](https://github.com/leeovery/claude-manager) ^1.0 (installed automatically)

## Contributing

Contributions are welcome! Whether it's:

- **Bug fixes** in the documentation or skill definitions
- **Improvements** to the workflow or templates
- **Discussion** about approaches and trade-offs
- **New skills** that complement the discuss-plan-implement workflow

Please open an issue first to discuss significant changes.

## Related Packages

- [**claude-manager**](https://github.com/leeovery/claude-manager) — The plugin manager that powers skill installation
- [**claude-laravel**](https://github.com/leeovery/claude-laravel) — Laravel development skills for Claude Code

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with care by <a href="https://github.com/leeovery">Lee Overy</a></sub>
</p>
