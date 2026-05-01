# OpenCode Instructions

> This document defines the **workflow and process** OpenCode must follow in this project.
> All coding standards are defined in docs/development-guides/coding-standards read it before writing any code.

---

## Coding Standards

**Before writing any code**, read all the coding standards in full. Every rule there is mandatory.

---

## Mandatory Confirmation Before Action

Before implementing, editing files, creating files, running non-trivial commands, or changing configuration, the assistant must first confirm the request with the user.

Required flow:
- Clarify missing details and resolve ambiguities first
- Summarize the proposed solution or scope in concrete terms
- Ask for confirmation before proceeding

Exception:
- If the request is already fully specified and unambiguous, the assistant may ask for a brief final confirmation of scope and then proceed once confirmed

The assistant must not start from scratch without that confirmation step.


## Workflow Asset Review

When editing workflow assets, use the `workflow-reviewer` agent before treating the change as correct or final.

Workflow assets include:
- `.opencode/commands/**`
- `.opencode/agents/**`
- `docs/development-guides/**`
- Agent-related workflow documentation
- Feature analysis format or process documentation

The reviewer must check that changes are clear, placed in the correct file/section, general enough to prevent the root problem, and not narrow reactions to a single bad output. It must also check that generated-document formats do not gain extra fields unless the relevant standard explicitly defines them.

Internal workflow assets should stay in English unless the file intentionally uses another language. User-facing generated documents should use the user's language.

## Sync Rule

Whenever any of these are added or changed, keep equivalent assets within this repository aligned in the same task whenever it applies:
- Instruction files
- Skills
- Slash commands
- Agent-related workflow documentation

Do not modify sibling repositories automatically. Only modify another repository when the user explicitly asks to move or sync the workflow there.

---

## Absolute Rule

- **Everything defined in `README.md` is mandatory**
- If a tool, helper, package, or pattern already exists: use it, never reimplement it, never ignore it

If the assistant detects a deviation, it must explicitly point it out, explain why it breaks the standard, and suggest the correct alternative.
