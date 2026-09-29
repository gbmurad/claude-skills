# day-to-calendar

A Claude Code skill that writes a short summary of each day you worked into its own Apple Calendar, so you can look back and see what happened on any date.

Ask "log today to my calendar" and Claude drafts a title and a few sentences for the day, shows you, and on your yes adds it as an all day event in a separate calendar called **Workday Log**. It can also backfill past days from your git history.

## What you need
- A Mac on macOS 14 or newer
- Xcode Command Line Tools (`xcode-select --install`)
- Claude Code

## Install
```sh
git clone https://github.com/JrejL/day-to-calendar.git
cd day-to-calendar
sh install.sh
```
The first time you use it, the helper compiles (about 20 seconds) and macOS asks for calendar access. Click **Allow** once.

## Safety
- Events go only into the "Workday Log" calendar. Your own calendars are never touched.
- Claude shows you every event before writing it.
- Running it twice does not duplicate events.
- To remove everything, delete the "Workday Log" calendar in the Calendar app.
- The calendar syncs to iCloud, so the skill tells Claude to leave out secrets and private details.

## Setup
`install.sh` asks a few quick questions (press Enter to keep the default). If you skip them, Claude asks on first use. Rerun `sh setup.sh` any time to change them.

| Question | Default | Notes |
|---|---|---|
| Calendar name | Workday Log | The separate calendar events go into |
| Color | teal | A name (red, orange, yellow, green, teal, blue, purple, pink, brown, gray) or a hex like `#1A73E8` |
| Event length | all day | Or a number of minutes; then you also pick a start time |
| Longest title | 8 words | Claude keeps titles within this |
| Longest note | 4 sentences | Claude keeps notes within this |

Answers are saved in `~/.config/day-to-calendar/config.json`, which you can also edit by hand. Changing the color updates the existing calendar the next time it runs.

## Why it ships its own tiny app
macOS only shows the calendar permission prompt to an app that declares why it wants access. Claude's app does not, so the request fails silently. `DayCal.app` is built on your Mac from `scripts/daycal.swift`, carries the declaration, and is the only thing that touches your calendar. Read the source; it is about 80 lines.

## License
MIT, by George Murad.
