# OpenCode Instructions

> This document defines the **workflow and process** OpenCode must follow in this project.
> All coding standards are defined in docs/development-guides/coding-standards read it before writing any code.

---

## Coding Standards

**Before writing any code**, read all the coding standards in full. Every rule there is mandatory.

When adding or clarifying standards, keep edits surgical: change only the rule, example, or nearby wording needed for the reported issue. Do not reformat, reorder, rename, or style-clean unrelated standards content in the same change.

Mechanical PHP formatting is formatter-owned. Weblabor projects currently use Laravel Pint through the Weblabor Coding Standards package as the source of truth for Pint/PHP-CS-Fixer-compatible style. Standards, reviews, and fixes must not fight formatter output unless the user explicitly asks to change the formatter configuration.

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

## Browser Validation Rule

For local browser validation, visual checks, or UI traversal, use Playwright connected over CDP to a user-opened Chrome session with remote debugging enabled.

Required behavior:
- Read the local project URL from the project environment when available, preferring `APP_URL`
- Probe common CDP endpoints such as `http://127.0.0.1:9222/json/version`, `:9223`, and `:9224`; also try any CDP port provided by the user or project
- Connect Playwright over CDP to that existing Chrome session instead of launching or controlling a separate browser
- When auth is required, ask the user to log in manually in that Chrome session before validation

Prohibited behavior:
- Do not use browser skills, browser plugins, in-app browser automation, Selenium, Puppeteer, or any tool that attempts to launch its own browser as a fallback for local validation
- Do not spend time trying browser approaches that are known to fail in this environment when CDP is unavailable
- Do not claim a user-facing flow was visually validated unless Playwright CDP, or an explicitly approved equivalent runtime browser path, actually opened and checked it

If no usable CDP endpoint is available, stop browser validation, report the exact endpoints tried, and ask the user to provide a Chrome remote debugging session or the correct CDP port. Continue only with clearly labeled non-browser fallback checks when appropriate.

---

## Absolute Rule

- **Everything defined in `README.md` is mandatory**
- If a tool, helper, package, or pattern already exists: use it, never reimplement it, never ignore it

If the assistant detects a deviation, it must explicitly point it out, explain why it breaks the standard, and suggest the correct alternative.
