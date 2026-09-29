#!/bin/sh
# setup.sh: asks a few questions and saves your answers to ~/.config/day-to-calendar/config.json.
# Press Enter to accept the value in [brackets]. Run it again any time to change your answers.
dir="$HOME/.config/day-to-calendar"; mkdir -p "$dir"
ask() { printf "%s [%s]: " "$1" "$2" >&2; read -r a; a="${a:-$2}"; printf "%s" "$a" | tr -d "\"\\\\"; echo; }
echo "day-to-calendar setup" >&2
cal=$(ask "Calendar name" "Workday Log")
color=$(ask "Calendar color (red, orange, yellow, green, teal, blue, purple, pink, brown, gray, or a hex like #1A73E8)" "teal")
len=$(ask "Event length: 'allday' or a duration in minutes (for example 30 or 60)" "allday")
start="17:00"; mins=60; allday=true
case "$len" in allday|"") ;; *[!0-9]*) echo "Not a number, using all day." >&2 ;; *) allday=false; mins=$len; start=$(ask "What time should it start (24 hour, like 17:00)" "17:00") ;; esac
words=$(ask "Longest title, in words" "8")
sent=$(ask "Longest note, in sentences" "4")
cat > "$dir/config.json" <<JSON
{
  "calendar": "$cal",
  "color": "$color",
  "all_day": $allday,
  "start_time": "$start",
  "duration_minutes": $mins,
  "title_max_words": $words,
  "notes_max_sentences": $sent
}
JSON
echo "Saved to $dir/config.json" >&2
