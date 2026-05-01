---
name: review
description: Use this command when the user wants to review, refactor, or clean up existing code — whether to check standards compliance, validate a change, or fix violations. Triggers on "revisa", "refactoriza", "limpia", "review", "check", or any request to inspect or fix existing code. Do NOT use to implement new features from scratch — use /develop for that.
---

# /review — Code Review & Refactor

Your goal is to review existing code thoroughly with the external Code Analysis analyzer, identify violations and risks, and optionally implement all corrections. External Code Analysis belongs in this command and in `/develop`.

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

Show the exact command, result, and findings for each file. If the analyzer cannot read a file or the command is unavailable, stop and report the blocker.

If `../ia-analyzer` does not exist, use the previous internal fallback review flow: call `code-reviewer` to load the relevant standards, classify findings, flag regressions/translation issues, and group findings by file.

When the review scope includes a local user-facing flow, prefer Browser Use to inspect the affected screen after fixes:

- Read the project URL from `.env`, preferring `APP_URL` when available.
- If the URL does not include a scheme, prepend `http://`.
- Use the Codex in-app browser and reload after local code changes before checking the flow.
- If browser validation is not possible, report that explicitly instead of implying the flow was checked visually.

---

## Phase 3 — Present Findings And Ask

Present the Code Analysis report when `../ia-analyzer` exists, or the internal code-reviewer report when it does not. Then ask:

> "¿Quieres que implemente los cambios?"

If **no** → deliver the report and stop.

If **yes** → continue to Phase 4.

---

## Phase 4 — Implement Corrections And Revalidate

Call the `developer` agent to apply the approved fixes.

After the developer modifies files:

1. Compare the working tree to the baseline recorded before fixes.
2. If `../ia-analyzer` exists, validate every code or implementation file modified by this command with `php artisan validate:now "Code Analysis" "{absolute_modified_file_path}"` from `../ia-analyzer`.
3. If any file fails, return the analyzer findings to `developer`, update the affected files, and rerun Code Analysis for every affected modified code file.
4. If the developer changes additional code files while fixing analyzer findings, add those files to the validation queue.
5. Keep iterating until every modified code file passes completely. Do not stop only because the number of analyzer iterations is high.
6. If `../ia-analyzer` does not exist, use the previous fallback flow: `developer` applies fixes, `code-reviewer` reviews changed files and cycles with `developer` until clean, then `tech-lead` does architecture review.

If 10 minutes pass without a file reaching a passing analyzer result, stop the current analyzer loop, clear the current validation attempt, and retry the analyzer flow once from the current changed-file queue.

If the retry also goes 10 minutes without a passing file, stop, summarize the remaining findings, and report the blocker instead of continuing indefinitely.

Do not present the refactor/fix as final-ready until either all modified code files pass Code Analysis when `../ia-analyzer` exists, or the internal fallback review passes when it does not exist.

---

## Phase 5 — Present Results

Once validation passes, present the final result to the user:

- Summary of what was corrected
- Files created or modified
- Validation method used (`Code Analysis` or internal fallback), iterations, and final pass status
- Translation files updated or synchronized (if applicable)
- Open questions or blockers (if any)

---

## Rules

- Never implement fixes before the user approves in Phase 3
- Prioritize bugs, regressions, and standards violations over cosmetic suggestions
- If a fix would expand scope materially, stop and ask before continuing
- If translation issues are found, run `lang:search` and `lang:sync` after corrections are applied
- If `../ia-analyzer` exists, do not skip the external Code Analysis validation loop for any code or implementation file modified by this command
- If `../ia-analyzer` does not exist, use the previous `developer` → `code-reviewer` → `tech-lead` fallback flow
