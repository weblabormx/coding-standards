# Laravel Models

## Rules

### Models

- Always use `$guarded`, never `$fillable`
- Model internal organization order: **Static Functions → Functions → Scopes → Relationships → Attributes**
- Do not mix responsibilities or add decorative comments
- Short section comments that mark real structural groups such as `Static Functions`, `Functions`, `Scopes`, `Relationships`, and `Attributes` are allowed when they help scan a larger model. Do not fail just because these organization comments exist or because one group is split into two nearby blocks while the overall order still stays coherent.
- The organization order is relative, not mandatory. Do not fail because a model omits an empty group such as `Static Functions`; only fail when groups or methods that actually exist are out of order.
- A `Functions` section may be the first section in a model when there are no static methods. This still satisfies the order because there is no `Static Functions` content to place before it.
- Accessors: only for presentation, formatting, and read-only transformations
- Eloquent accessors and mutators belong in the `Attributes` section, including both modern `Attribute` return methods and legacy `getFooAttribute()` / `setFooAttribute()` methods. Do not treat legacy accessors as ordinary Functions for ordering purposes.
- Relationship names must reflect exactly what they return — do not add qualifiers (`Included`, `Active`, `List`) unless multiple relationships of the same type exist on the model (e.g. `addOns` is correct; `addOnsIncluded` is only valid if `addOnsExcluded` also exists)
- Static query/finder methods must name what they **return**. They may also include the relevant filter after the returned noun — e.g. `getPricesByInterval` is valid because it returns prices and filters by interval; `findByInterval` is invalid because it names only the filter and hides what is returned.
- Do not fail a method like `getUsersByRole`, `pricesForCountry`, or `getPricesByInterval` merely because the name includes a filter. Fail only when the returned subject is missing or misleading.
- Static methods do not have to start with `get` or `find` when the noun already states the returned subject clearly. Names such as `billingPriceVariations`, `countryOptions`, `currencyOptions`, and `availableIntervals` are valid return-subject names.

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
It is acceptable for a model method to delegate to a service or job when the model method is still the public domain surface used by callers. Do not fail thin model wrappers just because they forward to a service; fail when callers bypass the model and reach straight into the service for model-owned behavior.
Do not require a trait just because one model has two related helper or domain methods. Apply the trait guidance when the same behavior is being reused or duplicated across multiple models or files.

### No `ValidationException` in Models

Models must not throw or import `Illuminate\Validation\ValidationException`. Form/input validation belongs in Livewire components, form requests, action classes, or dedicated validation rules — not in Eloquent models.

Flag this rule only when a model directly imports, throws, or constructs `ValidationException`, or when it uses validation-style exceptions to report normal user-correctable form errors.

When replacing a `ValidationException` in a model:
- Move field-level validation and user-facing error messages to the Livewire component's `rules()`, validation helpers, or `addError()` flow.
- If the model method represents an expected domain operation that can fail without being exceptional, return an explicit result such as `true`/`false` or another project-approved result object, and let the caller decide how to show the message.
- Do not require every model method to return `bool`. The `true`/`false` guidance applies only to methods that were using `ValidationException` for expected failure control flow.
- Domain-invariant exceptions are allowed when the state is genuinely exceptional, but use a domain-specific exception instead of `ValidationException`.

```php
// Correct — component owns validation and user-facing errors
if (! $this->object->activate()) {
    $this->addError('object', __('This item cannot be activated.'));
    return;
}

// Incorrect — model throws UI/form validation exception
throw ValidationException::withMessages([
    'object' => __('This item cannot be activated.'),
]);
```

### Dates, Timezones, and Casts

- All dates must be stored in **UTC**
- All date fields must define a **cast**
- Do not manually convert dates in Livewire
- Do not format dates manually when a cast applies
- Assigning `now()`, a `Carbon` instance, or another date object/string to an attribute that is already listed in `$casts` as `date`/`datetime` is allowed. That is normal Eloquent cast usage, not manual conversion.
- Fail manual date conversion only when the code parses/formats/timezone-converts the value itself (`Carbon::parse(...)->format(...)`, `date(...)`, `setTimezone(...)`, etc.) or when a local date attribute is used without a required cast.
- Do not fail this rule by inferring framework-managed or inherited date fields that are not declared in the reviewed file. Require concrete evidence from the file itself that it owns a date attribute without the needed cast, or that it manually formats/converts a date where the existing casted value should have been used directly.
- Do not fail when the formatted date belongs to a related or external model and is being rendered into a user-facing message or label. This rule targets the reviewed model's own persisted attributes and redundant local date conversions, not ordinary presentation of already-available related dates.
- Do not fail this rule just because the model uses framework traits such as `SoftDeletes` or inherited timestamps that imply dates like `deleted_at`, `created_at`, or `updated_at`. Those framework-managed dates need explicit casts only when the reviewed file itself overrides or depends on custom local casting behavior.
- `SoftDeletes` alone is never evidence of a missing date cast. Do not infer a `deleted_at` violation from the trait import/use statement; require an explicit local `deleted_at` attribute assignment, manual conversion, or custom date handling in the reviewed file before failing.

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
- Apply this rule only when the reviewed code actually uses an enum-backed attribute or branches directly on enum cases/state objects. Ordinary boolean guards, null checks, subscription status methods, or other non-enum domain conditionals do not fail this rule.
- Do not fail presentation-only accessors that derive display labels or CSS classes from a boolean/null/numeric calculation (for example paid/unpaid based on `paid_at` or `missing_cost`) unless the model owns a persisted multi-state attribute that should be enum-backed. This rule targets state management, not simple display formatting.

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

Apply this rule only when the reviewed code clearly shows that the related collection is edited through incoming form/state arrays and later synchronized back to the database. Do not fail a model merely because it has a `hasMany` relationship or exposes a related collection for read/query purposes.

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
