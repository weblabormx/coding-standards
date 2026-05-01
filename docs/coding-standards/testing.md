# Tests

## Introduction

This testing strategy ensures **system stability through real user flows in a real browser**.

> If all Dusk tests pass, the system should work correctly from the user's perspective.

Tests are organized by **approved user-facing use cases**, not by technical layers, routes, controllers, Livewire components, models, services, or implementation details.

## Objective

- Validate the application through real browser behavior.
- Prevent regressions in the flows users actually execute.
- Standardize testing across all projects with Laravel Dusk as the only automated test style.
- Enable consistent test generation, including AI-assisted test creation.

## Rules

### Scope

All automated tests for Weblabor projects must be **Laravel Dusk browser tests**.

Do not create PHPUnit unit tests, PHPUnit feature tests, route response tests, Livewire component tests, model tests, service tests, or helper-only tests for project behavior.

Internal logic is protected by testing the browser flow that exposes that behavior to the user.

### Dusk-only coverage

New automated coverage must be created from approved use cases through the `/test` workflow.

Do not recreate old PHPUnit unit or feature tests just because they existed before. Legacy PHPUnit tests may be removed when the project is intentionally moving to the Dusk-only, use-case-driven test suite.

When a repository has no tests yet, keep only Dusk infrastructure. Add the first real test only after the browser use case is proposed and approved.

### Use case driven coverage

Tests must represent **real system behavior in the browser**.

Tests must be driven by approved user-facing use cases, not by technical checklists.

Before writing or changing tests, the assistant must propose the browser use cases that need coverage and wait for user approval.

The testing workflow supports two modes:

- Specific use case mode: the user provides a concrete browser flow, and the assistant analyzes existing Dusk coverage and proposes the exact test needed.
- Feature audit mode: the user provides a feature area, and the assistant audits expected behavior and proposes missing browser use cases.

Do not write tests until the proposed use cases are reviewed and approved by the user.

### Test grouping

Group tests by user-facing areas, such as:

- Auth
- Users
- Billing
- Add-ons
- Announcements
- Profile
- Admin

Do not group tests by technical layers, such as:

- Routes
- Livewire components
- Middleware
- Models
- Services
- Helpers

### Test file ownership

Each test file should protect one meaningful browser use case or user goal.

A file may include scenario variations for the same goal, such as success, validation errors, blocked access, or cancellation.

Use names that describe the user goal:

```text
LoginTest.php
RegisterTest.php
ManageProfileTest.php
SubscribeToPlanTest.php
CreateUserTest.php
```

### Route coverage

Every important route must be exercised by at least one approved browser use case.

Do not create route-by-route tests only to satisfy coverage. A route should be tested through the flow that gives it user value.

Simple static pages may be grouped in one Dusk test only when there is no meaningful user flow beyond loading the page and seeing expected content.

### Factories and seeds

Factories and seeds may be used only to prepare browser test state.

Factories must produce valid models, stay lightweight, and avoid heavy automatic relationships.

Use factory states for repeated setup variants, seeds for roles, permissions, and static data, and factories for dynamic data.

Do not use `Model::create()` in tests when a factory exists.

```php
$admin = User::factory()->admin()->create();
```

Factories prepare the scenario. Browser actions validate the behavior.

### Browser interaction

Use Laravel Dusk for all automated behavior coverage.

Do not replace browser behavior with direct HTTP requests, Livewire calls, service calls, model assertions, or helper assertions.

Prefer browser actions such as:

- Visiting pages.
- Clicking buttons and links.
- Typing into fields.
- Selecting options.
- Confirming modals.
- Waiting for Livewire or JavaScript updates.
- Seeing success, error, or empty states.

### Visible assertions

Prefer assertions that match what the user can observe:

- The page changed.
- A record appears in a table.
- A validation message is shown.
- A toast or confirmation is visible.
- A button becomes enabled or disabled.
- The user is redirected to the expected area.

Database assertions may be used as supporting checks, but they must not replace visible browser assertions.

### Test helpers

Helpers may be used for repeated setup or repeated browser actions.

Helpers must not contain the main assertions for the use case.

### Deterministic behavior

Tests must be deterministic.

Do not branch test behavior based on environment, current data, optional UI, or existing records.

### Assertion scope

Multiple assertions are allowed when they validate the same browser flow.

Do not combine unrelated user goals in a single test.

### Laravel Front testing

Laravel Front resources must be tested through Dusk browser flows.

Do not use Laravel Front PHPUnit helpers as the main coverage strategy.

Examples of valid Dusk use cases:

- Admin lists users.
- Admin creates a user.
- Admin updates a user's role.
- Admin disables or blocks a user.
- Admin manages billing plans or add-ons.

### Prohibited tests

Do not write automated tests whose only purpose is to validate:

- A model method directly.
- A service method directly.
- A trait method directly.
- A helper function directly.
- A cast directly.
- A validation rule directly.
- A route response directly.
- A Livewire method directly.

If that logic matters, identify the browser flow where the user depends on it and test that flow with Dusk.

### Validation

Do not run the full Dusk suite by default.

Run only the smallest targeted Dusk command needed to validate the approved scope, such as:

```bash
php artisan dusk tests/Browser/WeblaborBase/Auth/LoginTest.php
```

Use targeted filters when validating a single method:

```bash
php artisan dusk --filter=test_admin_can_create_user
```

When relevant Dusk tests already exist, ask before running them:

> Los tests relevantes ya existen. ¿Quieres que validemos solo los tests necesarios para este caso de uso?

### Naming

Use method names that describe the user's goal:

```text
test_user_can_login
test_user_can_reset_password
test_admin_can_create_user
test_user_can_update_profile
test_user_can_subscribe_to_plan
test_user_can_purchase_addon
```

## Documentation

### Structure

```text
tests/
├── Browser/
│   ├── WeblaborBase/
│   │   ├── Auth/
│   │   │   ├── LoginTest.php
│   │   │   ├── RegisterTest.php
│   │   │   └── ResetPasswordTest.php
│   │   ├── App/
│   │   │   ├── DashboardTest.php
│   │   │   └── ProfileTest.php
│   │   ├── Admin/
│   │   │   ├── ManageUsersTest.php
│   │   │   └── ManageBillingPlansTest.php
│   │   └── Billing/
│   │       ├── SubscribeToPlanTest.php
│   │       └── ManageAddOnsTest.php
│   ├── {Project}/
│   ├── Pages/
│   └── Components/
├── DuskTestCase.php
└── README.md
```

Only keep shared testing infrastructure outside `tests/Browser/`, such as `tests/DuskTestCase.php` and browser support folders generated by Dusk.

### Example

```php
public function test_admin_can_create_user(): void
{
    $admin = User::factory()->admin()->create();

    $this->browse(function (Browser $browser) use ($admin) {
        $browser->loginAs($admin)
            ->visit('/admin/users/create')
            ->type('name', 'John Doe')
            ->type('email', 'john@example.com')
            ->type('password', 'password')
            ->press('Save')
            ->waitForText('User created')
            ->assertSee('John Doe')
            ->assertSee('john@example.com');
    });
}
```

## Final rule

Tests are written to protect approved user-facing business flows through Laravel Dusk only.

Do not add PHPUnit unit, feature, route, Livewire, model, service, trait, helper, cast, or rule tests for project behavior.

Validation should run the smallest targeted Dusk check needed to confirm the relevant behavior. Do not run the full suite by default.
