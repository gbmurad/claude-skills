// daycal.swift: writes one all day event per worked day into a dedicated Apple Calendar, through EventKit.
//   daycal status              -> the calendar access macOS has granted
//   daycal request             -> asks macOS for full calendar access (click Allow once)
//   daycal add <events.json>   -> writes the events, skipping any with the same title on the same day
// events.json: [{"date": "2026-09-24", "title": "...", "notes": "..."}]
// Everything goes into one calendar (default name "Workday Log"), so you can
// hide or delete it in one go and it never mixes with your own events.
import EventKit
import Foundation

let store = EKEventStore()
let args = CommandLine.arguments

// Settings live in ~/.config/day-to-calendar/config.json (written by setup.sh); DAYCAL_* env vars override.
let cfgPath = NSHomeDirectory() + "/.config/day-to-calendar/config.json"
let cfg = (FileManager.default.contents(atPath: cfgPath).flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }) ?? [:]
let env = ProcessInfo.processInfo.environment
let calendarName = env["DAYCAL_CALENDAR"] ?? (cfg["calendar"] as? String) ?? "Workday Log"
let colorSetting = env["DAYCAL_COLOR"] ?? (cfg["color"] as? String) ?? "teal"
let allDay = (cfg["all_day"] as? Bool) ?? true
let startTime = (cfg["start_time"] as? String) ?? "17:00"      // used when all_day is false
let minutes = (cfg["duration_minutes"] as? Int) ?? 60          // used when all_day is false

func parseColor(_ s: String) -> CGColor {
    let named: [String: String] = ["red": "E5484D", "orange": "F76B15", "yellow": "F5C400", "green": "30A46C",
        "teal": "21A08C", "blue": "0090FF", "purple": "8E4EC6", "pink": "E93D82", "brown": "A18072", "gray": "8B8D98"]
    var hex = (named[s.lowercased()] ?? s).replacingOccurrences(of: "#", with: "")
    if hex.count != 6 { hex = "21A08C" }
    let v = UInt32(hex, radix: 16) ?? 0x21A08C
    return CGColor(red: CGFloat((v >> 16) & 255) / 255, green: CGFloat((v >> 8) & 255) / 255, blue: CGFloat(v & 255) / 255, alpha: 1)
}

func statusWord() -> String {
    switch EKEventStore.authorizationStatus(for: .event) {
    case .notDetermined: return "notDetermined"
    case .restricted: return "restricted"
    case .denied: return "denied"
    case .fullAccess: return "fullAccess"
    case .writeOnly: return "writeOnly"
    case .authorized: return "authorized"
    @unknown default: return "unknown"
    }
}

func workCalendar() -> EKCalendar? {
    if let found = store.calendars(for: .event).first(where: { $0.title == calendarName }) {
        let want = parseColor(colorSetting)
        if found.cgColor != want && found.allowsContentModifications { found.cgColor = want; try? store.saveCalendar(found, commit: true) }
        return found
    }
    let cal = EKCalendar(for: .event, eventStore: store)
    cal.title = calendarName
    cal.cgColor = parseColor(colorSetting)
    let sources = store.sources
    cal.source = sources.first(where: { $0.sourceType == .calDAV && $0.title.lowercased().contains("icloud") })
        ?? store.defaultCalendarForNewEvents?.source
        ?? sources.first(where: { $0.sourceType == .local })
    do { try store.saveCalendar(cal, commit: true); return cal } catch { print("could not make the \(calendarName) calendar: \(error)"); return nil }
}

let cmd = args.count > 1 ? args[1] : "status"
if cmd == "status" {
    print(statusWord())
} else if cmd == "request" {
    let sem = DispatchSemaphore(value: 0)
    store.requestFullAccessToEvents { granted, error in
        print(granted ? "granted" : "not granted \(String(describing: error))")
        sem.signal()
    }
    _ = sem.wait(timeout: .now() + 900)
} else if cmd == "add" {
    guard args.count > 2, let data = FileManager.default.contents(atPath: args[2]),
          let list = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] else {
        print("usage: add <events.json>"); exit(1)
    }
    guard let cal = workCalendar() else { exit(1) }
    let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"; fmt.timeZone = TimeZone.current
    var added = 0, skipped = 0
    for e in list {
        guard let day = fmt.date(from: e["date"] ?? ""), let title = e["title"] else { continue }
        let end = Calendar.current.date(byAdding: .day, value: 1, to: day)!
        let existing = store.events(matching: store.predicateForEvents(withStart: day, end: end, calendars: [cal]))
        if existing.contains(where: { $0.title == title }) { skipped += 1; continue }
        let ev = EKEvent(eventStore: store)
        ev.calendar = cal
        ev.title = title
        ev.notes = e["notes"]
        if allDay {
            ev.isAllDay = true
            ev.startDate = day
            ev.endDate = day
        } else {
            let hm = startTime.split(separator: ":").compactMap { Int($0) }
            let start = Calendar.current.date(bySettingHour: hm.first ?? 17, minute: hm.count > 1 ? hm[1] : 0, second: 0, of: day) ?? day
            ev.startDate = start
            ev.endDate = start.addingTimeInterval(TimeInterval(minutes * 60))
        }
        do { try store.save(ev, span: .thisEvent, commit: false); added += 1 } catch { print("failed \(e["date"] ?? ""): \(error)") }
    }
    do { try store.commit() } catch { print("commit failed: \(error)") }
    print("added \(added), already there \(skipped), calendar \(cal.title) on \(cal.source?.title ?? "?")")
} else {
    print("unknown command \(cmd); use status, request or add <events.json>"); exit(1)
}
