import Combine
import Foundation
import SwiftUI

class DotInspectionDetailViewModel: ObservableObject {
    @ObservedObject var logsViewModel: LogsViewModel
    @Published var driverName: String = ""
    @Published var driverId: String = "-"
    @Published var coDriverName: String = "-"
    @Published var coDriverId: String = "-"
    @Published var officeAddress: String = ""
    @Published var truckTractor: String = "-"
    @Published var licenseNumber: String = ""
    @Published var licenseState: String = ""
    @Published var eldRegistrationId: String = "-"
    @Published var eldIdentifier: String = "-"
    @Published var provider: String = "Safemiles"

    @Published var exemptDriverStatus: String = "No"
    @Published var unidentifiedDrivingRecords: String = "No"
    @Published var logDate: String = "-"
    @Published var displayDate: String = "-"
    @Published var displayLocation: String = "-"
    @Published var displayCertified: String = "No"
    @Published var periodStartTime: String = "00:00"
    @Published var dataDiagIndicators: String = "No"
    @Published var deviceMalfnIndicators: String = "No"
    @Published var vin: String = "-"
    @Published var odometer: String = "-"
    @Published var engineHours: String = "-"
    @Published var trailers: String = "-"
    @Published var shippingDocs: String = "-"
    @Published var carrier: String = "-"
    @Published var homeTerminal: String = "-"

    @Published var totalMiles: String = "0.0"
    @Published var cycleTotal: String = "00:00"

    var dotInspectionDates: [Date] {
        let allDates = logsViewModel.availableDates
        return Array(allDates.suffix(8))
    }

    @Published var statusTotals: [DutyStatus: Int] = [:]  // Seconds

    private var cancellables = Set<AnyCancellable>()

    init(logsViewModel: LogsViewModel) {
        self.logsViewModel = logsViewModel
        setupProfileData()
        setupLogsObservation()
        calculateTotals()
    }

    private func setupProfileData() {
        if driverName.isEmpty {  // Only if not already set by a log
            if let profile = Global.shared.myProfile {
                self.driverName =
                    "\(profile.user?.first_name ?? "") \(profile.user?.last_name ?? "")"
                    .trimmingCharacters(in: .whitespaces)
                self.driverId = profile.user?.email ?? "-"
                self.exemptDriverStatus = (profile.log_setting_exempt ?? false) ? "Yes" : "No"

                let addr = profile.home_terminal_addr
                var address = ""
                if let line = addr?.address_line, !line.isEmpty { address += line }
                if let city = addr?.city, !city.isEmpty {
                    address += (address.isEmpty ? "" : ", ") + city
                }
                if let state = addr?.state, !state.isEmpty {
                    address += (address.isEmpty ? "" : ", ") + state
                }
                if let zip = addr?.postal_code, !zip.isEmpty {
                    address += (address.isEmpty ? "" : " ") + zip
                }
                self.officeAddress = address
                self.homeTerminal = address

                self.periodStartTime = addr?.period_start_time ?? "00:00"
                self.carrier = profile.company?.name ?? "-"
                self.licenseNumber = profile.license_number ?? ""
                self.licenseState = profile.license_state ?? ""
            }
        }
    }

    private func setupLogsObservation() {
        logsViewModel.$dutySegments
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.calculateTotals()
            }
            .store(in: &cancellables)

        logsViewModel.$currentLog
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateLogData()
            }
            .store(in: &cancellables)
    }

    private func updateLogData() {
        guard let log = logsViewModel.currentLog else { return }

        // Date formatting
        let df = DateFormatter()
        df.timeZone = getAppTimeZone()
        df.dateFormat = "MMMM d, yyyy"
        self.logDate = df.string(from: logsViewModel.selectedDate)
        self.displayDate = self.logDate

        // Driver Info from Log
        if let driver = log.log?.driver {
            self.driverName =
                "\(driver.first_name ?? "") \(driver.last_name ?? "")".trimmingCharacters(
                    in: .whitespaces
                ).isEmpty ? driverName : "\(driver.first_name ?? "") \(driver.last_name ?? "")"
            self.driverId = driver.email ?? driverId
            self.licenseNumber = driver.license_number ?? licenseNumber
            self.licenseState = driver.license_state ?? licenseState
            self.exemptDriverStatus = (driver.log_setting_exempt ?? false) ? "Yes" : "No"
            self.carrier = driver.company?.name ?? carrier
        }

        // Co-Driver from Log
        self.coDriverName = "-"
        self.coDriverId = "-"
        if let coDriver = log.log?.co_driver {
            self.coDriverName = "\(coDriver.first_name ?? "") \(coDriver.last_name ?? "")"
                .trimmingCharacters(in: .whitespaces)
            self.coDriverId = coDriver.id ?? "-"
        }

        // Vehicle & ELD from Log
        self.truckTractor = log.vehicle?.unit_number ?? truckTractor
        self.vin = log.vehicle?.vin ?? vin
        self.eldRegistrationId = log.eld_registration ?? eldRegistrationId
        self.eldIdentifier = log.eld_identifier ?? eldIdentifier
        self.provider = log.provider ?? provider

        // Indicators
        self.unidentifiedDrivingRecords = log.unidentified_records ?? "No"
        self.dataDiagIndicators = log.diagnose_indicator ?? "No"
        self.deviceMalfnIndicators = log.malfunctioning ?? "No"
        self.periodStartTime = log.period_starting_time_24 ?? periodStartTime

        // Home Terminal from Log
        if let ht = log.home_terminal {
            var address = ""
            if let line = ht.address_line, !line.isEmpty { address += line }
            if let city = ht.city, !city.isEmpty { address += (address.isEmpty ? "" : ", ") + city }
            if let state = ht.state, !state.isEmpty {
                address += (address.isEmpty ? "" : ", ") + state
            }
            if let zip = ht.postal_code, !zip.isEmpty {
                address += (address.isEmpty ? "" : " ") + zip
            }
            if !address.isEmpty {
                self.homeTerminal = address
                self.officeAddress = address
            }
        }

        self.displayCertified = (log.log?.certified ?? false) ? "Yes" : "No"
        self.trailers = log.log?.trailers ?? "-"
        self.shippingDocs = log.log?.shipping_docs ?? "-"

        if let events = log.events, let lastEvent = events.last {
            // Use log level odometer/engine hours if available, else last event
            self.odometer =
                log.odometer != nil
                ? "\(log.odometer!)"
                : String(format: "%.0f", Double(lastEvent.odometer ?? 0) ?? 0)
            self.engineHours =
                log.engine_hours != nil
                ? "\(log.engine_hours!)"
                : String(format: "%.1f", Double(lastEvent.engine_hours ?? "0") ?? 0)

            if let firstEvent = events.first {
                self.displayLocation = firstEvent.location_notes ?? "-"
            }
        } else {
            self.odometer = log.odometer != nil ? "\(log.odometer!)" : "-"
            self.engineHours = log.engine_hours != nil ? "\(log.engine_hours!)" : "-"
        }

        calculateTotals()
    }

    func calculateTotals() {
        var totals: [DutyStatus: Int] = [
            .off: 0,
            .sleeper: 0,
            .driving: 0,
            .on: 0,
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
                currentOdo = Double(Global.shared.odometer) ?? 0
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

        let totalCycleSeconds =
            totals[.driving, default: 0] + totals[.on, default: 0] + totals[.sleeper, default: 0]
            + totals[.off, default: 0]
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
        if let date = formatter.date(from: isoString)
            ?? ISO8601DateFormatter().date(from: isoString)
        {
            let df = DateFormatter()
            df.timeZone = getAppTimeZone()
            df.dateFormat = "hh:mm a"
            return df.string(from: date)
        }
        return "-"
    }
}
