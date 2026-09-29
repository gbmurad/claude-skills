#!/bin/sh
# install.sh [skill ...]: copies skills into ~/.claude/skills (every project). No arguments installs all of them.
set -e
here=$(cd "$(dirname "$0")" && pwd)
dest="$HOME/.claude/skills"
mkdir -p "$dest"
list="$*"; [ -n "$list" ] || list=$(ls "$here/skills")
for s in $list; do
  [ -f "$here/skills/$s/SKILL.md" ] || { echo "no such skill: $s" >&2; exit 1; }
  rm -rf "$dest/$s"
  cp -R "$here/skills/$s" "$dest/"
  echo "installed $s"
  if [ -f "$dest/$s/scripts/setup.sh" ] && [ -t 0 ]; then sh "$dest/$s/scripts/setup.sh"; fi
done
echo "Restart Claude Code, then ask for a skill by what it does."
