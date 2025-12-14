<h1 align="center">Claude Technical Workflows</h1>

<p align="center">
  <strong>Structured Discussion & Planning Skills for Claude Code</strong>
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#the-five-phase-workflow">Workflow</a> •
  <a href="#skills">Skills</a> •
  <a href="#commands">Commands</a> •
  <a href="#how-it-works">How It Works</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## About

A structured approach to technical discussions and implementation planning with Claude Code. These skills enforce a deliberate **discuss-then-specify-then-plan-then-implement-then-review** workflow that captures context, decisions, and rationale before any code is written—then validates the work against those artifacts.

**Why this matters:** Complex features benefit from thorough discussion before implementation. These skills help you document the *what* and *why* before diving into the *how*—preserving architectural decisions, edge cases, and the reasoning behind choices that would otherwise be lost.

**This is a work in progress.** The workflow is being refined through real-world usage. Expect updates as patterns evolve.

## Installation

```bash
composer require --dev leeovery/claude-technical-workflows
```

That's it. The [Claude Manager](https://github.com/leeovery/claude-manager) handles everything else automatically.

## The Five-Phase Workflow

This package enforces a deliberate progression through five distinct phases:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Discussion    │ ──▶ │  Specification  │ ──▶ │    Planning     │ ──▶ │ Implementation  │ ──▶ │     Review      │
│   (Phase 1)     │     │    (Phase 2)    │     │    (Phase 3)    │     │    (Phase 4)    │     │    (Phase 5)    │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ WHAT and WHY    │     │ REFINING        │     │ HOW             │     │ DOING           │     │ VALIDATING      │
│                 │     │                 │     │                 │     │                 │     │                 │
│ • Architecture  │     │ • Validate      │     │ • Phases        │     │ • Tests first   │     │ • Plan check    │
│ • Decisions     │     │ • Filter        │     │ • Tasks         │     │ • Then code     │     │ • Decision check│
│ • Edge cases    │     │ • Enrich        │     │ • Acceptance    │     │ • Commit often  │     │ • Test quality  │
│ • Debates       │     │ • Standalone    │     │   criteria      │     │ • Phase gates   │     │ • Code quality  │
│ • Rationale     │     │   spec          │     │ • Output format │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘     └─────────────────┘     └─────────────────┘
         ▲                       ▲                       ▲                       ▲                       ▲
         │                       │                       │                       │                       │
  technical-discussion   technical-specification  technical-planning   technical-implementation  technical-review
```

**Phase 1 - Discussion:** Captures the back-and-forth exploration of a problem. Documents competing solutions, why certain approaches won or lost, edge cases discovered, and the journey to decisions—not just the decisions themselves.

**Phase 2 - Specification:** Transforms discussion documentation into a validated, standalone specification. Filters hallucinations and inaccuracies, enriches gaps through discussion, and builds a document that planning can execute against without referencing other sources.

**Phase 3 - Planning:** Converts specifications into actionable implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats (local markdown, Linear, Backlog.md).

**Phase 4 - Implementation:** Executes the plan using strict TDD. Writes tests first, implements to pass, commits frequently, and stops for user approval between phases.

**Phase 5 - Review:** Validates completed work against discussion decisions, specification requirements, and plan acceptance criteria. Provides structured feedback without fixing code directly.

## How It Works

This package depends on [`leeovery/claude-manager`](https://github.com/leeovery/claude-manager), which:

1. **Symlinks skills** into your project's `.claude/skills/` directory
2. **Symlinks commands** into your project's `.claude/commands/` directory
3. **Manages your `.gitignore`** with a deterministic list of linked skills and commands
4. **Handles installation/removal** automatically via Composer hooks

You don't need to configure anything—just install and start discussing.

### Output Structure

Discussion, specification, and planning documents are stored in your project:

```
docs/specs/
├── discussions/
│   └── <topic-name>/
│       └── discussion.md      # Phase 1 output
├── specifications/
│   └── <topic-name>/
│       └── specification.md   # Phase 2 output
└── plans/
    └── <topic-name>/
        └── plan.md            # Phase 3 output
```

## Skills

| Skill | Phase | Description |
|-------|-------|-------------|
| [**technical-discussion**](skills/technical-discussion/) | 1 | Document technical discussions as expert architect and meeting assistant. Captures context, decisions, edge cases, competing solutions, debates, and rationale. |
| [**technical-specification**](skills/technical-specification/) | 2 | Build validated specifications from discussion documents through collaborative refinement. Filters hallucinations, enriches gaps, produces standalone spec. |
| [**technical-planning**](skills/technical-planning/) | 3 | Transform specifications into actionable implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats. |
| [**technical-implementation**](skills/technical-implementation/) | 4 | Execute implementation plans using strict TDD workflow. Writes tests first, implements to pass, commits frequently, and gates phases on user approval. |
| [**technical-review**](skills/technical-review/) | 5 | Review completed implementation against discussion decisions, specification, and plan acceptance criteria. Produces structured feedback without fixing code. |

### technical-discussion

Acts as both **expert software architect** (participating in discussions) and **documentation assistant** (capturing them) simultaneously.

**Use when:**
- Discussing or exploring architecture and design decisions
- Working through edge cases before specification
- Documenting technical decisions and their rationale
- Capturing competing solutions and why certain choices were made

**What it captures:**
- Back-and-forth debates showing how decisions were reached
- Small details and edge cases that were discussed
- Competing solutions and why some won over others
- The journey—false paths, "aha" moments, course corrections

### technical-specification

Acts as **expert technical architect** and **specification builder**. Transforms discussion documents into validated, standalone specifications.

**Use when:**
- Ready to validate and refine discussion content
- Need to filter potential hallucinations or inaccuracies from source material
- Building a standalone document that planning can execute against
- Converting discussions into verified requirements

**What it produces:**
- Validated, standalone specification document
- Filtered content (hallucinations and inaccuracies removed)
- Enriched content (gaps filled through discussion)
- Clear bridge document for formal planning

### technical-planning

Converts specifications into structured implementation plans.

**Use when:**
- Ready to plan implementation after specification is complete
- Need to structure how to build something with phases and concrete steps
- Converting specification into actionable developer guidance

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
- Were specification requirements implemented?
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
- **New skills** that complement the discuss-specify-plan-implement workflow

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
