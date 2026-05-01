# Laravel Traits

## Rules

### Traits & Reuse

- Reusable logic must be placed in **Traits**
- No copy/paste logic, no duplication across components
- Trait location by type:
  - Model traits → `app/Traits/` (`App\Traits`)
  - Livewire traits → `app/Livewire/Traits/` (`App\Livewire\Traits`)
- Traits follow the same internal organization order as models: **Static Functions → Functions → Scopes → Relationships → Attributes** — use section comments only for the sections that are present. **This order is strict** — never add a section out of sequence regardless of what the method does
- **Traits must be self-contained.** When a trait encapsulates a feature, all pieces of that feature must live together in the trait: the property, the relationship, the scopes, and any methods related to that behavior. When extracting or reviewing a trait, always inspect the model's observer too — logic that belongs to the trait may be living there instead. If that is the case, move it to a dedicated observer for the trait, declared inside the trait via `bootTraitName()` so the observer registers automatically when the trait is used. The model-specific observer keeps only behavior unique to that model.

