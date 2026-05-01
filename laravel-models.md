# Laravel Models

## Rules

### Models

- Always use `$guarded`, never `$fillable`
- Model internal organization order: **Static Functions → Functions → Scopes → Relationships → Attributes**
- Do not mix responsibilities or add decorative comments
- Accessors: only for presentation, formatting, and read-only transformations
- Relationship names must reflect exactly what they return — do not add qualifiers (`Included`, `Active`, `List`) unless multiple relationships of the same type exist on the model (e.g. `addOns` is correct; `addOnsIncluded` is only valid if `addOnsExcluded` also exists)
- Static query/finder methods must be named after what they **return**, not how they filter — e.g. `getPricesByInterval`, not `findByInterval`

### Rich Domain Models

Domain actions must be exposed through model methods. Livewire components call model methods, not services directly.

Pattern: `Livewire / Controller → Model Method → Service / Job`

```php
// Correct
$user->toggleAddOn($addOn);

// Incorrect
AddOnService::toggle(auth()->user(), $addOn);
```

When 2 or more methods share the same functionality (e.g. prices, limits, formatting), extract them into a **Trait** immediately — do not wait for 4+.

### Dates, Timezones, and Casts

- All dates must be stored in **UTC**
- All date fields must define a **cast**
- Do not manually convert dates in Livewire
- Do not format dates manually when a cast applies

Casts must be used for: Dates, Booleans, Arrays/JSON, Enums.
Do not replace casts with accessors or manual transformations.

### Enums

- Use Enums for state management. Use the project's `IsEnum` trait.
- Enum class names must **not** include the word `Enum` (e.g., `AddonStatus`, not `AddonStatusEnum`)
- Enum case names: **PascalCase** (e.g., `Active`, `Pending`)
- Enum string values: **snake_case** (e.g., `'active'`, `'pending'`)
- Use `$model->status->is('CaseName')` passing the PascalCase case name
- Enum business logic must live inside the Enum
- Do not branch logic based on enum cases inside Models

```php
// Correct
$subAddon->status->is('Active');

// Incorrect
$subAddon->status === AddOnStatus::Active;
```

### Relationship-Based Model Creation

Always use Eloquent relationships to create related models.

```php
// Correct
$plan->limits()->create(['limit_key' => 'activities', 'limit_value' => 100]);

// Incorrect
StripeLimit::create(['limitable_type' => Plan::class, 'limitable_id' => $plan->id, ...]);
```

### Pending Collections — Mutator + Observer Pattern

When a model owns a collection of related models that must be synchronized on save (insert, update, or delete rows), use a **mutator + observer** pattern. Never implement the sync loop in a Livewire component or controller.

**Model:** declare a public array to hold the pending state, a mutator to capture it, and an accessor to expose the pre-filled form data.

```php
public array $pendingItems = [];

// Mutator: captures the incoming array without touching the DB
public function setItemsDataAttribute(array $items)
{
    $this->pendingItems = $items;
}

// Accessor: returns the collection formatted for form re-population
public function getItemsDataAttribute()
{
    return $this->items->map(fn ($item) => [
        'id'    => $item->id,
        'key'   => $item->key,
        'value' => $item->value,
    ])->values()->all();
}
```

**Observer:** implement `saved` that reads `$pendingItems` and syncs: delete rows not present, update existing rows by ID, insert new rows (no ID).

**Caller (Livewire / controller):** assign the array and call `save()`:

```php
// mount
$this->items = $this->object->items_data;

// save
$this->object->items_data = $this->items;
$this->object->save();
```

### Domain Logic Reuse (Single Source of Truth)

Each calculation lives in the model that owns the data. Other models and services reuse that method.

```php
// Correct
$total = $project->tasks->sum('cost');

// Incorrect — duplicates the formula
$total = $project->tasks->sum(fn ($task) => $task->hours * $task->rate);
```
