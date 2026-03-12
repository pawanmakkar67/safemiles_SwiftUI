
import SwiftUI
import Combine

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
            
            self.truckTractor = profile.vehicle?.id ?? "-"
            self.licenseNumber = profile.license_number ?? ""
            self.licenseState = profile.license_state ?? ""
        }
    }
    
    private func setupLogsObservation() {
        logsViewModel.$currentLog
            .sink { [weak self] _ in
                self?.calculateTotals()
            }
            .store(in: &cancellables)
    }
    
    func calculateTotals() {
        var totals: [DutyStatus: Int] = [.off: 0, .sleeper: 0, .driving: 0, .on: 0]
        var totalDistance: Double = 0.0
        
        for segment in logsViewModel.dutySegments {
            let durationSeconds = Int((segment.endHour - segment.startHour) * 3600)
            totals[segment.status, default: 0] += durationSeconds
        }
        
        // Distance Calculation (requires odometer difference from events)
        if let events = logsViewModel.currentLog?.events {
            // Usually, distance is calculated from odometer diffs between consecutive events
            // but for a day it's often total odometer at end - total at start
            if let firstOdo = events.first?.odometer, let lastOdo = events.last?.odometer {
                totalDistance = lastOdo - firstOdo
            }
        }
        
        self.statusTotals = totals
        self.totalMiles = String(format: "%.1f", totalDistance)
        
        let totalCycleSeconds = totals.values.reduce(0, +)
        self.cycleTotal = secondsToHoursMinutes(totalCycleSeconds)
    }
    
    func formatDuration(seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        return String(format: "%d:%02d", hrs, mins)
    }
    
    func getStatusTitle(_ status: DutyStatus) -> String {
        switch status {
        case .off: return "Off Duty"
        case .sleeper: return "Sleeper"
        case .driving: return "Driving"
        case .on: return "On Duty"
        }
    }
}
