# Laravel Observers

## Rules

### General Observers Rules

Preferred event order: `saving` → `creating/updating` → `created/updated`

If logic always runs on model changes, modifies related data, and must remain centralized → it belongs in an **Observer**.

Jobs and side effects that must always run after a model is saved (e.g. syncing with an external service) belong in the observer's `saved` hook, not in the caller. The Livewire component or controller must never dispatch jobs on behalf of a model, and must never call side effects directly on related models. UI actions that remove or change related data must only update the local pending state — the observer handles persistence on save.

```php
// Correct — observer owns the side effect
public function saved(Plan $plan)
{
    SyncWithExternalServiceJob::dispatch($plan)->afterCommit();
}

// Incorrect — caller dispatches the job
public function save()
{
    $this->object->save();
    SyncWithExternalServiceJob::dispatch($this->object)->afterCommit(); // wrong place
}
```

When an observer has more than 4 methods total, organize them with section comments using the same `/* */` style as models: **Live Events** (hooks that fire before the DB write: `saving`, `creating`, `updating`, `deleting`) → **Events** (hooks that fire after: `saved`, `created`, `updated`, `deleted`) → **Methods** (all private helpers). Include only sections that are present — do not add an empty section. Do not add section comments when the observer has 4 or fewer methods.

Observer hook methods (`saving`, `updating`, `saved`, etc.) should delegate to named `private` methods when the logic is **3 or more lines**, or when the same logic is called from **multiple hooks**. Single-line operations must stay inline — extracting them to a private method adds indirection with no benefit.

```php
// Correct — 1 line stays inline
public function creating(BillingPrice $price): void
{
    $price->stripe_price_id = app(StripeSyncService::class)->syncPrice($price);
}

// Correct — 3+ lines get a named private method
public function updating(BillingPrice $price): void
{
    $this->preventAmountModification($price);
}

private function preventAmountModification(BillingPrice $price): void
{
    if ($price->isDirty('amount')) {
        throw ValidationException::withMessages([
            'prices' => __('The price amount cannot be modified once created.'),
        ]);
    }
}

// Incorrect — 1-line logic extracted unnecessarily
public function creating(BillingPrice $price): void
{
    $this->assignStripePriceId($price);
}

private function assignStripePriceId(BillingPrice $price): void
{
    $price->stripe_price_id = app(StripeSyncService::class)->syncPrice($price);
}
```

### Observer Ownership — Each Observer Handles Its Own Model

Each observer is responsible **only** for the behavior of the model it observes. Side effects triggered by a child model's state change belong in the **child model's observer**, not in the parent observer or a Livewire component.

```php
// Correct — ChildObserver reacts to its own state changes
class ChildObserver
{
    public function updating(Child $child)
    {
        // modify child fields before the write
    }

    public function updated(Child $child)
    {
        // trigger side effects after the write (e.g. call a service)
    }
}

// Incorrect — child logic leaking into parent observer or Livewire component
class ParentObserver
{
    protected function syncChildren(Parent $parent)
    {
        // ...
        $child->someChildSideEffect(); // wrong place
    }
}
```

The parent observer only upserts child rows. The child observer reacts to its own model events.

