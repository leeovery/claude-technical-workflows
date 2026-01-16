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

A complete development workflow for Claude Code: explore ideas, capture decisions, build actionable plans, implement via strict TDD, and validate the result.

Use it as a **six-phase workflow** or pick individual capabilities as needed:

```
Research → Discussion → Specification → Planning → Implementation → Review
```

**Why this matters:** Complex features benefit from thorough discussion before implementation. This toolkit documents the *what* and *why* before diving into the *how*, preserving architectural decisions, edge cases, and the reasoning behind choices that would otherwise be lost.

**Flexible entry points:** Need the full workflow? Start at Research or Discussion and progress through each phase. Already know what you're building? Jump straight to Specification with `/start-feature`. Skills are input-agnostic - commands gather context and feed it to them.

> [!NOTE]
> **Work in progress.** The workflow is being refined through real-world usage. Expect updates as patterns evolve.

> [!IMPORTANT]
> **Model compatibility:** These skills have been developed and refined for Claude Code running on **Opus 4.5**. Different models may exhibit different edge cases, and future model releases may require adjustments to the prompts and workflows.

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

### Two Ways to Use the Skills

**1. Full Workflow** - Sequential phases that build on each other:

```
Research → Discussion → Specification → Planning → Implementation → Review
```

Start with `/workflow:start-research` or `/workflow:start-discussion` and follow the flow. Each phase outputs files that the next phase consumes.

**2. Standalone Commands** - Jump directly to a skill with flexible inputs:

| Command | What it does |
|---------|-------------|
| `/start-feature` | Create a spec directly from inline context (skip research/discussion) |

*More standalone commands coming soon.*

### The Command/Skill Architecture

**Skills are input-agnostic.** They don't know or care where their inputs came from: a discussion document, inline context, or external sources. They just process what they receive.

**Commands are the input layer.** They gather context (from files, prompts, or inline) and pass it to skills. This separation means:

- The same skill can be invoked from different entry points
- You can create custom commands that feed skills in new ways
- Skills remain reusable without coupling to specific workflows

```
┌─────────────────────────────────────────────────────────────┐
│                        COMMANDS                             │
│  (gather inputs from files, prompts, inline context)        │
├─────────────────────────────────────────────────────────────┤
│  /workflow:start-spec     /start-feature    (your custom)   │
│         │                       │                 │         │
│         └───────────┬───────────┘                 │         │
│                     ▼                             ▼         │
├─────────────────────────────────────────────────────────────┤
│                         SKILLS                              │
│  (process inputs without knowing their source)              │
├─────────────────────────────────────────────────────────────┤
│           technical-specification skill                     │
│           technical-planning skill                          │
│           technical-implementation skill                    │
│           etc.                                              │
└─────────────────────────────────────────────────────────────┘
```

### Workflow Commands

| Phase          | Command                          |
|----------------|----------------------------------|
| Research       | `/workflow:start-research`       |
| Discussion     | `/workflow:start-discussion`     |
| Specification  | `/workflow:start-specification`  |
| Planning       | `/workflow:start-planning`       |
| Implementation | `/workflow:start-implementation` |
| Review         | `/workflow:start-review`         |

Run the command directly or ask Claude to run it. Each gathers context from previous phase outputs and passes it to the skill.

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

Skills are copied to `.claude/` and can be committed, giving you ownership and making them available everywhere including Claude Code for Web.

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

**Phase 2 - Discussion:** Captures the back-and-forth exploration of a problem. Documents competing solutions, why certain approaches won or lost, edge cases discovered, and the journey to decisions, not just the decisions themselves.

**Phase 3 - Specification:** Transforms discussion documentation into a validated, standalone specification. Filters hallucinations and inaccuracies, enriches gaps through discussion, and builds a document that planning can execute against without referencing other sources.

**Phase 4 - Planning:** Converts specifications into actionable implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats (local markdown, Linear, Backlog.md).

**Phase 5 - Implementation:** Executes the plan using strict TDD. Writes tests first, implements to pass, commits frequently, and stops for user approval between phases.

**Phase 6 - Review:** Validates completed work against specification requirements and plan acceptance criteria. The specification is the validated source of truth; earlier phases may contain rejected ideas that were intentionally filtered out. Provides structured feedback without fixing code directly.

## How It Works

### Installation

This package depends on [`@leeovery/claude-manager`](https://github.com/leeovery/claude-manager), which:

1. **Copies skills** into your project's `.claude/skills/` directory
2. **Copies commands** into your project's `.claude/commands/` directory
3. **Copies agents** into your project's `.claude/agents/` directory
4. **Tracks installed plugins** via a manifest file
5. **Handles installation/removal** automatically via npm hooks

You don't need to configure anything. Just install and start using the commands.

### Output Structure

Documents are stored in your project using a **phase-first** organisation:

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

```
skills/                              # Input-agnostic processors
├── technical-research/              # Explore and validate ideas
├── technical-discussion/            # Document discussions
├── technical-specification/         # Build validated specifications
├── technical-planning/              # Create implementation plans
├── technical-implementation/        # Execute via TDD
└── technical-review/                # Validate against artefacts

commands/                            # Input layer (gather context → invoke skills)
├── workflow:start-research.md       # Sequential: begin research
├── workflow:start-discussion.md     # Sequential: begin discussions
├── workflow:start-specification.md  # Sequential: begin specification
├── workflow:start-planning.md       # Sequential: begin planning
├── workflow:start-implementation.md # Sequential: begin implementation
├── workflow:start-review.md         # Sequential: begin review
├── workflow:interview.md            # Utility: focused questioning for research/discussion
├── workflow:status.md               # Utility: show workflow status and next steps
├── workflow:view-plan.md            # Utility: view plan tasks and progress
├── start-feature.md                 # Standalone: spec from inline context
└── link-dependencies.md             # Standalone: wire cross-topic deps

agents/
└── chain-verifier.md                # Parallel task verification for review
```

## Skills

Skills are **input-agnostic processors**: they receive inputs and process them without knowing where the inputs came from. This makes them reusable across different commands and workflows.

| Skill                                                            | Description                                                                                                                                                                                                  |
|------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [**technical-research**](skills/technical-research/)             | Explore ideas from their earliest seed. Investigate market fit, technical feasibility, business viability. Free-flowing exploration across technical, business, and market domains.                          |
| [**technical-discussion**](skills/technical-discussion/)         | Document technical discussions as expert architect and meeting assistant. Captures context, decisions, edge cases, competing solutions, debates, and rationale.                                              |
| [**technical-specification**](skills/technical-specification/)   | Build validated specifications from source material through collaborative refinement. Filters hallucinations, enriches gaps, produces standalone spec.                                                       |
| [**technical-planning**](skills/technical-planning/)             | Transform specifications into actionable implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats.                                                                 |
| [**technical-implementation**](skills/technical-implementation/) | Execute implementation plans using strict TDD workflow. Writes tests first, implements to pass, commits frequently, and gates phases on user approval.                                                       |
| [**technical-review**](skills/technical-review/)                 | Review completed implementation against specification requirements and plan acceptance criteria. Uses parallel subagents for efficient chain verification. Produces structured feedback without fixing code. |

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
- The journey: false paths, "aha" moments, course corrections

### technical-specification

Acts as **expert technical architect** and **specification builder**. Transforms source material into validated, standalone specifications.

**Use when:**
- Ready to validate and refine source material into a spec
- Need to filter potential hallucinations or inaccuracies
- Building a standalone document that planning can execute against
- Converting discussions, feature descriptions, or other inputs into verified requirements

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
- No code before tests: write the failing test first
- No test changes to pass: fix the code, not the tests
- No scope expansion: if it's not in the plan, don't build it
- Commit after green: every passing test is a commit point

### technical-review

Reviews completed work with fresh perspective. Validates implementation against prior workflow artefacts without fixing code directly.

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

Commands are the input layer: they gather context and pass it to skills. Two types:

### Workflow Commands

Sequential commands prefixed with `workflow:`. They expect files from previous phases and pass content to skills.

| Command                                                                              | Description                                                                                                                                                                                                |
|--------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [**/workflow:start-research**](commands/workflow:start-research.md)                  | Begin research exploration. For early-stage ideas, feasibility checks, and broad exploration before formal discussion.                                                                                     |
| [**/workflow:start-discussion**](commands/workflow:start-discussion.md)              | Begin a new technical discussion. Gathers topic, context, background information, and relevant codebase areas before starting documentation.                                                               |
| [**/workflow:start-specification**](commands/workflow:start-specification.md)        | Start a specification session from an existing discussion. Validates and refines discussion content into a standalone specification.                                                                       |
| [**/workflow:start-planning**](commands/workflow:start-planning.md)                  | Start a planning session from an existing specification. Creates implementation plans with phases, tasks, and acceptance criteria. Supports multiple output formats (markdown, Linear, Backlog.md, Beads). |
| [**/workflow:start-implementation**](commands/workflow:start-implementation.md)      | Start implementing a plan. Executes tasks via strict TDD, committing after each passing test.                                                                                                              |
| [**/workflow:start-review**](commands/workflow:start-review.md)                      | Start reviewing completed work. Validates implementation against plan tasks and acceptance criteria.                                                                                                        |

### Utility Commands

Helpers for navigating and understanding the workflow.

| Command                                                                              | Description                                                                                                                                 |
|--------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| [**/workflow:status**](commands/workflow:status.md)                                  | Show workflow status - what topics exist at each phase, and suggested next steps.                                                           |
| [**/workflow:view-plan**](commands/workflow:view-plan.md)                            | View a plan's tasks and progress, regardless of output format.                                                                              |
| [**/workflow:interview**](commands/workflow:interview.md)                            | Shift into focused questioning mode during research or discussion. Probes ideas, challenges assumptions, and surfaces concerns.             |

### Standalone Commands

Independent commands that gather inputs flexibly (inline context, files, or prompts) and invoke skills directly. Use these when you want skill capabilities without the full workflow structure.

| Command                                                 | Description                                                                                                                                 |
|---------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| [**/start-feature**](commands/start-feature.md)         | Create a specification directly from inline context. Invokes the specification skill without requiring a discussion document.              |
| [**/link-dependencies**](commands/link-dependencies.md) | Link external dependencies across topics. Scans plans and wires up unresolved cross-topic dependencies.                                    |

### Creating Custom Commands

Since skills are input-agnostic, you can create your own commands that feed them in new ways. A command just needs to:

1. Gather the inputs the skill expects
2. Invoke the skill with those inputs

See `/start-feature` as an example: it provides inline context to the specification skill instead of a discussion document.

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

- [**@leeovery/claude-manager**](https://github.com/leeovery/claude-manager) - The plugin manager that powers skill installation
- [**@leeovery/claude-laravel**](https://github.com/leeovery/claude-laravel) - Laravel development skills for Claude Code
- [**@leeovery/claude-nuxt**](https://github.com/leeovery/claude-nuxt) - Nuxt.js development skills for Claude Code

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with care by <a href="https://github.com/leeovery">Lee Overy</a></sub>
</p>
