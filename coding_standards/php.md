# PHP

## Rules

### Language & Text

Code identifiers and comments must be in English.

User-facing non-English copy must live in translation files, not directly in PHP/Blade source. Report this rule only when the text is clearly rendered to the user, such as labels, buttons, headings, notifications, dialogs, validation messages, emails, or Blade output.

Do not use this rule to require translation wrappers for already-English text. Translation helper usage is a separate consistency concern.

When fixing user-facing non-English copy, prefer a literal translation key such as `__('Format saved')`, `__('Edit')`, or `__('Remote')`. Do not invent abstract, numbered, variable-like, or namespaced translation keys such as `__('validator.text1')`, `__('message_1')`, or `__('module.section.label')` unless the project already has that convention or the current change explicitly adds the required translation entries as part of a deliberate i18n change.

When replacing user-facing non-English copy with a translation helper, update the appropriate JSON translation file in the same change unless the key already exists. Preserve the original visible text exactly as the translation value, including accents, punctuation, capitalization, and spacing. Do not leave the source code changed to `__('English key')` without adding or verifying the matching JSON entry.

Do not apply the user-facing copy rule to tests that assert expected rendered text. Test assertions may contain or reference the exact non-English copy they verify because they are not themselves rendered to users.

Do not apply the user-facing copy rule to internal persisted values, enum/database values, array keys, route names, event names, config keys, or comparison tokens that are not directly rendered to users. For example, a status-to-color map keyed by stored Spanish status values is internal logic, not visible copy.

### Code Cleanliness

Keep code direct and readable:

- Inline single-use variables when they do not clarify meaning.
- Inline tiny single-use helper methods when the name does not add a useful concept.
- Keep comments only when they explain non-obvious intent or mark a real section.
- Prefer PHPDoc over method return types, except when a contract/framework override requires the type.
- Use long-form `function` closures; never use arrow functions (`fn`).

Return types are allowed when they are required by a parent class, interface, abstract method, framework contract, or when the project convention clearly uses them for small predicate/calculation helpers.

### Formatter-Owned Style

- Follow the project's configured formatter for purely mechanical whitespace and token style.
- Do not report formatter-owned style as a manual cleanup finding unless it contradicts the formatter output or the formatter is unavailable.
- Do not run Pint, PHP-CS-Fixer, or any formatter command to fix or validate these standards unless the user explicitly asks for formatting. Formatter execution is handled separately by project maintainers.
- For string concatenation, follow the active Pint/PHP-CS-Fixer configuration. In Weblabor projects that use `weblabormx/weblabor-cs`, concatenation uses one space around the `.` operator: `$prefix . '_suffix'`.
- Do not "clean up" concatenation by removing those spaces in projects using the Weblabor formatter config.

```php
// Correct
public static function all()
{
    return Plan::all();
}

// Incorrect
public static function all(): Collection
{
    return Plan::all();
}
```

**Exception:** When a method must keep a return type to satisfy a PHP compatibility contract, you **must** keep the same return type. This includes overriding a parent method, implementing an interface method, fulfilling an abstract method, or preserving a framework/library contract that the class explicitly declares. Removing it causes a fatal error or breaks the declared integration.

Laravel migration methods `up(): void` and `down(): void` are allowed because they follow Laravel's migration stub/contract conventions. Do not fail those return types.

```php
// Correct — parent declares BelongsToMany, override must match
public function roles(): BelongsToMany
{
    return $this->belongsToMany(Role::class, 'role_has_permissions');
}

// Incorrect — omitting the type breaks compatibility with the parent
public function roles()
{
    return $this->belongsToMany(Role::class, 'role_has_permissions');
}

// Correct — interface declares array, implementation must match
public function set($model, string $key, $value, array $attributes): array
{
    return [$key => $value];
}
```

Before removing a return type, check whether the method satisfies any declared parent, interface, abstract, or explicit framework contract. If it does, keep the type.

### Class Declarations (Namespaces Only)

Use imports for real class references. Do not write fully qualified class names inline in executable code, types, catches, or `::class` references.

This rule applies only to actual class references such as `new \App\Services\Billing\PlanSyncService()`, `\Throwable $e`, or `\App\Models\User::class`. It does not apply to quoted strings, route/resource names, config keys, translation keys, helper/function calls, or short class names that resolve in the current namespace.

```php
// Correct
use App\Services\Billing\PlanSyncService;

return new PlanSyncService();
Route::front('Team\\Supplier');

// Incorrect
return new \App\Services\Billing\PlanSyncService();
```

### Framework & Helper Preference

Prefer Laravel Collections, Laravel helpers, facades, and existing project helpers when they are clearly more expressive or more consistent than native PHP for that concern.

Report this rule only when a concrete existing abstraction is a better fit in the reviewed context. Native PHP is fine for simple local operations such as scalar formatting, array mechanics, and one-off file reads/writes unless the project already standardizes that exact concern behind a helper/facade.

### Use of long-form function syntax

Always use long-form function syntax, never arrow functions.

Fail this rule only when the source code actually contains the `fn (` or `fn(` token for an arrow function. If every closure uses `function (...) { ... }`, this rule passes.
If the file contains only `function (...) { ... }` closures, this rule must pass even when the closure is one line long or immediately chained in a collection pipeline.
Do not identify `function ($item) { ... }`, `each(function ($item) { ... })`, `map(function ($item) { ... })`, or any other long-form closure as an arrow function. Those are compliant long-form closures.
Do not fail with contradictory reasoning. The presence or absence of the literal `fn` token is the deciding evidence for this rule.

```php
// Correct
->whereHas('plan', function ($query) {
    return $query->where('slug', 'free');
})

// Incorrect
->whereHas('plan', fn($q) => $q->where('slug', 'free'))
```
