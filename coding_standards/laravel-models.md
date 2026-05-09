# Laravel Models

## Rules

### Models

- Eloquent models use `$guarded`, never `$fillable`.
- Keep model sections in this relative order when those sections exist: **Static Functions → Functions → Scopes → Relationships → Attributes**.
- Accessors and mutators belong in `Attributes`, including legacy `getFooAttribute()` / `setFooAttribute()` methods.
- Relationship names must describe exactly what they return. Add qualifiers only when there are multiple relationships of the same type.
- Static query/finder methods must name the returned subject. Filters may appear after the subject, e.g. `getPricesByInterval`.
- Comments are allowed when they mark real structural groups or explain non-obvious domain logic. Decorative comments are not allowed.

### Eloquent Query Building

Do not use `Model::query()` in ordinary Eloquent chains. Prefer calling scopes and builder methods directly on the model, such as `Project::active()->orderBy('name')->get()`, instead of `Project::query()->active()->orderBy('name')->get()`.

`Model::query()` is allowed only when the code truly needs an explicit `Eloquent\Builder` instance, such as passing a builder to another API, returning a typed builder from a method, or building a query from a dynamic model class like `$modelClass::query()`. Do not add `query()` only to start a normal chain.

```php
// Wrong
return Project::query()
    ->active()
    ->orderBy('name')
    ->get();

// Correct
return Project::active()
    ->orderBy('name')
    ->get();
```

For simple conditional Eloquent filters, keep the query as a fluent chain and use `when()` instead of creating a mutable `$query` variable and applying filters through separated `if` blocks.

Use long-form `function` closures in `when()` callbacks, following the PHP closure rule. Use a separate `$query` variable only when the conditional composition is too complex for a readable `when()` chain, when multiple branches return materially different query shapes, or when an external API requires a builder instance.

```php
// Wrong
$query = Project::active();

if ($search) {
    $query->where('name', 'like', "%{$search}%");
}

if ($planId) {
    $query->where('plan_id', $planId);
}

return $query->orderBy('name')->get();

// Correct
return Project::active()
    ->when($search, function ($query) use ($search) {
        $query->where('name', 'like', "%{$search}%");
    })
    ->when($planId, function ($query) use ($planId) {
        $query->where('plan_id', $planId);
    })
    ->orderBy('name')
    ->get();
```

### Rich Domain Models

When a domain action belongs to a model, expose it through a model method. Livewire components and controllers call the model method, not the service/job directly.

Pattern: `Livewire / Controller → Model Method → Service / Job`

```php
// Correct
$user->toggleAddOn($addOn);

// Incorrect
AddOnService::toggle(auth()->user(), $addOn);
```

Extract a trait when the same model behavior is reused or duplicated across multiple models/files. A single model with two related methods does not require a trait by itself.

### No `ValidationException` in Models

Models must not import, construct, or throw `Illuminate\Validation\ValidationException` for user-correctable form/input errors. Form validation belongs in Livewire components, form requests, action classes, or dedicated validation rules.

Domain-invariant exceptions are allowed when the state is genuinely exceptional, but use a domain-specific exception.

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

- Store dates in UTC.
- Cast model-owned date, boolean, array/JSON, and enum attributes in `$casts`.
- Do not replace casts with accessors or manual transformations.
- Report missing casts only for attributes the reviewed model clearly owns.
- Report manual date handling only when the code parses, formats, or timezone-converts a model-owned date instead of relying on the cast.

```php
// Wrong
'expires_at' => Carbon::parse($value)->format('Y-m-d'),

// Correct
protected $casts = [
    'expires_at' => 'datetime',
];
```

### Enums

Use enums for persisted multi-state attributes.

- Enum class names must not include `Enum`, e.g. `AddonStatus`, not `AddonStatusEnum`.
- Enum case names use PascalCase.
- Enum string values use snake_case.
- Use `$model->status->is('CaseName')` with the PascalCase case name.
- Enum-specific business logic belongs inside the enum.

This rule applies to enum-backed state, not simple booleans, null checks, or presentation-only labels.

```php
// Correct
$subAddon->status->is('Active');

// Incorrect
$subAddon->status === AddOnStatus::Active;
```

### Relationship-Based Model Creation

When creating a related model, use the owning Eloquent relationship.

```php
// Correct
$plan->limits()->create(['limit_key' => 'activities', 'limit_value' => 100]);

// Incorrect
StripeLimit::create(['limitable_type' => Plan::class, 'limitable_id' => $plan->id, ...]);
```

### Pending Collections — Mutator + Observer Pattern

When a form edits a related collection through arrays and that collection must be synchronized on save, use a model mutator plus observer. Do not put the sync loop in Livewire or a controller.

Use this pattern only for write flows that insert, update, or delete related rows from incoming state arrays.

**Model:** declare pending state, capture it with a mutator, and expose form-ready data with an accessor.

```php
public array $pendingItems = [];

public function setItemsDataAttribute(array $items)
{
    $this->pendingItems = $items;
}

public function getItemsDataAttribute()
{
    return $this->items->map(fn ($item) => [
        'id' => $item->id,
        'key' => $item->key,
        'value' => $item->value,
    ])->values()->all();
}
```

**Observer:** in `saved`, read `$pendingItems` and sync deletes, updates, and inserts.

**Caller:** assign the array and call `save()`.

### Domain Logic Reuse (Single Source of Truth)

Each calculation lives in the model that owns the data. Other models and services reuse that method.

```php
// Correct
$total = $project->tasks->sum('cost');

// Incorrect — duplicates the formula
$total = $project->tasks->sum(fn ($task) => $task->hours * $task->rate);
```
