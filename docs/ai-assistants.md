# AI Assistants

This project is configured to work with Codex and OpenCode.

The goal is to keep one shared workflow, one shared standards source, and a single set of commands that any supported assistant can use.

---

## Source of Truth

- `docs/development-guides/coding-standards/`: coding standards for all assistants and developers
- `OPENCODE.md`: main workflow and assistant behavior rules for the project
- `.opencode/commands/*.md`: canonical command definitions — each file contains the full workflow for that command
- `.opencode/agents/*.md`: agent role definitions — each file defines a specialist's responsibilities and behavior

---

## Mandatory Confirmation Before Action

Before implementing, editing files, creating files, running non-trivial commands, or changing configuration, the assistant must first gather enough context, then confirm the request with the user.

Required flow:
1. Clarify missing details and remove ambiguity
2. Summarize the exact proposed solution or scope
3. Ask for confirmation
4. Only then execute the change

Exception:
- If the request is already fully specified and unambiguous, the assistant may ask for a brief final confirmation of scope and proceed once confirmed

The assistant must not start from scratch without this confirmation step.

---

## Sync Rule

Whenever a shared AI workflow asset is added or modified, update the equivalent asset for supported assistant environments within this repository whenever it applies.

This includes:
- Instruction files
- Commands
- Agent-related workflow documentation

If a change intentionally applies to only one environment, document that exception explicitly in the relevant file.

Do not update sibling repositories automatically. Only modify another repository, such as a sibling project repository, when the user explicitly asks to move or sync the workflow there.

---

## Agent Roles

Commands orchestrate agents. Each agent is a specialist with a narrow, well-defined responsibility. Agents can call other agents — commands define the flow.

### Core roles (code quality chain)

| Agent | Responsibility |
|---|---|
| `analyst` | Analyzes requests, identifies gaps, explores codebase context, produces clear requirements |
| `developer` | Implements solutions based on defined requirements and returns changed files for validation |
| `code-reviewer` | Internal fallback reviewer when `../ia-analyzer` is unavailable; validates standards and cycles with developer until clean |
| `tech-lead` | Architecture review: separation of concerns, repetition, understandability. Manages rule creation and updates |

### Frontend roles (UI quality chain)

| Agent | Responsibility |
|---|---|
| `frontend` | Implements UI changes in Blade, Livewire HTML, and resources following `docs/development-guides/coding-standards/tailwind.md`. Always calls `ux-designer` when done |
| `ux-designer` | Reviews UI for user experience: navigation, actions, clarity, hierarchy, consistency. Cycles with `frontend`. Can propose new Tailwind/UX rules |

### Specialists (called directly by commands)

| Agent | Responsibility |
|---|---|
| `feature-analyst` | Analyzes feature/module ideas, reviews code/docs/previous analyses, and produces Spanish minimum-scope feature analysis documents |
| `tester` | Proposes approved user-facing use cases, then writes and validates targeted PHPUnit or Laravel Dusk tests |
| `documenter` | Writes and updates project documentation in `docs/{project}` |

### Role chains

```
/develop:
  analyst → developer → if ../ia-analyzer exists: Code Analysis ↔ developer fixes until pass; otherwise: code-reviewer ↔ developer → tech-lead fallback

/review:
  analyst → if ../ia-analyzer exists: Code Analysis report; otherwise: code-reviewer report → optional developer fixes → same validation gate/fallback until pass

/repair-project:
  compare working source → repair checklist → developer → if ../ia-analyzer exists: Code Analysis ↔ fixes; otherwise: code-reviewer ↔ developer → tech-lead → targeted validation → optional commit per repair task

/finish:
  frontend → ux-designer ↔ cycle → if ../ia-analyzer exists: Code Analysis for modified UI/code files
  (after backend is already clean)

/test:
  tester

/document:
  documenter

/analyze-feature:
  command orchestrates scope/classification, repository review, optional decisions, feature-analyst drafting,
  analysis artifact creation, then if `../ia-analyzer` exists: external Document Analysis validation with `php artisan validate:now`;
  failed analyzer findings return to feature-analyst until the document passes completely; if `../ia-analyzer` is unavailable, use the previous internal review fallback
```

---

## Available Commands

Commands live in `.opencode/commands/` and are shared across all supported assistants.

| Command | Description | File |
|---|---|---|
| `/plan` | Exhaustive planning session via analyst. Produces a complete implementation prompt. | [plan.md](../.opencode/commands/plan.md) |
| `/develop` | Full implementation flow with Code Analysis when `../ia-analyzer` exists, otherwise the previous code-reviewer/tech-lead fallback | [develop.md](../.opencode/commands/develop.md) |
| `/review` | Run Code Analysis when `../ia-analyzer` exists, otherwise internal code-reviewer review, and optionally refactor until validation passes | [review.md](../.opencode/commands/review.md) |
| `/repair-project` | Repair a broken branch/project after a merge, Laravel upgrade, base update, dependency update, or branch divergence by comparing against a known-working source, validating fixes, and optionally committing each repair task. | [repair-project.md](../.opencode/commands/repair-project.md) |
| `/finish` | Final polish after code is working: frontend review, UX review, optional Code Analysis when available, translations, tests, docs | [finish.md](../.opencode/commands/finish.md) |
| `/test` | Inspect, create, and validate automated tests | [test.md](../.opencode/commands/test.md) |
| `/document` | Write or update project documentation in the correct docs folder | [document.md](../.opencode/commands/document.md) |
| `/analyze-feature` | Analyze a feature/module request, create the analysis document, and validate with Document Analysis when `../ia-analyzer` exists or internal fallback otherwise | [analyze-feature.md](../.opencode/commands/analyze-feature.md) |
| `/add-rules` | Fix a bug and update coding standards to prevent recurrence | [add-rules.md](../.opencode/commands/add-rules.md) |
| `/quote` | Estimate project scope at a high level | [quote.md](../.opencode/commands/quote.md) |
| `/cleanup` | Run project-wide cleanup, refactor, and standards health checks after the project already works | [cleanup.md](../.opencode/commands/cleanup.md) |

---

## OpenCode

OpenCode uses:
- `OPENCODE.md` as the repository entry point
- `.opencode/commands/*.md` for repository-local command definitions
- `.opencode/agents/*.md` for repository-local agent definitions

### Installing OpenCode Commands

If your OpenCode setup loads repository-local commands automatically, no extra setup is needed.

If it uses another local commands directory, copy the markdown files from `.opencode/commands/` into the directory your OpenCode installation reads.

If commands do not appear after opening the repository, restart OpenCode or reload the workspace.

---

## Codex

Codex can use the repository commands directly by linking them into the local Codex skills directory.

When a linked command says to call an agent from `.opencode/agents/`, Codex must read the corresponding agent file directly and follow that role definition for the command flow.

### Installing Codex Commands

1. Ensure the local Codex skills directory exists:

```bash
mkdir -p ~/.codex/skills
```

2. Link each repository command into `~/.codex/skills`:

```bash
for cmd in .opencode/commands/*.md; do
  [ -f "$cmd" ] || continue
  skill_name=$(basename "$cmd" .md)
  mkdir -p "$HOME/.codex/skills/$skill_name"
  ln -sfn "$(pwd)/$cmd" "$HOME/.codex/skills/$skill_name/SKILL.md"
done
```

3. Restart Codex or open a new session in this repository.

Because Codex reads the linked command files directly and command files reference repository agent files, there is no separate command copy to keep in sync.

---

## Maintenance Rule

When updating assistant workflow in this repository:

1. Update the command file in `.opencode/commands/` that defines the behavior
2. Update the agent file in `.opencode/agents/` if the role's responsibilities changed
3. Update `OPENCODE.md` if the overall workflow or process changes
4. Update this documentation if the command list, agent list, or installation process changed
5. Keep references in `README.md` and `docs/weblabor-base/README.md` in sync

If the same instruction exists in more than one place, prefer reducing duplication and documenting which file is authoritative.
