# Tailwind CSS Standards

## Rules

### Colors

**Use only project primary and secondary color tokens.**

Do not introduce arbitrary Tailwind color classes (`text-red-500`, `bg-blue-300`, `border-yellow-400`, etc.) unless they map directly to a defined project token. If a color has no defined token, flag it and ask before using it.

Classes using project tokens pass with shades, opacity, and state/variant prefixes: `text-primary-600`, `border-secondary-300`, `focus:ring-primary-600`, `hover:bg-secondary-50`, and similar `primary-*` / `secondary-*` utilities are valid. Do not list primary/secondary token classes as arbitrary colors.

Common WireUI/form semantic tokens such as `positive`, `negative`, `warning`, and `info` also pass when used for validation or status states. Still fail raw Tailwind palette colors (`red`, `green`, `blue`, `gray`, `amber`, `rose`, etc.) unless the project explicitly maps them as tokens.

```blade
{{-- Wrong --}}
<button class="bg-blue-600 text-white">Guardar</button>

{{-- Correct --}}
<button class="bg-primary text-white">Guardar</button>
```

### Dark Mode

**Do not use `dark:` variant classes.**

Dark mode is not in use. Remove any `dark:` prefixed classes found in existing code.

```blade
{{-- Wrong --}}
<div class="bg-white dark:bg-gray-900">

{{-- Correct --}}
<div class="bg-white">
```

### Hover States

**All buttons and links must have a `hover:` state.**

This applies to `<button>`, `<a>`, and any element with a Livewire action (`wire:click`) or Alpine action (`@click`) that the user can interact with.

Do not fail design-system Blade components such as `<x-button>`, `<x-link>`, or other interactive `x-*` components solely because the Blade invocation does not include a `hover:` utility. These components own their rendered hover styles internally. Apply this rule to raw HTML elements or custom wrappers where the reviewed class list controls the actual interactive styling.

```blade
{{-- Wrong --}}
<button class="bg-primary text-white px-4 py-2">Guardar</button>

{{-- Correct --}}
<button class="bg-primary hover:bg-primary-dark text-white px-4 py-2">Guardar</button>
```

### Cursor

**Interactive elements must have `cursor-pointer`. Non-interactive elements must not.**

Treat any element with an active `wire:click`, `x-on:click`, or `@click` handler as interactive, including table cells and headers. Do not fail `cursor-pointer` on those elements. Do not fail neutral cursor classes such as `cursor-default` or `cursor-text` on non-interactive elements; only flag misleading interactive cursors like `cursor-pointer` on elements with no interaction.

```blade
{{-- Wrong: button without cursor --}}
<button class="bg-primary text-white">Guardar</button>

{{-- Wrong: div pretending to be interactive --}}
<div class="text-gray-500">Texto informativo</div>

{{-- Correct --}}
<button class="bg-primary text-white cursor-pointer">Guardar</button>
```

### Nesting

**Do not nest divs unnecessarily.**

A `div` with no styling purpose and a single child should be removed. Every wrapper must have a clear layout or spacing reason.

Do not fail wrappers that provide spacing, padding, borders, overflow, positioning, Alpine/Livewire behavior, conditional boundaries, or semantic grouping for multiple children. A wrapper with classes such as `space-*`, `p-*`, `border`, `overflow-*`, `relative`, `absolute`, `flex`, `grid`, `x-show`, `wire:*`, or multiple meaningful children has a layout or behavior purpose.

```blade
{{-- Wrong --}}
<div>
    <div>
        <span>Contenido</span>
    </div>
</div>

{{-- Correct --}}
<span>Contenido</span>
```

**Do not wrap components in a `div` just to apply spacing or layout classes.** Pass those classes directly to the component.

```blade
{{-- Wrong --}}
<div class="mb-10">
    <x-card>...</x-card>
</div>

{{-- Correct --}}
<x-card class="mb-10">...</x-card>
```

### x-dropdown

If using x-dropdown component.

**Use `position` instead of `align`.** The `align` attribute no longer exists. Use:
- `position="bottom"` — opens downward, centered (replaces `align="center"`)
- `position="top"` — opens upward, centered

**Always set `width="xl"` unless there is a specific reason to use a different size.**

```blade
{{-- Wrong --}}
<x-dropdown align="center">

{{-- Correct --}}
<x-dropdown position="bottom" width="xl">
```

### x-modal

If using x-modal component

**Always add `w-full` to the `x-card` inside an `x-modal`.**

WireUI's modal wrapper uses a flex container. Without `w-full`, the card shrinks to its content width instead of filling the modal.

```blade
{{-- Wrong --}}
<x-modal wire:model="myModal">
    <x-card title="Título" class="z-10">

{{-- Correct --}}
<x-modal wire:model="myModal">
    <x-card title="Título" class="z-10 w-full">
```

### Class Repetition

**Do not repeat the same utility class on the same element.**

If the same class appears twice, remove the duplicate. If you see conflicting classes (e.g., `text-sm text-lg`), resolve the conflict — do not leave both.

### Inline Styles

**Prefer Tailwind utilities and project classes over direct inline styles.**

Do not add `style=""` attributes for static visual styling such as spacing, width, height, color, typography, borders, shadows, or layout when an equivalent Tailwind utility, project token, Blade component prop, or CSS class can express the same intent.

Inline styles are allowed when the value is genuinely dynamic at runtime, browser-specific, generated by a third-party integration, or cannot be represented safely with Tailwind classes. Examples include Alpine-bound progress widths, CSS variables populated from runtime data, vendor-required attributes, or chart/library container sizing that cannot be moved to a class.

When an inline style is necessary, keep it as narrow as possible and do not mix unrelated static styling into the same `style` attribute.

### Responsive Design

**All views must work on mobile.** Use responsive prefixes (`sm:`, `md:`, `lg:`) when an element needs different behavior across breakpoints instead of hiding or ignoring mobile layouts.

- Do not use fixed widths for main layout containers, cards, forms, tables, modals, or content columns when the element must adapt to small screens.
- Fixed widths and `min-w-*` utilities are allowed for small bounded UI elements such as icons, avatars, badges, handles, narrow table columns, action columns, dropdown minimums, progress controls, and intentionally constrained controls when they do not cause horizontal overflow or block mobile usability.
- Do not flag arbitrary spacing or sizing utilities solely because they are arbitrary. Utilities like `min-w-[50px]`, `w-[72px]`, or `h-[18px]` are allowed when they size a small bounded UI element, table column, icon area, control, badge, handle, or other intentionally constrained piece of UI and do not break mobile usability.
- Arbitrary fixed widths such as `w-[320px]`, `min-w-[20rem]`, or inline `min-width` must have a clear bounded-component reason. If the width controls page or section layout, prefer responsive combinations such as `w-full`, `max-w-*`, `min-w-0`, `flex-1`, grid columns, or breakpoint-prefixed widths.
- Do not flag `min-w-0`, `min-w-full`, or breakpoint-scoped minimum widths like `sm:min-w-64` solely because they contain `min-w`; evaluate whether they preserve or break responsive behavior.
- Responsive prefixes are required only when the element needs different behavior across breakpoints. Do not require `sm:`, `md:`, or `lg:` on every fixed or arbitrary size.
- Verify that text, buttons, and forms are usable at small screen sizes.
- Prefer `flex-col` on mobile and `flex-row` on larger breakpoints when stacking is needed.
