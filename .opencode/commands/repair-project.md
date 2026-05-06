---
name: repair-project
 description: Use this command when a project, branch, or copied implementation stopped working after a merge, Laravel upgrade, Weblabor Base update, dependency update, branch divergence, or copy from another project. It compares against a known-working source, repairs the broken project with minimal fixes, validates functionality with focused runtime checks plus Playwright-over-CDP browser validation when available, traverses reachable pages in the repaired flow with explicit pass/fail reporting, and creates one commit per completed repair task by default unless the user explicitly forbids commits.
---

# /repair-project - Restore Broken Project

Your goal is to restore functionality as quickly and safely as possible with the smallest practical diff.

Repair existing functionality by preserving the current project's structure and working patterns whenever possible. Do not replace the existing architecture, form surface, component structure, service split, authorization shape, or UI structure unless that structure is proven to be the breakage source or the user/known-working source confirms the structural change is required.

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

## Phase 1 - Validation Readiness Check

Before planning repairs, always run a baseline project readiness check. This is mandatory for every repair run, even when the visible failure seems unrelated.

Baseline readiness requirements:
- Confirm the expected environment file exists, normally `.env`; if it is missing, stop and tell the user which env file is required
- Inspect required environment keys from config, `.env.example`, bootstrap, service providers, package integrations, and the failing flow before running commands that depend on them
- If a required environment key is missing or blank, stop and report the exact key name and where it appears to be needed, using this style: `Falta configurar <ENV_KEY>. Por favor agregala a .env antes de continuar.`
- Confirm database connection settings are present before database commands; do not run migrations or seeders when the database env is incomplete
- Run `composer install` and treat failures as repair blockers or dependency repair evidence
- Run `npm run build` and treat failures as repair blockers or frontend repair evidence
- Run pending migrations with `php artisan migrate` when the configured environment is local/development and database env is complete
- Run `php artisan db:seed` when the configured environment is local/development, database env is complete, and the command is safe for the current database
- If migrations or seeding are unsafe, destructive, production-like, or blocked by missing env/database access, do not run them; report the explicit blocker and ask for confirmation or missing configuration
- Record every baseline check as `passed`, `failed`, `blocked`, or `skipped with reason` before moving to repair planning

Do not continue to repair planning when baseline readiness fails because of missing env configuration, failed dependency installation, failed build, failed migrations, or failed seeding unless the user explicitly instructs you to continue with lower confidence and the blocker is not required for the affected flow.

Before planning repairs, check whether the project has focused validation available for the affected area.

Inspect, without modifying files:
- Local project URL in `.env`, preferring `APP_URL`
- Whether the local server and affected route can be opened in a real browser session that the user can authenticate manually, preferring Chrome remote debugging for Playwright CDP control when available
- Relevant artisan, route, config, or build commands that can prove the broken area
- Existing browser tooling only as context, not as a required workflow step
- Whether the repaired flow has a practical browser traversal scope such as dashboard, module navigation, index/detail pages, or route group entry points

When browser validation is possible:
- Use the global Browser Validation Rule, with Playwright connected over CDP to a user-opened Chrome session as the preferred primary way to reproduce and verify the visible failure
- Identify the traversal scope and entry points that will be used later during browser validation

If browser validation is not possible, tell the user clearly:

> No pude validar este flujo en un navegador real porque falta URL local utilizable, servidor levantado, una sesion autenticada, acceso a un browser path compatible, o el entorno necesario. Puedo continuar con checks funcionales, artisan, build y comparacion contra la fuente que si funciona, pero la confianza visual sera menor.

When continuing without browser validation:
- State that validation confidence is lower
- Use the strongest available checks: artisan commands, targeted manual reasoning from branch comparison, build, and translation checks
- State explicitly that command-line checks, runtime checks, or automated tests do not replace visible browser validation for a user-facing flow when Playwright CDP validation is available
- Do not claim the flow is fully validated if no browser or equivalent runtime validation covered it

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
   - Validation failure
   - Browser flow failure
   - Login or route failure
   - Livewire failure
   - Translation issue
   - Build or install failure
   - Unknown failure
If the user already provided enough context, infer the answers and state them briefly before proceeding.

Default commit interpretation for this command:
- Unless the user explicitly forbids commits, `Commits per completed repair task` is the required default behavior for this command
- Do not ask whether commits are allowed, do not ask for per-task commit confirmation, and do not delay a passed repair task's commit waiting for extra approval
- The only valid opt-out is an explicit user instruction to avoid commits

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
- Inspect critical files such as `composer.json`, `composer.lock`, `package.json`, config files, routes, migrations, Livewire components, and language files when relevant

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
- Browser validation under the global Browser Validation Rule for the visible flow when the issue is user-facing and the local URL is available
- `php artisan route:list` for route or controller failures
- `php artisan config:clear` or `php artisan view:clear` for local cache issues when safe
- `composer install` when dependency installation is the suspected issue
- `npm run build` when assets or frontend build are involved
- `php artisan lang:search` when translations are involved and a read-only check is enough

When the issue is a user-facing flow and Playwright CDP validation is available, do not treat command-line checks, runtime checks, PHPUnit, Pest, or build output as a substitute for browser validation. Those checks can support the repair, but the visible flow must still be traversed in the browser before the task is considered fully validated.

Run mutation-capable translation commands such as `php artisan lang:sync` only after the repair plan is approved or when the user already authorized direct repair.

Do not run destructive commands, production migrations, data resets, force operations, or broad environment changes without explicit user approval.

---

## Phase 6 - Repair Checklist

Create and maintain a repair checklist. Each checklist item must be a repair task, not a general cleanup task.

For each task, capture:
- The failure or risk being repaired
- Evidence from browser validation, errors, diffs, logs, or branch comparison
- The smallest safe fix
- The validation that proves the fix worked
- Whether a commit was created
- The current attempt count for that task
- The traversal scope and notable page-access blockers relevant to that task when the task affects a user-facing flow

Valid repair tasks include:
- Resolve merge conflicts
- Restore compatibility with the updated Laravel/Weblabor Base version
- Fix imports, namespaces, signatures, config keys, routes, middleware, policies, casts, enums, traits, or Livewire APIs broken by an update
- Synchronize required translations directly related to the failure
- Update project documentation only when the repair changes behavior or prevents recurrence

Invalid repair tasks for this command:
- Broad code style cleanup
- Refactor for readability without a failure
- UX polish
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
- Browser traversal scope and entry points for the repaired flow when Playwright CDP validation is available
- Browser traversal cap for the repaired flow when Playwright CDP validation is available
- Timebox and stall rules for this run

Do not ask the user to choose a commit mode during this confirmation. Commits happen automatically per completed repair task unless the user explicitly forbade commits earlier.

Do not edit files, run mutation-capable commands, or create commits until the user confirms the repair plan, unless the user already gave explicit permission to proceed with repairs in the original request.

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
7. Unless the user explicitly forbade commits, create that task's commit immediately after the task passes validation and before starting the next independent repair task
8. If the task stops without passing, record the blocker and continue with the next independent task when possible

This command must not run external Code Analysis and must not use `code-reviewer` or `tech-lead` as approval gates during repair.

If a task works but leaves follow-up quality concerns:
- Record them as follow-up items
- Do not block the repair on them
- Recommend `/cleanup` or `/review` only after the broken flow works again

Visible progress rules:
- Report progress in the user's language at least every 15 minutes during long runs
- Report when a task starts, when a task passes validation, when a task is committed, and when a task is blocked
- Show a visible checklist for the baseline readiness phase before repair planning, including `.env`, required env keys, `composer install`, `npm run build`, migrations, seeding, and browser readiness
- When inspecting or changing files, report each relevant file with a pass/fail/blocker line using the file path and what was checked, for example `✓ Archivo: app/Http/Controllers/FooController.php - carga y coincide con la ruta reparada`
- When inspecting or validating routes, report each relevant route with a pass/fail/blocker line using method, URI, route name when available, and outcome
- When browser traversal runs, report the current iteration number plus page coverage and blockers according to Phase 9
- For each validation step that materially checks the repair, emit a visible test-style pass/fail line so the user can see what succeeded, failed, or was blocked
- Treat these visible pass/fail lines as reporting evidence only. Do not present them as proof that automated unit or integration tests were executed unless such tests actually ran
- Do not make PHPUnit, Pest, or other unit/integration test output the main user-facing report unless the user explicitly asked for test execution; tests are supporting evidence only and never replace file, route, and browser/page validation for a repair flow
- If the run is stalled, say exactly what was tried, what failed, and what evidence is still missing

---

## Phase 9 - Validation Strategy

The command must validate that the project works as completely as is practical in the current environment.

Validation order:

1. **Functional validation**
   - Reproduce the original failure or the closest observable proxy
   - Run the narrowest command or flow that can prove the repair worked
   - Prefer runtime or behavior validation over standards validation
   - Maintain a user-visible validation checklist grouped by baseline checks, files inspected/changed, routes checked, pages traversed, and remaining blockers
   - Each checklist line must include a clear outcome marker such as `✓`, `✗`, `Bloqueado`, or `Omitido`, plus the concrete file, route, command, or page being validated

2. **File and route validation**
   - For every relevant changed or inspected file, report the file path and whether the file passes the repair-specific check
   - For every relevant route in the repaired flow, report method, URI, route name when available, and whether it resolves, renders, redirects correctly, or is blocked
   - Use `php artisan route:list` or equivalent route inspection to identify in-scope routes when routes/controllers/views are involved
   - Do not claim that all files or all routes work unless the run actually checked all files or all routes in that stated scope
   - If only a scoped subset was checked, label it clearly as `Rutas revisadas en alcance` or `Archivos revisados en alcance`

3. **Static and install validation**
   - Dependency install when relevant
   - Autoload, config, route, or view sanity checks when relevant

4. **Translations**
   - Run `php artisan lang:sync`, `php artisan lang:search`, and a final `php artisan lang:sync` only when translations or user-facing copy were part of the repair
   - Fix missing keys or hardcoded user-facing strings only when directly related to the repair

5. **Frontend/build validation**
   - Run `npm run build` only when assets, Blade, Livewire views, CSS, or JS changed

6. **Browser validation**
   - Use the global Browser Validation Rule for repaired user-facing flows using the local project URL from `.env`
   - Add `http://` when the URL is missing a scheme
   - When auth is required, ask the user to log in manually in the browser session used for traversal
   - Reload after code changes before checking the repaired flow
   - Traverse the reachable in-scope pages for the repaired flow, not only the first visible page
   - Start from the confirmed entry points and build a queue of reachable in-scope pages
   - The default traversal boundary is the approved repaired area only: stay within the same module, route group, or visible task flow; follow reachable internal links page by page through a systematic in-scope traversal; do not fan out into unrelated navigation, pagination, filter combinations, destructive actions, or secondary modules unless the user explicitly included them
   - Stop traversal when the in-scope queue is exhausted, when the agreed traversal cap is reached, or when further expansion yields no new in-scope pages
   - Follow internal links, menus, tabs, and index/detail transitions that are directly reachable and relevant to the repaired area
   - Do not perform destructive actions during traversal unless the user explicitly approved them as part of the repair
   - For each visited page, report the required evidence fields: current repair iteration, page number or identifier, page label or route, outcome, and blocker or finding when relevant
   - Use a route/page checklist format for every visited page, for example `✓ Pagina 3: GET /admin/users (users.index) - carga correctamente`
   - If a page fails, include the visible error, HTTP/status signal when known, screenshot/trace reference when available, and the file/route suspected only when supported by evidence
   - The visible trace for each visited page must use a localized test-style pass/fail line with a clear outcome marker such as `✓`, `✗`, or an equivalent unambiguous pass/fail label in the user's language
   - Keep counts for pages discovered, pages visited, pages passed, pages blocked, pages skipped, and total traversal iterations
   - Treat the traversal output as a page coverage report of reachable pages and findings inside the approved scope
   - If Playwright CDP browser validation is unavailable for this run, state that limitation and replace it with the strongest available runtime checks

7. **Automated tests**
   - Run PHPUnit, Pest, or other automated tests only when they are the narrowest useful validation, when the user requested them, or when the repair directly affects test-covered backend behavior
   - Report automated tests as supporting evidence, not as the primary repair report
   - A final report that only lists unit test results is incomplete for this command when files, routes, or browser-visible behavior were part of the repair

Important:
- Repair confidence comes from proving the broken flow works again
- Do not block runtime validation on analyzer or standards review
- Do not require extra validation work that materially delays a repair run when existing evidence is already enough to restore service

---

## Phase 10 - Commit Flow

Create commits automatically for each completed repair task unless the user explicitly forbade commits.

Default behavior after plan approval:
- `Commits per completed repair task` is the active mode unless the user explicitly forbade commits
- Under the default mode, a passed repair task is not complete until its commit is created

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
- `docs: document required repair configuration`

Commit rules:
- One commit per completed repair task
- Create the task commit before moving on to the next independent repair task unless the user approved a different commit strategy
- Do not mix unrelated code, docs, and translation changes unless they are inseparable for that repair
- Do not commit unrelated user changes
- Do not wait for unrelated follow-up cleanup before committing a task that already works
- Do not push unless explicitly requested
- Do not amend commits unless explicitly requested
- The only mode that skips commits is an explicit user instruction to avoid commits

---

## Phase 11 - Final Verification And Report

Before finishing:

1. Run the strongest practical validation set for the repaired scope
2. Confirm translations if translations were involved
3. Confirm build if frontend or assets were involved
4. Confirm browser validation or the strongest equivalent runtime validation for repaired user flows
5. Review final `git status`
6. List commits created, if any
7. List blocked tasks, skipped tasks, and follow-up cleanup items separately

Final report must include:
- Broken source repaired
- Working source used for comparison
- What changed recently
- Repair tasks completed
- Baseline readiness checklist with outcomes for `.env`, required env keys, `composer install`, `npm run build`, migrations, seeding, and browser readiness
- Files inspected or changed, with one pass/fail/blocker line per relevant file
- Routes checked in scope, with one pass/fail/blocker line per route including method, URI, and route name when available
- Validation executed and results, separated by baseline, files, routes, pages, commands, and optional automated tests
- Total repair iterations and per-task attempt counts
- Browser traversal coverage: entry points, pages discovered, pages visited, pages passed, pages blocked, and pages skipped
- A concise page-by-page findings report for the reachable pages inspected during the run
- Counts summary for scoped files, routes, and pages, for example `Archivos: 6 revisados, 6 pasan, 0 bloqueados`; `Rutas: 8 revisadas, 8 pasan`; `Paginas: 5 visitadas, 5 pasan`
- Automated test results only as supporting evidence when tests actually ran; do not substitute test results for file, route, or page validation
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
- Do not restructure existing working patterns as part of repair unless that structure is the confirmed cause of the breakage
- Do not change product behavior unless the working source or user confirms that behavior is correct
- Stop and ask when the correct behavior is ambiguous
- Prefer targeted validation early and broader validation after repairs pass
- Check for browser validation readiness at the start and warn the user before continuing without it
- Be explicit when direct Playwright CDP validation is unavailable
- Never loop forever: stop after the configured attempt limits or when the run is blocked
- Recommend `/cleanup` for non-blocking cleanup and `/review` for standards work only after repair
