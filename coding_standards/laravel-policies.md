# Laravel Policies

## Rules

### General Rules

- Policies live in `app/Policies/`
- Only extend `BasePolicy` when the model has its own independent CRUD in the admin frontend (registered via Laravel Front). `BasePolicy` validates `hasPermissionTo($name)` against permissions stored in the database — if there is no CRUD, the permission does not exist and there is no reason to create it.
- Do not infer that a model lacks independent CRUD merely because a policy adds business logic such as `&& $model->canBeDeleted()` or `&& ! $instance->is_paid`. Verify route/resource evidence such as `Route::front('ModelName')`, an `app/Front/Resources/ModelName.php` resource, or an explicit permission before failing `extends BasePolicy`.
- When a model does not have its own CRUD (e.g. `BillingPrice`, `BillingPriceVariation`), the policy handles only business logic (e.g. "cannot delete if it has children") without checking user permissions by name. Access is inherited from the parent model's permission (e.g. if the user has the `plans` permission, they have access to prices and variations).
- Do not register policies manually in `AppServiceProvider`. Laravel autodiscovers policies that follow the `App\Policies\{Model}Policy` naming convention.
- When a policy enforces a persistence-sensitive business rule, pair it with an observer safety net for the same rule.
- When delete authorization has business logic (e.g. "cannot delete if it has children"), put that logic in `canBeDeleted(): bool` on the model. The policy `delete()` and observer `deleting()` call `$model->canBeDeleted()` instead of duplicating the condition.
