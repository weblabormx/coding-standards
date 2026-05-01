# Feature Analysis

This guide explains what feature analysis documents are for, how they are organized, and what information they should contain.

It is a documentation guide for humans and AI assistants. It should describe the expected document, not the internal workflow of a command or agent.

---

## Purpose

A feature analysis document captures the agreed understanding of a feature or module before planning or implementation.

The goal is to define the minimum indispensable scope needed to solve the real use case, with enough context for a developer, product owner, or future assistant to understand what should be built and what should not be assumed.

Use feature analysis documents to:

- Preserve the business context behind a feature.
- Explain who will use it and how.
- Separate the confirmed first version from adjacent ideas or larger future modules.
- Organize the feature into functional characteristics or tasks.
- Document relevant limitations, validations, risks, and decisions without turning the document into a code plan.

Feature analysis is not a replacement for `/plan`. The analysis explains what the feature needs to achieve; planning later explains how to implement it technically.

---

## Document Location

Store feature analysis documents under the project documentation folder:

```text
docs/{project}/analysis/
```

Use numbered filenames with a three-digit prefix and kebab-case slug:

```text
001-feature-name.md
002-another-feature.md
```

Keep numbering global within the project analysis folder.

Keep an `analysis/README.md` index listing every analysis document. The main project `README.md` should link to the analysis index, not to every individual analysis document.

Index format:

```md
# Analisis de Features

| # | Feature | Estado | Fecha | Documento |
|---|---|---|---|---|
| 001 | Ordenes de compra | Implementado | 2026-04-26 | [001-ordenes-de-compra.md](001-ordenes-de-compra.md) |
```

---

## Main Document Structure

Write feature analysis documents in Spanish.

Use the feature or module name as the main title. Do not add a generic `Documento de Analisis` title.

Base structure:

```md
# [Nombre de la feature o modulo]

*Fecha:* YYYY-MM-DD

*Estado:* Borrador

## Objetivo

[Objetivo claro de la feature]

## Contexto y uso esperado

[Quien lo pidio, quien lo usara, como se usara y que problema resuelve]

## Caso de uso principal

[Flujo principal que debe resolver la primera version]

## Alcance minimo indispensable

[Lo que si entra en esta version]

## Limitantes

[Solo casos relevantes donde la feature no aplica, no funciona bien, o puede confundirse con modulos adyacentes]

## Caracteristicas

## 1. [Caracteristica en orden de creacion]

**Ubicacion:** ...
**Usuarios:** ...

[Descripcion completa y clara de la caracteristica]
```

Omit `Limitantes` only when there are no relevant limitations to document.

---

## Section Definitions

`Objetivo` explains the business or product result expected from the feature.

`Contexto y uso esperado` explains who requested it, who will use it, how it will be used, and what problem it solves.

`Caso de uso principal` describes the primary flow that the first version must solve.

`Alcance minimo indispensable` lists only what must exist for the confirmed use case to work.

`Limitantes` lists only relevant boundaries where the feature does not apply, does not work well, or could be confused with adjacent modules.

`Caracteristicas` contains the functional tasks/features in the order they should be created or understood.

Do not add sections just to fill a template. If a section does not add useful information, keep the document simple.

---

## Feature Organization

Organize work by functional feature, not by code layer.

Correct:

- Captura de datos fiscales del cliente
- Generacion de factura
- Consulta de facturas emitidas

Incorrect:

- Migraciones
- Modelos
- Livewire
- Tests

Each characteristic must be understandable, manual-like, and unambiguous. There is no required subsection template inside each characteristic. Use whatever structure makes the feature clear.

The feature description should include the details needed to avoid ambiguity: menu location, buttons, modals, fields, user decisions, empty states, filters, messages, validations, permissions, states, and what happens after each action.

Do not present a screen, menu, setting, field, button, action, route, permission, feature flag, subscription module, status, report, workflow, data source, provider operation, configuration key, file, model, table, command, or job as already available unless it exists in the repository or documentation. If a referenced item does not exist yet, the document must clearly make it part of a current characteristic, cite the previous analysis document where it is already planned, or label it as a limitation, external requirement, uncertainty, or blocker.

Each characteristic should be clear for three readers: the client or product owner must understand what will be visible and what outcome it enables; the developer must understand the relevant technical context when the implementation is not obvious; and the reviewer must understand the minimum flows and validations to verify.

When technical context is needed to make the analysis actionable, include it in clearly named technical subsections so non-technical readers can skip it. Useful subsection names include `Notas de desarrollo`, `Decision de implementacion`, `Requisitos externos`, `Checks de claridad para desarrollo`, and `Checks de validacion funcional`.

Technical subsections may include table names, columns, JSON paths, commands, endpoints, headers, payload notes, storage decisions, adapters, jobs, locks, transactions, imports, seeders, file paths, or functional validation checks when those details are required to avoid implementation ambiguity. They should support the functional analysis, not replace the user-facing description of the characteristic.

Do not put dense implementation detail in `Objetivo`, `Contexto y uso esperado`, `Caso de uso principal`, `Alcance minimo indispensable`, the opening description of a characteristic, or the first lines of the document. Those areas must remain readable as product analysis for the client or product owner.

Do not repeat data, decisions, behavior, rules, or context unless the repetition adds clarity that was not already present.

Do not add obvious dependency sections. Mention dependencies only when they are not obvious, materially affect scope, or change implementation risk.

Do not over-specify base Weblabor behavior such as standard sidebar visibility, permission hiding, feature flag gating, table patterns, or existing CRUD conventions unless the feature requires behavior different from the base.

Include validations where they affect user input or data correctness. Optional fields may be empty, but when a value is present and format matters, document the expected validation.

If a future idea, optional module, or adjacent feature is not part of the confirmed scope, do not document it as a task. Mention it only when leaving it out creates a relevant limitation, risk, or possible misunderstanding.

---

## Status Values

Use only these status values:

- Borrador
- En analisis
- Listo para implementar
- Implementado
- Pausado
- Descartado

---

## Analyzer Rules

This section is the source used by `php artisan get:analyzers` to import validation rules into the database.

Keep this structure stable:

- `### Document` contains rules evaluated once against the full analysis document.
- `### Characteristics` contains rules evaluated independently against each numbered characteristic under `## Caracteristicas`.
- Each `####` heading is imported as a rule name.
- The content below each `####` heading is imported as the rule instructions.

### Document

#### Document Identity and Metadata

Validate that the full feature analysis document clearly defines the business goal, user context, main use case, minimum scope, relevant limitations, and characteristic list. Technical details are allowed when they are placed in clearly named development or technical subsections and support the functional analysis.

This rule evaluates only the text of the analysis document. Do not fail it for external checks that require reading another file or inspecting the filesystem, such as whether the file is in the right folder, whether the filename is correct, or whether `analysis/README.md` links to it.

**Document identity**

The document must be recognizable as a specific feature analysis. The first heading should be the feature or module name, not a generic title like `Documento de Analisis`, and the content should be written mainly in Spanish.

Evaluate only the document identity requirements for this checklist item: specific first heading and mainly Spanish content. Do not fail this checklist item because the document contains technical details elsewhere; technical placement belongs to the `Analysis instead of implementation plan` checklist item.

Good example:

```md
# Órdenes de compra sin inventario
```

Bad example:

```md
# Documento de Analisis
```

**Required metadata**

The document must include `*Fecha:* YYYY-MM-DD` and `*Estado:*` with one of the allowed status values. The status should communicate the current maturity of the analysis, not the technical implementation state.

Allowed status values:

- Borrador
- En analisis
- Listo para implementar
- Implementado
- Pausado
- Descartado

#### Document Structure and Required Sections

Validate that the full feature analysis document clearly defines the business goal, user context, main use case, minimum scope, relevant limitations, and characteristic list. Technical details are allowed when they are placed in clearly named development or technical subsections and support the functional analysis.

This rule evaluates only the text of the analysis document. Do not fail it for external checks that require reading another file or inspecting the filesystem, such as whether the file is in the right folder, whether the filename is correct, or whether `analysis/README.md` links to it.

**Required sections**

The document must include useful `Objetivo`, `Contexto y uso esperado`, `Caso de uso principal`, `Alcance minimo indispensable`, and `Caracteristicas` sections. `Limitantes` may be omitted only when there are no relevant limitations to document. Technical sections such as `Notas de desarrollo`, `Decision de implementacion`, `Requisitos externos`, `Checks de claridad para desarrollo`, or `Checks de validacion funcional` are optional and may appear inside characteristics when needed. A section exists only if it adds meaningful content; placeholders, empty text, or repeated title text should fail.

#### Business Context and Main Use Case

Validate that the full feature analysis document clearly defines the business goal, user context, main use case, minimum scope, relevant limitations, and characteristic list. Technical details are allowed when they are placed in clearly named development or technical subsections and support the functional analysis.

This rule evaluates only the text of the analysis document. Do not fail it for external checks that require reading another file or inspecting the filesystem, such as whether the file is in the right folder, whether the filename is correct, or whether `analysis/README.md` links to it.

**Business objective**

`Objetivo` must explain the expected business or product result, not the implementation work. It should answer what outcome the feature enables and why that outcome matters.

Good example:

```md
Permitir que SmartTex registre compras a proveedores dentro de Control Total sin activar inventario, manteniendo un flujo operativo separado de ventas.
```

Bad example:

```md
Crear migraciones, modelos y pantallas para compras.
```

**Context and expected use**

`Contexto y uso esperado` must explain who requested or needs the feature, who will use it, how it will be used, and what problem it solves. The reader should understand the operational reason behind the feature without needing a separate conversation.

**Main use case**

`Caso de uso principal` must describe the primary user flow that the first version must solve. It should be written from the user's perspective and should focus on the confirmed scenario, not every possible edge case or future expansion.

#### Scope, Limitations and Exclusions

Validate that the full feature analysis document clearly defines the business goal, user context, main use case, minimum scope, relevant limitations, and characteristic list. Technical details are allowed when they are placed in clearly named development or technical subsections and support the functional analysis.

This rule evaluates only the text of the analysis document. Do not fail it for external checks that require reading another file or inspecting the filesystem, such as whether the file is in the right folder, whether the filename is correct, or whether `analysis/README.md` links to it.

**Minimum indispensable scope**

Evaluate only the content inside the `Alcance minimo indispensable` section for this checklist item. Do not scan the full document, the `Caracteristicas` list, or other sections to decide whether this item passes.

`Alcance minimo indispensable` must exist and list only what is required for the confirmed use case to work. It should exclude nice-to-have features, future modules, broad reporting, advanced filters, or adjacent workflows unless that same section clearly states they are required for the first version.

Do not fail this document-level rule because another section contains a characteristic that may exceed the minimum scope. Extra or oversized characteristics must be evaluated by the per-characteristic `Scope boundaries` rule instead. For this checklist item, fail only when the `Alcance minimo indispensable` section itself is missing, empty, vague, or includes non-indispensable scope as part of the minimum.

**Limitations and exclusions**

`Limitantes`, when present, must document real boundaries where the feature does not apply, does not work well, or could be confused with adjacent modules. Future ideas should appear here only when excluding them prevents misunderstanding.

### Characteristics

#### Functional Characteristic and Client Clarity

Validate that each numbered characteristic is a self-contained user-facing functional capability with enough behavior, data, validation, technical context, and scope detail to avoid implementation ambiguity.

This rule receives one characteristic at a time. Evaluate only that characteristic text. Do not fail it because another characteristic or the full document might contain additional context, unless this characteristic cannot be understood without that missing context.

**Functional title**

The characteristic title must identify a functional capability, not a code layer or generic implementation task. It should be specific enough for a reader to understand the user-facing area being described.

Good examples:

- Catalogo de Proveedores
- Poder capturar datos fiscales del cliente
- Poder visualizar facturas emitidas

Bad examples:

- Migraciones
- Modelo
- Livewire
- Tests
- Crear Servicio de OpenAI

**Client-readable clarity**

The characteristic must be understandable for a non-technical client or product owner. It should explain the user-facing goal, access path, expected result, and scope in plain language before relying on technical notes.

A client should be able to answer: what will be available, who can use it, where it is accessed, what problem it solves, what happens after the main action, and what is intentionally not included. Technical subsections may exist, but they must not be required to understand the functional promise.

Fail this rule when the characteristic is mostly code terms, table names, commands, endpoints, or implementation steps without a clear user-facing explanation.

#### User Flow, Actors and UX Visibility

Validate that each numbered characteristic is a self-contained user-facing functional capability with enough behavior, data, validation, technical context, and scope detail to avoid implementation ambiguity.

This rule receives one characteristic at a time. Evaluate only that characteristic text. Do not fail it because another characteristic or the full document might contain additional context, unless this characteristic cannot be understood without that missing context.

**User action and result**

The characteristic must explain what the user can do and what happens after each relevant action. A reader should be able to describe the action, expected result, and important state changes without guessing.

**Location and actors**

Include menu location, screen, module, or entry point when it affects understanding. Include the users or roles involved when permissions, responsibilities, or workflow ownership matter.

Good example:

```md
**Ubicacion:** `Compras -> Proveedores`.

**Usuarios:** administradores y usuarios que preparan catálogos de compra o registran órdenes.
```

**UX visibility and interaction path**

The characteristic must explain where the user sees or accesses the feature in the interface. It should name the menu, screen, tab, modal, table, card, form, action menu, button, link, or empty state where the behavior appears when that location affects understanding.

If the characteristic adds or changes a button, action, field, filter, badge, status, message, modal, or screen, it must explain where it appears, when it is visible, what the user clicks or opens, and what the user sees next. A reader should be able to follow the interface path without guessing.

The UX description does not need wireframes or final copy, but it must provide a clear proposal for how the behavior is presented. If the characteristic is backend-only or not directly visible to users, it must say so and explain the visible effect, system behavior, or validation message that proves it exists.

When the final format is central to understanding the feature, such as a report, dashboard, table, financial statement, generated document, email, message, export, or complex empty state, the characteristic must include a representative example of the final result. The example can be a Markdown table, text mockup, sample rows, sample totals, or suggested copy with realistic dummy data. It must show labels, hierarchy, totals or states that matter, and the exact neutral/unavailable messages when those messages affect user interpretation. Fail this rule when a developer could implement the correct data but still not know how the final output should look to the user.

#### Data, Validations, Errors and States

Validate that each numbered characteristic is a self-contained user-facing functional capability with enough behavior, data, validation, technical context, and scope detail to avoid implementation ambiguity.

This rule receives one characteristic at a time. Evaluate only that characteristic text. Do not fail it because another characteristic or the full document might contain additional context, unless this characteristic cannot be understood without that missing context.

**Data and fields**

Include the fields, records, or data concepts needed to understand the characteristic. Required fields, optional fields, derived values, historical references, and relationships should be documented when they affect behavior or data correctness.

For every field or data concept that users capture, select, import, or store, state whether it is free text, number, date, boolean, uploaded file, computed value, JSON structure, relationship to an existing record, or selection from a catalog. If the value comes from a catalog, relationship, provider, or official source, the characteristic must say whether that source already exists in the repository, is created by the current characteristic, is planned by another analysis, or is an external dependency. Do not present a catalog-backed value as a free text field; if the catalog does not exist yet, include creating or importing it in the current scope or mark it as a blocker/open decision.

When a characteristic describes a user action, it must explain the UX flow, not only the business rule. Include where the user accesses it, the visible section or button, the modal or form that opens, the fields shown, the validation or message shown on failure, and what changes on screen after confirmation.

Do not describe backend, accounting, or operational concepts with names of existing modules unless that module is explicitly part of the confirmed scope. For example, do not mention cashier shifts, cash register closing, reports, or dashboards when the confirmed feature only needs purchase payments to be separated from sale payments.

Do not repeat data, decisions, behavior, rules, or context unless the repetition adds clarity that was not already present. If fields are described in the UI/form text, do not duplicate the same field list again as `Datos necesarios` unless the second list adds different conceptual information that is truly necessary.

Do not add obvious dependency sections. Mention dependencies only when they are not obvious, materially affect scope, or change implementation risk. Do not over-specify base Weblabor behavior such as standard sidebar visibility, permission hiding, feature flag gating, table patterns, or existing CRUD conventions unless the feature requires behavior different from the base.

Do not force developer notes, data breakdowns, future impact sections, or characteristic-level use-case sections. Add them only when materially useful for correctness, complex flows, implementation handoff, or future growth decisions.

Include validations where they affect user input or data correctness. Optional fields may be empty, but when a value is present and format matters, document the expected validation.

---

## Feature Organization

Organize work by functional feature, not by code layer.

Each characteristic must be a real user-facing capability or a complete functional responsibility that can be understood, built, and tested as its own flow. A characteristic may include several technical steps, validations, UI changes, services, permissions, and output formatting when those pieces exist only to make that one user capability work.

Do not create separate characteristics for technical layers or abstract intermediate work such as a renderer, helper, service, format, template, permission check, shared rule, or reusable backend mechanism unless it produces an independent user-visible capability or materially separate operational responsibility. If a format exists only because the user downloads, sends, prints, imports, exports, or views it, describe the format inside that action's characteristic instead of making “create the format” its own characteristic.

Splitting by action is correct when each action is a different user flow or produces a different result, such as managing suppliers, importing suppliers, sending supplier notifications, downloading a PDF, or emailing a PDF. However, do not split the same button, file, result, data update, or validation into multiple characteristics. Each primary user action must have one owner characteristic; shared behavior belongs as a rule or development note under the owning characteristic.

When two characteristics are similar and the second reuses the first, state the base behavior once and document only the differences, exceptions, and extra rules. Reuse should reduce repeated explanation and usually reduce the estimate unless the second flow has materially different data, UI, validation, permissions, provider behavior, or risk.

Before saving or validating an analysis, run a cross-characteristic responsibility check:

- Each button, menu action, generated file, sent message, imported/exported dataset, or saved data change has exactly one owner characteristic.
- No characteristic exists only because of an internal implementation layer.
- Format, layout, permissions, limits, and shared validation rules are nested under the user action that needs them unless they are independently usable features.
- Similar characteristics name their base reference and only repeat details that differ or could be misunderstood.
- If a characteristic cannot be tested as a user flow or complete functional responsibility, merge it into the characteristic that consumes it.

Order characteristics by real dependency, build, and use sequence. Foundational setup that must exist before the main flow, such as providers, payment methods, catalogs, configuration, or required reference data, should appear before the main operational module. Secondary actions, reports, exports, cleanup flows, and optional shortcuts should appear after the main flow unless they are required foundations.

When an existing feature already behaves almost the same as the requested feature, use it as the base reference instead of documenting the full behavior again. The analysis should state which feature is being reused or cloned conceptually, then focus on the differences, additions, and exceptions.

Example:

```text
Purchase orders use the existing sales order flow as their base reference.

The general behavior for item capture, totals, detail view, listing, and printed ticket is preserved, except for the documented differences: it uses a supplier instead of a customer, records expenses instead of income, and applies purchase-specific rules.
```

Do not ask whether every inherited behavior should also exist when it is clearly part of the referenced base flow. Only document inherited behavior when it changes, becomes a limitation, or could be misunderstood.

Correct:

- Captura de datos fiscales del cliente
- Generacion de factura
- Consulta de facturas emitidas

Incorrect:

- Migraciones
- Modelos
- Livewire
- Tests

Inside each feature, include enough functional and technical context to identify missing pieces such as columns, relationships, screens, validations, permissions, states, buttons, filters, messages, reports, and behavior that must be verified. Do not force test subsections by default.

Avoid tiny summaries such as "crear modulo", "agregar formulario", or "permitir administrar registros" without explaining the actual flow, visible data, allowed actions, restrictions, and resulting behavior.

---

## Status Values

Use only these status values in English documents:

- Draft
- In analysis
- Ready to implement
- Implemented
- Paused
- Rejected

Translate status values to the generated document language when appropriate. For Spanish documents, use: `Borrador`, `En analisis`, `Listo para implementar`, `Implementado`, `Pausado`, `Descartado`.

---

## Analysis Index

The `analysis/README.md` file must act as an index.

The main project `README.md` should link to the analysis index. It does not need to link every individual analysis document.

Use this structure:

```md
# Feature Analysis

## Committed For Implementation

| # | Feature | Estado | Fecha | Documento |
|---|---|---|---|---|
| 001 | Purchase Orders | Implementado | 2026-04-26 | [001-purchase-orders.md](001-purchase-orders.md) |

## Future / Planning

| Feature | Estado | Fecha | Documento |
|---|---|---|---|
| Loyalty Program | Borrador | 2026-04-26 | [future/loyalty-program.md](future/loyalty-program.md) |
```
