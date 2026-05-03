---
name: cleanup
description: Use this command when the project already works and the user wants project-wide cleanup, refactor, standards alignment, or internal code quality improvements without changing the intended behavior. Triggers when the user says "limpia el proyecto", "refactoriza todo", "dejalo al punto", "cleanup", or anything suggesting broad execution-heavy cleanup. It should actively clean the codebase in small validated groups, preserve visible behavior and business logic, review every relevant file in strict area order, maintain an explicit per-file coverage ledger, validate each modified group with Code Analysis when available plus Playwright-over-CDP browser validation for user-facing flows, keep a visible progress trace, and leave larger architectural or product recommendations for the final summary. Do NOT use to repair a broken branch/project after a merge, Laravel upgrade, Weblabor Base update, dependency update, branch divergence, or copy from another project — use /repair-project for that. Do NOT use to implement new features — use /develop for that. Do NOT use for a narrow file/module-only request — use /review for that.
---

# /cleanup - Project Cleanup And Refactor

Your goal is to leave a working project cleaner, more standard, and easier to maintain without changing its intended behavior.

Treat this command as an execution-heavy cleanup flow, not as a report-only audit.

Core behavior:
- Refactor and clean the project proactively in small validated groups
- Preserve the same visible behavior, business logic, routes, permissions, and data behavior unless a strictly behavior-preserving fix requires a minimal adjustment
- Review every relevant file in the cleanup order, including files that do not need edits
- Maintain a visible per-file coverage ledger with a terminal status for every discovered file
- Keep the user informed with a visible progress trace while continuing automatically
- Validate each modified cleanup group before moving on
- Record larger issues, risky changes, schema changes, new features, or product recommendations for the final summary instead of expanding scope mid-run
- Traverse the codebase in strict cleanup order instead of cherry-picking easy wins from unrelated areas

Coverage contract:
- Cleanup is not complete just because several groups were improved or the git tree is clean
- A broad cleanup run must either review, clean, validate, skip with reason, or block with reason every relevant file discovered in the mandatory cleanup areas
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
- Whether the local project can be opened in a Chrome session that the user can authenticate manually and expose through remote debugging for Playwright CDP control
- Whether the current project's parent directory contains a sibling repository named `ia-analyzer` (`../ia-analyzer`)
- Relevant artisan, build, route, or runtime checks that can validate the cleaned area

Validation expectations:
- If `../ia-analyzer` exists, use external Code Analysis for modified code or implementation files in this command
- If a cleaned group affects a user-facing flow and browser validation is possible, use Playwright connected over CDP to a user-opened Chrome session as the primary visible validation for that flow
- If browser validation is not possible, say so clearly and use the strongest available fallback checks

If browser validation is unavailable for a user-facing flow, tell the user clearly:

> No pude validar este flujo en el navegador con Playwright por CDP porque falta URL local utilizable, servidor levantado, una sesion autenticada en Chrome con remote debugging, o el entorno necesario. Puedo continuar con cleanup y validaciones de codigo, artisan o build, pero la confianza visual sera menor.

Do not pretend a UI flow was visually validated if it was not opened.

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
- If the user asked for a long cleanup run and did not forbid commits, present `Commit per validated cleanup group` as the selected default
- If commit preference is unclear and the run is interactive, state the default instead of leaving commit behavior implicit

Do not ask for per-group approval, per-phase approval, or end-of-run approval. The command should either continue automatically, stop on a real blocker, or finish and report.

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
- Validation method
- Whether the group touches a visible flow
- Whether a commit was created
- Attempt count

Coverage rules:
- Build the file queue for the entire active area before cleaning the first file in that area
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

Folder and file placement review must still happen, but it is part of the area being processed instead of a separate excuse to roam across the repo. When a file is misplaced, record the placement issue under the current area and fix it there if the move is behavior-preserving.

Those belong in final recommendations.

---

## Phase 4 - Cleanup Execution Loop

Process the checklist from top to bottom. Do not stop after each task just to ask whether to continue.

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
3. Show the current coverage counts for the active area before editing
4. Call `developer` with the current cleanup group, file queue, and cleanup findings
5. `developer` refactors the smallest coherent unit possible
6. Keep the intended behavior the same
7. Validate the modified unit immediately
8. If validation passes, continue to the next cleanup unit or next group automatically
9. If validation fails, fix only the affected unit and revalidate
10. If the group reveals a larger non-cleanup issue, record it as a follow-up item and continue when safe

Visible progress rules:
- Report progress in the user's language at least every 15 minutes during long runs
- Report the active area name and coverage counts whenever the command enters a new area
- Report when a cleanup group starts, when it passes validation, when it is blocked, and when it is committed
- Keep a visible file-by-file or pair-by-pair trace
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
- Mark unchanged inspected files as `reviewed-no-change` with the specific standard or convention that was checked
- If a file is skipped, say why
- If a file is deferred because it would change behavior or needs a larger design change, count it as `blocked` or `recommendation`, not as silently skipped or completed

Behavior-preserving rule:
- The system should still work the same after cleanup
- The visible flow, business rules, and expected outputs should remain the same
- If a possible cleanup would change behavior, stop that specific item and move it to recommendations unless the user explicitly approves the behavior change

Recommendation rule:
- If cleanup reveals missing migrations, schema redesigns, new abstractions, UI redesigns, performance work, or business-rule problems, do not silently implement them as part of cleanup
- Finish the approved cleanup work first
- Report those items in the final recommendations section with enough context to decide later

---

## Phase 5 - Validation Strategy

Every modified cleanup group must be validated before it is treated as complete.

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
- If a file fails, return the findings to `developer`, fix only the affected files, and rerun validation for the affected modified files in the current group
- If additional files are modified during the fix, add them to the current validation queue
- Do not silently ignore analyzer failures
- Treat analyzer results as a strong validation source, but not as an infinite-stop requirement when the remaining failures are narrow, repeated, or likely analyzer/rule friction

If `../ia-analyzer` does not exist:
- Use the previous internal fallback flow for modified files: `developer` fixes, `code-reviewer` reviews the changed files, and iterate until the group is clean or clearly blocked

### Browser Validation

When a cleanup group affects a local visible flow:
- Read the project URL from `.env`, preferring `APP_URL`
- If the URL does not include a scheme, prepend `http://`
- Open the relevant flow by connecting Playwright over CDP to a user-opened Chrome session
- When auth is required, ask the user to log in manually in that Chrome session before traversal starts
- Reload after code changes before checking the updated flow
- Confirm the flow still behaves the same from the user's perspective
- Report blockers such as auth state, missing server, missing seed data, or unavailable route

Command-line checks, runtime checks, or Code Analysis do not replace visible browser validation for a user-facing flow when Playwright CDP validation is available.

### Validation Failure Rules

If validation fails:
- Keep the scope on the current cleanup group
- Fix the specific issue
- Revalidate the affected files and visible flow
- Do not keep broadening scope while a group is still failing

Analyzer stall rules:
- Try to fix repeated analyzer failures for the current file or tightly coupled file set before giving up
- Stop the current analyzer loop for that file or file set after 5 implementation attempts, or earlier if 2 consecutive attempts produce no meaningful code change or no new evidence
- If the analyzer keeps rejecting a file after meaningful attempts, classify the remaining result as one of:
  - real cleanup issue still pending
  - likely analyzer inconsistency or rule friction
  - larger refactor that exceeds the cleanup timebox
- Record that classification in the coverage report and continue to the next file in the same area when possible
- Do not let one stubborn file block the rest of the cleanup area forever
- If several files in the same area stall for the same root cause, mark the area partially blocked, summarize the shared blocker, and continue to the next cleanup area

Continuation rules:
- Prefer continuing with the next file over ending the whole cleanup run when the current file is the only blocker
- Prefer continuing with the next cleanup group over ending the whole cleanup run when the current group is partially blocked but the remaining groups are independent
- A partially blocked cleanup run is still successful if it materially improved the covered files, validated what it could, and clearly reported what remained open
- Final status should distinguish between fully validated cleanup groups and groups closed with reported blockers or inconsistencies

If a cleanup group stalls:
- Stop after 5 implementation attempts for that group, or earlier if 2 consecutive attempts produce no new evidence
- Mark the group as blocked
- Continue to the next independent cleanup group only after the blocked files are explicitly listed in the area coverage report
- Report the blocker clearly in the final summary

---

## Phase 6 - Commit Rules

If commits are allowed for the cleanup run:
- Create one commit per validated cleanup group as the default behavior
- If the user explicitly asked for per-file commits, use one commit per modified file only when the files are independently valid and separable
- If multiple modified files are inseparable for one cleanup fix, create the smallest coherent cleanup-group commit and say why
- Stage only the files that belong to the current validated cleanup unit
- Do not mix unrelated cleanup work in the same commit
- Do not push unless the user explicitly asks

If commits are not allowed:
- Still keep the same cleanup grouping and validation boundaries in the report

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
  - Playwright CDP browser coverage
  - artisan/build/runtime checks
- Reported analyzer inconsistencies or files skipped after repeated attempts
- Commits created
- Total cleanup groups processed
- Total validation iterations

Then include a separate follow-up section for larger items discovered during cleanup but not implemented, such as:
- Database or schema changes
- Product/UI redesign opportunities
- Architectural changes that would alter behavior or require separate approval
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
- Preserve intended behavior unless the user explicitly approves a behavior change
- Treat explicit cleanup wording as approval to start unless a real ambiguity remains
- Review every relevant file in strict cleanup order; unchanged files still require an explicit reviewed status
- Maintain and report the per-file coverage ledger throughout the run
- Do not stop after every cleanup task just to request permission to continue
- Do not end the command with a follow-up question; end with the cleanup result and the separate recommendations section
- Do not cherry-pick easy files from unrelated areas before earlier cleanup areas were covered
- Livewire first, then models, then traits, then services, then notifications/policies/observers, then Blade/translations, then routes/config, then tooling/helpers/casts
- Do not present a clean git working tree as evidence that the cleanup scope was fully covered
- Keep a visible progress trace throughout the run
- Validate every modified cleanup group before considering it complete
- Use Playwright over CDP for user-facing flows when available
- Use external Code Analysis for modified files when `../ia-analyzer` exists
- If `../ia-analyzer` does not exist, use the internal `developer` -> `code-reviewer` fallback for modified files
- Do not let one analyzer-rejected file or one stubborn cleanup group block the rest of the run forever
- After repeated meaningful attempts, report the blocker or inconsistency and continue with the next independent file or group
- Record larger non-cleanup issues as final recommendations instead of silently expanding scope
- Do not claim UI validation when no browser validation happened
- Do not push unless the user explicitly asks
