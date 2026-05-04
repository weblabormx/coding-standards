# Livewire

## Rules

Apply these rules only to actual Livewire components, normally classes under `app/Livewire` or classes extending `Livewire\Component` / `LivewireUI\Modal\ModalComponent`. Do not apply them to Blade view components under `app/View/Components`, even if those classes have a `render()` method.

### Mandatory Structure Order

Keep Livewire components in this order:

1. `use` statements / traits
2. Properties
3. `mount()` when present
4. Validation rule methods (`rules()`, `validationAttributes()`, `validationMessages()`)
5. Domain/action/helper methods grouped by concern
6. Main action such as `save()` when present
7. `render()` when present

`mount()` must be the first method after properties only when the file actually declares a `mount()` method. If the component has no `mount()`, validation rule methods may be the first methods after properties. `render()` must be the last method only when it exists. Do not require either method when the component does not need it.

Section comments are optional. When used, they must use the multi-line format:

```php
/*
 * Rules
 */
```

Report this rule only for objective ordering problems, not for missing optional section comments or compact components with few methods.

### Authorization in Livewire Components

Livewire components that read or mutate protected resources must enforce a server-side authorization boundary.

Use one component-level guard in `mount()` for the screen/resource whenever possible. Do not repeat the same authorization in every action when `mount()` already protects the component. Add action-level authorization only when that action touches a different resource or ability.

A hard guard such as `abort_unless(...)` is acceptable when there is no useful policy subject. Public authentication flows and public intake/marketing forms do not require policy authorization unless they access authenticated-only resources.

```php
// Correct
public function mount(BillingPlan $billing_plan)
{
    $this->authorize('view', $billing_plan);
    $this->billingPlan = $billing_plan;
}

// Incorrect — protected component has no server-side guard
public function deletePlan()
{
    $this->billingPlan->delete();
}
```

### `render()` Must Stay Clean

In Livewire components, `render()` must only return the view with optional layout configuration. Build data for the view in `#[Computed]` methods instead of local variables inside `render()`.

Blade view components under `app/View/Components` or classes extending `Illuminate\View\Component` are outside this Livewire rule.

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

// Incorrect
public function render()
{
    $currencyOptions = BillingPlan::currencyOptions();
    return view('livewire.admin.plan-edition', compact('currencyOptions'));
}
```

In Blade, reference computed properties as `$this->propertyName`.

```blade
{{-- Correct --}}
:options="$this->currencyOptions"

{{-- Incorrect --}}
:options="$currencyOptions"
```

When a computed method returns Eloquent models, pass the models to Blade instead of mapping them into plain arrays.

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
- Declare multiple simple untyped properties with the same visibility on one line using comma-separated declarations. Do not split adjacent simple public properties into one declaration per line.
- Keep typed Eloquent model/object properties as their own declarations.
- Never initialize string properties to empty string (`''`)
- A meaningful non-empty default string is allowed when it is intentional UI or workflow state. Do not fail this rule just because a simple property has a non-empty string default.

```php
// Correct
public Plan $object;
public $prices = [], $limits = [], $features = [], $newFeature;
public $afterDeployCommands = 'composer install';

// Incorrect
public $prices = [];
public $limits = [];
public $features = [];
public string $name = '';
public string $description = '';
```

### Direct Model Binding

This rule applies only when a component directly persists an Eloquent model with `save()`, `create()`, `update()`, `fill()`, or an equivalent direct model persistence call.

Report this rule only when all of these are true:

1. The component directly saves a model.
2. Several public properties mirror attributes of that same model.
3. Those properties are manually passed into the model persistence call.
4. The component is not already using a public model property as the main form surface.

If the code is not directly persisting a model, this rule does not apply.

```php
public User $user;

<input type="text" wire:model="user.name">

public function save(): void
{
    $this->user->save();
}
```

### WireUI Feedback

Use WireUI feedback APIs from `WireUiActions` only for messages shown directly to the user. Both `$this->notification()` and `$this->dialog()` / `$this->dialog()->show([...])` are allowed.

This rule applies when the code creates user-facing feedback text or UI state for an alert/message. It does not apply to Livewire events such as `$this->dispatch(...)`, browser events, parent refresh events, modal close events, or other internal communication.

Use notifications for passive feedback. Use dialogs for confirmations, blockers, destructive actions, or messages the user must acknowledge. Do not replace either with custom alert flags, flash messages, or ad-hoc view state when the code is actually showing a user-facing message.

```php
$this->notification()->success(
    title: __('Saved'),
    description: __('The record has been saved successfully.')
);

$this->dialog()->show([
    'icon' => 'warning',
    'title' => __('No items'),
    'description' => __('Add at least one item before continuing.'),
]);
```

### Modals Must Use wire-elements/modal

Use `wire-elements/modal` (`LivewireUI\Modal\ModalComponent`) for modal screens. Do not use WireUI `<x-modal>` markup.

Report this rule in Blade only when `<x-modal>` appears. Report it in PHP only when a component clearly implements a WireUI-style embedded modal instead of using a dedicated `ModalComponent`.

Do not report this rule for normal Livewire form state, `wire:model`, public properties, buttons, `closeModal()`, `save()`, or `confirm()` by themselves.

```php
use LivewireUI\Modal\ModalComponent;

class CreatePost extends ModalComponent
{
    public function save(): void
    {
        $this->validate();
        $this->closeModal();
    }
}
```

### Validation Rules

Keep validation aligned with the persisted contract when the field clearly maps to stored data:

- Non-nullable stored fields need `required`.
- Numeric stored fields need reasonable `min` / `max` bounds.
- Stored strings need length validation.

Do not invent database constraints from a snippet. If the reviewed code does not show that a field is persisted, treat it as component state.

For user-facing validation names, prefer `validationAttributes()` / `attributes()`. Use `messages()` only when the message wording is genuinely custom, not just Laravel's default message with a translated field name.

```php
// Correct
protected function validationAttributes()
{
    return [
        'task.name' => __('name'),
    ];
}

// Incorrect
protected function messages()
{
    return [
        'task.name.required' => __('The name field is required.'),
    ];
}
```

### Custom Rule Classes

Create a dedicated Rule class when custom validation logic is reused across components or forms. Do not duplicate reusable custom validation inline.

This rule does not apply to ordinary `$this->validate([...])`, `rules()`, `validateOnly()`, standard Laravel rule strings, or small conditional validation blocks.

Report this rule when repeated custom validation logic appears inline, such as duplicated closure rules, repeated `Validator::after(...)`, repeated manual `$fail(...)`, or repeated field-level `ValidationException::withMessages(...)` blocks.

```php
// app/Rules/LimitValidator.php
class LimitValidator implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (collect($value)->pluck('limit_key')->duplicates()->isNotEmpty()) {
            $fail(__('Each limit key can only be used once.'));
        }
    }
}

// In rules()
'limits' => ['array', new LimitValidator],
```
