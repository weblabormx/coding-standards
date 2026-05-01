---
name: analyze-feature
description: Use this command when the user wants to analyze a feature, module, or client-specific request before planning or implementation. It asks scope questions, reviews code and docs, identifies the minimum indispensable scope, candidate optional scope, limitations, validation rules, and technical risks, then creates or updates a Spanish analysis document under docs/{project}/analysis/. It may save analysis draft files incrementally when the user asks for that workflow.
---

# /analyze-feature - Feature Analysis

Do NOT write implementation code during this command.

Your goal is to create a complete feature analysis document in Spanish, focused on the minimum indispensable scope for the real use case.

Always follow `docs/development-guides/coding-standards/feature-analysis.md`.

---

## Purpose

Use this command when the user wants to analyze:

- A new module sold or proposed to a client
- A client-specific feature request
- A product idea that needs scope definition
- A feature that may depend on existing code, documentation, or previous analyses
- A feature that must be reduced to the minimum useful first version

This command produces an analysis document, not an implementation plan.

Prefer saving analysis work in repository files instead of keeping substantial draft content only in assistant context when the user asks to update or re-run an existing analysis, or when the user explicitly says they prefer changes to be saved as the command progresses. Incremental saves are allowed only for analysis/documentation files, never for implementation code.

Use `/plan` after this command when the user wants a technical implementation plan.

---

## Phase 1 - Understand The Real Use Case

Read the user's request fully.

Before inspecting deeply or drafting the final document, gather only the context needed to understand the real use case and minimum indispensable scope.

Ask questions such as:

- Para que cliente o caso de negocio es esta feature?
- Quien la va a usar?
- Que problema quiere resolver?
- Como se usaria en la operacion real?
- Que se vendio o prometio exactamente?
- Que debe funcionar en la primera version?
- Que sabes que no se necesita todavia?
- El presupuesto/tiempo requiere ir al minimo posible o permite incluir mejoras recomendadas?

Do not ask broad technical questions that can be answered by reading the codebase.

Move forward when the real use case is clear enough to analyze the repository.

---

## Phase 2 - Repository And History Review

Call the `feature-analyst` agent for analysis findings and a draft scope package. The agent must not treat the analysis as final until confirmable decisions, optional recommendations, and open decisions are resolved.

The agent must review:

- Relevant code
- Relevant documentation under `docs/{project}`
- `docs/development-guides/coding-standards/feature-analysis.md`
- Previous analysis documents under `docs/{project}/analysis/` when the folder exists
- Similar historical feature documents under the standard analysis folder

The review must identify:

- What already exists
- What can be reused
- Which referenced screens, settings, fields, buttons, routes, permissions, modules, reports, statuses, workflows, data sources, provider operations, and configuration points already exist, with evidence
- Which referenced items do not exist yet but are explicitly planned in the current analysis or in a previous analysis document
- Which installed libraries, UI components, helpers, traits, services, screens, commands, jobs, or project patterns must be reused instead of inventing a custom approach
- What is missing
- What non-obvious dependencies materially affect scope or risk
- What edge-case decisions must be resolved into rules, validations, limitations, risks, flow text, or open decisions
- What limitations should be explicit
- What future-facing decisions could matter later
- Which recommendations are useful but optional
- Which adjacent or recommended modules need user approval before inclusion

If the `feature-analyst` has technical doubts during this review, it must resolve them through repository evidence, documented assumptions, or user questions. Any assumption or recommended answer that materially affects scope, cost, risk, data ownership, user behavior, permissions, or implementation direction must be returned as a confirmable decision before the document is treated as ready to create or finalize. Do not send the package to other agents as approval gates; final quality approval comes from the external document analyzer validation loop.

---

## Phase 3 - Decision Proposal And Confirmation

After the repository and history review, pause before creating, updating, or finalizing the analysis document unless the user explicitly requested an incremental saved draft for non-material wording cleanup. This confirmation gate still applies when re-running or improving an existing analysis if the change affects scope, cost, risk, data ownership, user behavior, permissions, validation rules, implementation direction, or operational responsibility.

Present a concise decision proposal for user confirmation. The proposal must include every missing specification, material assumption, optional recommendation, adjacent module, report, integration, configuration, operational shortcut, or technical direction that affects current scope, cost, risk, data ownership, user behavior, permissions, validation rules, or implementation direction.

Do not return broad open-ended questions when a reasonable recommendation can be made from the user's context and repository evidence. Instead, show the question or missing specification, one concrete recommended answer, why that answer is recommended, the impact if the user chooses differently, and whether it belongs in the minimum scope, optional scope, deferred scope, limitation, risk, or open decision. Do not leave multiple equivalent implementation paths as the recommendation; choose one recommended path and list alternatives only as rejected, deferred, or optional with rationale.

Ask only for confirmation or corrections to the proposed decisions. If the user changes any decision, update the proposal and ask for confirmation again when the change materially affects the scope package. Do not create, update, or finalize the analysis document until the material decisions are confirmed, except for explicitly requested incremental drafts that remain clearly marked as draft and unresolved. If a validation run or analyzer feedback reveals a new material decision after drafting starts, stop, present the recommended correction, and wait for user confirmation before saving that decision into the document.

Use this pattern:

```text
Antes de generar/finalizar el analisis, estas son las decisiones que faltaban y mi recomendacion:

1. [pregunta o especificacion faltante]
   Recomendacion: [respuesta recomendada]
   Motivo: [evidencia de negocio/repositorio]
   Si se decide distinto: [impacto]
   Clasificacion: [alcance minimo | opcional | diferido | limitante | riesgo | decision abierta]

Alcance minimo propuesto:
- ...

Opcionales recomendados:
- [incluir ahora o dejar fuera, con recomendacion]

Plan del documento:
- [documento a crear/actualizar]
- [secciones/caracteristicas principales]
- [validaciones o riesgos clave]

Confirmas que estas decisiones estan bien, o que cambiarias?
```

If the user confirms minimum scope, omit non-selected recommendations from the final document unless excluding them creates a concrete limitation that users or developers must know.

---

## Phase 4 - Working Draft Save

If the user has requested incremental saving, or if the command is re-running/improving an existing analysis document, maintain a working draft in the repository while the analysis evolves only after the material decisions for that draft iteration are confirmed. Existing-analysis reruns do not waive the confirmation gate for new characteristics, changed ownership, background automation versus manual UI, provider/source choices, data model direction, permissions, or operational workflow changes.

Rules for working drafts:

- Only create or update files under the analysis documentation path, normally `docs/{project}/analysis/` and related analysis use-case files.
- Do not modify implementation code.
- Do not treat the draft as final until confirmable decisions, optional recommendations, and open decisions are resolved enough for the current scope, and the external document analyzer validation loop passes.
- Keep optional recommendations clearly marked as optional, deferred, out of scope, or pending decision; do not silently include them in the required scope.
- If a material decision is unresolved, write it as an open decision, limitation, or risk only when the user explicitly wants a saved unresolved draft; otherwise pause and ask for confirmation before writing.
- Tell the user which files were saved and what remains unresolved.
- Validate the saved draft against the checklist before reporting it as improved; do not rely only on the agent/context summary.

When the user did not request incremental saving and the command is creating a brand-new analysis, continue to use the confirmation summary before writing files. When the command is updating an existing analysis, use the same confirmation summary before saving any material scope or implementation-direction change.

---

## Phase 5 - Draft Analysis Summary

Present a concise summary before finalizing files, or before writing files when incremental saving is not active. This summary is separate from the Phase 3 decision proposal and can only run after material decisions have been confirmed:

- Proposed document title
- Proposed filename under `docs/{project}/analysis/`
- Every file that will be created or modified
- Proposed status
- Confirmed minimum scope
- Optional recommendations that were accepted into scope
- Key limitations
- Any remaining open decisions that do not block the current draft

Ask for explicit confirmation before creating or updating files when incremental saving is not active. If the user has already confirmed the Phase 3 decision proposal and asked to continue, create or update the analysis document as a draft and present the saved proposal for feedback. If incremental saving is active, ask for confirmation before marking the analysis as final-ready or changing status/classification, but keep saving draft improvements as needed.

Example:

```text
Documento propuesto:
docs/control-total/analysis/004-facturacion-mexico.md

Archivos que se crearan o actualizaran:
- docs/control-total/analysis/004-facturacion-mexico.md
- docs/control-total/analysis/README.md
- docs/control-total/README.md si todavia no enlaza el indice de analisis

Estado: Borrador

Alcance minimo confirmado:
- ...

Limitantes:
- ...

Confirmas que genere/finalice el documento de analisis y actualice el indice?
```

---

## Phase 6 - Create Or Update Analysis Documents

When incremental saving is active, create or update analysis documents as working drafts during the command. Also create or update the draft when the user has confirmed the Phase 3 decision proposal and explicitly asked to continue with the analysis. Otherwise, only create or update files after explicit confirmation.

1. Call `feature-analyst` again with the confirmed decision proposal, resolved optional recommendations, confirmed scope, limitations, and open decisions.
2. The agent must return the complete final analysis document content.
3. Create `docs/{project}/analysis/` if it does not exist.
4. Create or update `docs/{project}/analysis/README.md` as the analysis index.
5. Create the numbered analysis document using the next available three-digit number.
6. Link the new document from the analysis index.
7. If the project README does not link the analysis index, add that link.

The analysis index should use this structure:

```md
# Analisis de Features

| # | Feature | Estado | Fecha | Documento |
|---|---|---|---|---|
| 001 | Nombre de la feature | Borrador | 2026-04-26 | [001-nombre-de-la-feature.md](001-nombre-de-la-feature.md) |
```

Do not modify implementation code.

Do not modify unrelated feature documentation unless the user explicitly asks.

---

## Phase 7 - External Document Analyzer Validation

Before running external Document Analysis, perform an explicit existence and planned-dependency audit on the saved analysis document.

For every concrete product or technical reference in the document, verify that it fits exactly one of these categories:

- Existing in the repository, documentation, or database/schema history, with a concrete file, route, component, migration, config, command, policy, or document reference.
- Created or changed by a characteristic in the current analysis document.
- Already planned by a previous analysis document under `docs/{project}/analysis/`, with the exact document reference.
- External dependency or provider behavior that is clearly labeled as an external requirement, uncertainty, or blocker.

Concrete references include screens, menus, settings, fields, buttons, actions, routes, permissions, feature flags, subscription modules, teams, branches, countries/regions, statuses, reports, imports/exports, jobs, commands, models, tables, provider endpoints, configuration keys, files, and operational workflows.

If a referenced item does not exist and is not planned by the current or previous analysis, do not leave it as an assumed dependency. Either:

- add or update a characteristic so the current analysis explicitly creates or changes that item;
- rewrite the document so the item is not presented as existing;
- move it to a limitation, external requirement, or open decision when it cannot be verified yet; or
- ask the user to confirm a scope expansion when creating the missing item materially changes scope, cost, UX, data model, permissions, or risk.

Do not mark the analysis as final-ready and do not run the external analyzer until this audit has no invalid references. The audit result does not need to be added as a new section in the generated document unless it changes the analysis content; keep process-only evidence in the assistant response.

After the `feature-analyst` creates or updates the analysis document, check whether the current project's parent directory contains a sibling repository named `ia-analyzer` (`../ia-analyzer`). Do not hardcode a machine-specific absolute analyzer path.

If `../ia-analyzer` exists, external Document Analysis is mandatory and becomes the approval gate for this command. Run this command from `../ia-analyzer`:

```bash
php artisan validate:now "Document Analysis" "{absolute_analysis_document_path}"
```

The second argument must be the exact absolute path of the primary analysis document that was created or updated, for example:

```bash
php artisan validate:now "Document Analysis" "/absolute/path/to/project/docs/project/analysis/001-example.md"
```

Validation rules:

- Show the user the document path or clickable document reference before or during validation.
- Show each validation iteration as `Document analyzer iteration N started`.
- Show the exact command being run, including the resolved absolute document path.
- If the analyzer returns a negative, failed, or non-passing result, treat that result as authoritative feedback.
- Return the analyzer's requested fixes to `feature-analyst`, update the saved analysis document with the corrected content, then run the same analyzer command again.
- Keep the document in the queue until the analyzer fully passes. There is no default iteration limit and no timeout-based stopping point.
- Do not mark the analysis as final-ready, approved, or `Listo para implementar` until the analyzer passes completely.
- Stop the external analyzer loop only when the analyzer command is unavailable, the analyzer cannot read the document, the user sets an explicit iteration limit, or a missing external answer blocks correctness. In that case, show the exact blocker and leave the document as `Borrador` or `En analisis`.

If `../ia-analyzer` does not exist, use the previous internal fallback review flow instead of blocking on the missing analyzer. The fallback must run the document/feature checklist and the available internal review gates for this repository, such as `feature-analysis-reviewer`, `feature-estimator`, and `tech-lead` when they exist; when those agents are not present, use the local checklist plus the pre-existing command review path. Do not mark the document final-ready until the fallback review passes.

Use concise progress blocks in the user's language. Prefer this shape:

```text
Document analyzer iteration 1 started
→ Document: /absolute/path/to/analysis.md
→ Command: php artisan validate:now "Document Analysis" "/absolute/path/to/analysis.md"
→ Result: failed
→ Findings:
  ✗ [exact analyzer finding]
→ Returning findings to feature-analyst and updating analysis document

Document analyzer iteration 2 started
→ Document: /absolute/path/to/analysis.md
→ Command: php artisan validate:now "Document Analysis" "/absolute/path/to/analysis.md"
→ Result: passed
```

Do not expose private chain-of-thought. The visible trace must show analyzer results, fixes applied, commands/tools used, paths, and final result — not hidden reasoning.

---

## Phase 8 - Learning Loop

Keep the learning loop active during corrections.

When the user corrects format, structure, naming, level of detail, analysis behavior, optional recommendation behavior, or scope classification:

1. Decide whether the correction should become a reusable rule.
2. Show the exact rule that would be added or changed.
3. State the exact file that would be modified:
   - Document format or content style: `docs/development-guides/coding-standards/feature-analysis.md`
   - Command flow or confirmation behavior: `.opencode/commands/analyze-feature.md`
   - Analysis decision behavior: `.opencode/agents/feature-analyst.md`
4. Ask for explicit confirmation unless the user has already clearly asked to update the command/standard behavior in this conversation.
5. Update the standard after confirmation, or immediately when the user's correction is an explicit instruction to change the command/standard behavior.

Never save learning into any file without showing or summarizing the exact change, unless the user has explicitly asked to apply that behavior change now.

When changing standards, commands, agents, or workflow documentation, fix the root rule instead of adding a narrow symptom-specific ban. Before saving the change, call `workflow-reviewer` to review the proposed change. The review must cover at least documentation clarity and execution/testability, and technical/workflow consistency when relevant. The change should explain the general behavior expected next time, where it applies, and what it should prevent.

---

## Output Document Rules

- The final document must follow `docs/development-guides/coding-standards/feature-analysis.md`.
- Do not add sections that are not in the standard by default.
- Keep each characteristic proportional to the work. A small UI/data change should not have a long architectural essay.
- One characteristic must describe one cohesive implementation responsibility. It can include several small steps when they affect the same component/screen/data concept and are reviewed together.
- Split characteristics when they cross different components, files, screens, feature toggles, permissions, jobs, services, migrations, or user actions that can be implemented or reviewed independently.
- Each characteristic must include concise developer notes when reuse matters. Explicitly name existing libraries, components, traits, services, files, or patterns to reuse.
- Generated document labels should be localized to the document language while preserving the standard meaning. Do not add internal review metadata, confidence judgments, or process notes as document fields unless the standard explicitly defines them.
- Optional or future-facing ideas should appear in the final document only when the user accepted them or when excluding them creates a concrete limitation in the confirmed scope.
- Technical risks, validations, dependencies, and edge-case decisions should be written naturally inside the relevant section or characteristic instead of forcing extra subsections.
- Keep the final analysis simple, clear, and useful as a document, not as a command log.

---

## Hard Rules

- Do not write implementation code.
- Do not create or update implementation files during this command.
- Do not keep substantial analysis drafts only in assistant context when the user requested incremental saving or is asking to re-run/update an existing analysis.
- Do not skip repository and documentation review.
- Do not skip the external document analyzer validation loop before treating the final analysis document as final-ready.
- Do not inflate the scope beyond the real use case.
- Do not combine unrelated work into one characteristic just because both belong to the same module.
- Do not split cohesive work into artificial micro-tasks when the same developer would implement and review it as one change.
- Do not write long analysis text for trivial changes; keep detail proportional and move broad architecture notes to the affected larger characteristic.
- Do not miss existing installed packages or project patterns that should be reused.
- Do not hide optional recommendations inside required scope.
- Do not include optional or recommended modules without asking first.
- Do not leave material edge-case decisions undocumented.
- Do not mark an analysis as ready when material decisions remain open or when provider/API uncertainty is too vague to plan.
- Do not use “must be confirmed later” as a substitute for defining the current scope, source of truth, state flow, validations, and fallback behavior.
- Do not produce a `/plan` implementation prompt as the main output.
- Reply in Spanish during this command.
