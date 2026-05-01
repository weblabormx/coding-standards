# Documentation

Any new feature, config option, or architectural component **must** include documentation in `/docs/{project}`.

- All docs in `/docs/{project-name}` using **kebab-case** folder names
- Each project folder must have a `README.md` linking every `.md` file
- New `.md` files must be linked from the project `README.md`
- Content: practical and usage-focused — never include database schemas or migration details
- If a folder in `/docs` does NOT match the current project → ignore it completely

## What Requires Documentation

- New Livewire components with non-obvious behavior
- New `config/` keys → update `docs/{project}/configuration.md`
- New custom Artisan commands → update `docs/{project}/development.md`
- New services, traits, helpers created for reuse
- New Blade components created in this project → update `docs/{project}/ui-components.md`
- New environment variables introduced by this project
- Architectural decisions

---

## Dead Code & No-Impact Changes

Flag explicitly:
- New files not referenced anywhere
- Classes never used
- Logic that never executes
- Changes that do not alter behavior
