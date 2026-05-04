# Laravel Notifications

## Rules

### General Rules

- Every actual Laravel notification class must extend `App\Notifications\Notification`
- Never extend `Illuminate\Notifications\Notification` directly
- Every actual Laravel notification class must define: `subject()`, `description()`, `image()`
- Use `php artisan make:notification MyNotification` (the stub already extends the base class) to create a new Notification
- Do not force channels manually unless justified
- This rule applies only to actual Laravel notification classes, normally files under `app/Notifications` or classes extending Laravel/project notification base classes.
- Inside `namespace App\Notifications;`, `extends Notification` is valid because it resolves to the local `App\Notifications\Notification` base class. Do not require writing `extends App\Notifications\Notification` or importing the class in that namespace.
