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

## What is this?

A six-phase workflow for Claude Code that captures context, decisions, and rationale before any code is written, then implements and validates the work against those artifacts.

```
Research       → Explore ideas
     ↓
Discussion     → Debate and decide
     ↓
Specification  → Validate and refine
     ↓
Planning       → Structure the work
     ↓
Implementation → Build via TDD
     ↓
Review         → Validate against spec
```

**Why this matters:** Complex features benefit from thorough discussion before implementation. These skills help you document the *what* and *why* before diving into the *how*, preserving architectural decisions, edge cases, and the reasoning behind choices that would otherwise be lost.

**This is a work in progress.** The workflow is being refined through real-world usage. Expect updates as patterns evolve.

**Model compatibility:** These skills have been developed and refined for Claude Code running on **Opus 4.5**. Different models may exhibit different edge cases, and future model releases may require adjustments to the prompts and workflows.

### Quick Install

**Marketplace** (cached globally):
```
/plugin marketplace add leeovery/claude-plugins-marketplace
/plugin install claude-technical-workflows@claude-plugins-marketplace
```

**npm** (copied to your repo):
```bash
npm install -D @leeovery/claude-technical-workflows
```

See [Installation](#installation) for details and trade-offs.

## How do I use it?

You have two entry points:

| Start here... | When... | Command |
|---------------|---------|---------|
| **Research** | You have a fresh idea to explore: feasibility, market, viability, early thoughts | `/start-research` |
| **Discussion** | You already know what you're building and need to iron out the details | `/start-discussion` |

**Research** is a free-for-all. Explore broadly, follow tangents, challenge assumptions. Not everything researched gets built, and that's fine. Use this for ideas that need validating before you commit.

**Discussion** is where you work through the challenging parts: core architecture, edge cases, non-obvious decisions. The key value is that it captures *how* you arrived at decisions, not just the decisions themselves. When you explore four approaches and pick one, the document explains why you rejected the others. This context is invaluable later.

Then follow the flow:

```
Research → Discussion → Specification → Planning → Implementation → Review
```

Each phase builds on the previous. Specification validates your discussions into a standalone doc. Planning breaks that into tasks. Implementation executes via TDD. Review validates against the spec.

### Commands

Each phase has a command designed as its entry point:

| Phase          | Command                 |
|----------------|-------------------------|
| Research       | `/start-research`       |
| Discussion     | `/start-discussion`     |
| Specification  | `/start-specification`  |
| Planning       | `/start-planning`       |
| Implementation | `/start-implementation` |

Run the command directly or ask Claude to run it. Each command gathers the context it needs, asking what you're researching, discussing, or planning. Where relevant, it looks at outputs from the previous phase and offers you a choice from the list.

## Installation

| Method | Where files live | Best for |
|--------|------------------|----------|
| **Marketplace** | `~/.claude/plugins/` (global cache) | Quick setup, don't need files in repo |
| **npm** | `.claude/` in your project | Ownership, version control, Claude Code for Web |

### Option 1: Claude Marketplace

```
/plugin marketplace add leeovery/claude-plugins-marketplace
/plugin install claude-technical-workflows@claude-plugins-marketplace
```

Skills are cached globally. They won't be available in Claude Code for Web since files aren't in your repository.

### Option 2: npm

```bash
npm install -D @leeovery/claude-technical-workflows
```

Skills are copied to `.claude/` and can be committed—giving you ownership and making them available everywhere including Claude Code for Web.

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

## The Six-Phase Workflow

This package enforces a deliberate progression through six distinct phases:

```
┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   Research    │──▶│  Discussion   │──▶│ Specification │──▶│   Planning    │──▶│Implementation │──▶│    Review     │
│   (Phase 1)   │   │   (Phase 2)   │   │   (Phase 3)   │   │   (Phase 4)   │   │   (Phase 5)   │   │   (Phase 6)   │
├───────────────┤   ├───────────────┤   ├───────────────┤   ├───────────────┤   ├───────────────┤   ├───────────────┤
│ EXPLORING     │   │ WHAT & WHY    │   │ REFINING      │   │ HOW           │   │ DOING         │   │ VALIDATING    │
│               │   │               │   │               │   │               │   │               │   │               │
│ • Ideas       │   │ • Architecture│   │ • Validate    │   │ • Phases      │   │ • Tests first │   │ • Plan check  │
│ • Market      │   │ • Decisions   │   │ • Filter      │   │ • Tasks       │   │ • Then code   │   │ • Specs check │
│ • Viability   │   │ • Edge cases  │   │ • Enrich      │   │ • Criteria    │   │ • Commit often│   │ • Test quality│
│               │   │ • Rationale   │   │ • Standalone  │   │ • Outputs     │   │ • Phase gates │   │ • Code quality│
└───────────────┘   └───────────────┘   └───────────────┘   └───────────────┘   └───────────────┘   └───────────────┘
        ▲                   ▲                   ▲                   ▲                   ▲                   ▲
        │                   │                   │                   │                   │                   │
 technical-research  technical-discussion  technical-spec  technical-planning  technical-impl  technical-review
```

**Phase 1 - Research:** Explore ideas from their earliest seed. Investigate market fit, technical feasibility, business viability. Free-flowing exploration that may or may not lead to building something.

**Phase 2 - Discussion:** Captures the back-and-forth exploration of a problem. Documents competing solutions, why certain approaches won or lost, edge cases discovered, and the journey to decisions—not just the decisions themselves.

**Phase 3 - Specification:** Transforms discussion documentation into a validated, standalone specification. Filters hallucinations and inaccuracies, enriches gaps through discussion, and builds a document that planning can execute against without referencing other sources.

**Phase 4 - Planning:** Converts specifications into actionable implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats (local markdown, Linear, Backlog.md).

**Phase 5 - Implementation:** Executes the plan using strict TDD. Writes tests first, implements to pass, commits frequently, and stops for user approval between phases.

**Phase 6 - Review:** Validates completed work against specification requirements and plan acceptance criteria. The specification is the validated source of truth—earlier phases may contain rejected ideas that were intentionally filtered out. Provides structured feedback without fixing code directly.

## How It Works

This package depends on [`@leeovery/claude-manager`](https://github.com/leeovery/claude-manager), which:

1. **Copies skills** into your project's `.claude/skills/` directory
2. **Copies commands** into your project's `.claude/commands/` directory
3. **Copies agents** into your project's `.claude/agents/` directory
4. **Tracks installed plugins** via a manifest file
5. **Handles installation/removal** automatically via npm hooks

You don't need to configure anything—just install and start discussing.

### Output Structure

Documents are stored using a **phase-first** organization:

```
docs/workflow/
├── research/              # Phase 1 - flat, semantically named files
│   ├── exploration.md
│   ├── competitor-analysis.md
│   └── pricing-models.md
├── discussion/            # Phase 2 - one file per topic
│   └── {topic}.md
├── specification/         # Phase 3 - one file per topic
│   └── {topic}.md
└── planning/              # Phase 4 - one file per topic
    └── {topic}.md
```

Research starts with `exploration.md` and splits into topic files as themes emerge. From discussion onwards, each topic gets its own file per phase.

### Package Structure

This package provides:

```
skills/
├── technical-research/        # Phase 1: Explore and validate ideas
├── technical-discussion/      # Phase 2: Document discussions
├── technical-specification/   # Phase 3: Build validated specifications
├── technical-planning/        # Phase 4: Create implementation plans
├── technical-implementation/  # Phase 5: Execute via TDD
└── technical-review/          # Phase 6: Validate against artifacts

commands/
├── start-research.md          # Begin research exploration
├── start-discussion.md        # Begin technical discussions
├── start-specification.md     # Begin specification building
├── start-planning.md          # Begin implementation planning
└── interview.md               # Focused questioning mode

agents/
└── chain-verifier.md          # Parallel task verification for review
```

## Skills

| Skill                                                            | Phase | Description                                                                                                                                                                                                  |
|------------------------------------------------------------------|-------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [**technical-research**](skills/technical-research/)             | 1     | Explore ideas from their earliest seed. Investigate market fit, technical feasibility, business viability. Free-flowing exploration across technical, business, and market domains.                          |
| [**technical-discussion**](skills/technical-discussion/)         | 2     | Document technical discussions as expert architect and meeting assistant. Captures context, decisions, edge cases, competing solutions, debates, and rationale.                                              |
| [**technical-specification**](skills/technical-specification/)   | 3     | Build validated specifications from discussion documents through collaborative refinement. Filters hallucinations, enriches gaps, produces standalone spec.                                                  |
| [**technical-planning**](skills/technical-planning/)             | 4     | Transform specifications into actionable implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats.                                                                 |
| [**technical-implementation**](skills/technical-implementation/) | 5     | Execute implementation plans using strict TDD workflow. Writes tests first, implements to pass, commits frequently, and gates phases on user approval.                                                       |
| [**technical-review**](skills/technical-review/)                 | 6     | Review completed implementation against specification requirements and plan acceptance criteria. Uses parallel subagents for efficient chain verification. Produces structured feedback without fixing code. |

### technical-research

Acts as **research partner** with broad expertise spanning technical, product, business, and market domains.

**Use when:**
- Exploring a new idea from its earliest seed
- Investigating market fit, competitors, or positioning
- Validating technical feasibility before committing to build
- Learning and exploration without necessarily building anything
- Brain dumping early thoughts before formal discussion

**What it does:**
- Explores ideas freely across technical, business, and market domains
- Prompts before documenting: "Shall I capture that?"
- Creates research documents that may seed the discussion phase
- Follows tangents and goes broad when useful

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
- Multiple output formats: local markdown, Linear, Backlog.md, or Beads

### technical-implementation

Executes plans through strict TDD. Acts as an expert senior developer who builds quality software through disciplined test-driven development.

**Use when:**
- Implementing a plan from `docs/workflow/planning/{topic}.md`
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
- Were specification requirements implemented?
- Were all plan acceptance criteria met?
- Do tests actually verify requirements?
- Does code follow project conventions?

## Commands

Slash commands to quickly invoke the workflow.

| Command                                                       | Description                                                                                                                                                                                                |
|---------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [**/start-research**](commands/start-research.md)             | Begin research exploration. For early-stage ideas, feasibility checks, and broad exploration before formal discussion.                                                                                     |
| [**/start-discussion**](commands/start-discussion.md)         | Begin a new technical discussion. Gathers topic, context, background information, and relevant codebase areas before starting documentation.                                                               |
| [**/start-specification**](commands/start-specification.md)   | Start a specification session from an existing discussion. Validates and refines discussion content into a standalone specification.                                                                       |
| [**/start-planning**](commands/start-planning.md)             | Start a planning session from an existing specification. Creates implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats (markdown, Linear, Backlog.md, Beads). |
| [**/start-implementation**](commands/start-implementation.md) | Start implementing a plan. Executes tasks via strict TDD, committing after each passing test.                                                                                                              |
| [**/interview**](commands/interview.md)                       | Shift into focused questioning mode during research or discussion. Probes ideas with non-obvious questions, challenges assumptions, and surfaces concerns.                                                 |

## Agents

Subagents that skills can spawn for parallel task execution.

| Agent                                          | Used By          | Description                                                                                                                                                                                              |
|------------------------------------------------|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [**chain-verifier**](agents/chain-verifier.md) | technical-review | Verifies a single plan task was implemented correctly. Checks implementation, tests (not under/over-tested), and code quality. Multiple chain-verifiers run in parallel to verify ALL tasks efficiently. |

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

- [**@leeovery/claude-manager**](https://github.com/leeovery/claude-manager) — The plugin manager that powers skill installation
- [**@leeovery/claude-laravel**](https://github.com/leeovery/claude-laravel) — Laravel development skills for Claude Code
- [**@leeovery/claude-nuxt**](https://github.com/leeovery/claude-nuxt) — Nuxt.js development skills for Claude Code

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with care by <a href="https://github.com/leeovery">Lee Overy</a></sub>
</p>
