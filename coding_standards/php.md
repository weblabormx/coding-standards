# PHP

## Rules

### Language & Text

- All **code must be written in English**
- **Pull Request comments must be written in Spanish**
- Any **user-facing text in Spanish detected in code must be moved to `lang` files** (keys in English)
- No hardcoded user-facing text in Blade or PHP
- No Spanish text directly in Blade or PHP files
- Only fail this rule when the text is clearly user-facing in the running product (notifications, dialogs, labels, buttons, headings, validation messages, emails, Blade output). Do not fail for internal log labels, debugging text, shell snippets, or purely developer-facing comments.

### Code Cleanliness

- No single-use variables (inline them)
- No very small functions called only once that don't improve clarity
- No decorative comments — only comments that add real clarity
- **Section comments are not decorative** — a short inline comment that names or explains what a code block does (e.g. `// Already has a Stripe Price ID — skip`, `// Archive old price only after new one is created`) must be preserved during refactors. They orient the reader through complex methods and must never be removed just because the adjacent code was simplified
- No return type declarations on methods (use PHPDoc if needed)
- Always use `function` for closures — never use arrow functions (`fn`). This applies to all `map`, `filter`, `each`, `mapWithKeys`, and similar calls
- Do not fail just because a callback, closure, process collector, or helper method is used once. Fail only when inlining would clearly improve readability and the extracted piece does not name a meaningful concept.
- Do not fail a short intermediate variable when it carries useful type context, avoids repeating a long chain, or makes a side effect call clearer (for example a documented authenticated user before `notify()`).

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

### Class Declarations (Namespaces Only)

- Always declare classes with `use` statements at the top of the file
- Never use fully qualified class names inline
- Group imports from the same namespace: `use App\Models\{User, Plan};`
- This rule applies to class-like symbols (`new \Foo\Bar`, `\Foo\Bar::class`, `catch (\Throwable $e)`, return/param/property type declarations). It does **not** apply to plain function calls or Laravel/global helpers such as `trim()`, `now()`, `str()`, or `abort()`.
- If the only inline backslashes in the file are function/helper calls such as `\trim()` or `\now()`, this rule passes.

```php
// Correct — helper calls are not class names
$expiresAt = \now()->addMinute();
$value = \trim($process->getOutput());

// Incorrect — inline FQCN
return new \App\Services\Billing\PlanSyncService();
```

### Framework & Helper Preference

- Prefer **Laravel Collections**, Laravel helpers, and existing project helpers when they provide a real readability, consistency, or framework-integration benefit
- If a helper already exists in the project: do not recreate it, do not duplicate its logic inline
- Fail this rule only when there is a clear existing abstraction that is materially better in this context: a Laravel helper/facade already used for that concern, an existing project helper, or a collection pipeline that is clearly more expressive than manual native manipulation.
- Native PHP is allowed when it is the simplest clear option and there is no meaningful Laravel or project-level equivalent to prefer.
- Do not fail a native PHP call just because Laravel has *some* alternative API. Preference here is about better fit, not blanket replacement.
- Do **not** fail this rule for basic scalar or formatting functions such as `trim`, `implode`, `json_encode`, `count`, `is_array`, `explode`, or similar small native helpers used locally.
- Do **not** fail this rule for tiny local array accumulation mechanics such as `$items[] = $value` or `array_push($items, $value)` inside a short callback or collector.
- Do **not** fail simple one-off local file reads or writes with native PHP (`file_get_contents`, `file_put_contents`, `fopen`, etc.) unless the project already standardizes that exact concern behind `File`, `Storage`, or a local helper and using that abstraction would clearly improve consistency or behavior.

```php
// Correct — native PHP is fine when it is simple and there is no meaningful abstraction win
$contents = file_get_contents($path);
$json = json_encode($payload, JSON_PRETTY_PRINT);
$lines = explode("\n", $text);

// Correct — use framework/project abstractions when they are the real domain fit
$diskContents = Storage::disk('s3')->get($path);
$normalized = str($value)->trim()->lower()->squish();
$grouped = collect($rows)->groupBy('type');

// Incorrect — recreates an existing project/helper abstraction inline
$countryCode = strtoupper(trim($request->input('country')));
```

### Use of long-form function syntax

Always use long-form function syntax, never arrow functions.

Fail this rule only when the source code actually contains the `fn (` or `fn(` token for an arrow function. If every closure uses `function (...) { ... }`, this rule passes.

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

Fail this rule only when there is an actual empty line immediately before the `if` statement. Do not infer a failure from spacing elsewhere in the method. Quote the exact offending snippet when failing.

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
