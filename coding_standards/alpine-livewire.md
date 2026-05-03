# Alpine.js and Livewire Usage Rules

## Purpose
This rule clarifies when to use Alpine.js for interactivity versus when to use Livewire components for complex frontend logic in Blade views.

## Guidelines

- **Alpine.js** is intended for simple interaction and small bits of dynamic behavior directly in Blade templates.
  - Use Alpine.js for simple UI toggles, small animations, basic reactive properties, and event handling that does not require backend communication or complex state.
  - Avoid embedding any of the following complex behaviors in Alpine.js within Blade templates:
    - Timers, intervals, or clock logic.
    - Drag-and-drop implementations.
    - Multi-step workflows or conditional sequences.
    - Complex state management involving multiple related properties.
    - Sorting or ordering logic.
    - Extended data structures (arrays, objects) beyond very simple reactive flags.

- **Livewire** should be used for complex UI logic, state management, server interactions, and multi-step user workflows.
  - Move all substantial JavaScript logic, stateful behavior, timers, sorting, and event-driven multi-step interactions out of Alpine.js into Livewire components.
  - Livewire components handle backend coordination, long-running state, data fetching, form state management, and workflow transitions.

- **Performance Exceptions:**
  - If Livewire causes unacceptable UI latency for very fast updates or animations, Alpine.js may be used with caution.
  - Performance-based Alpine.js use must be explicitly documented with reasoned comments referencing this rule.

## Examples

```blade
<!-- Simple Alpine toggle example -->
<div x-data="{ open: false }">
    <button @click="open = !open">Toggle</button>
    <div x-show="open">Content</div>
</div>
```

```php
// Complex Livewire component example
class TaskTracker extends Livewire\Component
{
    public $activeTask;
    public $timerSeconds = 0;

    public function startTimer() { /* ... */ }
    public function stopTimer() { /* ... */ }

    public function render()
    {
        return view('livewire.task-tracker');
    }
}
```

## Enforcement

- Scan and flag Blade views embedding Alpine.js code implementing:
  - Timer or clock intervals.
  - Drag and drop reordering.
  - Sorting or ordering logic.
  - Multi-state coordination involving multiple properties.
  - Complex event-driven workflows.
- Recommend moving flagged logic into Livewire components.
- Require documentation comments citing performance exceptions if Alpine.js is used for complex logic.

---

*This updated rule clarifies and expands the prohibitions on complex Alpine.js logic to prevent maintainability issues and enforce better separation of concerns via Livewire components. This change is driven by human feedback observed in the recent review of the task tracker Blade view.*
