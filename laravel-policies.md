# Laravel Policies

## Rules

### General Rules

- Policies live in `app/Policies/`
- Only extend `BasePolicy` when the model has its own independent CRUD in the admin frontend (registered via Laravel Front). `BasePolicy` validates `hasPermissionTo($name)` against permissions stored in the database — if there is no CRUD, the permission does not exist and there is no reason to create it.
- When a model does not have its own CRUD (e.g. `BillingPrice`, `BillingPriceVariation`), the policy handles only business logic (e.g. "cannot delete if it has children") without checking user permissions by name. Access is inherited from the parent model's permission (e.g. if the user has the `plans` permission, they have access to prices and variations).
- Do not register policies manually in `AppServiceProvider`. Laravel autodiscovers policies that follow the `App\Policies\{Model}Policy` naming convention.
- Pair every policy with an observer: the policy blocks at the authorization layer, the observer is the safety net at the persistence layer. Both must enforce the same rule.
- Deletion business logic (e.g. "cannot delete if it has children") must live in a `canBeDeleted(): bool` method on the model. Both the policy `delete()` and the observer `deleting()` call `$model->canBeDeleted()` — never duplicate the condition inline in each layer.
