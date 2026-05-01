# Installation

This guide explains how to install these coding standards globally so they stay in one shared repository and are not copied into individual projects.

The goal is simple:

- keep this repository as the single source of truth
- expose the same source to Codex, Cloud environments, and OpenCode
- avoid per-project copies of `guides/`, `coding_standards/`, commands, or agents

---

## What Gets Installed

The global setup points your tools to the files that already live in this repository:

- `guides/`
- `coding_standards/`
- `.opencode/commands/`
- `.opencode/agents/`

The installation uses symlinks or stable global paths. It does not copy these files into application repositories.

---

## Recommended Setup

Clone this repository once in a stable local path.

Example:

```bash
git clone <repo-url> ~/weblabor/coding-standards
cd ~/weblabor/coding-standards
```

If you move the repository later, re-run the global installation steps so every link points to the new path.

---

## Helper Script

This repository includes a helper script for global installation:

```bash
./scripts/install-global.sh
```

By default it prepares all supported targets:

- Codex global skills
- an OpenCode global bundle path
- a Cloud global bundle path

It also creates a stable source alias at:

```text
~/.weblabor/coding-standards
```

That alias points back to this repository so the rest of the setup can use one stable location even if you want tools to reference a home-directory path.

---

## Codex

### What Codex Needs

Codex consumes commands as skills. The recommended global install links every command in `.opencode/commands/` into `~/.codex/skills/`, while still reading the actual file from this repository.

### Install with the Helper Script

From this repository:

```bash
./scripts/install-global.sh --codex
```

### Manual Install

```bash
mkdir -p ~/.weblabor ~/.codex/skills
ln -sfn "$(pwd)" "$HOME/.weblabor/coding-standards"

for cmd in "$HOME/.weblabor/coding-standards"/.opencode/commands/*.md; do
  [ -f "$cmd" ] || continue
  skill_name=$(basename "$cmd" .md)
  mkdir -p "$HOME/.codex/skills/$skill_name"
  ln -sfn "$cmd" "$HOME/.codex/skills/$skill_name/SKILL.md"
done
```

### Verify

- restart Codex or open a new session
- confirm commands such as `/plan`, `/develop`, or `/review` are available
- confirm command content still resolves back to this repository, not a copied file

---

## OpenCode

### What OpenCode Needs

OpenCode should point to a stable global bundle that exposes:

- `commands/`
- `agents/`
- `guides/`
- `coding_standards/`

Because OpenCode environments can vary, this repository prepares a global bundle path instead of assuming one exact OpenCode config layout.

### Install with the Helper Script

```bash
./scripts/install-global.sh --opencode
```

Default bundle path:

```text
~/.opencode/weblabor/
```

That folder is populated with symlinks back to this repository:

```text
~/.opencode/weblabor/source
~/.opencode/weblabor/commands
~/.opencode/weblabor/agents
~/.opencode/weblabor/guides
~/.opencode/weblabor/coding_standards
```

### Manual Install

```bash
mkdir -p ~/.weblabor ~/.opencode/weblabor
ln -sfn "$(pwd)" "$HOME/.weblabor/coding-standards"

ln -sfn "$HOME/.weblabor/coding-standards" "$HOME/.opencode/weblabor/source"
ln -sfn "$HOME/.weblabor/coding-standards/.opencode/commands" "$HOME/.opencode/weblabor/commands"
ln -sfn "$HOME/.weblabor/coding-standards/.opencode/agents" "$HOME/.opencode/weblabor/agents"
ln -sfn "$HOME/.weblabor/coding-standards/guides" "$HOME/.opencode/weblabor/guides"
ln -sfn "$HOME/.weblabor/coding-standards/coding_standards" "$HOME/.opencode/weblabor/coding_standards"
```

### Verify

- confirm your OpenCode setup points to the global bundle path you installed
- confirm it reads commands and agents from `~/.opencode/weblabor/`
- confirm edits in this repository are reflected immediately without copying files anywhere else

---

## Cloud

### What Cloud Needs

For Cloud or remote assistant environments, the important rule is the same: keep a single shared checkout or mounted path and point the environment to it globally.

The installation here creates a stable bundle folder you can reference from your cloud bootstrap, startup script, mounted home directory, or global assistant configuration.

### Install with the Helper Script

```bash
./scripts/install-global.sh --cloud
```

Default bundle path:

```text
~/.config/weblabor/cloud/
```

That folder is populated with symlinks back to this repository:

```text
~/.config/weblabor/cloud/source
~/.config/weblabor/cloud/commands
~/.config/weblabor/cloud/agents
~/.config/weblabor/cloud/guides
~/.config/weblabor/cloud/coding_standards
```

### Manual Install

```bash
mkdir -p ~/.weblabor ~/.config/weblabor/cloud
ln -sfn "$(pwd)" "$HOME/.weblabor/coding-standards"

ln -sfn "$HOME/.weblabor/coding-standards" "$HOME/.config/weblabor/cloud/source"
ln -sfn "$HOME/.weblabor/coding-standards/.opencode/commands" "$HOME/.config/weblabor/cloud/commands"
ln -sfn "$HOME/.weblabor/coding-standards/.opencode/agents" "$HOME/.config/weblabor/cloud/agents"
ln -sfn "$HOME/.weblabor/coding-standards/guides" "$HOME/.config/weblabor/cloud/guides"
ln -sfn "$HOME/.weblabor/coding-standards/coding_standards" "$HOME/.config/weblabor/cloud/coding_standards"
```

### Verify

- confirm the remote environment can access the installed global path
- confirm the assistant bootstrap or global instructions reference the bundle path instead of project-local files
- confirm updates come from this repository checkout only

---

## Common Commands

Install everything at once:

```bash
./scripts/install-global.sh --all
```

Install Codex only:

```bash
./scripts/install-global.sh --codex
```

Install OpenCode only:

```bash
./scripts/install-global.sh --opencode
```

Install Cloud only:

```bash
./scripts/install-global.sh --cloud
```

Use custom directories:

```bash
./scripts/install-global.sh \
  --codex \
  --opencode \
  --cloud \
  --global-root ~/custom/weblabor \
  --codex-skills-dir ~/.codex/skills \
  --opencode-dir ~/.opencode/weblabor \
  --cloud-dir ~/.config/weblabor/cloud
```

---

## Updating

When this repository changes:

```bash
cd ~/weblabor/coding-standards
git pull
./scripts/install-global.sh --all
```

Most of the time `git pull` is enough because the install uses symlinks. Re-running the script is useful after path changes or if you add new commands.

---

## Troubleshooting

### Commands do not appear in Codex

- verify the skill links exist under `~/.codex/skills/`
- restart Codex or open a new session
- confirm each `SKILL.md` symlink points to this repository

### OpenCode or Cloud is reading stale files

- verify the global bundle directory contains symlinks, not copied files
- verify the symlinks resolve to this repository checkout
- if you moved the repo, re-run `./scripts/install-global.sh --all`

### I want to install this in a project

Do not copy these files into the project. Keep the installation global and point the assistant environment to this repository instead.
