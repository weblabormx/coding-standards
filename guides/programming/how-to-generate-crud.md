# How to Generate a CRUD with Laravel Front

This guide explains how to create a CRUD in Weblabor projects using Laravel Front, policies, observers, and optional Livewire overrides.

The goal is to give developers and AI assistants a practical, repeatable workflow. A CRUD must not start with code generation. It must start with analysis: confirm the requested screen is a CRUD, choose the correct architecture, define the data contract, and then implement the files following the project coding standards.

---

## Source of Truth

Before implementing, review the documents in `coding_standards/`.

If this guide conflicts with a specific coding standard, follow the coding standard.

---

## 1. Confirm the Request Is a CRUD

A CRUD manages records for a model or entity. It usually includes some or all of these actions:

- List records.
- Create a record.
- View a record.
- Edit a record.
- Delete a record.

A CRUD does not need to expose every action. It can still use Laravel Front if the requirement is only an index, a read-only admin list, or a limited management screen. Laravel Front is useful when the screen is record-centered and should follow the standard admin UI.

### Valid CRUD Requests

Use this workflow for requests like:

- "Create an admin for blog posts."
- "Manage categories."
- "Create a supplier catalog."
- "Show a list of contact submissions."
- "Create a quick index for event types."

### Not CRUD Requests

Do not use Laravel Front as the main solution for:

- Dashboards.
- Analytics reports.
- Chart-heavy screens.
- Checkout flows.
- Multi-step wizards.
- Configuration builders.
- Screens centered on actions instead of records.

Those screens usually need a dedicated Livewire component or another architecture.

---

## 2. Analyze Before Implementing

Answer these questions before running commands:

1. **Entity:** What model is being managed?
2. **Area:** Does it belong in `admin`, `app`, or another route area?
3. **Actions:** Does it need index, create, edit, detail, delete, or only some of them?
4. **Fields:** What columns are required?
5. **Relationships:** Does it reference other models?
6. **Inline children:** Does the form create, edit, or delete related rows inline?
7. **States:** Does it have persisted states that should use an enum?
8. **Validation:** What are the create and update rules?
9. **Authorization:** What policy rules are required?
10. **Lifecycle behavior:** Does saving the model trigger derived values, syncs, or side effects?
11. **Architecture:** Is it Laravel Front only, Laravel Front with Livewire overrides, or not a CRUD?

If any required answer is missing, ask before creating files.

---

## 3. Choose the Architecture

Use three possible paths:

- **Laravel Front only** for simple CRUDs.
- **Laravel Front + Livewire** when create/edit need advanced UI.
- **Dedicated Livewire** when the screen is not a CRUD.

### Laravel Front Only

Use Laravel Front only when:

- Fields are simple.
- Validation is direct.
- Relationships are simple selects or relation inputs.
- The form does not manage related rows inline.
- There are no dynamic add/remove rows.
- The UI does not need complex reactive behavior.
- The default admin CRUD experience is enough.

Examples:

- Categories.
- Event types.
- Simple announcements.
- Read-only logs.
- Basic catalogs.

### Laravel Front + Livewire

Use a hybrid when Laravel Front should own the CRUD shell, but the create/edit form needs a custom experience.

Use this when:

- The form manages multiple related models inline.
- The form has dynamic add/remove rows.
- Fields depend on other fields in real time.
- The UI has complex conditional sections.
- The form validates nested arrays.
- The create/edit experience is too advanced for Laravel Front fields.

In this architecture:

- Laravel Front provides index, detail, delete, actions, route structure, and admin consistency.
- Livewire replaces create and/or edit.

### Dedicated Livewire

Use a dedicated Livewire screen when the request is not record management.

Examples:

- Sales dashboard.
- Finance report.
- Onboarding flow.
- Usage analytics.
- Custom operational panel.

---

## 4. Example Used in This Guide

This guide uses a `BlogPost` CRUD.

Planned structure:

- Model: `BlogPost`
- Table: `blog_posts`
- Admin URL: `/admin/blog-posts`
- Front resource: `App\Front\Resources\BlogPost`
- Policy: `App\Policies\BlogPostPolicy`
- Observer: `App\Observers\BlogPostObserver`
- Enum: `App\Enums\BlogPostStatus`

Fields:

| Field | Type | Notes |
|---|---|---|
| `user_id` | foreign id | Author |
| `title` | string | Required |
| `slug` | string | Required and unique |
| `excerpt` | text nullable | Short summary |
| `content` | long text | Required |
| `status` | string | `draft` or `published` |
| `published_at` | timestamp nullable | Set automatically when published |

Behavior:

- A post can be draft or published.
- When a post becomes published, `published_at` is set if it is empty.
- When a post returns to draft, `published_at` is cleared.

This example avoids delete business rules so the policy example stays focused on permissions and the observer example stays focused on lifecycle data updates.

---

## 5. Generate the Scaffold

From the Laravel project root, run:

```bash
php artisan front:resource BlogPost -a
```

The `-a` option generates the resource, model, policy, and migration.

The scaffold is only a starting point. Always review and edit the generated files to match the coding standards.

Useful variants:

```bash
php artisan front:resource BlogPost --all
php artisan front:resource BlogPost --model
php artisan front:resource BlogPost --policy
```

Rules:

- A CRUD must have a policy.
- A CRUD usually needs a model, migration, Front resource, policy, and route.
- If there are persisted states, use an enum.
- If saving the model has lifecycle behavior, use an observer.
- If create/edit is advanced, add Livewire route overrides.

---

## 6. Migration

Example migration:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('blog_posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained();
            $table->string('title');
            $table->string('slug')->unique();
            $table->text('excerpt')->nullable();
            $table->longText('content');
            $table->string('status')->default('draft');
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down()
    {
        Schema::dropIfExists('blog_posts');
    }
};
```

Rules:

- Do not use `cascadeOnDelete()`.
- Do not use `nullOnDelete()`.
- Use `constrained()` when appropriate.
- Add `softDeletes()` only when the resource should keep deleted records.
- Store dates in UTC.
- Do not add speculative fields.

### Altering Tables

When removing columns in later migrations, use `dropColumnWithIndexes()`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::table('blog_posts', function (Blueprint $table) {
            $table->boolean('is_featured')->default(false)->after('status');
        });
    }

    public function down()
    {
        Schema::table('blog_posts', function (Blueprint $table) {
            $table->dropColumnWithIndexes('is_featured');
        });
    }
};
```

---

## 7. Enum for Persisted States

Use an enum when a persisted attribute has multiple states.

Example:

```php
<?php

namespace App\Enums;

enum BlogPostStatus: string
{
    use IsEnum;

    case Draft = 'draft';
    case Published = 'published';
}
```

Rules:

- Do not include `Enum` in the class name.
- Case names use PascalCase.
- String values use snake_case.
- Use the project enum helper trait when available.
- Enum-specific behavior belongs inside the enum.

Example usage:

```php
$blogPost->status->is('Published');
```

---

## 8. Model

Example:

```php
<?php

namespace App\Models;

use App\Enums\BlogPostStatus;
use App\Observers\BlogPostObserver;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use WeblaborMx\TallUtils\Models\{HasSlug, Searchable, WithActivityLog};

#[ObservedBy([BlogPostObserver::class])]
class BlogPost extends Model
{
    use HasSlug, Searchable, SoftDeletes, WithActivityLog;

    protected $guarded = [];
    protected $searchable = ['title', 'excerpt'];
    protected $casts = [
        'published_at' => 'datetime',
        'status'       => BlogPostStatus::class,
    ];

    /*
     * Functions
     */

    public function getRouteKeyName()
    {
        return 'slug';
    }

    /*
     * Scopes
     */

    public function scopePublished($query)
    {
        return $query->where('status', BlogPostStatus::Published);
    }

    /*
     * Relationships
     */

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
```

Rules:

- Use `$guarded`, not `$fillable`.
- Add casts for dates, booleans, arrays, JSON, and enums.
- Do not use `Model::query()` for ordinary chains.
- Relationship names must describe exactly what they return.
- Model domain behavior belongs in the model only when it is reusable domain behavior, not UI validation.
- Models must not throw or construct `ValidationException` for user-correctable form errors.
- Keep model sections in the standard order.

---

## 9. Policy

Every CRUD must have a policy.

For a standard CRUD backed by Laravel Front, the policy extends `BasePolicy`:

```php
<?php

namespace App\Policies;

class BlogPostPolicy extends BasePolicy
{
    protected string $name = 'blog_post';
}
```

Rules:

- Policies live in `app/Policies`.
- CRUD policies extend `BasePolicy`.
- Define `protected string $name` with the permission name.
- Do not manually register policies in `AppServiceProvider`.
- Put authorization rules in the policy.
- Do not duplicate policy logic in Blade or Livewire.

### Policy with Business Authorization

If a protected action has business authorization, keep the authorization in the policy.

Example:

```php
<?php

namespace App\Policies;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;

class BlogPostPolicy extends BasePolicy
{
    protected string $name = 'blog_post';

    public function delete(User $user, Model $instance)
    {
        return parent::delete($user, $instance) && $instance->status->is('Draft');
    }
}
```

This keeps the user-facing authorization decision in the policy. If the same rule must also be protected at the lifecycle level, add an observer safety net without using `ValidationException`.

### Permission Naming

Use stable names that match the resource permission convention used by the project.

Examples:

| Model | Permission name |
|---|---|
| `BlogPost` | `blog_post` |
| `BillingPlan` | `billing_plan` |
| `Announcement` | `announcement` |

---

## 10. Observer

Use an observer for model lifecycle behavior that must always happen when the model is saved.

Example:

```php
<?php

namespace App\Observers;

use App\Models\BlogPost;

class BlogPostObserver
{
    public function saving(BlogPost $blogPost): void
    {
        $this->setPublishedAt($blogPost);
    }

    private function setPublishedAt(BlogPost $blogPost): void
    {
        if (! $blogPost->isDirty('status')) {
            return;
        }

        if ($blogPost->status->is('Published') && ! $blogPost->published_at) {
            $blogPost->published_at = now();
        }

        if ($blogPost->status->is('Draft')) {
            $blogPost->published_at = null;
        }
    }
}
```

Rules:

- Observers own lifecycle side effects and derived values.
- Observers must not throw or import `ValidationException`.
- Field-level validation and user-facing messages belong in Livewire, form requests, action classes, or validation rules.
- If an operation should be blocked before save, check it in the caller through policy authorization or validation.
- Observer hook methods should remain lifecycle handlers.

### Observer Safety Net

When a persistence-sensitive rule needs a lifecycle safety net, do not use `ValidationException`.

Example:

```php
public function deleting(BlogPost $blogPost): bool
{
    if (! $blogPost->status->is('Draft')) {
        return false;
    }

    return true;
}
```

Use this as a safety net only. The normal user-facing block should happen earlier through authorization or Livewire validation.

---

## 11. Laravel Front Resource

Example:

```php
<?php

namespace App\Front\Resources;

use App\Enums\BlogPostStatus;
use App\Models\BlogPost as Model;
use WeblaborMx\Front\Inputs;

class BlogPost extends Resource
{
    public $base_url = '/admin/blog-posts';
    public $model = Model::class;
    public $icon = 'newspaper';
    public $title = 'title';

    public function fields()
    {
        return [
            Inputs\ID::make(),
            Inputs\Text::make('Title')
                ->rules(['required', 'string', 'max:255']),
            Inputs\Text::make('Slug')
                ->rules(['required', 'string', 'max:255'])
                ->creationRules(['unique:blog_posts,slug'])
                ->updateRules(['unique:blog_posts,slug,' . $this->object?->id])
                ->hideFromIndex(),
            Inputs\Textarea::make('Excerpt')
                ->rules(['nullable', 'string', 'max:1000'])
                ->hideFromIndex(),
            Inputs\ToastEditor::make('Content')
                ->rules(['required', 'string'])
                ->hideFromIndex(),
            Inputs\Select::make('Status')
                ->options(BlogPostStatus::options())
                ->rules(['required'])
                ->default(BlogPostStatus::Draft->value),
            Inputs\DateTime::make('Published At')
                ->onlyOnDetail(),
            Inputs\DateTime::make('Created At')
                ->onlyOnDetail(),
        ];
    }
}
```

Rules:

- Set `base_url` for the correct area.
- Alias the model as `Model` when the resource has the same class name.
- Add validation rules to fields.
- Hide long content from the index.
- Show timestamps on detail unless there is a reason not to.
- Use `creationRules()` and `updateRules()` when the rules differ.
- Keep labels readable.

### Simple Relationships

Use Laravel Front relationship inputs when the relationship is simple.

Example:

```php
Inputs\BelongsTo::make('User')
    ->rules(['required'])
    ->hideFromIndex(),
```

If the form edits related rows inline or needs nested validation, use Livewire for create/edit.

---

## 12. Routes

For an admin CRUD, register the Front resource in the admin route file:

```php
<?php

use App\Livewire\{Admin, Shared};
use Illuminate\Support\Facades\Route;

Route::livewire('/', Admin\Dashboard::class)->name('dashboard');

// CRUDS
Route::front('BlogPost');
```

Rules:

- Use `Route::front('ModelName')` for Laravel Front CRUDs.
- Use the correct route file for the area.
- Do not use controllers for standard CRUD screens.
- Do not invent route names.
- Verify route names with `php artisan route:list` when referencing them.

### Laravel Front Route Names

Laravel Front uses the pattern `{prefix}.front.{resource-slug}`.

Example for `BlogPost` in admin:

| Action | Route name |
|---|---|
| index | `admin.front.blog-posts` |
| create | `admin.front.blog-posts.create` |
| edit | `admin.front.blog-posts.edit` |

Rules:

- The index route does not use `.index`.
- Do not use names like `admin.blog-posts.index` for Front routes.
- Do not guess route names. Verify them.

---

## 13. Hybrid CRUD: Laravel Front + Livewire

Use a hybrid when the CRUD is valid but the create/edit form is too advanced for Laravel Front fields.

The route pattern is:

```php
<?php

use App\Livewire\{Admin, Shared};
use Illuminate\Support\Facades\Route;

Route::livewire('/', Admin\Dashboard::class)->name('dashboard');

// Blog Posts
Route::front('BlogPost');
Route::livewire('/blog-posts/create', Admin\BlogPostEdition::class)->name('blog-posts.create');
Route::livewire('/blog-posts/{front_object}/edit', Admin\BlogPostEdition::class)->name('blog-posts.edit');
```

Rules:

- Register `Route::front('BlogPost')` first.
- Add Livewire overrides after the Front route.
- Use `{front_object}` for edit overrides.
- Keep the same URL structure as the Front resource.
- Verify final names with `php artisan route:list --name=blog-posts`.

In an admin route group, the Livewire override names are usually:

| Action | Route name |
|---|---|
| create Livewire | `admin.blog-posts.create` |
| edit Livewire | `admin.blog-posts.edit` |

### Livewire Component

Example component for an advanced create/edit form:

```php
<?php

namespace App\Livewire\Admin;

use App\Enums\BlogPostStatus;
use App\Models\BlogPost;
use Illuminate\Validation\Rule;
use Livewire\Component;
use WireUi\Traits\WireUiActions;

class BlogPostEdition extends Component
{
    use WireUiActions;

    public BlogPost $object;
    public $tags = [];

    public function mount(?BlogPost $front_object = null)
    {
        $this->object = $front_object ?? new BlogPost;

        if (is_null($this->object->id)) {
            return $this->authorize('create', $this->object);
        }

        $this->authorize('update', $this->object);
        $this->tags = $this->object->tags_data;
    }

    /*
     * Rules
     */

    protected function rules()
    {
        return [
            'object.title'   => ['required', 'string', 'max:255'],
            'object.slug'    => ['required', 'string', 'max:255', Rule::unique('blog_posts', 'slug')->ignore($this->object->id)],
            'object.excerpt' => ['nullable', 'string', 'max:1000'],
            'object.content' => ['required', 'string'],
            'object.status'  => ['required'],
            'tags'           => ['array'],
            'tags.*.name'    => ['required', 'string', 'max:255'],
        ];
    }

    protected function validationAttributes()
    {
        return [
            'object.title'   => __('title'),
            'object.slug'    => __('slug'),
            'object.excerpt' => __('excerpt'),
            'object.content' => __('content'),
            'object.status'  => __('status'),
            'tags.*.name'    => __('tag name'),
        ];
    }

    /*
     * Tags
     */

    public function addTag(): void
    {
        $this->tags[] = ['name' => ''];
    }

    public function removeTag($index): void
    {
        $this->tags = collect($this->tags)->forget($index)->values()->all();
    }

    /*
     * Process
     */

    public function save()
    {
        $this->validate();

        $isNew = is_null($this->object->id);
        $this->object->tags_data = $this->tags;
        $this->object->save();

        $this->notification()->success(
            title: $isNew ? __('Post created') : __('Post updated'),
            description: __('The post has been saved successfully.')
        );

        if ($isNew) {
            return redirect()->route('admin.front.blog-posts');
        }
    }

    public function render()
    {
        return view('livewire.admin.blog-post-edition', [
            'statusOptions' => BlogPostStatus::options(),
        ])->layout('layouts.app', [
            'title' => $this->object->id ? __('Edit Post') : __('Create Post'),
        ]);
    }
}
```

Rules:

- Authorize protected resources in `mount()`.
- Use backend validation.
- Add `validationAttributes()` for fields that can show validation errors.
- Keep the Livewire method order required by the coding standard.
- Do not duplicate policy logic in the component.
- Use WireUI feedback APIs for user-facing feedback.
- Do not throw `ValidationException` from models or observers.

### Livewire Blade View

Example view:

```blade
<div class="space-y-8">
    <form wire:submit="save" class="space-y-8">
        <x-card :title="__('Post Information')">
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
                <x-input
                    wire:model="object.title"
                    :label="__('Title')"
                    :placeholder="__('Post title')"
                />

                <x-input
                    wire:model="object.slug"
                    :label="__('Slug')"
                    :placeholder="__('post-title')"
                />

                <div class="sm:col-span-2">
                    <x-textarea
                        wire:model="object.excerpt"
                        :label="__('Excerpt')"
                        rows="3"
                    />
                </div>

                <div class="sm:col-span-2">
                    <x-textarea
                        wire:model="object.content"
                        :label="__('Content')"
                        rows="10"
                    />
                </div>

                <x-select
                    wire:model="object.status"
                    :label="__('Status')"
                    :options="$statusOptions"
                    option-key-value
                />
            </div>
        </x-card>

        <x-card :title="__('Tags')">
            <div class="space-y-3">
                @foreach ($tags as $index => $tag)
                    <div class="flex items-center gap-3">
                        <x-input
                            wire:model="tags.{{ $index }}.name"
                            class="flex-1"
                            :placeholder="__('Tag name')"
                        />

                        <x-button
                            type="button"
                            wire:click="removeTag({{ $index }})"
                            icon="trash"
                            color="red"
                            flat
                        />
                    </div>
                @endforeach

                <x-button
                    type="button"
                    wire:click="addTag"
                    icon="plus"
                    color="primary"
                    outline
                    :label="__('Add')"
                />
            </div>
        </x-card>

        <div class="flex items-center justify-end gap-4">
            <a href="{{ route('admin.front.blog-posts') }}" class="text-sm text-gray-600 hover:text-gray-900">
                {{ __('Cancel') }}
            </a>

            <x-button
                type="submit"
                :label="$object->id ? __('Save Changes') : __('Create Post')"
                color="primary"
                wire:loading.attr="disabled"
            />
        </div>
    </form>
</div>
```

Rules:

- Use `wire:submit` for Livewire forms.
- Use project form components.
- Buttons must perform an action or clearly communicate disabled/unavailable state.
- Do not use WireUI `<x-modal>` markup for modals.
- Use named routes instead of hardcoded internal paths when possible.
- Do not duplicate policy conditions in Blade.

---

## 14. Related Collections in Advanced Forms

When a form edits a related collection through arrays, use the mutator + observer pattern if that collection must be synchronized on save.

The flow is:

1. Livewire assigns the array to the model.
2. The model captures the array in pending state through a mutator.
3. The observer synchronizes related rows after save.

Model example:

```php
public array $pendingTags = [];

public function setTagsDataAttribute(array $tags): void
{
    $this->pendingTags = $tags;
}

public function getTagsDataAttribute(): array
{
    return $this->tags->map(function ($tag) {
        return [
            'id'   => $tag->id,
            'name' => $tag->name,
        ];
    })->values()->all();
}
```

Observer example:

```php
public function saved(BlogPost $blogPost): void
{
    if (empty($blogPost->pendingTags)) {
        return;
    }

    $this->syncTags($blogPost);
}
```

Rules:

- Livewire should not own domain synchronization.
- The model defines how form data is received and exposed.
- The observer persists the related changes.
- Simple relationships can stay in Laravel Front.

---

## 15. Decision Examples

### Case A: Simple Categories

Request:

> "Create an admin CRUD for categories with name and description."

Decision:

- It is a CRUD.
- Use Laravel Front only.
- Policy is required.
- Livewire is not required.
- Observer is only required if there is lifecycle behavior.

Expected files:

- `app/Models/Category.php`
- `app/Front/Resources/Category.php`
- `app/Policies/CategoryPolicy.php`
- `database/migrations/*_create_categories_table.php`
- `routes/admin.php`

### Case B: Blog Posts With Publishing

Request:

> "Create an admin CRUD for blog posts and let admins publish them."

Decision:

- It is a CRUD.
- Laravel Front only can be enough.
- Use an enum for `status`.
- Use an observer to maintain `published_at`.
- Policy is required.

Expected files:

- `app/Enums/BlogPostStatus.php`
- `app/Models/BlogPost.php`
- `app/Observers/BlogPostObserver.php`
- `app/Policies/BlogPostPolicy.php`
- `app/Front/Resources/BlogPost.php`
- `database/migrations/*_create_blog_posts_table.php`
- `routes/admin.php`

### Case C: Products With Dynamic Variants

Request:

> "Create products and let admins add variants, prices, and inventory rows in the same form."

Decision:

- It is a CRUD.
- Laravel Front only is not enough for create/edit.
- Use Laravel Front + Livewire.
- Use `Route::front('Product')` for the CRUD shell.
- Override create/edit with Livewire.
- Use mutator + observer for related collection synchronization when appropriate.

Expected files:

- `app/Models/Product.php`
- `app/Models/ProductVariant.php`
- `app/Front/Resources/Product.php`
- `app/Policies/ProductPolicy.php`
- `app/Observers/ProductObserver.php`
- `app/Livewire/Admin/ProductEdition.php`
- `resources/views/livewire/admin/product-edition.blade.php`
- `database/migrations/*_create_products_table.php`
- `database/migrations/*_create_product_variants_table.php`
- `routes/admin.php`

### Case D: Sales Dashboard

Request:

> "Create a screen with metrics, charts, and monthly sales."

Decision:

- It is not a CRUD.
- Do not use Laravel Front as the main architecture.
- Create a dedicated Livewire screen.
- Use model methods or services for data access when appropriate.

---

## 16. Common Mistakes

Avoid:

- Creating a CRUD without a policy.
- Using controllers for normal CRUD screens.
- Using Laravel Front only for forms with complex nested arrays.
- Putting domain or authorization logic in Blade.
- Duplicating policy logic in Livewire or Blade.
- Throwing `ValidationException` from models or observers.
- Using `cascadeOnDelete()` or `nullOnDelete()` in migrations.
- Using `$fillable` in models.
- Forgetting casts for dates, booleans, arrays, JSON, and enums.
- Referencing `admin.front.resource.index`; Front index routes do not use `.index`.
- Guessing route names without checking them.
- Hardcoding internal URLs when a named route exists.
- Synchronizing related collections directly in Livewire when the model + observer pattern applies.

---

## 17. Final CRUD Checklist

Before delivering, confirm:

- The request was classified as a CRUD.
- The architecture choice is explained.
- The scaffold command was used or intentionally skipped with a reason.
- The migration follows the standards.
- The model uses `$guarded`, casts, relationships, and the correct section order.
- The policy exists.
- The Front resource has fields, validation, and `base_url`.
- The route uses `Route::front('ModelName')`.
- Livewire overrides exist if create/edit is advanced.
- The observer exists if lifecycle behavior is required.
- The enum exists if persisted states are required.
- No controller was added for a normal CRUD screen.
- Route references are verified.
- Policy logic is not duplicated in Blade or Livewire.
- Models and observers do not throw `ValidationException`.

---

## 18. AI Prompt Template

Use this prompt when asking an AI assistant to create a CRUD:

```text
Create a CRUD following Weblabor Coding Standards.

Before coding:
1. Confirm whether the request is actually a CRUD.
2. Choose Laravel Front only, Laravel Front + Livewire, or dedicated Livewire.
3. List fields, relationships, states, authorization rules, and lifecycle behavior.
4. Ask questions if required information is missing.

Mandatory rules:
- Use `php artisan front:resource ModelName -a` as the scaffold when applicable.
- Every CRUD must have a policy.
- CRUD policies extend `BasePolicy`.
- Use Laravel Front only for simple CRUDs.
- Use Livewire create/edit overrides for inline relations, dynamic add/remove rows, nested arrays, or reactive UI.
- Do not use controllers for normal CRUD screens.
- Migrations must not use `cascadeOnDelete()` or `nullOnDelete()`.
- Models use `$guarded`, casts, relationships, and the standard section order.
- Models and observers must not throw `ValidationException`.
- Persisted states use enums.
- Authorization rules belong in policies.
- Do not duplicate policy logic in Blade or Livewire.
- Verify route names with `php artisan route:list` when referencing them.

Deliver:
- Explain the chosen architecture.
- List created and modified files.
- Include a validation checklist.
- State which tests or manual checks were run.
```

---

## 19. Recommended Implementation Order

Implement in this order:

1. Confirm the request is a CRUD.
2. Choose the architecture.
3. Generate the scaffold with `php artisan front:resource ModelName -a`.
4. Adjust the migration.
5. Add an enum if there are persisted states.
6. Adjust the model.
7. Adjust the policy.
8. Add an observer if lifecycle behavior is required.
9. Adjust the Front resource.
10. Register the route.
11. Add Livewire create/edit overrides if required.
12. Verify routes with `php artisan route:list`.
13. Test index, create, edit, detail, and delete as applicable.

This order keeps the domain contract, authorization, and UI aligned.
