---
name: cleanup
description: Use this command when the project already works and the user wants a general health check, cleanup, refactor, standards pass, or project-wide improvement — not a specific file. Triggers when the user says "limpia el proyecto", "el proyecto está desactualizado", "hay cosas que no siguen estándares en todo el proyecto", "cleanup", or anything suggesting broad project-wide cleanup. Do NOT use to repair a broken branch/project after a merge, Laravel upgrade, base update, or branch divergence — use /repair-project for that. Do NOT use for a specific file or module — use /review for that.
---

# /cleanup — Project Health Check & Cleanup

Your goal is to run structured cleanup and refactor tasks on a project that already works, one at a time, each scoped to ~10-15 minutes of work. After each task you present findings and ask how to proceed.

If the project is currently broken after a merge, Laravel upgrade, Weblabor Base update, dependency update, branch divergence, or copy from another project, stop and recommend `/repair-project` first. Cleanup happens after repair, not before.

---

## Entry Point

When invoked, explain the process briefly:
> "Voy a revisar el proyecto por áreas. Cada tarea es independiente — después de cada una te digo qué encontré y decides si ejecutamos, generamos el prompt para Copilot, o pasamos a la siguiente."

Then start with Task 1.

---

## Standard Tasks (run in this order)

### Task 1 — Folder & File Structure
- Are Livewire components in the correct directories? (`app/Livewire/Admin/`, `app/Livewire/Teams/`, etc.)
- Are models, observers, notifications, traits in their standard locations?
- Are there files in non-standard custom folders that should be moved?

### Task 2 — Notifications
- Do all notifications extend `App\Notifications\Notification`?
- Do all notifications define `subject()`, `description()`, and `image()`?
- Are any using hardcoded channels instead of the base class?

### Task 3 — Translations
- Are there hardcoded user-facing strings in Blade or PHP files?
- Are there Spanish strings that should be in `lang` files?
- If the volume is large: split into batches of ~10-15 files and propose a phased plan

### Task 4 — Browser Flow Validation
- Does the project define a local URL in `.env`, preferably `APP_URL`?
- Can the main user flows be opened with Browser Use in the Codex in-app browser?
- Are there broken screens, blocked actions, missing assets, or visible regressions in the main flows?
- Report: what was validated, what is blocked, and what environment detail is missing

---

## Per-Task Flow

For each task:

1. **Analyze** — inspect the relevant area against the repository root standards files and guides under `guides/`, plus local project conventions. Do not run external Code Analysis in this command; if analyzer-driven review is needed, hand off to `/review`
2. **Report** findings clearly:
   - What's correct
   - What's wrong, with specific file references
   - If the scope is large: estimate how many steps it would take and flag it
3. **Ask**:
   > "¿Qué deseas hacer con esto?"
   - **Ejecutar aqui** — call `developer` to apply fixes, then run focused validation for the specific cleanup task
   - **Generar prompt para Copilot** — generate a ready-to-paste prompt with full context and instructions
   - **Saltar** — move to the next task
4. Apply or generate. If code files were modified, run focused validation for that task, return failed findings to `developer`, and repeat only as needed for the task in scope. Use `/review` if the user wants analyzer-backed standards validation. Then move to the next task

---

## Large Scope Rule

If a task would take more than ~15 minutes to fix completely:
- Split it into phases of 3-5 files or logical groups
- Present the phases and ask which to start with
- Never work more than one phase without checking in

---

## Wrap Up

After all tasks, summarize:
- What was fixed
- What was skipped
- What still needs attention

Then ask:
> "¿Te gustaría continuar con /review para profundizar en algún módulo, o con /finish para pulir flujos visibles y documentación?"

---

## Output: Copilot Prompt Format

When the user chooses "Generar prompt para Copilot", produce a self-contained prompt that includes:
- Full context: which files, what's wrong, what the correct version looks like
- Step-by-step instructions referencing the coding standards and guides in this repository
- Expected outcome: what should be true when the task is done
- Edge cases to watch out for

The prompt must be usable by a developer or another AI without needing to ask any clarifying questions.
