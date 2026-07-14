#!/usr/bin/env bash
# Symlinks the agent definitions in this repo into ~/.claude/agents/, so Claude
# Code picks them up as available subagent types. Run once after cloning, and
# again any time an agent file is added, renamed, or removed under agents/.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$HOME/.claude/agents"

mkdir -p "$TARGET_DIR"

for agent_file in "$REPO_DIR"/agents/*.md; do
  [ -f "$agent_file" ] || continue
  name="$(basename "$agent_file")"
  dest="$TARGET_DIR/$name"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "WARNING: $dest already exists and is not a symlink — skipping. Move/delete it manually and re-run if you want it linked." >&2
    continue
  fi

  ln -s "$agent_file" "$dest"
  echo "linked: $dest -> $agent_file"
done

echo "Done."
