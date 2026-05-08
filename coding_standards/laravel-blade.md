# Blade

## Rules

### General Blade & Frontend rules

- Reuse existing Blade components — do not duplicate markup

### Prefer Project Form Components

Use project form components such as `<x-input>`, `<x-select>`, `<x-textarea>`, `<x-checkbox>`, `<x-radio>`, and other existing internal or WireUI form components instead of raw HTML form controls in application forms.

Avoid raw `<input>`, `<select>`, `<option>`, `<textarea>`, and similar controls when an equivalent project component exists. Project components provide consistent styling, labels, errors, accessibility, Livewire behavior, and validation presentation.

For date fields, use the project `<x-date-input>` component instead of raw HTML date inputs or generic inputs with `type="date"`. The date component handles the project's timezone behavior consistently.

Raw HTML controls are allowed for hidden inputs, vendor-required markup, small browser-native controls with no project component equivalent, or cases where the existing component cannot support the required behavior. When using a raw control, the reason should be clear from nearby context.

```blade
{{-- Wrong --}}
<select wire:model="user.role">
    <option value="admin">{{ __('Admin') }}</option>
</select>

{{-- Correct --}}
<x-select wire:model="user.role" :options="$roleOptions" option-key-value />

{{-- Wrong --}}
<x-input type="date" wire:model="object.starts_at" />

{{-- Correct --}}
<x-date-input wire:model="object.starts_at" />
```

### `x-select` Options Format

For local `x-select` options, use `option-key-value` with `:options` arrays.

For async selects using `async-data` or `:async-data`, `option-label` and `option-value` are allowed because the API response defines the label/value fields.

```blade
{{-- Correct --}}
<x-select wire:model="currency" :options="$currencyOptions" option-key-value />
<x-select :async-data="route('api.products.index')" option-label="name" option-value="id" wire:model.live="product" />
```

### User Feedback And Error States

Interactive Blade and Livewire UI must give understandable feedback when an action cannot complete or input is invalid.

- Forms must render validation errors near the relevant fields using project form components or the project's established error-display pattern.
- Buttons or actions that can fail must surface a clear user-facing message through the existing feedback pattern, such as validation errors, WireUI notifications/dialogs, inline errors, or an existing alert component.
- Elements that visually look like action buttons must perform an action, navigate, open/close UI, submit, dispatch an event, or clearly communicate why they are unavailable. If an element is only informational or decorative, do not style it like an actionable button; use text, badge, label, tooltip, disabled state, or another non-action pattern instead.
- Report a button-like element as a UX error when it has no click/navigation/submission behavior and no clear unavailable/disabled semantics.
- Do not leave a user action with no visible result when the operation is blocked, rejected, invalid, or fails server-side.
- Error text must explain what happened or what the user needs to change. Generic messages such as `Error`, `Invalid`, or `Something went wrong` are not enough when the code knows the specific reason.
- It is acceptable for purely local UI controls such as tabs, dropdown toggles, modal close buttons, filters, and pagination to avoid explicit success/error messages when they are not performing a risky or persistent operation.

### Authorization in Livewire Components

Every Blade view that reads or mutates protected resources must enforce authorization when protected actions or protected data are present.

- For protected mutating action buttons that exist in the view (delete, migrate, edit), prefer `@can` / `@cannot` directives when adding or changing authorization visibility
- Equivalent existing project authorization wrappers are acceptable when they already delegate to policy-backed authorization; do not rewrite them just for style
- Never duplicate policy logic inside the view. If the policy already checks a condition (e.g. `hasSubscribers`), do not re-check it in Blade — trust the policy
- The `@can` wrapper controls visibility only; the Livewire component must still have its authoritative server-side guard at the component level, normally in `mount()` as defined in `coding_standards/livewire.md`
- Do not require `@can` for non-mutating UI controls such as `closeModal`, `cancel`, tab switches, filters, pagination, or other purely local UI state actions.
- Do not require an additional `@can` wrapper inside a dedicated Livewire modal/component view when the component itself authorizes the protected resource at mount/component level. The Blade rule guards visibility in parent/list views; it must not duplicate the component-level authorization rule for every button inside an already-authorized component.

```blade
{{-- Correct — policy handles all conditions internally --}}
@can('delete', $billingPlan)
    <x-button wire:click="deletePlan" ... />
@endcan

{{-- Incorrect — duplicates logic already inside the policy --}}
@can('delete', $billingPlan)
    @if (! $billingPlan->hasSubscribers)
        <x-button wire:click="deletePlan" ... />
    @endif
@endcan
```

### Backend Validation Is Required

Livewire forms must enforce validation on the backend (`rules()`, `$this->validate()`, form objects, or equivalent). HTML validation attributes such as `required`, `min`, `max`, or `pattern` are optional UI hints only and must not be the only validation.

Prefer not to add new HTML validation attributes when backend validation already covers the rule, because they duplicate server-side validation and can be bypassed client-side. However, do not remove existing HTML validation attributes just for cleanup when they are already present and do not break the flow.

```blade
{{-- Correct — backend validation owns the rule --}}
<x-input wire:model="object.name" :label="__('Name')" />

{{-- Also acceptable when backend validation exists and the attribute is only a UI hint --}}
<x-input wire:model="object.name" :label="__('Name')" required />
```

### Modals Must Use wire-elements/modal

Do not use WireUI modal markup in Blade. Report this rule only when the reviewed Blade contains `<x-modal>`.

Use `wire-elements/modal` (`LivewireUI\Modal\ModalComponent`) for modal screens. Ordinary Livewire markup such as `wire:model`, form inputs, buttons, `closeModal`, `save`, or `confirm` is not evidence for this rule.

```blade
{{-- Wrong --}}
<x-modal wire:model="showModal">
    ...
</x-modal>

{{-- Correct --}}
<button wire:click="$dispatch('openModal', { component: 'posts.create-post' })">
    New Post
</button>
```
