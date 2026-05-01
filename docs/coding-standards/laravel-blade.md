# Blade

## Rules

### General Blade & Frontend rules

- Reuse existing Blade components — do not duplicate markup

### `x-select` Options Format

If using x-select input, always use `option-key-value`. Never use `option-label`/`option-value` with manually mapped arrays.

```blade
{{-- Correct --}}
<x-select wire:model="currency" :options="$currencyOptions" option-key-value />
```

### Authorization in Livewire Components

Every blade that reads or mutates protected resources must enforce authorization. 

- Action buttons (delete, migrate, edit) must be wrapped in `@can` / `@cannot` directives
- Never duplicate policy logic inside the view. If the policy already checks a condition (e.g. `hasSubscribers`), do not re-check it in Blade — trust the policy
- The `@can` wrapper controls visibility only; the component action is still the authoritative guard

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

### No HTML Validation Attributes

Never add HTML validation attributes (`required`, `min`, `max`, `pattern`, etc.) to inputs inside Livewire views. All validation belongs in the component's `rules()` method. HTML attributes are bypassable client-side and duplicate logic that Livewire already enforces on the server.

```blade
{{-- Correct --}}
<x-input wire:model="object.name" :label="__('Name')" />

{{-- Incorrect — required is redundant and bypassable --}}
<x-input wire:model="object.name" :label="__('Name')" required />
```

### Modals Must Use wire-elements/modal

All modals must use the `wire-elements/modal` package (`LivewireUI\Modal\ModalComponent`). Never use WireUI's `<x-modal wire:model="...">` embedded inside a parent component.

**Why:** WireUI modals force all modal logic (form fields, validation, save) into the parent component, mixing concerns. Wire Elements modals are fully independent Livewire components.

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

- The parent component must NOT hold properties or methods that belong to a modal
- `<x-modal>` from WireUI is forbidden