<h1 align="center">Claude Technical Workflows</h1>

<p align="center">
  <strong>From Idea to Implementation: Software Engineering Workflows for Claude Code</strong>
</p>

<p align="center">
  <a href="#what-is-this">What is this?</a> •
  <a href="#how-do-i-use-it">How to Use</a> •
  <a href="#installation">Installation</a> •
  <a href="#skills">Skills</a> •
  <a href="#contributing">Contributing</a>
</p>

---

<p align="center">
  <a href="https://leeovery.github.io/claude-technical-workflows/"><strong>Open the Interactive Workflow Explorer</strong></a>
</p>

> **Workflow Explorer** — A visual, interactive guide to every phase and skill in this toolkit. Trace decision logic through flowcharts and understand the full pipeline at a glance. No install required — runs in your browser.

---

## What is this?

A complete development workflow for Claude Code: explore ideas, capture decisions, build actionable plans, implement via strict TDD, and validate the result.

Use it as a **six-phase workflow** or pick individual capabilities as needed:

```
Research → Discussion → Specification → Planning → Implementation → Review
```

**Why this matters:** Complex features benefit from thorough discussion before implementation. This toolkit documents the *what* and *why* before diving into the *how*, preserving architectural decisions, edge cases, and the reasoning behind choices that would otherwise be lost.

**Flexible entry points:** Need the full workflow? Start at Research or Discussion and progress through each phase. Already know what you're building? Jump straight to Specification with `/start-feature`. Entry-point skills gather context and feed it to processing skills.

**Engineered like software.** This isn't a collection of prompts — it's built with the same discipline you'd apply to code. Processing skills follow the single responsibility principle. Entry-point skills compose with them, keeping input gathering DRY. Output formats implement a [5-file adapter contract](#output-formats), so planning works identically regardless of where tasks end up. Agents handle isolated concerns. The result is a natural language workflow that's modular, extensible, and maintainable — software engineering principles applied to agentic workflows.

> [!NOTE]
> **Work in progress.** The workflow is being refined through real-world usage. Expect updates as patterns evolve.

> [!IMPORTANT]
> **Model compatibility:** These skills have been developed and refined for Claude Code running on **Opus 4.5**. Different models may exhibit different edge cases, and future model releases may require adjustments to the prompts and workflows.

### Quick Install

```bash
npm install -D @leeovery/claude-technical-workflows
```

See [Installation](#installation) for details.

## How do I use it?

### Where to Start

Pick your entry point based on where you are:

- **Seeds of an idea?** → Start with `/start-research` *(recommended)*
  You have a rough idea but haven't explored feasibility, alternatives, or scope yet. Research lets you think freely before committing to anything.

- **Know what you're building?** → Start with `/start-discussion`
  You've moved past exploration and want to capture architecture decisions, edge cases, and rationale for specific topics.

- **Clear feature, ready to spec?** → Use `/start-feature`
  You already know the what and why. Jump straight to building a specification from inline context — no prior documents needed.

**Why research is the recommended default:** When you move from research to discussion, the skill analyses your research document and automatically breaks it into focused discussion topics. Skip research and you manage topic structure yourself. That automatic topic breakdown is one of the highest-value transitions in the workflow.

### The Workflow

```
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   Research    │──▶│  Discussion   │──▶│ Specification │
│   (Phase 1)   │   │   (Phase 2)   │   │   (Phase 3)   │
├───────────────┤   ├───────────────┤   ├───────────────┤
│ EXPLORING     │   │ WHAT & WHY    │   │ REFINING      │
│               │   │               │   │               │
│ • Ideas       │   │ • Architecture│   │ • Validate    │
│ • Market      │   │ • Decisions   │   │ • Filter      │
│ • Viability   │   │ • Edge cases  │   │ • Enrich      │
│               │   │ • Rationale   │   │ • Standalone  │
└───────────────┘   └───────────────┘   └───────────────┘
                                                │
                                                ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│    Review     │◀──│Implementation │◀──│   Planning    │
│   (Phase 6)   │   │   (Phase 5)   │   │   (Phase 4)   │
├───────────────┤   ├───────────────┤   ├───────────────┤
│ VALIDATING    │   │ DOING         │   │ HOW           │
│               │   │               │   │               │
│ • Plan check  │   │ • Tests first │   │ • Phases      │
│ • Specs check │   │ • Then code   │   │ • Tasks       │
│ • Test quality│   │ • Commit often│   │ • Criteria    │
│ • Code quality│   │ • Task gates  │   │ • Outputs     │
└───────────────┘   └───────────────┘   └───────────────┘
```

Each phase produces documents that feed the next. Here's the journey:

**Research** — Free-form exploration. Investigate ideas, market fit, technical feasibility, business viability. The output is a research document capturing everything you've explored. The key benefit: when you move to discussion, the skill analyses this document and breaks it into focused topics automatically.

**Discussion** — Per-topic deep dives into architecture, edge cases, competing approaches, and rationale. Each topic gets its own document. This captures not just decisions, but *why* you made them — the alternatives considered, the trade-offs weighed, the journey to the decision. Conclude each topic when its decisions are made.

**Specification** — This is where the magic happens. The skill analyses *all* your discussions and creates intelligent groupings — 10 discussions might become 3–5 specifications, or you can unify everything into one. It filters hallucinations, enriches gaps, and validates decisions against each other. The spec becomes the golden document: planning only references this, not earlier phases.

**Planning** — Converts each specification into phased implementation plans with tasks, acceptance criteria, and dependency ordering. Supports [multiple output formats](#output-formats) — from local markdown files to CLI tools with native dependency graphs. Task authoring has per-item approval gates (with auto-mode for faster flow).

**Implementation** — Executes plans via strict TDD. Tests first, then code, commit after each task. Per-task approval gates keep you in control, with auto-mode available when you trust the flow.

**Review** — Validates the implementation against spec and plan. Catches drift, missing requirements, and quality issues. The spec is the source of truth here — earlier phases may contain rejected ideas that were intentionally filtered out. Produces structured feedback without fixing code directly.

### Standalone Skills

Not every task needs the full workflow. These skills gather inputs flexibly and invoke processing skills directly:

| Skill | What it does |
|-------|-------------|
| `/start-feature` | Create a spec directly from inline context (skip research/discussion) |
| `/link-dependencies` | Wire cross-topic dependencies across plans |

### Under the Hood

Skills are organised in two tiers. **Entry-point skills** (`/start-*`, `/status`, etc.) gather context from files, prompts, or inline input. **Processing skills** (`technical-*`) receive those inputs and do the work — they don't know or care where inputs came from. This means the same processing skill can be invoked from different entry points, and you can create custom entry-point skills that feed them in new ways.

```
  Entry-Point Skills                Processing Skills
  (gather inputs)                   (do the work)

  /start-specification ──┐
                         ├────▶  technical-specification
  /start-feature ────────┘

  /start-planning ───────────▶  technical-planning

  /start-implementation ─────▶  technical-implementation

  (your custom) ─────────────▶  (any processing skill)
```

Entry-point skills are interchangeable — `/start-specification` and `/start-feature` both feed the same processing skill with different inputs.

### Workflow Skills

| Phase          | Skill                   |
|----------------|-------------------------|
| Research       | `/start-research`       |
| Discussion     | `/start-discussion`     |
| Specification  | `/start-specification`  |
| Planning       | `/start-planning`       |
| Implementation | `/start-implementation` |
| Review         | `/start-review`         |

Run the skill directly or ask Claude to run it. Each gathers context from previous phase outputs and passes it to the processing skill.

### Output Formats

Planning supports multiple output formats through an adapter pattern. Each format implements a 5-file contract — about, authoring, reading, updating, and graph — so the planning workflow works identically regardless of where tasks are stored.

| Format | Best for | Setup | |
|--------|----------|-------|-|
| **Tick** | AI-driven workflows, native dependencies, token-efficient | `brew install leeovery/tools/tick` | Recommended |
| **Local Markdown** | Simple features, offline, quick iterations | None | |
| **Linear** | Team collaboration, visual tracking | Linear account + MCP server | |

Choose a format when planning begins. New formats can be scaffolded with `/create-output-format`.

## Installation

```bash
npm install -D @leeovery/claude-technical-workflows
```

Skills are copied to `.claude/` in your project and can be committed, giving you ownership and making them available everywhere including Claude Code for Web.

<details>
<summary>pnpm users</summary>

pnpm doesn't expose binaries from transitive dependencies, so install the manager directly:

```bash
pnpm add -D @leeovery/claude-manager @leeovery/claude-technical-workflows
pnpm approve-builds  # approve when prompted
pnpm install         # triggers postinstall
```
</details>

<details>
<summary>Removal (npm/pnpm)</summary>

Due to bugs in npm 7+ ([issue #3042](https://github.com/npm/cli/issues/3042)) and pnpm ([issue #3276](https://github.com/pnpm/pnpm/issues/3276)), preuninstall hooks don't run reliably. Remove files manually first:

```bash
npx claude-manager remove @leeovery/claude-technical-workflows && npm rm @leeovery/claude-technical-workflows
```
</details>

## Project Structure

### Output Files

Documents are stored in your project using a **phase-first** organisation. Early phases use flat files; later phases use topic directories with multiple files for tracking and analysis.

```
docs/workflow/
├── research/                          # Phase 1 — flat, semantically named
│   ├── exploration.md
│   ├── competitor-analysis.md
│   └── pricing-models.md
├── discussion/                        # Phase 2 — one file per topic
│   └── {topic}.md
├── specification/                     # Phase 3 — directory per topic
│   └── {topic}/
│       └── specification.md
├── planning/                          # Phase 4 — directory per topic
│   └── {topic}/
│       ├── plan.md                    #   Plan index (phases, metadata)
│       └── tasks/                     #   Task files (local-markdown format)
│           ├── {topic}-1-1.md
│           └── {topic}-1-2.md
├── implementation/                    # Phase 5 — directory per topic
│   └── {topic}/
│       └── tracking.md               #   Progress, gates, current task
└── review/                            # Phase 6 — one file per review
    └── {topic}.md
```

Research starts with `exploration.md` and splits into topic files as themes emerge. From specification onwards, each topic gets its own directory. Planning task storage varies by [output format](#output-formats) — the tree above shows local-markdown; Tick and Linear store tasks externally.

### Package Structure

```
skills/
├── # Processing skills (model-invocable)
├── technical-research/              # Explore and validate ideas
├── technical-discussion/            # Document discussions
├── technical-specification/         # Build validated specifications
├── technical-planning/              # Create implementation plans
├── technical-implementation/        # Execute via TDD
├── technical-review/                # Validate against artefacts
│
├── # Entry-point skills (user-invocable)
├── migrate/                         # Keep workflow files in sync with system design
├── start-feature/                   # Standalone: spec from inline context
├── link-dependencies/               # Standalone: wire cross-topic deps
├── start-research/                  # Begin research
├── start-discussion/                # Begin discussions
├── start-specification/             # Begin specification
├── start-planning/                  # Begin planning
├── start-implementation/            # Begin implementation
├── start-review/                    # Begin review
├── status/                          # Show workflow status
└── view-plan/                       # View plan tasks

agents/
├── review-task-verifier.md           # Verifies single task implementation for review
├── implementation-task-executor.md  # TDD executor for single plan tasks
├── implementation-task-reviewer.md  # Post-task review for spec conformance
├── planning-phase-designer.md       # Design phases from specification
├── planning-task-designer.md        # Break phases into task lists
├── planning-task-author.md          # Write full task detail
└── planning-dependency-grapher.md   # Analyze task dependencies and priorities

tests/
└── scripts/                         # Shell script tests for discovery and migrations
```

## Skills

### Processing Skills

Processing skills are **input-agnostic**: they receive inputs and process them without knowing where the inputs came from. This makes them reusable across different entry points and workflows.

| Skill                                                            | Description                                                                                                                                                                                                  |
|------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [**technical-research**](skills/technical-research/)             | Explore ideas from their earliest seed. Investigate market fit, technical feasibility, business viability. Free-flowing exploration across technical, business, and market domains.                          |
| [**technical-discussion**](skills/technical-discussion/)         | Document technical discussions as expert architect and meeting assistant. Captures context, decisions, edge cases, competing solutions, debates, and rationale.                                              |
| [**technical-specification**](skills/technical-specification/)   | Build validated specifications from source material through collaborative refinement. Filters hallucinations, enriches gaps, produces standalone spec.                                                       |
| [**technical-planning**](skills/technical-planning/)             | Transform specifications into actionable implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats.                                                                 |
| [**technical-implementation**](skills/technical-implementation/) | Execute implementation plans using strict TDD workflow. Writes tests first, implements to pass, commits frequently, and gates phases on user approval.                                                       |
| [**technical-review**](skills/technical-review/)                 | Review completed implementation against specification requirements and plan acceptance criteria. Uses parallel subagents for efficient chain verification. Produces structured feedback without fixing code. |

### Entry-Point Skills

Entry-point skills are the input layer: they gather context and pass it to processing skills.

#### Workflow Skills

Sequential skills that expect files from previous phases and pass content to processing skills.

| Skill                                                                        | Description                                                                                                                                                                                                |
|------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [**/start-research**](skills/start-research/)                                | Begin research exploration. For early-stage ideas, feasibility checks, and broad exploration before formal discussion.                                                                                     |
| [**/start-discussion**](skills/start-discussion/)                            | Begin a new technical discussion. Gathers topic, context, background information, and relevant codebase areas before starting documentation.                                                               |
| [**/start-specification**](skills/start-specification/)                      | Start a specification session from existing discussion(s). Automatically analyses multiple discussions for natural groupings and consolidates them into unified specifications.                            |
| [**/start-planning**](skills/start-planning/)                                | Start a planning session from an existing specification. Creates implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats. |
| [**/start-implementation**](skills/start-implementation/)                    | Start implementing a plan. Executes tasks via strict TDD, committing after each passing test.                                                                                                              |
| [**/start-review**](skills/start-review/)                                    | Start reviewing completed work. Validates implementation against plan tasks and acceptance criteria.                                                                                                        |

#### Utility Skills

Helpers for navigating and maintaining the workflow.

| Skill                                                                        | Description                                                                                                                                 |
|------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| [**/migrate**](skills/migrate/)                                              | Keep workflow files in sync with the current system design. Runs automatically at the start of every workflow skill.                        |
| [**/status**](skills/status/)                                                | Show workflow status with relationship-aware display — specification sources, unlinked discussions, plan dependencies, and suggested next steps. |
| [**/view-plan**](skills/view-plan/)                                          | View a plan's tasks and progress, regardless of output format.                                                                              |

#### Standalone Skills

Independent skills that gather inputs flexibly (inline context, files, or prompts) and invoke processing skills directly. Use these when you want capabilities without the full workflow structure.

| Skill                                                   | Description                                                                                                                                 |
|---------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| [**/start-feature**](skills/start-feature/)              | Create a specification directly from inline context. Invokes the specification skill without requiring a discussion document.              |
| [**/link-dependencies**](skills/link-dependencies/)      | Link external dependencies across topics. Scans plans and wires up unresolved cross-topic dependencies.                                    |

### Creating Custom Skills

Since processing skills are input-agnostic, you can create your own entry-point skills that feed them in new ways. An entry-point skill just needs to:

1. Gather the inputs the processing skill expects
2. Invoke the processing skill with those inputs

See `/start-feature` as an example: it provides inline context to the specification skill instead of a discussion document.

## Agents

Subagents that skills can spawn for parallel task execution.

| Agent | Used By | Description |
|-------|---------|-------------|
| [**review-task-verifier**](agents/review-task-verifier.md) | technical-review | Verifies a single plan task was implemented correctly. Checks implementation, tests, and code quality. Multiple run in parallel. |
| [**implementation-task-executor**](agents/implementation-task-executor.md) | technical-implementation | Implements a single plan task via strict TDD. |
| [**implementation-task-reviewer**](agents/implementation-task-reviewer.md) | technical-implementation | Reviews a completed task for spec conformance, acceptance criteria, and architectural quality. |
| [**planning-phase-designer**](agents/planning-phase-designer.md) | technical-planning | Designs implementation phases from a specification. |
| [**planning-task-designer**](agents/planning-task-designer.md) | technical-planning | Breaks a single phase into a task list with edge cases. |
| [**planning-task-author**](agents/planning-task-author.md) | technical-planning | Writes full detail for a single plan task. |
| [**planning-dependency-grapher**](agents/planning-dependency-grapher.md) | technical-planning | Analyzes authored tasks to establish internal dependencies and priorities. |

## Requirements

- Node.js 18+
- [@leeovery/claude-manager](https://github.com/leeovery/claude-manager) ^2.0.0 (installed automatically)

## Contributing

Contributions are welcome! Whether it's:

- **Bug fixes** in the documentation or skill definitions
- **Improvements** to the workflow or templates
- **Discussion** about approaches and trade-offs
- **New skills** that complement the discuss-specify-plan-implement workflow

Please open an issue first to discuss significant changes.

## Related Packages

- [**@leeovery/claude-manager**](https://github.com/leeovery/claude-manager) - The plugin manager that powers skill installation
- [**@leeovery/claude-laravel**](https://github.com/leeovery/claude-laravel) - Laravel development skills for Claude Code
- [**@leeovery/claude-nuxt**](https://github.com/leeovery/claude-nuxt) - Nuxt.js development skills for Claude Code

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with care by <a href="https://github.com/leeovery">Lee Overy</a></sub>
</p>
