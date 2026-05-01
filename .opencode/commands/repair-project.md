---
name: repair-project
description: Use this command when a project, branch, or copied implementation stopped working after a merge, Laravel upgrade, Weblabor Base update, dependency update, branch divergence, or copy from another project. It compares against a known-working source, repairs the broken project with minimal fixes, validates functionality with automated and manual checks when available, and can create commits per completed repair task when approved.
---

# /repair-project - Restore Broken Project

Your goal is to restore functionality as quickly and safely as possible with the smallest practical diff.

Treat this command as a repair exception:
- Do not run external Code Analysis from `../ia-analyzer`
- Do not invoke `/review`, `/cleanup`, `/finish`, or standards-only sweeps during the repair
- Do not expand into refactors, architecture cleanup, or coding-standard fixes unless they are strictly required for the broken flow to work again

Use `/cleanup` or `/review` only after the project works and only when the user explicitly wants follow-up cleanup or standards work.

---

## Purpose

Use this command when something used to work, or works in another branch/project, and the current branch/project is now broken.

Common triggers:
- A merge from `weblabor-base` broke the project
- A Laravel or dependency upgrade broke the project
- `master` or `main` works but `staging` does not
- A feature was copied from another project where it works
- Tests, translations, routes, Livewire, build, or artisan commands fail after a large update
- The user asks to repair, compose, stabilize, or make the project work again after a known change

---

## Phase 1 - Test Readiness Check

Before planning repairs, check whether the project has automated validation available for the affected area.

Inspect, without modifying files:
- Existing PHPUnit unit or feature tests under `tests/`
- Tests for the affected models, services, Livewire components, routes, or flows when the failure area is known
- Browser/E2E tooling such as Laravel Dusk, Playwright, Cypress, Pest browser tests, or equivalent configuration
- Existing browser/E2E tests for the affected user flow when UI behavior is involved

If relevant automated tests exist:
- Use them as the first validation path
- Prefer reproducing the failure with an existing or targeted test before changing code

If relevant tests do not exist, tell the user clearly:

> No encontre tests automatizados relevantes para validar esta reparacion. Puedo continuar con checks funcionales y comparacion contra la fuente que si funciona, pero la confianza de validacion sera menor.

If browser validation would be useful but no Dusk/E2E tooling exists, tell the user clearly:

> No encontre Laravel Dusk ni otra herramienta E2E configurada. Puedo continuar con PHPUnit, artisan, build y comparacion contra la rama o proyecto que si funciona, pero no puedo validar click-by-click en navegador desde este flujo.

When continuing without tests:
- State that validation confidence is lower
- Use the strongest available checks: artisan commands, targeted manual reasoning from branch comparison, build, translation checks, and any existing test suite
- Do not claim the flow is fully validated if no automated or browser validation covered it

---

## Phase 2 - Repair Context

Understand the repair context before changing files.

Ask only for missing information that materially affects the repair:

1. What is broken?
   - Current branch
   - Specific branch such as `staging`
   - Current project
   - Copied implementation
2. Where does it work?
   - `master`, `main`, `production`, another branch, another local project, or no known working source
3. What changed recently?
   - Merge from Weblabor Base
   - Laravel upgrade
   - Dependency update
   - Large merge
   - Copied code from another project
4. What failure is known?
   - Test failure
   - Browser flow failure
   - Login or route failure
   - Livewire failure
   - Translation issue
   - Build or install failure
   - Unknown failure
5. Are commits allowed?
   - Commits per completed repair task
   - Commits only after user confirmation
   - No commits

If the user already provided enough context, infer the answers and state them briefly before proceeding.

Default commit interpretation for this command:
- If the user asked for a long repair run and did not forbid commits, treat `Commits per completed repair task` as preferred
- If commit preference is unclear and the command is running interactively, ask once before the first commit

---

## Phase 3 - Git Safety Baseline

Before changing files or switching branches:

1. Run `git status`
2. Identify the current branch
3. Identify staged, unstaged, and untracked files
4. Identify merge conflicts if any
5. Review recent commits relevant to the failure
6. If commits are allowed, inspect the current diff before every commit

Rules:
- Never revert user changes unless explicitly requested
- Never switch branches if uncommitted changes could be lost
- Prefer `git diff`, `git show`, or a temporary `git worktree` to inspect a working branch safely
- Ask before switching branches, even when the worktree is clean
- Ask before creating a temporary worktree unless the user already approved branch comparison work
- Do not push unless explicitly requested
- Do not amend commits unless explicitly requested

---

## Phase 4 - Working Source Comparison

If a known-working branch or project exists, compare against it before guessing.

When the working source is a branch:
- Compare current branch against the working branch using non-destructive git commands
- Review divergent commits and changed files
- Inspect critical files such as `composer.json`, `composer.lock`, `package.json`, config files, routes, migrations, Livewire components, language files, and tests when relevant

When the working source is another project folder:
- Identify equivalent files and flows
- Compare intentionally
- Adapt the working implementation to the current project instead of copying blindly

Comparison rules:
- Treat the working source as evidence, not as code to copy wholesale
- Identify why the working source succeeds and the current source fails
- Preserve project-specific behavior in the broken project
- If the working source conflicts with current project requirements, stop and ask

---

## Phase 5 - Failure Reproduction

Reproduce or detect the failure with the smallest safe validation first.

Use targeted checks before broad checks:
- Specific PHPUnit tests when the failing area is known
- `php artisan test --filter ...` for narrow behavior
- `php artisan route:list` for route or controller failures
- `php artisan config:clear` or `php artisan view:clear` for local cache issues when safe
- `composer install` when dependency installation is the suspected issue
- `npm run build` when assets or frontend build are involved
- `php artisan lang:search` when translations are involved and a read-only check is enough

Run mutation-capable translation commands such as `php artisan lang:sync` only after the repair plan is approved or when the user already authorized direct repair.

Do not run destructive commands, production migrations, data resets, force operations, or broad environment changes without explicit user approval.

---

## Phase 6 - Repair Checklist

Create and maintain a repair checklist. Each checklist item must be a repair task, not a general cleanup task.

For each task, capture:
- The failure or risk being repaired
- Evidence from tests, errors, diffs, logs, or branch comparison
- The smallest safe fix
- The validation that proves the fix worked
- Whether a commit was created
- The current attempt count for that task

Valid repair tasks include:
- Resolve merge conflicts
- Restore compatibility with the updated Laravel/Weblabor Base version
- Fix imports, namespaces, signatures, config keys, routes, middleware, policies, casts, enums, traits, or Livewire APIs broken by an update
- Synchronize required translations directly related to the failure
- Fix tests that fail because of the update, when the intended behavior is clear
- Add or update targeted tests for repaired behavior when they directly prove the repair
- Update project documentation only when the repair changes behavior or prevents recurrence

Invalid repair tasks for this command:
- Broad code style cleanup
- Refactor for readability without a failure
- UX polish
- General missing-test coverage
- Reorganizing files without a functional need
- Updating documentation unrelated to the repair

If those are needed after the project works, recommend `/cleanup` or `/review`.

---

## Phase 7 - Confirm Repair Plan

Before implementing repairs, present the repair checklist to the user and ask for approval.

The confirmation must include:
- Broken source being repaired
- Working source used for comparison, if any
- Known failure or validation target
- Planned repair tasks
- Validation commands or checks to run
- Commit mode
- Timebox and stall rules for this run

Do not edit files, run mutation-capable commands, or create commits until the user confirms the repair plan, unless the user already gave explicit permission to proceed with repairs and commits in the original request.

Default repair execution limits unless the user says otherwise:
- Progress update at least every 15 minutes during long runs, and also after each meaningful repair task
- Maximum 5 implementation attempts for the same repair task
- Stop earlier if 2 consecutive attempts produce no new evidence or no meaningful code change
- If one task stalls, move to the next independent repair task when possible instead of blocking the whole run
- If all remaining tasks are blocked, stop and report the blockers clearly instead of looping forever

---

## Phase 8 - Implementation And Functional Validation

For each repair task:

1. Call `developer` with the specific repair task and evidence
2. `developer` applies the smallest safe fix and returns the files it modified
3. Validate functionality immediately with the smallest practical check for that task
4. If the check fails, return the new evidence to `developer` and try again
5. Keep the task scope narrow; do not pull in cleanup, standards-only changes, or unrelated refactors
6. Stop the task when one of these is true:
   - The task passes its functional validation
   - The task reaches 5 attempts
   - Two consecutive attempts fail without producing new evidence
   - The task is blocked by missing environment, missing external dependency, or ambiguous intended behavior
7. If the task stops without passing, record the blocker and continue with the next independent task when possible

This command must not run external Code Analysis and must not use `code-reviewer` or `tech-lead` as approval gates during repair.

If a task works but leaves follow-up quality concerns:
- Record them as follow-up items
- Do not block the repair on them
- Recommend `/cleanup` or `/review` only after the broken flow works again

Visible progress rules:
- Report progress in the user's language at least every 15 minutes during long runs
- Report when a task starts, when a task passes validation, when a task is committed, and when a task is blocked
- If the run is stalled, say exactly what was tried, what failed, and what evidence is still missing

---

## Phase 9 - Validation Strategy

The command must validate that the project works as completely as is practical in the current environment.

Validation order:

1. **Functional validation**
   - Reproduce the original failure or the closest observable proxy
   - Run the narrowest command or flow that can prove the repair worked
   - Prefer runtime or behavior validation over standards validation

2. **Static and install validation**
   - Dependency install when relevant
   - Autoload, config, route, or view sanity checks when relevant

3. **Automated tests**
   - Run targeted PHPUnit tests for repaired areas when they exist
   - Add or update targeted tests only when they directly prove repaired behavior and fit the repair scope
   - Run a broader PHPUnit suite only when the repaired area is already stable and the suite is reasonable to run

4. **Translations**
   - Run `php artisan lang:sync`, `php artisan lang:search`, and a final `php artisan lang:sync` only when translations or user-facing copy were part of the repair
   - Fix missing keys or hardcoded user-facing strings only when directly related to the repair

5. **Frontend/build validation**
   - Run `npm run build` only when assets, Blade, Livewire views, CSS, or JS changed

6. **Browser or end-to-end validation**
   - If browser automation tools or existing browser tests are available, use them for the repaired user flow
   - If not available, state that limitation and replace it with the strongest available automated checks

Important:
- Repair confidence comes from proving the broken flow works again
- Do not block runtime validation on analyzer or standards review
- Do not require new tests when they would materially delay a repair run and existing evidence is sufficient to restore service

---

## Phase 10 - Commit Flow

Only create commits if the user approved commits in Phase 2.

For each completed repair task:

1. Review `git status` and `git diff`
2. Stage only files related to the task
3. Commit as soon as the task passes its agreed validation
4. Use a clear message focused on the repaired breakage
5. Run `git status` after the commit

Commit examples:
- `fix: restore compatibility after base merge`
- `fix: resolve Laravel upgrade failures`
- `fix: align staging config with working branch`
- `fix: synchronize missing translations`
- `test: cover repaired reservation flow`
- `docs: document required repair configuration`

Commit rules:
- One commit per completed repair task
- Do not mix unrelated code, docs, tests, and translation changes unless they are inseparable for that repair
- Do not commit unrelated user changes
- Do not wait for unrelated follow-up cleanup before committing a task that already works
- Do not push unless explicitly requested
- Do not amend commits unless explicitly requested

---

## Phase 11 - Final Verification And Report

Before finishing:

1. Run the strongest practical validation set for the repaired scope
2. Confirm translations if translations were involved
3. Confirm build if frontend or assets were involved
4. Confirm targeted tests pass when they were part of the repair
5. Review final `git status`
6. List commits created, if any
7. List blocked tasks, skipped tasks, and follow-up cleanup items separately

Final report must include:
- Broken source repaired
- Working source used for comparison
- What changed recently
- Repair tasks completed
- Validation executed and results
- Commits created
- Anything not validated and why
- Remaining blockers
- Follow-up `/cleanup` or `/review` recommendations only for non-blocking work

---

## Documentation Rules

Documentation is secondary during repair.

Update docs only when:
- The repair changes documented behavior
- The repair reveals missing setup or update notes needed to prevent recurrence
- The project documentation is directly wrong for the repaired flow

For `control-total`, use `docs/control-total` as the project documentation source. Do not update `docs/weblabor-base` or `docs/weblabor-teams` unless the repair truly changes those shared or base areas.

---

## Hard Rules

- Restore functionality first
- Treat this command as a repair-only exception to standards and analyzer workflows
- Always ask for or infer the known-working source before deep repair
- Compare against the working source when one exists
- Do not copy blindly from the working source
- Do not perform general cleanup or broad refactor in this command
- Do not change product behavior unless the working source, tests, or user confirms that behavior is correct
- Stop and ask when the correct behavior is ambiguous
- Prefer targeted validation early and broader validation after repairs pass
- Check for relevant tests at the start and warn the user before continuing without them
- Be explicit when direct browser validation is unavailable
- Never loop forever: stop after the configured attempt limits or when the run is blocked
- Recommend `/cleanup` for non-blocking cleanup and `/review` for standards work only after repair
