import SwiftUI
import Combine
import Foundation

class DotInspectionDetailViewModel: ObservableObject {
    @ObservedObject var logsViewModel: LogsViewModel
    @Published var driverName: String = ""
    @Published var coDriverName: String = "-"
    @Published var officeAddress: String = ""
    @Published var truckTractor: String = "-"
    @Published var licenseNumber: String = ""
    @Published var licenseState: String = ""
    @Published var eldRegistrationId: String = "-"
    @Published var provider: String = "Safemiles"
    
    @Published var totalMiles: String = "0.0"
    @Published var cycleTotal: String = "00:00"
    
    @Published var statusTotals: [DutyStatus: Int] = [:] // Seconds
    
    private var cancellables = Set<AnyCancellable>()
    
    init(logsViewModel: LogsViewModel) {
        self.logsViewModel = logsViewModel
        setupProfileData()
        setupLogsObservation()
        calculateTotals()
    }
    
    private func setupProfileData() {
        if let profile = Global.shared.myProfile {
            self.driverName = "\(profile.user?.first_name ?? "") \(profile.user?.last_name ?? "")".trimmingCharacters(in: .whitespaces)
            self.coDriverName = "-" // Can be updated if co-driver logic is available
            
            // Office Address
            let addr = profile.home_terminal_addr
            var address = ""
            if let line = addr?.address_line, !line.isEmpty { address += line }
            if let city = addr?.city, !city.isEmpty { address += (address.isEmpty ? "" : ", ") + city }
            if let state = addr?.state, !state.isEmpty { address += (address.isEmpty ? "" : ", ") + state }
            if let zip = addr?.postal_code, !zip.isEmpty { address += (address.isEmpty ? "" : " ") + zip }
            self.officeAddress = address
            
            self.truckTractor = profile.vehicle?.vehicle_id ?? "-"
            self.licenseNumber = profile.license_number ?? ""
            self.licenseState = profile.license_state ?? ""
        }
    }
    
    private func setupLogsObservation() {
        logsViewModel.$dutySegments
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.calculateTotals()
            }
            .store(in: &cancellables)
    }
    
    func calculateTotals() {
        var totals: [DutyStatus: Int] = [
            .off: 0,
            .sleeper: 0,
            .driving: 0,
            .on: 0,
            .login: 0,
            .yardMove: 0
        ]
        var totalDistance: Double = 0.0
        
        // Duration Calculation using precise seconds from events if possible
        // but dutySegments already covers the whole day including gaps.
        for segment in logsViewModel.dutySegments {
            let durationSeconds = Int(round((segment.endHour - segment.startHour) * 3600))
            if segment.status.rawValue == "ym" {
                totals[DutyStatus.on, default: 0] += durationSeconds
            } else {
                totals[segment.status, default: 0] += durationSeconds
            }
        }
        
        // Distance Calculation
        if let events = logsViewModel.currentLog?.events, let firstEvent = events.first {
            let startOdo = firstEvent.last_odometer ?? firstEvent.odometer ?? 0
            var currentOdo: Double = 0
            
            if Calendar.current.isDateInToday(logsViewModel.selectedDate) {
                currentOdo = Double(Global.shared.odometer ?? "0") ?? 0
                // If currentOdo is 0 or less than startOdo, fallback to last event odometer
                if currentOdo <= startOdo {
                    currentOdo = events.last?.odometer ?? startOdo
                }
            } else {
                currentOdo = events.last?.odometer ?? startOdo
            }
            
            totalDistance = max(0, currentOdo - startOdo)
        }
        
        self.statusTotals = totals
        self.totalMiles = String(format: "%.1f", totalDistance)
        
        let totalCycleSeconds = totals[.driving, default: 0] + totals[.on, default: 0] + totals[.sleeper, default: 0] + totals[.off, default: 0]
        self.cycleTotal = secondsToHoursMinutes(totalCycleSeconds)
    }
    
    func formatDuration(seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        return String(format: "%d:%02d", hrs, mins)
    }
    
    func getStatusTitle(_ status: DutyStatus) -> String {
        switch status {
        case DutyStatus.off: return "Off Duty"
        case DutyStatus.sleeper: return "Sleeper"
        case DutyStatus.driving: return "Driving"
        case DutyStatus.on: return "On Duty"
        case DutyStatus.login: return "Login"
        case DutyStatus.yardMove: return "Yard Move"
        }
    }
    
    func formatDisplayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = getAppTimeZone()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    func formatTime(_ isoString: String?) -> String {
        guard let isoString = isoString else { return "-" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: isoString) ?? ISO8601DateFormatter().date(from: isoString) {
            let df = DateFormatter()
            df.timeZone = getAppTimeZone()
            df.dateFormat = "hh:mm a"
            return df.string(from: date)
        }
        return "-"
    }
}
