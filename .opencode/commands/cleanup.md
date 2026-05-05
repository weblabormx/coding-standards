---
name: cleanup
description: Use this command when the project already works and the user wants project-wide cleanup, refactor, standards alignment, or internal code quality improvements without changing the intended behavior. Triggers when the user says "limpia el proyecto", "refactoriza todo", "dejalo al punto", "cleanup", or anything suggesting broad execution-heavy cleanup. It should actively clean the codebase in small validated groups, preserve visible behavior and business logic, review every relevant file in strict area order, maintain an explicit per-file coverage ledger, validate each modified group with Code Analysis when available plus real browser validation for user-facing flows, keep a visible progress trace, commit each validated improvement by default, and handle larger approval-needed refactors one by one after safe cleanup work. Do NOT use to repair a broken branch/project after a merge, Laravel upgrade, Weblabor Base update, dependency update, branch divergence, or copy from another project — use /repair-project for that. Do NOT use to implement new features — use /develop for that. Do NOT use for a narrow file/module-only request — use /review for that.
---

# /cleanup - Project Cleanup And Refactor

Your goal is to leave a working project cleaner, more standard, and easier to maintain without changing its intended behavior.

Treat this command as an execution-heavy cleanup flow, not as a report-only audit.

Core behavior:
- Refactor and clean the project proactively in small validated groups
- Apply small, safe, behavior-preserving cleanup findings directly after the run is approved; do not pause for each small fix
- Never perform whitespace-only, trailing-whitespace-only, final-newline-only, blank-line-only, indentation-only, wrapping-only, import-order-only, or cosmetic formatting cleanup unless a concrete project rule explicitly requires the exact hunk
- Preserve the same visible behavior, business logic, routes, permissions, and data behavior unless a strictly behavior-preserving fix requires a minimal adjustment
- Review every relevant file in the cleanup order, including files that do not need edits
- Maintain a visible per-file coverage ledger with a terminal status for every discovered file
- Keep the user informed with a visible progress trace while continuing automatically
- Validate each modified cleanup group before moving on
- Queue larger but potentially cleanup-relevant changes for explicit one-by-one approval after the safe direct cleanup pass for the affected area
- Record risky changes, schema changes, new features, product changes, and non-cleanup recommendations for the final summary instead of expanding scope mid-run
- Traverse the codebase in strict cleanup order instead of cherry-picking easy wins from unrelated areas

Coverage contract:
- Cleanup is not complete just because several groups were improved or the git tree is clean
- A broad cleanup run must either review, clean, validate, skip with reason, or block with reason every relevant file discovered in the mandatory cleanup areas
- Relevant files exclude generated or third-party dependency paths such as `vendor/`, `node_modules/`, build output, cache directories, compiled assets, lockfile vendor payloads, and files outside the project scope unless the user explicitly includes them
- Do not present a focused cleanup group as the result of `/cleanup` unless the user explicitly requested a focused/partial cleanup; otherwise continue through the mandatory order or report the run as paused/blocked, not completed
- Files that are inspected but left unchanged still count as `reviewed`, not `validated`, unless a concrete validation method was run for them
- The final summary must include a test-like coverage report so the user can see exactly what was checked, changed, validated, skipped, or blocked

If the project is currently broken after a merge, Laravel upgrade, Weblabor Base update, dependency update, branch divergence, or copy from another project, stop and recommend `/repair-project` first. Cleanup happens after repair, not before.

---

## Purpose

Use this command when the code should end up cleaner while the system still behaves the same from the user's perspective.

Expected cleanup outcomes:
- Better file placement and structure
- Better naming, consistency, readability, and reuse
- Removal of obvious duplication or dead cleanup-safe code
- Better standards compliance under `coding_standards/` and `guides/`
- Cleaner Livewire, Blade, model, notification, observer, policy, trait, service, route, and translation organization when relevant

Non-goals for this command:
- New features
- Product changes
- Intentional logic changes
- Database redesigns or migrations that change product behavior
- Broad architecture rewrites that need separate approval

If cleanup reveals those larger needs, finish the approved cleanup scope and report the follow-up items at the end.

---

## Phase 1 - Validation Readiness Check

Before planning cleanup execution, check what validation is available for the project.

Inspect, without modifying files:
- Current working tree state
- Local project URL in `.env`, preferring `APP_URL`
- Whether the local project can be opened in a real browser session that the user can authenticate manually, preferring Chrome remote debugging for Playwright CDP control when available
- Whether the current project's parent directory contains a sibling repository named `ia-analyzer` (`../ia-analyzer`)
- Relevant artisan, build, route, or runtime checks that can validate the cleaned area

Validation expectations:
- If `../ia-analyzer` exists, use external Code Analysis for modified code or implementation files in this command
- If a cleaned group affects a user-facing flow, browser validation under the global Browser Validation Rule is expected unless a concrete blocker is reported
- Probe common Chrome remote debugging endpoints such as `http://127.0.0.1:9222/json/version`, `:9223`, and `:9224` before declaring CDP unavailable, then switch to an approved equivalent runtime browser path when CDP is unavailable
- If no browser path works after safe recovery attempts, stop before closing the affected group and ask the user for the missing browser setup, auth state, server, port, or tooling access
- If browser validation remains unavailable, mark the affected visible-flow validation as `blocked`, not `validated`

If browser validation is unavailable for a user-facing flow, tell the user clearly and include the exact browser paths, endpoints, or setup that were tried:

> No pude validar este flujo en un navegador real porque no encontre un browser path disponible, falta URL local utilizable, falta servidor levantado, falta autenticacion, o falta el entorno necesario. Necesito acceso a una sesion autenticada o a un browser path compatible antes de marcar este flujo como validado.

Do not pretend a UI flow was visually validated if it was not opened. Do not silently downgrade a required browser validation to command-line validation only.

---

## Phase 2 - Cleanup Scope Confirmation

Before implementing, confirm the cleanup run once at the beginning only when the user's request was not already an explicit autonomous cleanup instruction.

Present:
- That this command will execute cleanup, not only report findings
- That the intended behavior must stay the same
- The cleanup areas that will be processed
- The validation strategy for each area
- Commit mode
- Timebox and stall rules for the run

If the user already asked for an execution-heavy run, use that as the default interpretation and present it as the selected path instead of asking whether cleanup should execute at all.

For this command, an explicit invocation such as `/cleanup`, "limpia el proyecto", "refactoriza todo", or "dejalo al punto" counts as approval to start the cleanup run unless the user added a restriction that still needs clarification.

Default commit interpretation:
- Commits are mandatory by default for `/cleanup` unless the user explicitly forbids commits with wording such as "no commits", "do not commit", or "leave changes uncommitted".
- Present `Commit per improved primary file` as the selected default for every cleanup run, not as an optional preference.
- Do not ask for separate commit approval after a cleanup unit passes validation; validation success is the commit trigger.

Do not ask for approval for small direct-fix groups, phase transitions, or end-of-run continuation. The command should continue automatically for direct-fix work, stop on a real blocker, or ask only for queued approval-needed findings that are too broad or risky to apply silently.

Do not start file modifications until this single run-level confirmation has been given, unless the user's original request already clearly approved direct cleanup execution.

---

## Phase 3 - Build The Cleanup Checklist

Create and maintain a cleanup checklist before the first code edit. Each item must be a cleanup group that can usually be completed and validated in about 10-15 minutes.

Before editing any file in an area, discover that area's full file queue with deterministic commands such as `find` or `rg --files`. The queue must include every relevant implementation file in the area, not only the files that look likely to need changes.

Strict default cleanup order:

1. Livewire components and their paired views
   - Naming, organization, consistency, validation rules, repeated patterns
   - Paired review of component class plus Blade view when the behavior depends on both
2. Models
   - Models
3. Traits
   - Traits
4. Services
   - Services
5. Notifications, policies, and observers
   - Notifications
   - Policies
   - Observers
6. Blade and translation cleanup outside paired Livewire views
   - Hardcoded user-facing strings
   - Repeated patterns
   - Readability and standards alignment
7. Routes and configuration cleanup when behavior stays the same
8. Supporting helpers, casts, console commands, and internal tooling
9. Remaining standards-alignment opportunities that do not change behavior

For each cleanup group, capture:
- Area name
- File queue
- Total files discovered in that area
- Per-file status ledger
- Why those files belong together
- Expected cleanup work
- Direct cleanup findings that are small, safe, and behavior-preserving
- Approval-needed findings that are cleanup-relevant but broad, risky, cross-cutting, or likely to affect multiple flows
- Validation method
- Whether the group touches a visible flow
- Whether a commit was created
- Attempt count

Coverage rules:
- Build the file queue for the entire active area before cleaning the first file in that area
- Reconcile discovered files against the project-owned implementation files that belong to the cleanup scope; every project-owned file must be assigned to a cleanup area, marked explicitly out of scope, or skipped with a reason
- Report queue counts for the active area and keep them updated as `queued`, `reviewed`, `cleaned`, `validated`, `blocked`, and `skipped`
- Assign every discovered file exactly one terminal status before leaving the area: `validated`, `reviewed-no-change`, `cleaned-unvalidated-fallback`, `blocked`, or `skipped`
- Use `validated` only when a concrete validation was run after the relevant review or edit
- Use `reviewed-no-change` when the file was inspected, no cleanup-safe change was needed, and no file-specific validation was run
- Use `cleaned-unvalidated-fallback` only when the file was changed and the strongest available validation could not be run; explain the missing validation
- Use `blocked` when cleanup is needed but cannot be completed safely in this command; include the blocker
- Use `skipped` only for files discovered in the queue but explicitly out of cleanup scope; include the reason
- Do not jump to a later cleanup area while the current area still has unreviewed files, unless the current area is empty or blocked by a real environment limitation
- Do not pick opportunistic files from later areas just because they are easier or already familiar
- If the project contains both Livewire classes and their Blade views, Livewire must be the first cleanup area processed
- If the project has no files for an area, state `0 files` and move to the next area
- After the ordered cleanup areas finish their direct-fix pass, run a final unqueued-file reconciliation with `rg --files` or equivalent deterministic discovery to confirm no project-owned implementation files were missed. Add any missed in-scope files to the appropriate area ledger before claiming completion.

Finding classification:
- `direct-fix`: small, local, behavior-preserving, reversible, covered by existing standards or obvious project convention, and validateable within the current cleanup group
- `approval-needed`: cleanup-relevant but broad, risky, cross-module, architectural, likely to affect multiple flows, or requiring a tradeoff between valid implementation options
- `recommendation-only`: outside cleanup scope, including product behavior changes, new features, schema redesign, UI redesign, large architecture migration, or validation/tooling scaffolding not requested by the user
- Apply `direct-fix` findings automatically after the run is approved, then validate and commit them in the smallest coherent unit
- Do not apply `approval-needed` findings silently. Queue them with file, evidence, likely impact, proposed smallest fix, and validation plan for the approval pass after the safe direct-fix coverage pass.
- Keep `recommendation-only` findings out of active cleanup and list them in the final recommendations section.

Coverage ledger format:

```text
Área: {area name}
Archivos: total={n}, queued={n}, reviewed={n}, cleaned={n}, validated={n}, blocked={n}, skipped={n}
- PASS validated {path} — {validation evidence}
- PASS reviewed-no-change {path} — {what was checked}
- WARN cleaned-unvalidated-fallback {path} — {fallback used and missing validation}
- BLOCKED {path} — {blocker}
- SKIPPED {path} — {reason}
```

The ledger is reporting evidence. It must not claim unit tests, browser checks, analyzer passes, or builds unless those checks actually ran.

If a group is too large:
- Split it into phases of 3-5 files or the smallest coherent subsets
- Continue phase by phase without stopping the whole run unless the next phase is risky or blocked

Checklist items must stay cleanup-scoped. Do not add these as active cleanup items:
- New features
- Database redesign
- Behavior changes
- Product/UI redesign requests
- Broad architecture migrations
- Whitespace-only cleanup such as trailing spaces, final-newline-only changes, blank-line-only edits, indentation-only edits, wrapping-only edits, or import-order-only edits unless a concrete project rule explicitly requires the exact hunk
- Test-suite or tooling scaffolding created only to make validation commands runnable, such as adding placeholder test directories or touching config files for final newlines; report missing validation infrastructure as a blocker or follow-up unless the user explicitly included tooling cleanup

Folder and file placement review must still happen, but it is part of the area being processed instead of a separate excuse to roam across the repo. When a file is misplaced, record the placement issue under the current area and fix it there if the move is behavior-preserving.

Those belong in final recommendations.

---

## Phase 4 - Cleanup Execution Loop

Process the checklist from top to bottom. Do not stop after each small direct cleanup task just to ask whether to continue.

Hard execution rule:
- Finish or block the current cleanup area before moving to the next one
- Within an area, work through the file queue in deterministic order
- Do not skip ahead to a later file just to find an easier refactor unless the current file is blocked and that blocker is reported
- Do not switch from Livewire to models, or from models to traits, until the current area's queue is exhausted or explicitly blocked

For each cleanup group:

1. Analyze the queued files against:
   - `coding_standards/**`
   - `guides/**`
   - local project conventions already in use
2. Build an explicit file queue in deterministic order
3. Classify findings as `direct-fix`, `approval-needed`, or `recommendation-only`
4. Show the current coverage counts for the active area before editing, plus the standards or project rules being applied to the current direct-fix set
5. Call `developer` with only the current `direct-fix` cleanup group, file queue, and cleanup findings
6. `developer` refactors the smallest coherent unit possible
7. Keep the intended behavior the same
8. Validate the modified unit immediately
9. If validation passes, create the required commit for that improved primary file or coherent unit, then continue to the next direct-fix unit or group automatically
10. If validation fails, fix only the affected unit and revalidate
11. If the group reveals an `approval-needed` item, queue it for the approval pass instead of implementing it silently
12. If the group reveals a larger non-cleanup issue, record it as a follow-up item and continue when safe

After all cleanup areas complete the safe direct-fix coverage pass, including unqueued-file reconciliation, process the global `approval-needed` queue one item at a time:
- Present the file or tightly coupled file set, the evidence found, the standard or project rule involved, the likely impact, the smallest proposed fix, and the validation plan.
- Ask whether to proceed with that single item.
- If the user approves, implement only that item, validate it fully, create the required commit when validation passes, update the ledger, and then present the next approval-needed item.
- If the user declines or does not decide, mark that item as `blocked` or `recommendation-only` with the reason, then move to the next approval-needed item.
- Stay inside the cleanup flow until every queued approval-needed item is approved and validated, declined, blocked, or moved to recommendations with an explicit ledger entry.

Visible progress rules:
- Report progress in the user's language at least every 15 minutes during long runs
- Report the active area name and coverage counts whenever the command enters a new area
- Report when a cleanup group starts, when it passes validation, when it is blocked, and when an improved primary file is committed
- Keep a visible file-by-file or pair-by-pair trace
- For each changed file or coherent unit, show the concrete standards, guides, analyzer findings, or project conventions applied before or alongside the change summary
- For each materially validated step, emit a visible pass/fail style line so the user can see what passed, failed, or was blocked
- For each unchanged file that was reviewed, emit a visible `PASS reviewed-no-change` line or include it in the next area ledger update
- Treat those lines as reporting evidence only. Do not imply that unit tests ran unless they actually ran

The command should feel like an active cleanup session, not a passive audit.

---

## Per-File And Per-Group Rules

Within each cleanup group:
- Analyze files in deterministic order
- Review tightly related file pairs together only when one file cannot be understood alone
- State why coupled files are being handled together
- Keep edits closely scoped to the cleanup group
- Prefer behavior-preserving refactors over stylistic churn
- Avoid broad rewrites when a smaller cleanup achieves the same result
- Do not make whitespace-only, trailing-whitespace-only, final-newline-only, blank-line-only, indentation-only, wrapping-only, import-order-only, or other cosmetic formatting changes unless a concrete cleanup rule explicitly requires that exact change
- Before validating or committing a cleanup unit, inspect the diff and revert any hunk whose only effect is spacing, trailing whitespace, final newline, blank lines, wrapping, import ordering, or cosmetic formatting not required by a concrete rule
- Do not run Pint, PHP-CS-Fixer, Prettier, `npm run format`, broad auto-formatters, project-wide formatting commands, or equivalent formatter scripts during `/cleanup` unless the user explicitly asks for formatting. Use targeted edits only and leave formatter execution to project maintainers.
- Mark unchanged inspected files as `reviewed-no-change` with the specific standard or convention that was checked
- If a file is skipped, say why
- If a file is deferred because it would change behavior or needs a larger design change, count it as `blocked` or `recommendation`, not as silently skipped or completed
- If a file has both direct-fix and approval-needed findings, apply only the direct-fix findings first; do not mark the file fully complete until the approval-needed finding is approved and validated, declined, blocked, or moved to recommendations with an explicit ledger entry

Behavior-preserving rule:
- The system should still work the same after cleanup
- The visible flow, business rules, and expected outputs should remain the same
- If a possible cleanup would change behavior, stop that specific item and move it to recommendations unless the user explicitly approves the behavior change

Recommendation rule:
- If cleanup reveals missing migrations, schema redesigns, new abstractions, UI redesigns, performance work, or business-rule problems, do not silently implement them as part of cleanup
- Distinguish approval-needed cleanup refactors from recommendation-only items: approval-needed cleanup refactors are presented one by one during the cleanup flow; recommendation-only items stay in the final recommendations section
- Report recommendation-only items with enough context to decide later

---

## Phase 5 - Validation Strategy

Every modified cleanup group must be validated before it is treated as complete.

Before validation, identify directly coupled files and flows affected by the diff. For Livewire components, Blade views, view models, routes, translations, or UI-facing data changes, include the paired view/component and affected browser route in the validation queue even when only one file was edited.

If cleanup moves data from a Livewire `render()` variable to a `#[Computed]` method, verify the paired Blade view now references the computed value as `$this->propertyName`; leaving the former bare render variable in Blade is a validation failure.

Validation order for each group:

1. Focused code validation
2. Focused runtime/artisan/build validation when relevant
3. Browser validation for user-facing flows when possible
4. External Code Analysis revalidation for modified code files when available

### Code Analysis Validation

Check whether the current project's parent directory contains a sibling repository named `ia-analyzer` (`../ia-analyzer`). Do not hardcode a machine-specific absolute analyzer path.

If `../ia-analyzer` exists, external Code Analysis is required for every modified code or implementation file in the current cleanup group. Run this command from `../ia-analyzer`:

```bash
php artisan validate:now "Code Analysis" "{absolute_modified_file_path}"
```

Rules:
- The second argument must be the exact absolute path of the modified file
- Show each analyzer pass as `Code analyzer iteration N started`
- Show the file queue for the current cleanup group
- If a file fails, return coherent, cleanup-safe findings to `developer`, fix only the affected files, and rerun validation for the affected modified files in the current group
- Apply most coherent small analyzer comments during cleanup when they preserve behavior and stay inside the current cleanup group
- Do not implement analyzer comments that are incoherent, contradict repository evidence, appear to be false positives, or only create formatter/rule churn with no meaningful cleanup benefit; classify and report them instead
- If an analyzer comment would require a broad architectural, data-model, cross-module, or product-behavior refactor, do not apply it automatically during cleanup; record the file, requested change, and likely impact, then ask the user at the end whether to proceed
- If additional files are modified during the fix, add them to the current validation queue
- Do not silently ignore analyzer failures
- Treat analyzer results as a strong validation source, but not as an infinite-stop requirement when the remaining failures are narrow, repeated, or likely analyzer/rule friction

If `../ia-analyzer` does not exist:
- Use the previous internal fallback flow for modified files: `developer` fixes, `code-reviewer` reviews the changed files, and iterate until the group is clean or clearly blocked

### Browser Validation

When a cleanup group affects a local visible flow:
- Read the project URL from `.env`, preferring `APP_URL`
- If the URL does not include a scheme, prepend `http://`
- Follow the global Browser Validation Rule: prefer Playwright connected over CDP, then use an approved equivalent runtime browser path when CDP is unavailable
- When auth is required, ask the user to log in manually in the browser session used for traversal
- Recover safe validation-environment issues before giving up, such as starting the normal dev server, choosing a free temporary local port, or installing missing validation dependencies through the project's package manager and lockfile conventions when safe
- Reload after code changes before checking the updated flow
- Open the affected route or entry point, confirm the page renders without visible errors, and verify the changed data or component output is still visible and correct
- Traverse the in-scope non-destructive controls needed to prove the changed UI still behaves the same from the user's perspective
- Report blockers such as auth state, missing server, missing seed data, unavailable route, unavailable browser path, or dependency/tooling failures

Command-line checks, runtime checks, or Code Analysis do not replace visible browser validation for a user-facing flow. Browser validation is a commit gate for UI-facing cleanup changes. If browser validation cannot run, mark that visible-flow validation as `blocked` or `cleaned-unvalidated-fallback` with the exact reason, browser paths, and endpoints tried, and do not commit that UI-facing cleanup as validated.

If browser validation reveals an error, missing variable, broken binding, console/runtime failure, or missing displayed data, return to implementation, fix the issue, and rerun Code Analysis plus browser validation for the affected files and flow.

### Validation Failure Rules

If validation fails:
- Keep the scope on the current cleanup group
- Fix the specific issue
- Revalidate the affected files and visible flow
- Do not keep broadening scope while a group is still failing

Analyzer stall rules:
- Try to fix repeated analyzer failures for the current file or tightly coupled file set before giving up
- Stop the current analyzer loop for that file or file set after 5 implementation attempts, or earlier if 2 consecutive attempts produce no meaningful code change or no new evidence
- If the analyzer keeps rejecting a file after meaningful attempts, or the remaining analyzer request is incoherent or too broad for cleanup, classify the remaining result as one of:
  - real cleanup issue still pending
  - likely analyzer inconsistency or rule friction
  - larger refactor that exceeds the cleanup timebox
- Record that classification in the coverage report and continue to the next file in the same area when possible
- For larger cleanup-relevant refactors, add the item to the approval-needed queue with the exact file and requested change instead of implementing it silently
- Do not let one stubborn file block the rest of the cleanup area forever
- If several files in the same area stall for the same root cause, mark the area partially blocked, summarize the shared blocker, and continue to the next cleanup area

Continuation rules:
- Prefer continuing with the next file over ending the whole cleanup run when the current file is the only blocker
- Prefer continuing with the next cleanup group over ending the whole cleanup run when the current group is partially blocked but the remaining groups are independent
- A partially blocked cleanup run is partial progress, not a completed cleanup; say `PARTIAL` or `BLOCKED` clearly and list the unprocessed areas
- Final status should distinguish between fully validated cleanup groups, committed file improvements, and groups closed with reported blockers or inconsistencies

If a cleanup group stalls:
- Stop after 5 implementation attempts for that group, or earlier if 2 consecutive attempts produce no new evidence
- Mark the group as blocked
- Continue to the next independent cleanup group only after the blocked files are explicitly listed in the area coverage report
- Report the blocker clearly in the final summary

---

## Phase 6 - Commit Rules

Commits are required for the cleanup run unless the user explicitly forbade commits:
- Create one commit per improved primary file as the default behavior
- Create the commit immediately after that primary file improvement passes its required validation and before moving to the next independent primary file
- Include both direct-fix and approved approval-needed changes in commits only after their own validation passes
- For UI-facing changes, validation passes only after the affected route or flow was opened in a real browser and the changed data or component output was checked
- When improving one primary file requires related changes in paired views, translations, tests, helpers, or other directly coupled files, include those related files in the same commit and keep the commit message focused on the primary file improvement
- If multiple primary files are inseparable for one cleanup fix, create the smallest coherent cleanup commit and say why it could not be split as one improved file per commit
- Stage only the files that belong to the current validated file improvement
- Do not mix unrelated cleanup work in the same commit
- If a commit cannot be created after validation, stop before continuing to unrelated cleanup work, report the exact blocker, and list the uncommitted changed files
- Do not push unless the user explicitly asks

Only when the user explicitly forbids commits:
- Still keep the same cleanup grouping and validation boundaries in the report
- Report each validated improvement that was intentionally left uncommitted because commits were explicitly disabled

---

## Final Summary

After all cleanup groups, summarize:
- What was cleaned and refactored
- Which groups were fully validated
- Which groups were blocked or partially completed
- Files or areas skipped and why
- Area-by-area coverage totals with `queued`, `reviewed`, `cleaned`, `validated`, `blocked`, and `skipped`
- A per-area file ledger with PASS/WARN/BLOCKED/SKIPPED evidence lines, grouped like a test report
- Validation methods used:
  - Code Analysis or internal fallback
  - Real browser coverage, including the browser path used
  - artisan/build/runtime checks
- Reported analyzer inconsistencies or files skipped after repeated attempts
- Direct-fix findings applied automatically, approval-needed findings processed one by one, and recommendation-only findings left for later
- Files created or modified by this cleanup run, grouped by committed improvement
- Commits created with hash and message, or the exact reason a validated improvement was left uncommitted
- Current `git status` summary after the last commit attempt
- Total cleanup groups processed
- Total validation iterations

Then include a separate follow-up section for recommendation-only items or approval-needed items the user declined, deferred, or could not validate, such as:
- Database or schema changes
- Product/UI redesign opportunities
- Architectural changes that would alter behavior or were declined/deferred during the approval-needed pass
- Significant technical debt that exceeded the cleanup timebox

That recommendations section should inform the user what is worth doing next without mixing those items into the finished cleanup result.

Completion wording rules:
- Do not say the project, repo, or cleanup run is "clean", "done", or "fully cleaned" just because `git status` is clean
- Use that wording only when every mandatory cleanup area was either completed, explicitly empty, or explicitly blocked with coverage counts
- If only part of the cleanup order was processed, say exactly which areas were completed and which areas remain pending
- A clean working tree is only git state, not cleanup completion
- If the final summary does not include the area-by-area ledger, say the run produced code changes but did not satisfy the cleanup reporting contract

---

## Rules

- Treat `/cleanup` as active project-wide cleanup execution by default when the user asks for a broad cleanup run
- Create commits by default during `/cleanup`; the only valid opt-out is an explicit user instruction forbidding commits
- Preserve intended behavior unless the user explicitly approves a behavior change
- Treat explicit cleanup wording as approval to start unless a real ambiguity remains
- Apply small direct-fix findings automatically after the run is approved; ask only for approval-needed findings that are broad, risky, cross-cutting, or likely to affect multiple flows
- Review every relevant file in strict cleanup order; unchanged files still require an explicit reviewed status
- Reconcile the discovered file queues before claiming completion so every project-owned implementation file is reviewed, validated, skipped, or blocked with a reason
- Maintain and report the per-file coverage ledger throughout the run
- Do not stop after every cleanup task just to request permission to continue
- Do not end the command with a follow-up question; end with the cleanup result and the separate recommendations section
- Do not cherry-pick easy files from unrelated areas before earlier cleanup areas were covered
- Livewire first, then models, then traits, then services, then notifications/policies/observers, then Blade/translations, then routes/config, then tooling/helpers/casts
- Do not present a clean git working tree as evidence that the cleanup scope was fully covered
- Keep a visible progress trace throughout the run
- Reject whitespace-only, trailing-whitespace-only, final-newline-only, blank-line-only, indentation-only, wrapping-only, import-order-only, and cosmetic formatting diffs unless a concrete cleanup rule explicitly requires them
- Validate every modified cleanup group before considering it complete
- For UI-facing cleanup groups, Code Analysis and command-line checks are not enough; open the affected browser flow and verify the visible output before marking the group validated or committing it
- Use the global Browser Validation Rule for user-facing flows when available
- Use external Code Analysis for modified files when `../ia-analyzer` exists
- If `../ia-analyzer` does not exist, use the internal `developer` -> `code-reviewer` fallback for modified files
- Do not let one analyzer-rejected file or one stubborn cleanup group block the rest of the run forever
- After repeated meaningful attempts, report the blocker or inconsistency and continue with the next independent file or group
- Process cleanup-relevant larger refactors through the approval-needed queue; record non-cleanup issues as final recommendations instead of silently expanding scope
- Do not claim UI validation when no browser validation happened
- Do not push unless the user explicitly asks
