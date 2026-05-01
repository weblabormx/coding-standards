# Laravel Notifications

## Rules

### General Rules

- Every notification must extend `App\Notifications\Notification`
- Never extend `Illuminate\Notifications\Notification` directly
- Every notification must define: `subject()`, `description()`, `image()`
- Use `php artisan make:notification MyNotification` (the stub already extends the base class) to create a new Notification
- Do not force channels manually unless justified
