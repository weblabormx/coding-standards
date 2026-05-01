---
name: test
description: Use this command when the user wants to analyze, create, complete, review, or validate Laravel Dusk browser tests for an implemented feature or user-facing use case. Supports specific use-case mode and feature-area audit mode. Do NOT write tests before the proposed use cases are approved.
---

# /test — Dusk Use Case Test Coverage & Validation

Your goal is to ensure the relevant Laravel Dusk browser tests exist, are meaningful, and can be validated safely without changing business logic unexpectedly.

---

## Phase 1 — Mode & Scope

Identify which testing mode applies:

1. **Specific use case mode**
   - The user provides a concrete use case or flow.
   - Analyze existing Dusk coverage for that use case.
   - Propose the exact Dusk tests needed to protect it.

2. **Feature audit mode**
   - The user provides a feature area, module, or route group.
   - Audit the existing behavior and Dusk test coverage.
   - Propose the missing browser user-facing use cases that should be covered.

Before proposing tests:

1. Confirm the feature area, use case, or behavior in scope
2. Clarify expected behavior and important flows if needed
3. Read `docs/development-guides/coding-standards/testing.md`
4. Call the `tester` agent to inspect existing coverage and identify gaps
5. Confirm each proposed use case is covered only through Laravel Dusk browser coverage
6. Do not propose PHPUnit unit tests, PHPUnit feature tests, route tests, Livewire component tests, model tests, service tests, trait tests, helper tests, cast tests, or rule tests

---

## Phase 2 — Use Case Proposal

Before writing or changing tests, present the proposed use cases.

For each proposed use case, include:

- User goal
- Important scenario variations or failure paths
- Existing test coverage, if any
- Proposed Dusk browser test file or flow
- Why the behavior must be protected through the browser-visible user flow

Ask for approval before creating or updating tests.

Do not create tests until the user approves the proposed use cases.

---

## Phase 3 — Targeted Validation

Do not run the full test suite by default.

Run only the smallest targeted Dusk command needed to validate the approved scope, such as:

- A specific Dusk test file
- A filtered Dusk test method
- A specific browser flow

If the relevant tests already exist, do not run them immediately.

First ask:
> "Los tests relevantes ya existen. ¿Quieres que validemos solo los tests necesarios para este caso de uso?"

Only proceed after the user confirms.

Validation approval only allows running targeted tests and reporting results. Do not edit tests or product code after a validation failure unless the user explicitly approved fixing failures or the original request already included correction.

When validating existing tests:
- Run only the targeted tests locally
- Report failures with the likely cause and proposed correction
- Fix failures only after explicit approval to correct them, and only when the issue is clearly inside the tests or a small, safe correction
- Respect the existing intended behavior as much as possible

If fixing a failure would require a significant code change or there is uncertainty about the correct behavior:
1. Stop
2. Explain the problem clearly
3. Propose options
4. Ask the user how to proceed

If the user asked to continue in bulk, still stop when one issue is taking too long or becoming unclear.

---

## Phase 4 — Wrap Up

At the end:
1. Summarize what tests were created or updated
2. Summarize what was validated successfully
3. List unresolved failures or questions, if any
4. Confirm whether there is another test batch or flow to review

---

## Rules

- Testing is use-case driven, not checklist driven
- Support two modes: specific use case analysis and feature-area audit
- Always propose use cases before writing or changing tests
- Do not write tests until the user approves the proposed use cases
- First check whether the needed tests already exist
- If tests are missing, ask before creating them
- If tests already exist, ask before running and correcting them
- Validation approval does not imply correction approval
- Use Laravel Dusk for all automated behavior coverage
- Do not propose or create PHPUnit unit, feature, route, Livewire, model, service, trait, helper, cast, or rule tests for project behavior
- Do not include Dusk in normal broad validation runs
- Do not run the full test suite by default
- Run only targeted Dusk checks needed for the approved scope
- Prefer real behavior coverage over shallow assertions
- Do not change business logic substantially without stopping to ask
- If one failure consumes too much time or becomes unclear, stop and check with the user
