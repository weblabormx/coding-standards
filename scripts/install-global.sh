#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/install-global.sh [--all] [--codex] [--opencode] [--cloud]
                              [--global-root PATH]
                              [--codex-skills-dir PATH]
                              [--opencode-dir PATH]
                              [--cloud-dir PATH]

Defaults:
  --all               Install all supported targets when no target flag is provided
  --global-root       ~/.weblabor
  --codex-skills-dir  ~/.codex/skills
  --opencode-dir      ~/.opencode/weblabor
  --cloud-dir         ~/.config/weblabor/cloud

This script only creates global symlinks and helper bundle paths.
It never copies files into individual projects.
EOF
}

expand_path() {
  case "$1" in
    "~") printf '%s\n' "$HOME" ;;
    "~/"*) printf '%s/%s\n' "$HOME" "${1#\~/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

install_codex=false
install_opencode=false
install_cloud=false

global_root="~/.weblabor"
codex_skills_dir="~/.codex/skills"
opencode_dir="~/.opencode/weblabor"
cloud_dir="~/.config/weblabor/cloud"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --all)
      install_codex=true
      install_opencode=true
      install_cloud=true
      ;;
    --codex)
      install_codex=true
      ;;
    --opencode)
      install_opencode=true
      ;;
    --cloud)
      install_cloud=true
      ;;
    --global-root)
      shift
      global_root="${1:-}"
      ;;
    --codex-skills-dir)
      shift
      codex_skills_dir="${1:-}"
      ;;
    --opencode-dir)
      shift
      opencode_dir="${1:-}"
      ;;
    --cloud-dir)
      shift
      cloud_dir="${1:-}"
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if ! $install_codex && ! $install_opencode && ! $install_cloud; then
  install_codex=true
  install_opencode=true
  install_cloud=true
fi

global_root="$(expand_path "$global_root")"
codex_skills_dir="$(expand_path "$codex_skills_dir")"
opencode_dir="$(expand_path "$opencode_dir")"
cloud_dir="$(expand_path "$cloud_dir")"

source_alias="$global_root/coding-standards"

mkdir -p "$global_root"
ln -sfn "$REPO_ROOT" "$source_alias"

echo "Global source alias:"
echo "  $source_alias -> $REPO_ROOT"

if $install_codex; then
  mkdir -p "$codex_skills_dir"

  for cmd in "$source_alias"/.opencode/commands/*.md; do
    [ -f "$cmd" ] || continue
    skill_name="$(basename "$cmd" .md)"
    mkdir -p "$codex_skills_dir/$skill_name"
    ln -sfn "$cmd" "$codex_skills_dir/$skill_name/SKILL.md"
  done

  echo
  echo "Codex installed:"
  echo "  Skills directory: $codex_skills_dir"
fi

if $install_opencode; then
  mkdir -p "$opencode_dir"
  ln -sfn "$source_alias" "$opencode_dir/source"
  ln -sfn "$source_alias/.opencode/commands" "$opencode_dir/commands"
  ln -sfn "$source_alias/.opencode/agents" "$opencode_dir/agents"
  ln -sfn "$source_alias/guides" "$opencode_dir/guides"
  ln -sfn "$source_alias/coding_standards" "$opencode_dir/coding_standards"

  echo
  echo "OpenCode bundle installed:"
  echo "  Bundle directory: $opencode_dir"
fi

if $install_cloud; then
  mkdir -p "$cloud_dir"
  ln -sfn "$source_alias" "$cloud_dir/source"
  ln -sfn "$source_alias/.opencode/commands" "$cloud_dir/commands"
  ln -sfn "$source_alias/.opencode/agents" "$cloud_dir/agents"
  ln -sfn "$source_alias/guides" "$cloud_dir/guides"
  ln -sfn "$source_alias/coding_standards" "$cloud_dir/coding_standards"

  echo
  echo "Cloud bundle installed:"
  echo "  Bundle directory: $cloud_dir"
fi

echo
echo "Done."
