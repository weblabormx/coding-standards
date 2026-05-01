# Services

## Rules

### Purpose

Services exist to communicate with **external systems** (Stripe, APIs, third-party integrations). They must not contain domain logic that belongs in a model, and must not manage model state directly.

### Services are read-only with respect to models

A service must never call `save()`, `update()`, `updateQuietly()`, or assign attributes on any model it receives. Services only read models and communicate results via return values. The observer or caller that invoked the service is responsible for persisting any returned data.

```php
// Correct — service returns the Stripe ID, observer assigns it before INSERT
public function creating(BillingPrice $price): void
{
    $price->stripe_price_id = app(StripeSyncService::class)->syncPrice($price);
}

// Incorrect — service writes directly to the model
public function syncPrice(BillingPrice $price)
{
    $result = $this->stripe->prices->create([...]);
    $price->updateQuietly(['stripe_price_id' => $result->id]); // wrong
}
```

### Services must not contain model domain logic

If a method only queries or operates on Eloquent models without touching an external system, it does not belong in a service — it belongs in the model or a model method.

```php
// Correct — model owns the logic
public function cancelSubscriptions()
{
    $this->subscriptions()->each(function ($subscription) {
        $subscription->cancel();
    });
}

// Incorrect — no external system involved, should be a model method
public function cancelSubscriptionsByPrice(BillingPrice $price)
{
    Subscription::whereHas('items', ...)->get()->each->cancel(); // wrong place
}
```

### Call pattern

Services are always called via model methods or observers — never directly from Livewire components or controllers.

Pattern: `Livewire / Controller → Model Method → Observer → Service`

```php
// Correct — Livewire calls the model method
$price->archive();

// Incorrect — Livewire calls the service directly
app(StripeSyncService::class)->archivePrice($price);
```

### Services communicate results via return values

When a service creates a resource in an external system and an ID must be persisted, the service returns that ID. The caller (observer or model) persists it.

```php
// Correct
public function syncPlan(BillingPlan $plan)
{
    $product = $this->stripe->products->create([...]);
    return $product->id;
}

// Caller persists the returned ID
private function assignStripeProductId(BillingPlan $plan): void
{
    $stripeProductId = app(StripeSyncService::class)->syncPlan($plan);
    if ($stripeProductId) {
        $plan->stripe_product_id = $stripeProductId;
    }
}
```
