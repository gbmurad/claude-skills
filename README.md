# Claude Skills by gmurad

Small, useful skills for [Claude Code](https://claude.com/claude-code), built by George Murad. Each one lives in its own folder under `skills/` with its own README.

## Skills
| Skill | What it does |
|---|---|
| [day-to-calendar](skills/day-to-calendar/README.md) | Writes a short summary of each day you worked into its own Apple Calendar. macOS only. |
| [gavel](skills/gavel/README.md) | Puts a decision on trial: a defense, a prosecution, a jury of specialists who vote alone, and a judge who rules on the evidence. |

## Install
```sh
git clone https://github.com/gbmurad/claude-skills.git
cd claude-skills
sh install.sh                    # every skill
sh install.sh day-to-calendar    # just one
sh install.sh gavel              # or just this one
```
Skills are copied to `~/.claude/skills/`, so they work in every project. Restart Claude Code, then ask for the skill by what it does (for example, "log today to my calendar").

## Adding a skill
Make `skills/<name>/SKILL.md` with `name` and `description` in its frontmatter. Put helper scripts in `skills/<name>/scripts/`. If it has `scripts/setup.sh`, the installer offers to run it.

## License
MIT. See [LICENSE](LICENSE).
