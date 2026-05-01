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

## Phase 2 — Confirm Before Implementing

Present the confirmed scope to the user. Ask for explicit confirmation before making any changes to the codebase.

If a plan from `/plan` was provided, follow it exactly — do not deviate without asking.

Before implementing, record the current working tree state so pre-existing user changes are not confused with files modified by this command.

---

## Phase 3 — Developer Implementation

After confirmation, call the `developer` agent to implement the confirmed scope.

The developer must:

- Modify only files required by the confirmed scope.
- Follow existing codebase patterns and `docs/development-guides/coding-standards/`.
- Return the list of files it created or modified.
- Apply any later Code Analysis findings sent back by this command.

Do not run tests or write documentation as part of this command unless the confirmed scope explicitly requires changing tests or documentation files.

---

## Phase 4 — External Code Analysis Validation

Identify the modified files by comparing the current working tree to the baseline recorded before implementation. Validate only files changed by this command, not unrelated pre-existing dirty files.

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

If `../ia-analyzer` does not exist, skip external Code Analysis in this command and use focused runtime, artisan, build, or test validation that matches the confirmed scope.

Do not expose private chain-of-thought. The visible trace must show analyzer results or fallback validations, fixes applied, commands or tools used, paths, and final result.

---

## Phase 5 — Present Results

Once validation passes, present the final result to the user:

- Summary of what was implemented
- Files created or modified
- Validation method used (`Code Analysis` or focused fallback), iterations, and final pass status
- Translation files updated or synchronized (if applicable)
- Open questions or blockers (if any)

Stop here. Do not run tests or documentation as part of this command unless explicitly requested or already included in the confirmed scope.

---

## Rules

- Never skip the analyst step, even for small changes
- Never implement without user confirmation after Phase 2
- Keep changes minimal — only what was defined in requirements
- Do not run tests or write documentation in this flow unless explicitly requested or included in the confirmed scope
- If `../ia-analyzer` exists, run external Code Analysis for modified code or implementation files in this command
- If `../ia-analyzer` does not exist, use focused validation that matches the confirmed scope
- External Code Analysis belongs in `/develop` and `/review`
