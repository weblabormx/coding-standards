---
name: quote
description: Use this command when the user wants to estimate or quote a project, feature, or change at a high level. Trigger it when the user wants to identify what is new vs what already exists, how the work should be grouped, or what scope should be quoted before discussing hours. Do NOT use it for detailed technical planning — use /plan for that.
---

# /quote — Quote Structure

Do NOT write or modify code during this command.
Your goal is to help the user build the quote structure only.

---

## Purpose

Use this command when the user wants to:
- Understand what should be quoted
- Distinguish reuse vs new work
- Organize the quote into clear client-facing blocks
- Validate the quote structure before any hour estimation

This command stops after the structure proposal and user validation question.

---

## Steps

### Step 1 — Understand What Needs To Be Quoted

- Read the request carefully.
- Identify only what affects scope, reuse, grouping, or risk.
- Ask only the minimum questions needed.
- Do not ask technical design questions unless they change the structure.
- Do not ask broad discovery questions that do not affect the quote structure.

Move to step 2 when the request is clear enough to decide whether reviewing the existing system would improve the structure.

### Step 2 — Ask Whether To Review The Existing System

- Ask whether the user wants you to review the current codebase or system before structuring the quote.
- If the user says yes, call the `analyst` agent to explore the codebase and identify what already exists, what's reusable, and what would be net new work.
- If the user says no, continue using explicit assumptions.
- Do not inspect the codebase without explicit user approval.
- Do not imply that you already reviewed the code if the user has not approved that step.

Move to step 3 after either:
- the user approved the review and you completed it, or
- the user declined the review and you are proceeding with assumptions.

### Step 3 — Confirm The Base Context If It Changes The Structure

- Detect whether the quote depends on the chosen base, especially `WebLabor Base` vs `WebLabor Teams`.
- If that choice changes how the quote should be grouped, ask before proposing the structure.
- If the project will not use `Teams`, do not classify anything as `Teams`.
- If the project will use `Teams`, classify team-context features accordingly.

Move to step 4 when the base context is clear enough.

### Step 4 — Separate Reuse Vs New Work

Before proposing the structure, identify:
- What already exists
- What looks like an adjustment to existing behavior
- What looks like net new work

If you reviewed the codebase, say this explicitly.
If you did not review the codebase, make it clear that this is an informed inference, not a confirmed technical validation.

Move to step 5 once this distinction is clear enough to structure the quote.

### Step 5 — Detect Which Area Each Block Belongs To

Classify each quoted block under one of these areas:
- `General`
- `App`
- `Teams`
- `Admin`

#### How To Detect The Area

- Use `General` for shared architecture, global decisions, migrations, common components, or cross-area logic.
- Use `App` for personal user-level features outside team context.
- Use `Teams` for features used inside a specific team or company context.
- Use `Admin` for superadministrator features with global visibility or control.

Rules for `Teams` vs `App`:
- If the feature belongs to a specific team, company, workspace, or team route/context, classify it as `Teams`.
- If the same user can belong to multiple teams and the feature changes per team, classify it as `Teams`.
- If the feature is a personal cross-team view for the user, classify it as `App`.
- If the project will not use `WebLabor Teams`, do not use `Teams`; classify those blocks under `App` or `General` as appropriate.
- If you are not sure whether something should be `App` or `Teams`, ask before finalizing the structure.

Example:
- A team wallet balance or team withdrawal flow belongs to `Teams`.
- A personal dashboard that aggregates information across all teams belongs to `App`.

Move to step 6 when each block can be placed in the right area.

### Step 6 — Propose The Quote Structure

Return a short, easy-to-scan proposal with:
- A short summary in 1 to 3 lines
- `Ya existe o parece reutilizable`
- `No existe o entra como trabajo nuevo`
- `Propuesta de modulos o modificaciones`
- `Esto involucra` only when useful

Format the proposed blocks like this:
- Use titles that are easy to understand for the user or client
- Show each block title in bold
- Put the description below the title, not on the same line
- Every block must include a description
- Keep the description very concise
- Use the description to clarify what the block does and what sub-items should not be forgotten, such as settings, permissions, approval rules, related admin changes, secondary configuration, buttons, or affected supporting pieces

Prefer concrete titles such as:
- `**Teams - Monedero por empresa**`
- `**Admin - Modulo de clientes**`
- `**App - Dashboard consolidado**`
- `**General - Nuevo input de CURP**`

Do not write long paragraphs when a short structure is enough.

Move to step 7 immediately after presenting this structure.

### Step 7 — Stop And Ask The User To Validate The Structure

Ask directly what should change.
Examples:
- `¿Como lo ves?`
- `¿Cambiarías, quitarías o agregarías algo?`
- `¿Hay algo que en realidad ya exista y solo sea ajuste?`
- `¿Hay algun bloque mal clasificado entre App, Teams, Admin o General?`

Stop here and wait for the user's reply.

Do not include in this response:
- Commercial recommendations
- Outside-scope sections
- Long assumptions sections
- Final quote summary documents

If the user says the structure should change:
- Ask what should be renamed, regrouped, added, removed, or clarified
- Ask whether that correction should become a persistent rule for the quote command
- If the user agrees, propose the rule clearly

---

## Hard Rules

- Do not inspect the codebase without explicit user approval
- Do not move past the structure stage
- Do not estimate hours, totals, ranges, or pricing
- Do not use a commercial quote format unless the user explicitly asks for it
- Do not write long prose when a short structure is enough
- Reply in Spanish
- Keep the process concise and practical
- Keep the learning loop active when the user corrects the structure

---

## Rules For Organizing The Quote

- Prefer a short list of modules or modifications, not a commercial proposal
- Separate `/app` and `/admin` when they have different fields, scope, behavior, or ownership
- If something already exists and only changes behavior, name it as `Modificacion a ...` instead of a net new module
- Distinguish clearly between reusable work, adjustments, and net new work
- Keep the structure easy to scan and easy to validate quickly
- Use titles that are easy to understand for the user or client
- Show each quoted block as a bold title with the description below it
- The description is mandatory
- Keep the description very concise
- Use the description to mention what the block does and the small sub-things that should not be forgotten inside that block, such as settings, permissions, approval rules, related admin changes, secondary configuration, buttons, or supporting changes
- If the project needs members, permissions, or administration by team, evaluate whether the correct base should be `WebLabor Teams` instead of `WebLabor Base`
- When `WebLabor Base` vs `WebLabor Teams` changes scope, mention it softly as a base decision and identify whether migrating to Teams is required
- Do not call out login, register, settings, members, or admin as quoted scope if they already come from the selected base; mention them only when the request changes them

---

## Learning Loop

- If the user corrects the structure, naming, grouping, area classification, or description style, ask whether that correction should be added to the command
- If the user agrees, restate the rule in your own words and confirm it briefly
- Save accepted learning only in `.opencode/commands/quote.md`, under `Rules For Organizing The Quote`
- After saving it, tell the user that the rule was added so the same mistake does not happen again

---

## Response Template

`Resumen`

`Ya existe o parece reutilizable`

`No existe o entra como trabajo nuevo`

`Propuesta de modulos o modificaciones`

`**Titulo del bloque**`
`Descripcion muy corta debajo que aclare que hace e involucra`

`**Otro bloque**`
`Descripcion muy corta debajo que aclare que hace e involucra`

`Esto involucra` when useful

`¿Como lo ves antes de seguir?`
