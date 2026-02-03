import Foundation

func secondsToHoursMinutes(_ seconds: Int) -> String {
    let hrs = seconds / 3600
    let mins = (seconds % 3600) / 60
    return String(format: "%02d:%02d", hrs, mins)
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
    // Handle fractional seconds if present
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    var date = formatter.date(from: isoString)
    if date == nil {
        // Try without fractional seconds
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
    formatter.dateFormat = "HH:mm:ss"
    return formatter.string(from: date)
}

func getOnlyDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func getDayName(from dateString: String) -> String {
    let formatter = DateFormatter()
    // Attempt common formats
    let formats = ["yyyy-MM-dd", "MM-dd-yyyy", "dd-MMM"] // Add more if needed based on API
    
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
