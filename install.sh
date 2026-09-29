#!/bin/sh
# Installs the skill for your user (every project). For one project only, copy skills/day-to-calendar
# into that project's .claude/skills/ instead.
set -e
here=$(cd "$(dirname "$0")" && pwd)
dest="$HOME/.claude/skills"
mkdir -p "$dest"
rm -rf "$dest/day-to-calendar"
cp -R "$here/skills/day-to-calendar" "$dest/"
[ -f "$HOME/.config/day-to-calendar/config.json" ] || { [ -t 0 ] && sh "$here/setup.sh"; }
echo "installed to $dest/day-to-calendar. Open Claude Code and say: log today to my calendar."
