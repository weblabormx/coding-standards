---
name: finish
description: Use this command when the code is already working and the feature needs to be fully polished and closed out. Runs frontend review, UX review, Browser Use validation, translation validation, and documentation in sequence. Do NOT use for active development — use /develop for that.
---

# /finish — Feature Completion

Your goal is to take a working feature and make it fully production-ready: polished UI, validated real browser flows, validated translations, and complete documentation.

Assumes code is already clean (standards-compliant, no known backend issues). If that is not the case, run `/review` or `/develop` first.

---

## Phase 1 — Scope confirmation

Ask the user what feature or area to finish. Confirm the affected files and flows before proceeding.

---

## Phase 2 — Frontend review

Call the `frontend` agent to review all UI files in scope against `coding_standards/tailwind.md`.

Frontend will produce a report of violations grouped by file and complexity. Present this to the user and ask:
> "¿Quieres que se implementen estas correcciones?"

Wait for confirmation. Only proceed with approved items.

---

## Phase 3 — UX review

Call the `ux-designer` agent to review the UI of the confirmed scope.

`ux-designer` will produce proposals grouped by concern. Present these to the user and ask:
> "¿Cuáles de estas propuestas quieres que se implementen?"

Wait for confirmation. Only proceed with approved proposals.

---

## Phase 4 — Frontend implementation

Call the `frontend` agent to implement everything confirmed in Phases 2 and 3.

The cycle runs automatically:
- `frontend` implements → calls `ux-designer`
- `ux-designer` confirms or sends feedback → `frontend` fixes → repeat
- Cycle continues until `ux-designer` confirms the UI is clean (or escalates after 3 cycles)

---

## Phase 5 — Browser Validation

If Phase 4 modified files, validate the confirmed user flow with Browser Use before translation validation.

- Read the project URL from `.env`, preferring `APP_URL` when available
- If the URL does not include a scheme, prepend `http://`
- Open the flow in the Codex in-app browser with Browser Use
- Reload after code changes before checking the updated flow
- Confirm the visible flow works, and note any blockers or environment limitations
- Run targeted build or runtime checks only when the changed files require them in addition to browser validation
- If a backend or standards issue appears, stop and recommend `/review` or `/develop`
- Do not run external Code Analysis in this command

---

## Phase 6 — Translation validation

Run the following in order:
```
php artisan lang:sync
php artisan lang:search
php artisan lang:sync
```

Report any missing or unsynced translations. Confirm they are complete across all existing locales before continuing.

---

## Phase 7 — Documentation

Call the `documenter` agent to:
- Identify what changed or was added
- Update or create documentation in the correct `docs/{project}` folder
- Link any new files from `docs/{project}/README.md`

---

## Wrap up

Summarize what was completed across all phases:
- Frontend violations corrected (and any skipped)
- UX proposals implemented (and any skipped)
- Browser validation status
- Translation status
- Documentation updated
- Any open items requiring follow-up

---

## Rules

- Never implement anything without user confirmation per phase
- Run Browser Use validation before translations and documentation
- If any phase surfaces a backend issue, stop and recommend `/review` or `/develop` before continuing
