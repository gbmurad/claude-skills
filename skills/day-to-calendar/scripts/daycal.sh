#!/bin/sh
# daycal.sh <status|request|add events.json>: runs DayCal.app as its own process (so macOS asks and
# remembers calendar access for it, not for whoever called it) and prints what it said.
# Set DAYCAL_CALENDAR to change the calendar name (default "Workday Log").
here=$(cd "$(dirname "$0")" && pwd)
[ -d "$here/DayCal.app" ] || sh "$here/make-app.sh" >/dev/null
out=$(mktemp); err=$(mktemp)
file=""; [ -n "$2" ] && file=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
open -W -n --stdout "$out" --stderr "$err" ${DAYCAL_CALENDAR:+--env "DAYCAL_CALENDAR=$DAYCAL_CALENDAR"} "$here/DayCal.app" --args "${1:-status}" $file 2>/dev/null
# open -W cannot always track a background app, so also wait for the process to finish (up to 15 minutes)
i=0; while pgrep -qf "DayCal.app/Contents/MacOS/DayCal" && [ $i -lt 4500 ]; do sleep 0.2; i=$((i+1)); done
cat "$out" "$err"; rm -f "$out" "$err"
