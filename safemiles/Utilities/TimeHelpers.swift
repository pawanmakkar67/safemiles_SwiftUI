import Foundation



// Helper to get the preferred TimeZone
func getAppTimeZone() -> TimeZone {
    let identifier = UserDefaults.getTimezone()
    return TimeZone(identifier: identifier) ?? TimeZone.current
}

func getAbbreviation(_ TZ: TimeZone?) -> String {
    guard let tz = TZ else { return "" }
    
    let abbreviation = tz.abbreviation() ?? ""
    
    // If it's already a nice abbreviation (not generic GMT offset), use it.
    // However, sometimes "GMT" is returned for UTC.
    // The user specifically wants to map GMT-based offsets to civilian codes.
    if abbreviation.hasPrefix("GMT") || abbreviation == "UTC" {
        // Calculate offset in hours
        let seconds = tz.secondsFromGMT()
        // We use the base offset or current offset?
        // User map is seemingly based on Standard Time offsets.
        // e.g. GMT-6 is CST.
        // If we are currently in DST, the offset might be -5 hours for Central Time?
        // Wait, TimeZone.secondsFromGMT() returns the CURRENT offset (including DST).
        // If I am in CDT, offset is -18000 (-5 hours).
        // If I am in CST, offset is -21600 (-6 hours).
        
        // This makes lookup tricky if I strictly use the table which says "GMT-6 = CST".
        // Use isDaylightSavingTime() to adjust?
        
        let isDST = tz.isDaylightSavingTime()
        var offsetHours = seconds / 3600
        
        // If DST is active, the table's "Standard" offset would be one hour less (more negative) for West, one hour less (less positive) for East?
        // Actually: CST is UTC-6. CDT is UTC-5.
        // If current offset is -5 and isDST is true, then Standard offset is -6.
        // So: StandardOffset = CurrentOffset - (isDST ? 1 : 0) ?
        
        // For Western hemisphere (negative offsets):
        // CDT (-5) -> CST (-6). (-5 - 1 = -6). Correct.
        // EDT (-4) -> EST (-5). (-4 - 1 = -5). Correct.
        
        // For Eastern hemisphere (positive offsets):
        // CEST (+2) -> CET (+1). (2 - 1 = 1). Correct.
        
        if isDST {
            offsetHours -= 1
        }
        
        switch offsetHours {
        // West
        case -4: return isDST ? "ADT" : "AST"
        case -5: return isDST ? "EDT" : "EST"
        case -6: return isDST ? "CDT" : "CST"
        case -7: return isDST ? "MDT" : "MST"
        case -8: return isDST ? "PDT" : "PST"
        case -9: return isDST ? "AKDT" : "AKST"
        case -10: return "HST" // Hawaii usually no DST
        case -11: return "NT"
            
        // East
        case 0: return "GMT"
        case 1: return isDST ? "CEST" : "CET"
        case 2: return isDST ? "EEST" : "EET"
        case 3: return "MSK"
        case 4: return "AMT"
        case 5: return "IST"
        case 6: return "OMSK"
        case 7: return "KRAT"
        case 8: return "CST" // China Standard Time
        case 9: return "JST"
        case 10: return "AEST"
        case 11: return "SAKT"
        case 12: return "NZST"
            
        default: return abbreviation // Fallback to whatever it was
        }
    }
    
    return abbreviation
}

func secondsToHoursMinutes(_ seconds: Int) -> String {
    let hrs = seconds / 3600
    let mins = (seconds % 3600) / 60
    return String(format: "%02d:%02d", hrs, mins)
}

/// Converts seconds to hours and minutes as separate integer values
/// - Parameter seconds: The total number of seconds
/// - Returns: A tuple containing (hours, minutes)
func convertSecondsToHoursAndMinutes(_ seconds: Int) -> (hours: Int, minutes: Int) {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    return (hours, minutes)
}

func convertTimeToSeconds(timeString: String) -> Int? {
    let components = timeString.components(separatedBy: ":")
    guard components.count == 2,
          let hours = Int(components[0]),
          let minutes = Int(components[1]) else {
        return nil
    }
    return (hours * 3600) + (minutes * 60)
}

struct HMSResult {
    let hours: Int
    let minutes: Int
    let seconds: Int
    let isPast: Bool
    let absSeconds: Int
}

func differenceHMSFromNow(isoString: String) -> HMSResult? {
    let formatter = ISO8601DateFormatter()
    // ISO8601 strings usually have TZ info, but for diffing "now", we compare absolute times.
    // However, if the ISO string lacks TZ, we might need to assume App TZ.
    // Standard ISO8601DateFormatter handles TZ in string well.
    // For "Now", we use Date(), which is absolute.
    // So strictly speaking, timezone primarily affects DISPLAY of dates, not difference between two absolute instants.
    // But let's ensure the formatter is set up correctly just in case.
    formatter.timeZone = getAppTimeZone()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    var date = formatter.date(from: isoString)
    if date == nil {
        formatter.formatOptions = [.withInternetDateTime]
        date = formatter.date(from: isoString)
    }
    
    guard let eventDate = date else { return nil }
    
    let diff = Date().timeIntervalSince(eventDate)
    let absDiff = Int(abs(diff))
    
    let hours = absDiff / 3600
    let minutes = (absDiff % 3600) / 60
    let seconds = absDiff % 60
    
    return HMSResult(hours: hours, minutes: minutes, seconds: seconds, isPast: diff > 0, absSeconds: absDiff)
}

func getOnlyTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = getAppTimeZone()
    formatter.dateFormat = "HH:mm:ss"
    return formatter.string(from: date)
}

func getOnlyDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = getAppTimeZone()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func getDayName(from dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = getAppTimeZone()
    // Attempt common formats
    let formats = ["yyyy-MM-dd", "MM-dd-yyyy", "dd-MMM"]
    
    for format in formats {
        formatter.dateFormat = format
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "EEEE" // Full day name
            return formatter.string(from: date)
        }
    }
    return dateString // Fallback
}

func getFormattedDate(from dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = getAppTimeZone()
    let formats = ["yyyy-MM-dd", "MM-dd-yyyy"] // Input formats
    
    for format in formats {
        formatter.dateFormat = format
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "dd-MMM" // Desired output format
            return formatter.string(from: date)
        }
    }
    return dateString // Fallback
}
