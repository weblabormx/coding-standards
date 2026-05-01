# PHP

## Rules

### Language & Text

- All **code must be written in English**
- **Pull Request comments must be written in Spanish**
- Any **user-facing text in Spanish detected in code must be moved to `lang` files** (keys in English)
- No hardcoded user-facing text in Blade or PHP
- No Spanish text directly in Blade or PHP files

### Code Cleanliness

- No single-use variables (inline them)
- No very small functions called only once that don't improve clarity
- No decorative comments — only comments that add real clarity
- **Section comments are not decorative** — a short inline comment that names or explains what a code block does (e.g. `// Already has a Stripe Price ID — skip`, `// Archive old price only after new one is created`) must be preserved during refactors. They orient the reader through complex methods and must never be removed just because the adjacent code was simplified
- No return type declarations on methods (use PHPDoc if needed)
- Always use `function` for closures — never use arrow functions (`fn`). This applies to all `map`, `filter`, `each`, `mapWithKeys`, and similar calls

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

**Exception:** When overriding a parent method that already declares a return type, you **must** keep the same return type to satisfy PHP's method compatibility contract. Removing it causes a fatal error.

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
```

Before removing a return type, check whether the method overrides a parent — if it does, keep the type.

### Class Declarations (Namespaces)

- Always declare classes with `use` statements at the top of the file
- Never use fully qualified class names inline
- Group imports from the same namespace: `use App\Models\{User, Plan};`

### Framework & Helper Preference

- Always prefer **Laravel Collections** and native Laravel helpers over native PHP functions for array manipulation, data transformation, and complex string handling
- If a helper already exists in the project: do not recreate it, do not duplicate its logic inline

### Use of long-form function syntax

Always use long-form function syntax, never arrow functions.

```php
// Correct
->whereHas('plan', function ($query) {
    return $query->where('slug', 'free');
})

// Incorrect
->whereHas('plan', fn($q) => $q->where('slug', 'free'))
```

### No Spaces Before `if`

Never add a blank line directly before an `if` statement inside a method.

```php
// Correct
$value = $this->getValue();
if (! $value) {
    return;
}

// Incorrect
$value = $this->getValue();

if (! $value) {
    return;
}
```