---
name: develop
description: Use this command when the user wants to implement, build, create, or modify something in the codebase. Triggers when the user says things like "implementa", "hazlo", "crea", "agrega", "modifica", "arregla", "desarrolla", or describes a feature/fix they want built. Also use when the user comes from /plan and is ready to execute. Do NOT use when the user only wants to plan or think through something — use /plan for that.
---

# /develop — Implementation

Triggered by: "implementa", "hazlo", "crea", "agrega", "modifica", "arregla", "desarrolla", "build", "create", "implement", or any request describing a feature or fix to be built.

---

## Phase 1 — Analyst

Call the `analyst` agent to confirm scope and surface any gaps in the requirements.

If the request is already complete and unambiguous, analyst confirms quickly and outputs requirements without blocking. If gaps exist, analyst asks all questions at once before proceeding.

---

## Phase 2 — Confirm Or Proceed

Decide whether explicit user confirmation is needed before changing the codebase. The default is to ask for confirmation unless the command is 100% sure the request is small, complete, unambiguous, and low risk.

Proceed directly only when all of these are true:
- The request is a small, localized change or bug fix with an obvious target.
- The exact file, component, route, UI element, behavior, or data flow to change is clear after code inspection.
- There is only one reasonable implementation path and it does not require choosing between product, UX, data, schema, permission, or architecture options.
- The change does not affect a broad or risky area, schema, data migration, permissions, security, billing, destructive actions, or cross-module behavior.

When proceeding directly, briefly state the understood scope, why it is unambiguous, record the baseline, and implement only that scope.

Ask for explicit confirmation before implementation whenever any part of the request is unclear, broad, risky, multi-interpretation, or larger than a small localized change. If the command cannot clearly explain why direct implementation is safe, it must ask instead of guessing.

For UI requests, treat generic references such as "the icon", "the button", "the modal", "the input", "the page", or "the layout" as ambiguous when code inspection shows more than one plausible target. Ask which route, component, layout, or element the user means before changing code.

If a plan from `/plan` was provided, follow it exactly — do not deviate without asking.

Before implementing, record the current working tree state so pre-existing user changes are not confused with files modified by this command.

Concurrent work protection:
- Treat any pre-existing modified, staged, untracked, or committed work as belonging to the user or another concurrent task unless this command created it.
- Do not discard, restore, reset, clean, stash, overwrite, amend, squash, rebase, or otherwise rewrite work that is outside this command's confirmed scope.
- Do not use destructive cleanup commands such as `git reset --hard`, `git checkout -- <path>`, `git restore <path>`, `git clean`, or `git stash` to make the working tree look clean.
- If unrelated work prevents safe implementation, validation, staging, or committing, stop and report the exact blocker instead of modifying that work.

Migration handling before implementation:
- If the task needs schema changes, inspect existing migration files in the working tree and unpushed commits on the current branch before creating a new migration
- Reuse or edit an existing unpushed migration for the same task/table/schema change when it has not been shared, pushed, or deployed
- Do not create a second migration that corrects a migration from the same unpushed task when the original migration can be safely updated instead
- Create a new migration only when the previous migration has been pushed/shared/deployed, belongs to a different task, or changing it would risk another developer/environment
- Never rewrite migrations that may already have been run outside the local development context unless the user explicitly confirms it is safe

Default commit interpretation for this command:
- Unless the user explicitly forbids commits, create one commit automatically after the confirmed or directly-proceeded implementation passes validation
- Use the confirmed task name or a concise task-based summary as the commit message
- Do not ask for a separate commit confirmation when the user already confirmed implementation
- The only valid opt-out is an explicit user instruction to avoid commits

---

## Phase 3 — Developer Implementation

After confirmation, or immediately for a small and unambiguous request, call the `developer` agent to implement the confirmed scope.

For bug fixes, the implementation must be conservative: identify the smallest root-cause fix that makes the confirmed behavior work, preserve existing UI and product behavior outside the defect, and avoid redesigns, rewrites, or opportunistic improvements unless the confirmed scope explicitly includes them.

When modifying or repairing existing functionality, preserve the existing structure and project patterns unless that structure is proven to be the root cause or the confirmed request explicitly asks to change it. Do not replace a working pattern with a different architecture, form surface, component structure, service split, authorization shape, or UI structure just to satisfy a preference. When building something that does not already exist, implement it according to the current standards and project conventions.

The developer must:

- Modify only files required by the confirmed scope.
- In existing files, modify only the specific lines, blocks, functions, classes, markup sections, or adjacent glue code required by the confirmed scope. Do not refactor, rename, reorder, restyle, or "clean up" untouched parts of the same file unless that exact surrounding change is required for the confirmed behavior to work.
- Follow existing codebase patterns and the standards under `coding_standards/` plus guides under `guides/`.
- Preserve existing patterns for existing features; apply standards to new code without restructuring unrelated working code.
- Reuse an existing unpushed migration for the same schema/task when safe instead of creating unnecessary follow-up migrations.
- Return the list of files it created or modified.
- Apply later Code Analysis findings only when they point to code created or changed by this command, or to the minimal adjacent code that must change for the confirmed implementation to work correctly. For newly created files, the whole new file is in scope. For existing files, do not modify untouched legacy code only because the analyzer flags it.
- Do not run Pint, PHP-CS-Fixer, Prettier, `npm run format`, project-wide formatting scripts, or equivalent formatter commands unless the user explicitly asks for formatting.

Do not write documentation as part of this command unless the confirmed scope explicitly requires changing documentation files.

---

## Phase 4 — Validation

Identify the modified files by comparing the current working tree to the baseline recorded before implementation. Validate only files changed by this command, not unrelated pre-existing dirty files.

Validation is mandatory for every implementation. Before choosing checks, analyze the concrete files and behavior changed, list the cases or flows that could be affected, and validate the strongest practical subset that proves those cases still work. Run validation before committing, and fix any error found by validation before considering the task complete. Do not stop at code edits only.

Impact analysis is required before validation:
- Inspect direct references to each modified class, component, route, view, helper, config key, translation key, event, job, migration, or public API touched by the change.
- Identify coupled files and user flows that could reasonably be affected even when they were not edited.
- When modified code reads models, relationships, lists, tables, detail screens, Livewire render/computed data, API resources, or other persisted data, identify the query paths, relationships accessed, and whether the change can introduce N+1 queries or unnecessary repeated queries.
- Add those coupled flows to the validation plan, or explicitly record why they are not affected.
- If the impact analysis reveals a broader or riskier scope than the user confirmed, stop and ask before expanding the implementation.

Required validation by change type:
- If PHP, Laravel, Livewire, routes, policies, observers, models, services, config, or backend behavior changed, run the narrowest relevant artisan/runtime checks and any project-specific validation that proves the behavior works
- Do not run full test suites or broad automated tests by default. Run tests only when the user explicitly asks for tests, when the task modifies tests or test infrastructure, or when a focused existing test is the narrowest practical validation for the changed behavior.
- If migrations were added or modified, confirm database env is configured, report exact missing env keys when blocked, run `php artisan migrate` in local/development, and fix migration errors before continuing
- If seeders or seeded data changed, confirm database env is configured, report exact missing env keys when blocked, and run the relevant seeder or `php artisan db:seed` in local/development when safe for the configured database
- If frontend assets, Blade, Livewire views, CSS, JS, Vite, or design changed, run the project's frontend proof/build command; prefer `npm run proof` when the project defines it, otherwise run `npm run build`
- If composer dependencies, autoloaded classes, package discovery, or PHP configuration changed, run the relevant Composer/artisan checks needed to prove the app still boots
- If the task affects translations or user-facing copy, run the relevant translation sync/search checks used by the project
- If model queries, Eloquent relationships, list/detail screens, Livewire render/computed data, API resources, table data, or other data-loading behavior changed, validate the affected query behavior. Check for relationships accessed in loops, views, computed properties, resources, or table rows; add or preserve eager loading when it is needed by the confirmed scope; and confirm the change did not introduce an obvious N+1 or repeated-query regression. Use the narrowest practical evidence available, such as code inspection, focused runtime/browser flow, query logging, Debugbar/Telescope output, or existing project query tools, and report the exact blocker when query evidence cannot be collected.
- If the task affects a user-facing flow and a local URL is available, validate it in a real browser after command-line checks pass


Check whether the current project's parent directory contains a sibling repository named `ia-analyzer` (`../ia-analyzer`). Do not hardcode a machine-specific absolute analyzer path.

If `../ia-analyzer` exists, external Code Analysis is required in this command. Run this command from `../ia-analyzer` for each modified code or implementation file:

```bash
php artisan validate:auto "{absolute_modified_file_path}"
```

The only argument must be the exact absolute path of the modified file. Do not pass an analysis type or extra context text; the analyzer detects the file type and rules automatically.

Validation rules:

- Show each validation pass as `Code analyzer iteration N started`.
- Show every file being validated and the exact command run for it.
- Treat analyzer findings as required development feedback when they are coherent, actionable, and connected to the confirmed implementation or a real defect introduced by it.
- When the analyzer reports an existing file, treat only findings inside the lines, blocks, or directly affected surrounding code changed by this command as in scope. For a newly created file, treat findings across the whole file as in scope.
- Return only in-scope analyzer-requested fixes to `developer`, update the affected files, then rerun Code Analysis for every affected modified code file.
- Apply small and medium analyzer fixes during development without asking for separate approval, as long as they preserve the confirmed scope and make technical sense.
- Do not modify unrelated pre-existing code in an existing file only to satisfy analyzer preferences, naming suggestions, formatter friction, or legacy issues elsewhere in that file.
- Do not chase analyzer comments that are incoherent, contradict repository evidence, request impossible changes, or only repeat formatter/rule friction with no meaningful code improvement; classify them explicitly instead of iterating forever.
- If the analyzer reports findings only in untouched legacy sections of an existing file, classify them as out-of-scope pre-existing findings, leave that code unchanged, and continue with the confirmed implementation instead of refactoring the file.
- A modified existing file does not require legacy-cleanup changes outside the confirmed diff just to achieve a globally clean analyzer report. Report the remaining out-of-scope findings clearly instead of expanding the implementation.
- If an analyzer finding would require a broad refactor outside the confirmed implementation scope, do not expand the task automatically unless it is necessary to fix a real defect in the delivered feature; report it as a follow-up or ask the user whether to proceed.
- If the developer changes additional code files while fixing analyzer findings, add those files to the validation queue.
- Do not stop just because the number of analyzer iterations is high when findings are still coherent and progress is being made.
- If 10 minutes pass without a file reaching a passing analyzer result, stop the current analyzer loop, clear the current validation attempt, and retry the analyzer flow once from the current changed-file queue.
- If the retry also goes 10 minutes without a passing file, stop and report the blocker or classified analyzer inconsistency instead of continuing indefinitely.

If `../ia-analyzer` does not exist, skip external Code Analysis in this command and use focused runtime, artisan, build, or browser validation that matches the confirmed scope.

When the confirmed scope affects a real user flow in a local project UI, validate it in a real browser, matching the global Browser Validation Rule:

- Read the project URL from `.env`, preferring `APP_URL` when available.
- If the URL does not include a scheme, prepend `http://`.
- Prefer Playwright connected over CDP to a user-opened Chrome session when available.
- If the preferred browser path is unavailable, use an approved equivalent runtime browser path from the current environment, such as the Codex in-app browser or installed browser automation plugin, and state which path was used.
- When auth is required, ask the user to log in manually in the browser session used for validation before checking protected flows.
- Do not create temporary users, reset credentials, or directly modify persisted records to make validation possible.
- If the local server is down, start the project's normal dev server. If the configured port is occupied, choose an available safe local port and update only the temporary validation URL, not committed project config.
- If validation dependencies are missing, install them using the project's package manager and lockfile conventions when that is safe in the current task; otherwise report the exact blocker.
- Reload after local code changes before checking the flow.
- Open the affected route or entry point and confirm the page renders without visible errors.
- Traverse the relevant in-scope section like `/repair-project`: click visible non-destructive buttons, links, tabs, filters, menus, pagination, and modal open/close controls that belong to the changed section.
- Do not click destructive actions such as delete, send, charge, publish, reset, or irreversible confirmations unless the user explicitly approved that action as part of validation.
- For each visited page or interaction, report a visible pass/fail/blocker line with the route or UI element checked.
- Keep counts for pages/interactions checked, passed, failed, blocked, and skipped.
- If any browser, command, migration, build, or runtime validation fails, first determine whether the failure is caused by the implementation or by a recoverable validation-environment issue. Fix implementation defects, recover safe environment issues, and rerun the affected validation until it passes or is clearly blocked.
- Do not report success for a user-facing change unless the affected route and the impact-analysis flows were actually opened in a browser, or the final report clearly marks browser validation as blocked with the exact recovery attempts made.
- Report clearly when browser validation remains blocked because the URL, server, auth state, tooling, dependency installation, or required environment was unavailable.

Do not expose private chain-of-thought. The visible trace must show analyzer results or fallback validations, fixes applied, commands or tools used, paths, and final result.

---

## Phase 5 — Automatic Commit

After validation passes, create a commit automatically unless the user explicitly forbade commits.

Commit rules:

- Review `git status` and the diff from the baseline recorded before implementation
- Stage only files changed by this command; never stage unrelated pre-existing user changes
- Never discard, revert, stash, reset, clean, amend, squash, rebase, or otherwise rewrite unrelated work or commits to create the commit for this command
- Use the confirmed task name as the commit message when it is already concise
- If the task name is too long or not commit-friendly, use a concise task-based message that preserves the task intent
- Prefer conventional prefixes when the task clearly fits, such as `feat:`, `fix:`, `docs:`, `refactor:`, or `chore:`
- Do not push, amend, squash, or create branches unless explicitly requested
- Run `git status` after the commit and include the commit hash in the final report

If the commit cannot be created because validation is blocked, Git is unavailable, or unrelated changes make safe staging ambiguous, do not commit. Report the blocker clearly and list the files that were intentionally changed by this command.

---

## Phase 6 — Present Results

Once validation passes and the automatic commit step is complete or explicitly skipped, present the final result to the user:

- Summary of what was implemented
- Files created or modified
- Impact analysis result, including coupled files or flows checked and any intentionally excluded areas
- Query and eager-loading validation result when data-loading code was touched, including relations or repeated-query risks checked and any blockers
- Validation method used (`Code Analysis` plus required command/browser checks, or focused fallback), iterations, and final pass status
- Migration handling result when migrations were involved, including whether an existing unpushed migration was reused or a new migration was necessary
- Browser validation coverage for user-facing flows, including routes/pages/interactions checked and pass/fail/blocker counts
- Commit created, including hash and message, or the explicit reason no commit was created
- Translation files updated or synchronized (if applicable)
- Open questions or blockers (if any)

Stop here. Do not run extra documentation work as part of this command unless explicitly requested or already included in the confirmed scope.

---

## Rules

- Never skip the analyst step, even for small changes
- Ask for confirmation by default unless the request is 100% small, complete, unambiguous, low risk, and has one obvious implementation path
- Proceed directly only after stating the understood scope, why it is unambiguous, and recording the baseline
- Never implement ambiguous, broad, risky, multi-interpretation, or larger-than-localized requests without explicit user confirmation after Phase 2
- For bug fixes, prefer the smallest conservative root-cause fix and avoid redesigning or changing unrelated behavior
- Preserve existing structure when changing existing functionality unless the structure is the confirmed root cause; use current standards for new functionality that does not already exist
- Unless the user explicitly forbids commits, create one validated commit with the task name after implementation and validation pass
- Protect concurrent work: modify, validate, stage, and commit only this command's files; never discard unrelated files or rewrite unrelated commits
- When `Code Analysis` runs on an existing modified file, only findings inside the confirmed diff or the minimal adjacent code required by that diff are in scope; findings elsewhere in the file must be classified and left unchanged unless fixing them is truly necessary for correctness
- Never create or alter existing persistent application data, users, passwords, PINs, or account records during implementation or validation unless the user explicitly approved that exact mutation
- Reuse safe unpushed migrations for the same task/schema instead of creating unnecessary follow-up migrations
- Always run impact analysis and validation that matches the change type before committing, including migrations, frontend proof/build, and browser validation for user-facing flows when available
- For data-loading changes, inspect query paths and eager loading; do not introduce N+1 or repeated-query regressions
- Do not run full test suites by default during `/develop`; prefer the narrowest validation that proves the specific change works
- If validation finds an error caused by the implementation, fix it and rerun the affected validation before reporting success
- Keep changes minimal — only what was defined in requirements
- Do not run formatter commands during implementation or validation unless the user explicitly asks for formatting; report formatter-owned issues instead
- Do not write documentation in this flow unless explicitly requested or included in the confirmed scope
- If `../ia-analyzer` exists, run external Code Analysis for modified code or implementation files in this command
- If `../ia-analyzer` does not exist, use focused validation that matches the confirmed scope
- Use Playwright connected over CDP for validating local user-facing flows when available, and use an approved equivalent runtime browser path when CDP is unavailable
- External Code Analysis belongs in `/develop`, `/review`, and `/cleanup`
