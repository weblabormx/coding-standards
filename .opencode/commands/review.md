---
name: review
description: Use this command when the user wants to review, refactor, or clean up existing code — whether to check standards compliance, validate a change, or fix violations. Triggers on "revisa", "refactoriza", "limpia", "review", "check", or any request to inspect or fix existing code. Do NOT use to implement new features from scratch — use /develop for that.
---

# /review — Code Review & Refactor

Your goal is to review existing code thoroughly with the external Code Analysis analyzer, identify violations and risks, and optionally implement corrections. External Code Analysis belongs in this command, `/develop`, and `/cleanup`, but `/review` must not get trapped indefinitely when the remaining analyzer output appears inconsistent, low-value, or rule-related rather than a real code defect. When corrections are approved, apply small safe fixes directly, validate them, and commit the validated correction by default unless the user explicitly forbids commits.

During `/review`, try to address most coherent analyzer comments, but do not treat every analyzer comment as automatically correct. Small, safe, clearly valid findings should be fixed when the user approves corrections. Incoherent findings, false positives, formatter friction, or comments that contradict repository evidence should be classified and reported instead of being chased forever. Findings that require a broad refactor beyond the approved review scope must be queued and presented one by one with the file, requested change, risk, smallest proposed fix, and validation plan; ask whether to proceed before implementing each larger refactor.

---

## Phase 1 — Analyst

Call the `analyst` agent to confirm what needs to be reviewed and surface any missing context. Analyst should identify the affected files, the intended behavior, and any gaps before the review starts.

---

## Phase 2 — External Code Analysis Review

Check whether the current project's parent directory contains a sibling repository named `ia-analyzer` (`../ia-analyzer`). Do not hardcode a machine-specific absolute analyzer path.

If `../ia-analyzer` exists, run the external analyzer for every target code or implementation file in scope. Run this command from `../ia-analyzer` for each target file:

```bash
php artisan validate:now "Code Analysis" "{absolute_file_path}"
```

The second argument must be the exact absolute path of the file being reviewed.

Show the exact command, result, and findings for each file. This command must keep a visible review trace from the start:

- Show each initial analyzer pass as `Code analyzer iteration 1 started`
- Show each file being checked and the exact command run
- Summarize findings in plain language as they appear, for example `Se encontro X -> pendiente de correccion`
- If no finding appears for a file, say so explicitly

If the analyzer cannot read a file or the command is unavailable, stop and report the blocker.

If `../ia-analyzer` does not exist, use the previous internal fallback review flow: call `code-reviewer` to load the relevant standards, classify findings, flag regressions/translation issues, and group findings by file.

When the review scope includes a local user-facing flow, validate it with the global Browser Validation Rule after fixes:

- Read the project URL from `.env`, preferring `APP_URL` when available.
- If the URL does not include a scheme, prepend `http://`.
- Prefer Playwright connected over CDP to a user-opened Chrome session when available.
- If CDP is unavailable, use an approved equivalent runtime browser path and state which path was used.
- Ask the user to log in manually in the browser session used for validation when auth is required.
- Recover safe validation-environment issues before giving up, such as starting the normal dev server, choosing a free temporary local port, or installing missing validation dependencies through the project's package manager and lockfile conventions when safe.
- If browser validation is still not possible, report that explicitly instead of implying the flow was checked visually.

---

## Phase 3 — Present Findings And Ask

Present the Code Analysis report when `../ia-analyzer` exists, or the internal code-reviewer report when it does not. Include the initial file list, findings by file, and the current status summary before asking:

- Files analyzed
- Files clean
- Files with direct-fix findings that are small, safe, and behavior-preserving
- Files with approval-needed findings that are broad, risky, cross-module, or likely to affect multiple flows
- Recommendation-only findings that should not be implemented in `/review`
- Open blockers or suspicious analyzer inconsistencies detected so far

Then ask:

> "¿Quieres que implemente los cambios?"

If **no** → deliver the report and stop.

If **yes** → continue to Phase 4.

---

## Phase 4 — Implement Corrections And Revalidate

Call the `developer` agent to apply the approved fixes.

Correction scope rules:
- Implement only the findings approved for correction and the minimum code needed to satisfy them.
- For approved review corrections, apply small coherent analyzer fixes directly, but pause before implementing analyzer suggestions that expand into broad architectural, data-model, cross-module, product-behavior, or multi-flow refactors.
- Process larger approval-needed findings one by one: present the file or tightly coupled file set, evidence, likely impact, smallest proposed fix, and validation plan; implement only that item when the user approves it.
- If an analyzer finding does not make sense after checking repository evidence, do not force a code change just to satisfy it; record the inconsistency and continue with other actionable findings.
- Do not reformat, reorder, or style-clean unrelated lines while fixing review findings.
- Do not make whitespace-only, blank-line-only, indentation-only, wrapping-only, import-order-only, or other cosmetic formatting changes unless the approved finding cites an explicit project rule that requires that exact change.
- Before revalidation, inspect the diff and revert any hunk whose only effect is spacing, blank lines, wrapping, import ordering, or cosmetic formatting not required by an approved rule.
- Do not run broad auto-formatters or project-wide formatting commands during `/review`; use the narrowest targeted edit needed for the approved finding.
- Do not change standards documentation during `/review` unless the user explicitly asked to update rules; use `/add-rules` for standards-rule changes.
- Treat mechanical PHP formatting as formatter-owned. In Weblabor projects, Laravel Pint through Weblabor Coding Standards is the current source of truth for Pint/PHP-CS-Fixer-compatible formatting, so do not ask `developer` to fight formatter output.

After the developer modifies files:

1. Compare the working tree to the baseline recorded before fixes.
2. If `../ia-analyzer` exists, validate every code or implementation file modified by this command with `php artisan validate:now "Code Analysis" "{absolute_modified_file_path}"` from `../ia-analyzer`.
3. Show progress for every iteration. At minimum report:
   - `Code analyzer iteration N started`
   - Files in the validation queue
   - For each repeated finding: `Se encontro X -> arreglando`, `Se encontro X otra vez -> revisar inconsistencia`, or `X resuelto`
   - Current counts: files passing, files failing, findings resolved this iteration, findings still open
4. If any file fails, return coherent and scope-safe analyzer findings to `developer`, update the affected files, and rerun Code Analysis for every affected modified code file.
5. If the developer changes additional code files while fixing analyzer findings, add those files to the validation queue.
6. If a finding would require a broad refactor outside the approved correction scope, stop before implementing it, summarize the requested refactor for the user, and ask whether to proceed.
7. If the same finding or essentially the same rule keeps failing after repeated fixes, or if the finding appears incoherent before any fix is safe, do not assume the code is wrong forever. Call `tech-lead` to classify the remaining issue as one of:
   - real code defect still pending
   - analyzer or rule inconsistency
   - ambiguous requirement or missing context
8. If `tech-lead` concludes the remaining issue is an analyzer or rule inconsistency, and the rest of the modified scope is already clean or materially ready, the command may stop the analyzer loop and close with `PASS WITH REPORTED INCONSISTENCIES` instead of blocking indefinitely.
9. If `../ia-analyzer` does not exist, use the previous fallback flow: `developer` applies fixes, `code-reviewer` reviews changed files and cycles with `developer` until clean, then `tech-lead` does architecture review.

After each direct-fix set or approved larger item passes validation, create one focused commit unless the user explicitly forbade commits. Stage only files changed for that validated correction, do not mix unrelated pre-existing changes, and include the commit hash in the result. If a safe commit cannot be created, report the blocker before continuing to unrelated corrections.

Treat the analyzer as the preferred gate, but not as an infinite loop requirement. Use this escalation logic:

- If 10 minutes pass without a file reaching a passing analyzer result, stop the current analyzer loop, clear the current validation attempt, and retry the analyzer flow once from the current changed-file queue.
- If the retry also goes 10 minutes without a passing file, call `tech-lead` before deciding the final status.
- If `tech-lead` confirms the remaining issue is still a real defect, report `BLOCKED`.
- If `tech-lead` confirms the remaining issue is likely a rule inconsistency, false positive, or missing standards clarification, report `PASS WITH REPORTED INCONSISTENCIES`.

Do not present the refactor/fix as full `PASS` until either all modified code files pass Code Analysis when `../ia-analyzer` exists, or the internal fallback review passes when it does not exist. When analyzer inconsistencies remain, use the explicit `PASS WITH REPORTED INCONSISTENCIES` status and explain exactly what was left open and why it was not treated as a blocker.

---

## Phase 5 — Present Results

Once validation finishes, present the final result to the user:

- Summary of what was corrected
- Files created or modified
- Validation method used (`Code Analysis` or internal fallback)
- Direct-fix findings applied, approval-needed findings processed, and recommendation-only findings left for later
- Commits created with hash and message, or the exact reason no commit was created
- Total analyzer iterations performed
- Per-iteration summary of progress and remaining findings
- Final status: `PASS`, `PASS WITH REPORTED INCONSISTENCIES`, or `BLOCKED`
- Any reported inconsistency, ignored analyzer rule, or standards gap that should be reviewed later
- Translation files updated or synchronized (if applicable)
- Open questions or blockers (if any)

---

## Rules

- Never implement fixes before the user approves in Phase 3, except when the original user request explicitly asked for direct correction rather than report-only review
- After correction approval, implement small safe findings directly; present broad or risky findings one by one before implementing each
- Prioritize bugs, regressions, and standards violations over cosmetic suggestions
- If a fix would expand scope materially, stop and ask before continuing
- During refactors, apply most coherent analyzer comments, but do not implement incoherent comments or broad refactors without reporting them and getting user approval
- If translation issues are found, run `lang:search` and `lang:sync` after corrections are applied
- If `../ia-analyzer` exists, run the external Code Analysis validation loop for every code or implementation file modified by this command, and keep a visible progress trace with iterations and findings
- Do not silently ignore analyzer failures; unresolved failures must end either as `BLOCKED` or as `PASS WITH REPORTED INCONSISTENCIES` with a clear explanation
- If `../ia-analyzer` does not exist, use the previous `developer` → `code-reviewer` → `tech-lead` fallback flow
