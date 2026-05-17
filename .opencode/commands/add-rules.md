---
name: add-rules
description: Use this command when the user reports a bug, incorrect AI output, or a missing standard and wants the fix to improve coding standards too. Trigger it when the issue should first be checked against the standards under `coding_standards/` and guides under `guides/`, then either reinforce an existing rule or create a new one if no rule covers it.
---

# /add-rules — Fix And Harden Standards

Your goal is to diagnose the problem, fix the code when a code change is needed, validate the fix with focused evidence, and update the standard so the issue cannot happen again.

---

## Phase 1 — Standards Check

1. Read `README.md` and the relevant standards or guide files.
2. Identify whether a rule already covers the reported issue.
3. If a rule exists, explain:
   - What the rule currently says
   - Why the existing code likely missed it
   - Whether the rule itself should be clarified or strengthened
4. If no rule exists, say that clearly — the issue is currently uncovered.

---

## Phase 2 — Diagnose Fix And Rule Change

Analyze the affected code and standards to identify:

- The smallest correct code fix, when code needs to change
- Whether a standard needs a new rule, stronger wording, or an example
- The exact standard text to add or update
- Any risk that would expand scope beyond the reported issue

Present the diagnosis and exact proposed standard text to the user. Ask for confirmation before proceeding.

---

## Phase 3 — Implement And Validate Code Changes

After user confirmation, call `developer` to apply the code fix when a code fix is needed.

If any code or implementation file is modified:

1. Choose the smallest validation that proves the reported issue is fixed.
2. Run targeted runtime, artisan, build, or Playwright-over-CDP browser checks based on the issue that triggered the rule change.
3. If validation fails, return the new evidence to `developer`, update the affected files, and rerun only the relevant validation.
4. Keep the loop bounded. If the same path fails repeatedly without new evidence, stop and report the blocker.

Do not treat the code fix as complete until the reported issue is functionally validated or the blocker is clearly documented.

---

## Phase 4 — Update Standards

After code validation passes, update the relevant standard under `coding_standards/` or guide under `guides/` with the confirmed rule.

If the change affects shared workflow guidance, update `guides/ai-assistants.md` and `OPENCODE.md` when applicable.

Standards update scope:
- Edit only the rule text, examples, or nearby context needed to cover the reported issue.
- Do not reformat, reorder, rename, or style-clean unrelated standards content while adding or clarifying a rule.
- Do not run Pint, PHP-CS-Fixer, Prettier, `npm run format`, broad formatters, project-wide formatting commands, or equivalent formatter scripts against code or standards documentation as part of a rule update unless the user explicitly asks for formatting.
- Treat mechanical PHP style as formatter-owned: Weblabor projects currently use the Weblabor Coding Standards package (`weblabormx/weblabor-cs`) as the formatting reference, not as a formatter this command should run, so rules must not contradict formatter output unless the user explicitly asks to change the formatter configuration.
- If the reported issue is caused by formatter output, document the formatter-backed convention instead of rewriting code or standards to fight the formatter.

---

## Rules

- Always check existing standards first — never skip Phase 1
- Never update standards without showing the exact proposed text and getting confirmation
- Prefer the smallest rule change that prevents recurrence
- Keep standards edits surgical: change only the requested rule or the minimum surrounding wording required for clarity
- Do not include unrelated markdown cleanup, wrapping, spelling changes, or formatting churn in a standards-rule change
- Never skip the standards update step when the issue reveals a gap
- Validate the fix with focused evidence tied to the reported issue
- Use `/review` when the user wants analyzer-backed standards review in addition to the standards update
