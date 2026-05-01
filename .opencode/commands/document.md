---
name: document
description: Use this command when the user wants to create or update project documentation for an implemented feature, architecture decision, configuration change, or developer-facing workflow. Do NOT use it for implementation or test execution.
---

# /document — Documentation

Your goal is to understand what changed, clarify any missing context, propose a documentation plan, and then write clear documentation in the correct project folder.

---

## Phase 1 — Scope & Understanding

1. Confirm what implementation, feature, architecture decision, or workflow should be documented
2. Ask any questions needed to remove ambiguity before writing documentation
3. Ask for product and audience context when it would improve the usefulness of the docs
4. Identify the correct project documentation folder under `docs/{project}`
5. Read the relevant existing documentation in that folder before proposing changes

Ask for clarification whenever needed to understand:
- What the feature or workflow is for
- Who uses it
- What problem it solves
- Whether the target reader is onboarding, product-facing, or developer-facing

---

## Phase 2 — Documentation Plan

Before writing documentation:
1. Propose what files should be updated or created
2. Explain why each file is the right place
3. Ask for approval before writing

Use the existing documentation structure intentionally:
- `Introduction` and `Getting Started` should help a new person understand what the project is and how it is used
- `Features` should explain what the system includes, what each feature does, and how it is used
- `Architecture & Conventions` should help developers understand purpose, responsibilities, and implementation conventions

---

## Phase 3 — Write Documentation

After approval:
1. Update or create the documentation in the correct `docs/{project}` location
2. Link every new `.md` file from `docs/{project}/README.md`
3. Keep the writing practical, direct, and understandable for the intended audience
4. Call the `documenter` agent to write the documentation in the correct location

Documentation should explain:
- What it is
- What it does
- What problem it solves
- Who uses it
- How to use it
- Any constraints or important behavior the team should know

Avoid unnecessary internal details such as:
- Database table breakdowns
- Model method inventories
- Migration explanations
- Function-by-function code summaries that are easier to read directly in code

---

## Phase 4 — Wrap Up

At the end:
1. Summarize which docs were created or updated
2. Confirm that new files were linked from `docs/{project}/README.md`
3. Note any missing information that still requires user clarification

---

## Rules

- Always document in the correct `docs/{project}` folder
- Ask questions first when the feature purpose or audience is unclear
- Always propose the documentation plan before writing
- Prefer explaining purpose, usage, and responsibility over low-level implementation details
- Keep the documentation useful for both onboarding and ongoing development when relevant
