# Laravel Migrations

## Rules

### General Rules

- Never use `->cascadeOnDelete()` in migration foreign key definitions
- Never use `->nullOnDelete()` in migrations
- Use `->constrained()` when appropriate
- Use our `->dropColumnWithIndexes()` function instead of `->dropColumn()`
