# Weblabor Base

A Laravel starter kit for rapid development of SaaS products and multi-tenant applications. Includes authentication, admin panel, subscription billing, PWA support, and opinionated conventions for consistency.

---

## Quick Start

```bash
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate --seed
npm ci && npm run build
php artisan storage:link
```

See [Installation](docs/weblabor-base/installation.md) for full setup instructions.

---

## Guides

| Section | Description |
|---|---|
| [Development Guides](docs) | Developer guides, including coding standards |

