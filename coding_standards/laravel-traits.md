# Laravel Traits

## Rules

### Traits & Reuse

- Reusable logic must be placed in **Traits**
- No copy/paste logic, no duplication across components
- Trait location by type:
  - Model traits → `app/Traits/` (`App\Traits`)
  - Livewire traits → `app/Livewire/Traits/` (`App\Livewire\Traits`)
- Traits follow the same internal organization order as models: **Static Functions → Functions → Scopes → Relationships → Attributes** — use section comments only for the sections that are present. **This order is strict** — never add a section out of sequence regardless of what the method does
- The order is relative, not mandatory. Do not fail because a trait omits an empty section comment such as `Static Functions`; only fail when methods or sections that actually exist are out of order.
- A `Functions` section may immediately follow static methods even if there is no `Static Functions` comment. That still satisfies the required order because the static methods came first.
- Eloquent accessors and mutators belong in the `Attributes` section, including both modern `Attribute` return methods and legacy `getFooAttribute()` / `setFooAttribute()` methods.
- A section comment applies to all following methods until the next section comment or the end of the trait. Do not require accessors/mutators to be physically inside a comment block; PHP comments are markers, not wrappers.
- If the response determines a section order is allowed, it must pass that point. Do not list allowed ordering observations as failures.
- **Traits must be self-contained.** When a trait encapsulates a feature, all pieces of that feature must live together in the trait: the property, the relationship, the scopes, and any methods related to that behavior. When extracting or reviewing a trait, always inspect the model's observer too — logic that belongs to the trait may be living there instead. If that is the case, move it to a dedicated observer for the trait, declared inside the trait via `bootTraitName()` so the observer registers automatically when the trait is used. The model-specific observer keeps only behavior unique to that model.
