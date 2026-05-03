# PHP

## Rules

### Language & Text

- All **code must be written in English**
- **Pull Request comments must be written in Spanish**
- Any **user-facing text in Spanish detected in code must be moved to `lang` files** (keys in English)
- No hardcoded user-facing text in Blade or PHP
- No Spanish text directly in Blade or PHP files
- Only fail this rule when the text is clearly user-facing in the running product (notifications, dialogs, labels, buttons, headings, validation messages, emails, Blade output). Do not fail for internal log labels, debugging text, shell snippets, or purely developer-facing comments.
- Do not fail internal guard-clause exception messages, invariant checks, or developer-oriented thrown error text unless the code clearly renders that exact message to end users in the product response or UI.
- Strings already wrapped in translation helpers such as `__()`, `trans()`, or `@lang()` pass this rule. In projects that use Laravel JSON translations, the English string inside `__()` is itself the translation key and must not be treated as hardcoded UI copy.
- Do not fail English user-facing labels under this rule merely because they are hardcoded in PHP. This rule enforces English code and prevents Spanish UI copy from living directly in code; it is not a blanket translation-wrapper rule for every English label unless another rule explicitly says so.
- If a literal user-facing string is already English, this Language & Text rule passes even when the string is not wrapped in `__()`. Prefer translation helpers where the surrounding code uses them, but do not fail English copy under this rule solely for missing translation wrappers.
- Do not treat proper nouns, country names, currency names, currency codes, or locale option labels written in English as Spanish text just because they refer to Spanish-speaking countries or currencies (for example `MX - Mexico`, `AR - Argentina`, `MXN - Mexican Peso`).
- Do not fail currency symbols, currency codes, date/number formatting fragments, or other locale-neutral display formatting as hardcoded language text when they contain no Spanish words.
- Do not apply the “Spanish text in code” failure to translation files under `lang/es`, `lang/*`, or other locale resource files. Spanish copy belongs in Spanish translation files; the rule is to move Spanish UI copy out of PHP/Blade source into those lang files, not to ban Spanish translations.

### Code Cleanliness

- No single-use variables (inline them)
- No very small functions called only once that don't improve clarity
- No decorative comments — only comments that add real clarity
- **Section comments are not decorative** — a short inline comment that names or explains what a code block does (e.g. `// Already has a Stripe Price ID — skip`, `// Archive old price only after new one is created`) must be preserved during refactors. They orient the reader through complex methods and must never be removed just because the adjacent code was simplified
- No return type declarations on methods (use PHPDoc if needed)
- Always use `function` for closures — never use arrow functions (`fn`). This applies to all `map`, `filter`, `each`, `mapWithKeys`, and similar calls
- Do not fail just because a callback, closure, process collector, or helper method is used once. Fail only when inlining would clearly improve readability and the extracted piece does not name a meaningful concept.
- Do not fail a short intermediate variable when it carries useful type context, avoids repeating a long chain, or makes a side effect call clearer (for example a documented authenticated user before `notify()`).
- Do not fail small framework lifecycle, convention, or contract methods whose value is their recognized name and integration point, even if they are short. Examples include `rules()`, `validationAttributes()`, `validationMessages()`, `casts()`, and similar framework hook methods.
- Do not fail explicit scalar or boolean return types on short predicate, capability, query, or calculation helper methods (for example `isActive(): bool`, `canBeDeleted(): bool`, `trackedSecondsFor(): int`) when the type materially clarifies intent and does not conflict with a visible contract or local style in the file.
- If a method name clearly communicates a boolean answer (`can*`, `has*`, `is*`, `should*`) or a numeric calculation (`*Count`, `*Total`, `*Seconds`, `*Amount`), treat a matching scalar return type as allowed unless the surrounding file consistently omits return types for comparable helpers.
- Do not fail enum/helper predicate methods such as `is($name): bool`; the boolean return type is allowed because it documents the predicate contract.

### Formatter-Owned Style

- Follow the project's configured formatter for purely mechanical whitespace and token style.
- Do not report formatter-owned style as a manual cleanup finding unless it contradicts the formatter output or the formatter is unavailable.
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

- Always declare classes with `use` statements at the top of the file
- Never use fully qualified class names inline
- Follow Laravel Pint import formatting. Do not group imports with curly-brace syntax when Pint separates them into individual `use` statements.
- This rule applies to class-like symbols (`new \Foo\Bar`, `\Foo\Bar::class`, `catch (\Throwable $e)`, return/param/property type declarations). It does **not** apply to plain function calls or Laravel/global helpers such as `trim()`, `now()`, `str()`, or `abort()`.
- If the only inline backslashes in the file are function/helper calls such as `\trim()` or `\now()`, this rule passes.
- Do not fail short class names that already resolve through the file's current namespace (for example `BillingPlan::class` inside `namespace App\Models;`). This rule is about inline fully qualified names with backslashes or missing imports for out-of-namespace classes, not normal short references to neighbors in the same namespace.
- Do not infer that a short class name is out-of-namespace solely because there is no `use` statement. If the reference has no namespace separator and the file namespace plausibly resolves it (for example neighboring models inside `App\Models`), it passes.
- Do not fail sibling classes in the same declared namespace, even when they live in the same folder and have no `use` statement. For example, inside `namespace App\Classes\HtmlFormatter;`, `new DesminifyHtml`, `new CommentRemover`, and `new ResolveRelativeUrls` pass because they resolve to that namespace.
- This same-namespace exception applies to static calls and dispatch helpers too. For example, inside `namespace App\Jobs;`, `PloiConfigureDeployAfter::dispatch(...)` passes without a `use` statement because it resolves to `App\Jobs\PloiConfigureDeployAfter`.
- Do not fail Laravel framework configuration arrays that conventionally use inline class references, such as `app/Http/Kernel.php` middleware stacks, route middleware aliases, exception handler maps, service provider lists, or config files. These arrays are declarations/configuration, not executable class construction, and Laravel's default stubs commonly use `\Foo\Bar::class` inline there.

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
If the file contains only `function (...) { ... }` closures, this rule must pass even when the closure is one line long or immediately chained in a collection pipeline.
Do not fail with contradictory reasoning. The presence or absence of the literal `fn` token is the deciding evidence for this rule.

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
Evaluate this literally from the raw source: there must be two consecutive line breaks between the previous non-empty line and the `if` line. A normal newline after a fluent chain or statement is not a blank line.
The line physically above the `if` must itself be blank. If the immediately preceding line contains code, a brace, a closure signature, or the end of a fluent chain, this rule passes.

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
