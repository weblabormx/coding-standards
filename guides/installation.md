# Installation

This guide explains how to install these coding standards globally so they stay in one shared repository and are not copied into individual projects.

The goal is simple:

- keep this repository as the single source of truth
- expose the same source to Codex, Claude, and OpenCode
- avoid per-project copies of `guides/`, `coding_standards/`, commands, or agents

---

## What Gets Installed

The global setup should point your tools to the files that already live in this repository:

- `guides/`
- `coding_standards/`
- `.opencode/commands/`
- `.opencode/agents/`

Do not copy these files into application repositories.

---

## Recommended Flow

Clone this repository once in a stable local path.

Example:

```bash
git clone <repo-url> ~/weblabor/coding-standards
cd ~/weblabor/coding-standards
```

After cloning it, open the assistant tool you use and ask it to install this repository globally from that path.

The important rule is always the same:

- install globally
- do not copy anything into the current project
- keep this repository as the only source of truth

---

## Base Instruction

This is the default prompt you can paste into Codex, Claude, or OpenCode:

```text
Por favor instala globalmente los workflows, commands, agents, guides y coding standards desde este repositorio:

~/weblabor/coding-standards

No los copies dentro de este proyecto.
Quiero que este repositorio quede como source of truth global y que los cambios futuros se lean desde aquí.
Al final dime qué configuraste globalmente.
```

If your clone is in another location, replace `~/weblabor/coding-standards` with the real path.

---

## Example Prompt

This version is a little more explicit and works well as a general example:

```text
Ya cloné este repositorio en:

~/weblabor/coding-standards

Por favor instálame globalmente estos skills, commands, agents, guides y coding standards desde ese repo.
No copies nada dentro del proyecto actual.
Quiero que ese repositorio sea la única fuente de verdad.
Al final dime qué quedó enlazado, importado o configurado globalmente.
```

---

## OpenCode

If you are using OpenCode, a prompt like this should be enough:

```text
Ya tengo este repositorio clonado:

~/weblabor/coding-standards

Por favor impórtame globalmente estos workflows y skills desde ese repositorio.
Quiero usar globalmente los archivos de `.opencode/commands/`, `.opencode/agents/`, `guides/` y `coding_standards/`.
No copies nada a este proyecto.
```

---

## Codex

If you are using Codex, use this version:

```text
Ya tengo este repositorio clonado:

~/weblabor/coding-standards

Por favor instálame globalmente los skills y referencias necesarias desde ese repositorio.
Quiero usar sus commands, agents, guides y coding standards como configuración global.
No copies archivos dentro de este proyecto.
```

---

## Claude

If you are using Claude, use this version:

```text
Ya tengo este repositorio clonado:

~/weblabor/coding-standards

Por favor configura globalmente este repositorio como fuente de workflows, guides y coding standards.
No copies los archivos dentro del proyecto actual.
Quiero que este repo quede como source of truth global y que los cambios futuros se lean desde ahí.
```

---

## What To Verify

After asking the tool to install the repository globally, verify this:

- the current project did not receive copied files from this repository
- the assistant points to the cloned repository path
- future edits in this repository are the ones the tool will read
- commands, agents, guides, and coding standards resolve back to the shared repository

---

## Updating

When this repository changes:

```bash
cd ~/weblabor/coding-standards
git pull
```

If needed, ask the tool again to refresh or re-import the global configuration from the same path.

---

## Troubleshooting

### The tool copied files into the project

Remove those copied files and repeat the instruction, making it explicit that the installation must be global and must not copy anything into the current repository.

### The tool is reading stale files

- verify the assistant still points to the cloned repository path
- verify it did not create a copied local snapshot somewhere else
- if you moved the repo, ask the assistant to re-install globally from the new path

### I want to install this in a project

Do not copy these files into the project. Keep the installation global and point the assistant environment to this repository instead.
