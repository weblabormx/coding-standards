# Laravel Traits

## Rules

### Traits & Reuse

- When logic is reused across classes, place it in a **Trait**
- No copy/paste logic, no duplication across components
- Trait location by type:
  - Model traits → `app/Traits/` (`App\Traits`)
  - Livewire traits → `app/Livewire/Traits/` (`App\Livewire\Traits`)
- When a trait has multiple method groups, follow the same relative order as models: **Static Functions → Functions → Scopes → Relationships → Attributes**. Use section comments only for sections that are present.
- The order is relative, not mandatory. Do not fail because a trait omits an empty section comment such as `Static Functions`; only fail when methods or sections that actually exist are out of order.
- A `Functions` section may immediately follow static methods even if there is no `Static Functions` comment. That still satisfies the required order because the static methods came first.
- Eloquent accessors and mutators belong in the `Attributes` section, including both modern `Attribute` return methods and legacy `getFooAttribute()` / `setFooAttribute()` methods.
- A section comment applies to all following methods until the next section comment or the end of the trait. Do not require accessors/mutators to be physically inside a comment block; PHP comments are markers, not wrappers.
- If the response determines a section order is allowed, it must pass that point. Do not list allowed ordering observations as failures.
- When a trait encapsulates a feature, keep that feature self-contained: properties, relationships, scopes, methods, and any trait-owned observer registration via `bootTraitName()`. Model-specific observers keep only behavior unique to that model.
