# Livewire

## Rules

### Mandatory Structure Order

The file has to respect the next structure order:

1. `use` statements / traits
2. Properties
3. `mount()` **(always first)**
4. Rules section — `rules()`, `validationAttributes()`, `validationMessages()`
5. Domain sections grouped by concern — use as many or as few as the component needs (e.g. Options, Prices, Limits, Features)
6. Validations section — custom validation helpers (`protected` methods that throw `ValidationException`)
7. `save()` / main action (no section comment)
8. `render()` **(always last)**

Section comments must always use the multi-line format:

```php
/*
 * Rules
 */
```

Never use single-line format: `/* Rules */` is incorrect.

> Section comments are required when the component has more than one logical group. `mount`, `save`, and `render` are never wrapped in a section — they are structural anchors.

### Authorization in Livewire Components

Every Livewire component that reads or mutates protected resources must enforce authorization. 

- `mount()` must call `$this->authorize()` for the view intent (`'view'`, `'create'`, `'update'`) before assigning any properties
- Every mutating action method (`delete`, `save`, `confirm*`, etc.) must call `$this->authorize()` with the relevant policy action before doing any work
- Authorization must never be skipped just because the button is hidden in the view — the component is the authoritative guard

```php
// Correct
public function mount(BillingPlan $billing_plan)
{
    $this->authorize('view', $billing_plan);
    $this->billingPlan = $billing_plan;
}

public function deletePlan()
{
    $this->authorize('delete', $this->billingPlan);
    $this->billingPlan->delete();
}

// Incorrect — no auth check, any user that calls the method can delete
public function deletePlan()
{
    $this->billingPlan->delete();
}
```

### `render()` Must Stay Clean

`render()` must only contain the `return view(...)` call with optional layout configuration. Never build or compute variables inside `render()`.

Data that the view needs (options for selects, derived collections, config-based lookups) must be declared as `#[Computed]` methods:

```php
use Livewire\Attributes\Computed;

// Correct
#[Computed]
public function currencyOptions(): array
{
    return BillingPlan::currencyOptions();
}

public function render()
{
    return view('livewire.admin.plan-edition')
        ->layout('layouts.app', ['title' => __('Edit Plan')]);
}

// Incorrect — building variables inside render()
public function render()
{
    $currencyOptions = BillingPlan::currencyOptions();
    return view('livewire.admin.plan-edition', compact('currencyOptions'));
}
```

In Blade templates, always reference computed properties via `$this->propertyName`, **not** `$propertyName`. Using `$propertyName` will fail or silently resolve to a regular variable, which does not exist.

```blade
{{-- Correct --}}
:options="$this->currencyOptions"

{{-- Incorrect — $currencyOptions is not a Livewire property --}}
:options="$currencyOptions"
```

> If a small number of truly dynamic values must be passed explicitly (e.g., a value that changes per loop iteration), use `compact()`. This should be the rare exception, not the default.

**Never flatten model collections into plain arrays**

When a `#[Computed]` method returns a collection of Eloquent models, pass the models directly to Blade and call model methods there. Do not map the collection into plain arrays to pre-extract fields.

```php
// Correct — pass models, call methods in Blade
#[Computed]
public function plans()
{
    return BillingPlan::getPricesByInterval($this->interval, $this->countryCode);
}
```

```blade
{{-- Correct --}}
@foreach ($this->plans as $plan)
    {{ $plan->billingPrice->priceable->name }}
    {{ $plan->isCurrentPlan($currentSubscription) }}
@endforeach
```

```php
// Incorrect — maps models into anonymous arrays, hides domain methods from Blade
#[Computed]
public function plans()
{
    return BillingPlan::getPricesByInterval($this->interval, $this->countryCode)
        ->map(fn ($plan) => [
            'name'       => $plan->billingPrice->priceable->name,
            'is_current' => $plan->isCurrentPlan($subscription),
        ])
        ->all();
}
```

Flattening into arrays breaks model method access, defeats the Rich Domain Models pattern, and forces the computed method to know about state that the model already encapsulates.

### Avoid `#[Computed]` for Single-Use Internal Checks

Do not create a `#[Computed]` method for a derived boolean or value that is only used once and only inside component logic (not in the Blade view). Express it inline instead.

```php
// Correct — inline, used in one place
if ($this->object?->hasSubscribers() ?? false) {

// Incorrect — unnecessary computed property for single internal use
#[Computed]
public function planHasSubscribers(): bool
{
    return $this->object?->hasSubscribers() ?? false;
}

if ($this->planHasSubscribers) {
```

Reserve `#[Computed]` for values consumed in the Blade view or reused across multiple methods.

### Property Declarations

- Do not declare types on simple (non-object) properties
- Typed properties only required for Eloquent model objects
- Declare multiple simple properties on one line
- Never initialize string properties to empty string (`''`)

```php
// Correct
public Plan $object;
public $prices = [], $limits = [], $features = [], $newFeature;

// Incorrect
public string $name = '';
public string $description = '';
```

### Direct Model Binding

- Always bind form fields directly to the model instance using `wire:model`, for example: `wire:model="user.name"`.
- When creating or editing a record, declare a public model property (for example, `public User $user`) and work exclusively with that instance throughout the component.
- Avoid creating separate public properties for each field or manually assembling data arrays before saving.
- Persist changes directly through the model instance with $this->user->save().

```php
public User $user;

public function mount(?User $user = null): void
{
    $this->user = $user ?? new User();
}

<input type="text" wire:model="user.name">

public function save(): void
{
    $this->user->save();
}
```

### WireUI Notifications

Use `$this->notification()` from the `WireUiActions` trait for all user-facing feedback in Livewire components. Never use custom alert divs, flash sessions, or ad-hoc boolean properties to show messages.

```php
use WireUi\Traits\WireUiActions;

class MyComponent extends Component
{
    use WireUiActions;

    public function save()
    {
        // ...
        $this->notification()->success(
            title: __('Saved'),
            description: __('The record has been saved successfully.')
        );
    }
}
```

- Always use named arguments (`title:`, `description:`)
- Both `title` and `description` must be wrapped in `__()`
- Available methods: `->success()`, `->error()`, `->warning()`, `->info()`
- Never add `public $someSuccessMessage` properties to pass messages to the view

### Modals Must Use wire-elements/modal

All modals must use the `wire-elements/modal` package (`LivewireUI\Modal\ModalComponent`). Never use WireUI's `<x-modal wire:model="...">` embedded inside a parent component.

**Why:** WireUI modals force all modal logic (form fields, validation, save) into the parent component, mixing concerns. Wire Elements modals are fully independent Livewire components.

**Modal component — extends `ModalComponent`, owns all its logic:**

```php
use LivewireUI\Modal\ModalComponent;

class CreatePost extends ModalComponent
{
    public $title, $content;

    public function save(): void
    {
        $this->validate();
        Post::create([...]);
        $this->closeModal();
    }

    public function render()
    {
        return view('livewire.posts.create-post');
    }
}
```

**Opening from a parent view — dispatch only, no logic in the parent:**

```blade
<button wire:click="$dispatch('openModal', { component: 'posts.create-post' })">
    New Post
</button>

{{-- With arguments --}}
<button wire:click="$dispatch('openModal', {
    component: 'posts.edit-post',
    arguments: { post: {{ $post->id }} }
})">
    Edit
</button>
```

**Closing from inside the modal:**

```php
$this->closeModal();
$this->closeModalWithEvents([ParentList::class => 'postSaved']); // close + notify parent
```

- The parent component must NOT hold properties or methods that belong to a modal
- `<x-modal>` from WireUI is forbidden

---

### Validation Rules

- Non-nullable DB fields → `required`
- Numeric values → reasonable `max`/`min`
- Strings → length validation
- Validate consistency between database schema and validation rules
- In Laravel or Livewire validation, do not use `messages()` just to restate Laravel's default validation text with a translated field name
- Prefer `validationAttributes()` or `attributes()` to provide the user-facing field label when the default validation message structure is still correct
- Use `messages()` only when the validation copy is genuinely custom and changes the meaning or wording beyond Laravel's standard message

```php
// Correct
protected function validationAttributes()
{
    return [
        'task.name' => __('name'),
        'task.description' => __('description'),
        'task.status' => __('status'),
    ];
}

// Incorrect
protected function messages()
{
    return [
        'task.name.required' => __('The name field is required.'),
        'task.name.string' => __('The name field must be a string.'),
        'task.name.max' => __('The name must not exceed :max characters.'),
    ];
}
```

### Custom Rule Classes

When validation logic applies to more than one component or form, extract it to a dedicated Rule class using `php artisan make:rule RuleName`. Never duplicate the same validation logic inline across multiple components.

**Naming:** name validators after the domain concept they validate, not the specific rule (e.g. `LimitValidator`, `PricingValidator`). This way, when new checks are needed for the same concept, they go in the same file instead of creating a new class per rule.

```php
// app/Rules/LimitValidator.php
class LimitValidator implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        $keys = collect($value)->pluck('limit_key')->whereNotNull();
        if ($keys->count() !== $keys->unique()->count()) {
            $fail(__('Each limit key can only be used once.'));
            return;
        }
        // add more limit checks here as needed
    }
}

// In rules() of any component that needs it
'limits' => ['array', new LimitValidator],
```

- Rule classes live in `app/Rules/`
- Apply the rule in the `rules()` array — never call validation helpers from `save()` for logic that can be expressed as a Rule
- When a rule has multiple checks, call `$fail` and `return` on the first failing check so errors don't stack confusingly
