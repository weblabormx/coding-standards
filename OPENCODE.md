# OpenCode Instructions

> This document defines the **workflow and process** OpenCode must follow in this project.
> All coding standards are defined in docs/development-guides/coding-standards read it before writing any code.

---

## Coding Standards

**Before writing any code**, read all the coding standards in full. Every rule there is mandatory.

When adding or clarifying standards, keep edits surgical: change only the rule, example, or nearby wording needed for the reported issue. Do not reformat, reorder, rename, or style-clean unrelated standards content in the same change.

Mechanical PHP formatting is formatter-owned. Weblabor projects currently use the Weblabor Coding Standards package (`weblabormx/weblabor-cs`) as the reference for project formatter-compatible style. This is a style reference, not an instruction to execute a formatter. Standards, reviews, and fixes must not fight formatter output unless the user explicitly asks to change the formatter configuration.

Do not run formatter commands as part of assistant implementation, review, cleanup, validation, or standards-update workflows unless the user explicitly asks for formatting. This includes `pint`, `./vendor/bin/pint`, PHP-CS-Fixer, Prettier, `npm run format`, project-wide formatting scripts, and equivalent auto-formatters. Formatting is handled separately by the project maintainers; assistants should make surgical edits, classify formatter-owned issues as such, and report when a formatter should be run instead of running it themselves.

## Persistent Data Safety

Validation, review, cleanup, finish, repair, and browser-check workflows must default to read-only interaction with persistent application data.

- Do not create, update, delete, or directly modify existing database records, users, passwords, PINs, tokens, or other persisted application data unless the user explicitly approved that exact write operation for the current task.
- Do not create temporary users, change existing credentials, or alter account data just to make validation, login, browser access, or testing easier.
- When auth is required, ask the user to log in manually with an existing account in the browser session used for validation.
- If a task truly requires changing persistent data, stop and ask the user to confirm the exact mutation before doing it.

## Surgical Diff Rule

All assistant edits must stay tightly inside the confirmed scope.

- Modify only the files, lines, blocks, or minimal adjacent glue code required by the approved task.
- Do not reformat, reorder, rename, restyle, or style-clean untouched code or markup.
- If an analyzer, reviewer, or validation tool reports issues outside the confirmed diff, classify and report them instead of editing unrelated code automatically.
- Cosmetic churn such as whitespace-only edits, blank-line-only edits, wrapping-only edits, import-order-only edits, class-order-only edits, or other formatter-like rewrites is forbidden unless the user explicitly asked for formatting or the exact hunk is required by a concrete approved rule.

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

For local browser validation, visual checks, or UI traversal, use a real runtime browser path. Prefer Playwright connected over CDP to a user-opened Chrome session with remote debugging enabled when available.

Required behavior:
- Read the local project URL from the project environment when available, preferring `APP_URL`
- Probe common CDP endpoints such as `http://127.0.0.1:9222/json/version`, `:9223`, and `:9224`; also try any CDP port provided by the user or project
- Connect Playwright over CDP to that existing Chrome session when available
- If CDP is unavailable, use an approved equivalent runtime browser path available in the current environment, such as the Codex in-app browser or installed browser automation plugin, and state which path was used
- When auth is required, ask the user to log in manually in the browser session used for validation
- Do not create, modify, or repair users, passwords, PINs, or other persisted records to make browser validation possible
- If the local app is not reachable, recover safe validation-environment issues before giving up: start the normal dev server, use a free temporary local port when the configured port is occupied, and install missing validation dependencies through the project's package manager and lockfile conventions when safe

Prohibited behavior:
- Do not use headless-only checks, static screenshots, or command output as a substitute for browser validation of a user-facing flow
- Do not keep retrying a browser path that is known to be broken in the current environment; switch to another approved runtime browser path or report the blocker
- Do not claim a user-facing flow was visually validated unless Playwright CDP, or an explicitly approved equivalent runtime browser path, actually opened and checked it

If no usable browser path is available after safe recovery attempts, stop browser validation, report the exact browser paths and endpoints tried, and ask the user for the missing server, auth, port, or browser access. Continue only with clearly labeled non-browser fallback checks when appropriate.

---

## Absolute Rule

- **Everything defined in `README.md` is mandatory**
- If a tool, helper, package, or pattern already exists: use it, never reimplement it, never ignore it

If the assistant detects a deviation, it must explicitly point it out, explain why it breaks the standard, and suggest the correct alternative.
