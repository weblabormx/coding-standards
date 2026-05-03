# Laravel Notifications

## Rules

### General Rules

- Every notification must extend `App\Notifications\Notification`
- Never extend `Illuminate\Notifications\Notification` directly
- Every notification must define: `subject()`, `description()`, `image()`
- Use `php artisan make:notification MyNotification` (the stub already extends the base class) to create a new Notification
- Do not force channels manually unless justified
- Apply this rule only to actual Laravel notification classes, normally files under `app/Notifications` or classes extending Laravel/project notification base classes. Do not apply it to Livewire components, Blade views, or UI classes that happen to be named `Notification` or live in a `Notifications` UI folder.
- Inside `namespace App\Notifications;`, `extends Notification` is valid because it resolves to the local `App\Notifications\Notification` base class. Do not require writing `extends App\Notifications\Notification` or importing the class in that namespace.
