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

Decide whether explicit user confirmation is needed before changing the codebase.

If the request is small, complete, and unambiguous, do not ask for confirmation. Briefly state the understood scope, record the baseline, and proceed directly to implementation.

Ask for explicit confirmation only when the request is unclear, could reasonably be interpreted in more than one way, affects a broad or risky area, changes data/schema/permissions/security, or requires choosing among implementation options.

If a plan from `/plan` was provided, follow it exactly — do not deviate without asking.

Before implementing, record the current working tree state so pre-existing user changes are not confused with files modified by this command.

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

The developer must:

- Modify only files required by the confirmed scope.
- Follow existing codebase patterns and the standards under `coding_standards/` plus guides under `guides/`.
- Reuse an existing unpushed migration for the same schema/task when safe instead of creating unnecessary follow-up migrations.
- Return the list of files it created or modified.
- Apply any later Code Analysis findings sent back by this command.

Do not write documentation as part of this command unless the confirmed scope explicitly requires changing documentation files.

---

## Phase 4 — Validation

Identify the modified files by comparing the current working tree to the baseline recorded before implementation. Validate only files changed by this command, not unrelated pre-existing dirty files.

Validation is mandatory for every implementation. Before choosing checks, analyze the concrete files and behavior changed, list the cases or flows that could be affected, and validate the strongest practical subset that proves those cases still work. Run validation before committing, and fix any error found by validation before considering the task complete. Do not stop at code edits only.

Required validation by change type:
- If PHP, Laravel, Livewire, routes, policies, observers, models, services, config, or backend behavior changed, run the narrowest relevant artisan/runtime checks and any project-specific validation that proves the behavior works
- If migrations were added or modified, confirm database env is configured, report exact missing env keys when blocked, run `php artisan migrate` in local/development, and fix migration errors before continuing
- If seeders or seeded data changed, confirm database env is configured, report exact missing env keys when blocked, and run the relevant seeder or `php artisan db:seed` in local/development when safe for the configured database
- If frontend assets, Blade, Livewire views, CSS, JS, Vite, or design changed, run the project's frontend proof/build command; prefer `npm run proof` when the project defines it, otherwise run `npm run build`
- If composer dependencies, autoloaded classes, package discovery, or PHP configuration changed, run the relevant Composer/artisan checks needed to prove the app still boots
- If the task affects translations or user-facing copy, run the relevant translation sync/search checks used by the project
- If the task affects a user-facing flow and a local URL is available, validate it in the browser with Playwright over CDP after command-line checks pass


Check whether the current project's parent directory contains a sibling repository named `ia-analyzer` (`../ia-analyzer`). Do not hardcode a machine-specific absolute analyzer path.

If `../ia-analyzer` exists, external Code Analysis is required in this command. Run this command from `../ia-analyzer` for each modified code or implementation file:

```bash
php artisan validate:now "Code Analysis" "{absolute_modified_file_path}"
```

The second argument must be the exact absolute path of the modified file.

Validation rules:

- Show each validation pass as `Code analyzer iteration N started`.
- Show every file being validated and the exact command run for it.
- If the analyzer returns a negative, failed, or non-passing result for any file, treat that result as authoritative feedback.
- Return the analyzer's requested fixes to `developer`, update the affected files, then rerun Code Analysis for every affected modified code file.
- If the developer changes additional code files while fixing analyzer findings, add those files to the validation queue.
- Do not stop just because the number of analyzer iterations is high.
- If 10 minutes pass without a file reaching a passing analyzer result, stop the current analyzer loop, clear the current validation attempt, and retry the analyzer flow once from the current changed-file queue.
- If the retry also goes 10 minutes without a passing file, stop and report the blocker instead of continuing indefinitely.

If `../ia-analyzer` does not exist, skip external Code Analysis in this command and use focused runtime, artisan, build, or Playwright-over-CDP browser validation that matches the confirmed scope.

When the confirmed scope affects a real user flow in a local project UI, validate it in the browser using Playwright connected over CDP, matching the `/review` browser validation approach:

- Read the project URL from `.env`, preferring `APP_URL` when available.
- If the URL does not include a scheme, prepend `http://`.
- When auth is required, ask the user to open Chrome with remote debugging enabled and log in manually before browser validation.
- Connect Playwright over CDP to that Chrome session and reload after local code changes before checking the flow.
- Open the affected route or entry point and confirm the page renders without visible errors.
- Traverse the relevant in-scope section like `/repair-project`: click visible non-destructive buttons, links, tabs, filters, menus, pagination, and modal open/close controls that belong to the changed section.
- Do not click destructive actions such as delete, send, charge, publish, reset, or irreversible confirmations unless the user explicitly approved that action as part of validation.
- For each visited page or interaction, report a visible pass/fail/blocker line with the route or UI element checked.
- Keep counts for pages/interactions checked, passed, failed, blocked, and skipped.
- If any browser, command, migration, build, or runtime validation fails, return to implementation, fix the issue, and rerun the affected validation until it passes or is clearly blocked.
- Report clearly when browser validation was not possible because the URL, server, auth state, or required environment was unavailable.

Do not expose private chain-of-thought. The visible trace must show analyzer results or fallback validations, fixes applied, commands or tools used, paths, and final result.

---

## Phase 5 — Automatic Commit

After validation passes, create a commit automatically unless the user explicitly forbade commits.

Commit rules:

- Review `git status` and the diff from the baseline recorded before implementation
- Stage only files changed by this command; never stage unrelated pre-existing user changes
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
- Do not ask for confirmation for small, complete, unambiguous requests; proceed directly after recording the scope and baseline
- Never implement ambiguous, broad, risky, or multi-interpretation requests without explicit user confirmation after Phase 2
- Unless the user explicitly forbids commits, create one validated commit with the task name after implementation and validation pass
- Reuse safe unpushed migrations for the same task/schema instead of creating unnecessary follow-up migrations
- Always run validation that matches the change type before committing, including migrations, frontend proof/build, and browser validation for user-facing flows when available
- If validation finds an error caused by the implementation, fix it and rerun the affected validation before reporting success
- Keep changes minimal — only what was defined in requirements
- Do not write documentation in this flow unless explicitly requested or included in the confirmed scope
- If `../ia-analyzer` exists, run external Code Analysis for modified code or implementation files in this command
- If `../ia-analyzer` does not exist, use focused validation that matches the confirmed scope
- Use Playwright connected over CDP for validating local user-facing flows when available
- External Code Analysis belongs in `/develop` and `/review`
