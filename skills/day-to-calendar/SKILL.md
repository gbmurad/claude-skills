---
name: day-to-calendar
description: Writes a short summary of each day you worked with Claude into its own Apple Calendar, so you can look back and see what happened on any date. Use when the user says log today, add my day to the calendar, backfill my calendar, or what did we do on a past day. macOS only.
---

# day-to-calendar: one calendar event per worked day

**Done =** each requested day has one all day event in the configured calendar, and the tool's output line confirms how many were added.

## Procedure
0. Settings live in `~/.config/day-to-calendar/config.json`. If that file is missing, run setup first: ask the user these six things (offer the default in brackets), then write the file with the keys shown, or tell them they can run `sh scripts/setup.sh` themselves.
   - Calendar name ["Workday Log"] → `calendar`
   - Color [teal]: red, orange, yellow, green, teal, blue, purple, pink, brown, gray, or a hex → `color`
   - Event length [all day] or a number of minutes → `all_day` (true/false), `duration_minutes`, and `start_time` like "17:00" if timed
   - Longest title [8 words] → `title_max_words`
   - Longest note [4 sentences] → `notes_max_sentences`
   Read the file on every run and obey the length limits when drafting.
1. Pick the days. Default is today. For a backfill, ask which dates, or use the days that have git commits or session history.
2. Gather what happened per day. Use, in this order: the current conversation, `git log --since="<date> 00:00" --until="<date> 23:59" --oneline` in the working repo, and any notes the user points to. Do not invent work you cannot see.
3. Write one event per day: a title within `title_max_words` (default 8) naming the main outcome, and notes within `notes_max_sentences` (default 4) in plain language on what was done, decided, and left open.
4. Leave out secrets, keys, passwords, balances, and private details of other people. The calendar syncs to iCloud.
5. Show the user the events and wait for a yes. The calendar is theirs.
6. Save them as `/tmp/day-events.json` in this shape:
   `[{"date":"2026-09-24","title":"Shipped the login fix","notes":"..."}]`
7. Check access: `sh scripts/daycal.sh status`. If it says `notDetermined`, run `sh scripts/daycal.sh request` and tell the user to click Allow in the macOS dialog. If it says `denied`, point them to System Settings, Privacy and Security, Calendars.
8. Write: `sh scripts/daycal.sh add /tmp/day-events.json`. Report the output line as printed.

## Guardrails
- Events go only into the dedicated calendar (the `calendar` setting, default "Workday Log"). Never touch the user's other calendars.
- Running twice is safe: an event with the same title on the same day is skipped.
- To undo everything, the user deletes that one calendar in the Calendar app.
- The first run compiles the helper and needs Xcode Command Line Tools (`xcode-select --install`). macOS 14 or newer.

## Related
The helper source is `scripts/daycal.swift`. Rebuild with `sh scripts/make-app.sh` after editing it.
