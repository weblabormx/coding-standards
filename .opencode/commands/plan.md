---
name: plan
description: Use this command whenever the user wants to plan, design, or think through a feature before writing code. Triggers when the user says things like "quiero planear", "ayúdame a planear", "cómo haríamos", "quiero que planeemos", "antes de codificar", "necesito que planees", "¿cómo lo implementarías?", or any request to figure out the technical approach to something. Use this command even if the user doesn't say "plan" explicitly — if they're describing a feature and asking how to do it, this command applies. Do NOT use when the user wants to execute or build immediately.
---

# /plan — Technical Planning

Do NOT write or modify any code during this command.

Your goal is to run the `analyst` agent in exhaustive mode, validate the full technical approach with the user, and produce a complete, self-contained implementation prompt ready to be passed to `/develop`.

---

## Phase 1 — Analyst (exhaustive mode)

Call the `analyst` agent. In this context, analyst must be thorough:
- Explore the codebase deeply before making any proposals
- Ask all clarifying questions needed — edge cases, affected flows, what must NOT change
- Leave nothing ambiguous
- Confirm understanding with the user before moving to Phase 2

---

## Phase 2 — Technical Validation

With the full context from Phase 1, validate the implementation approach piece by piece, confirming each section with the user before moving to the next:

- Be specific with technology choices:
  > "Para el listado usaría Laravel Front, para el form un componente Livewire con los inputs X e Y — ¿cómo lo ves?"
- Cover everything relevant: Livewire components, Laravel Front resources, models, traits, services, inputs, routes
- Call out how each edge case is handled
- Flag hidden steps the user may not have considered (observers that would fire, related models that need updating, etc.)
- Always follow `docs/development-guides/coding-standards` — favor simple and understandable over clever
- If something already exists that covers part of the need, reuse it

When the user corrects a section, adjust and re-confirm only that section — don't re-propose everything.

---

## Phase 3 — Output

Once all sections are approved:

1. Present the complete plan summary
2. Ask: > "¿Está todo completo o hay algo que considerar antes de continuar?"
3. Apply any final adjustments
4. Output the final implementation prompt — self-contained, with:
   - Full implementation flow step by step
   - What must work and what must NOT work
   - Every edge case and how it is handled
   - Hidden steps and side effects
   - Relevant code references when needed
   - Everything a developer needs without asking further questions
5. Ask whether the user also wants derived prompts for `/review`, `/test`, or `/document`

---

## Rules

- Never write or modify code during this command
- Always follow `docs/development-guides/coding-standards` in every proposal
- Favor simple implementations over clever ones
- Reuse what already exists in the codebase
