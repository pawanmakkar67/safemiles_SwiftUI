import Alamofire
import Combine
import CoreBluetooth
import ObjectMapper
import SwiftUI
import CoreLocation

#if !targetEnvironment(simulator)
    import PacificTrack
#endif

class HomeViewModel: ObservableObject {
    let id = UUID().uuidString // ID for tracking model instances
    @Published var circleBorderColor: Color = .gray.opacity(0.2)
    @Published var driveValue: String = "00:00"
    @Published var shiftValue: String = "00:00"
    @Published var cycleValue: String = "00:00"
    @Published var breakValue: String = "00:00"
    @Published var currentStatus: String = "OFF"
    @Published var timerString: String = "00:00"
    @Published var recapDays: [Recap_days] = []

    // Recap Summary
    @Published var totalRecapHours: String = "0.00"
    @Published var hoursWorkedToday: String = "0.00"
    @Published var hoursAvailableToday: String = "0.00"
    @Published var hoursAvailableTomorrow: String = "0.00"
    @Published var todayDateStr: String = ""
    @Published var tomorrowDateStr: String = ""

    @Published var currentCode: String = "off"
    @Published var vehicle: String = ""
    @Published var driver: String = ""
    // Removed headerTitle as it's now handled by direct Global observation in View

    // Drive Progress (0.0 to 1.0 for circular progress bar)
    @Published var driveProgress: Double = 0.0

    // Status Update Modal
    @Published var showStatusUpdateModal: Bool = false
    @Published var selectedStatusUpdateCode: String = ""
    @Published var event_notes: String = ""

    // Timer Logic
    private var timer: Timer?
    private var countdown = FlexibleTimer(totalSeconds: 0)
    /// Pending deferred fetchRecap after a hardware update. Cancelled if another update arrives.
    private var pendingRecapWorkItem: DispatchWorkItem?

    // Status Logic
    private var speedStateCounter = 0
    private var lastSpeedState: SpeedState?
    private var lastIMEventTime: Date?
    private var manualChange: String = ""
    private var lastHardwareUpdateTime: Date?
    private var lastHardwareUpdateCode: String?
    private var lastApiCallTimes: [String: Date] = [:]

    /// Minimum seconds that must pass before the same API can be called again.
    /// Adjust per-endpoint here — no need to hunt through individual functions.
    private let apiThrottleIntervals: [String: TimeInterval] = [
        ApiList.RecapApi:          30,   // recap — heavy, once per 30s is enough
        ApiList.getLogs:           60,   // live status/logs — driven by polling timer
        ApiList.allvehicles:       60,   // vehicles list rarely changes
        ApiList.getCoDrivers:      60,   // co-drivers list rarely changes
        ApiList.getMyprofile:      60,   // profile — almost never changes
    ]

    // Speed tracking
    @Published var speed: String = "0"

    // BLE Manager reference
    private let ble = BLEManager.shared

    // Speed State Enum
    enum SpeedState {
        case low
        case high
    }

    init() {
        LocationManager.shared.startUpdatingLocation()
        startPolling()

        // Initialize Countdown Tick Handler
        countdown.start(tick: { [weak self] remaining in
            DispatchQueue.main.async {
                self?.timerString = secondsToHoursMinutes(remaining)
            }
        })

        // Notification Observers
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRecapRefresh), name: .requestRecapRefresh, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRecapUpdate), name: .recapUpdate, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleVehicleUpdate), name: .vehicleUpdate, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleLogout),
            name: NSNotification.Name("LogoutNotification"), object: nil)
    }

    @objc func handleVehicleUpdate() {
    }

    @objc func handleProfileUpdate() {
    }

    @objc func handleRecapRefresh() {
        AppLog.debug("HomeViewModel: Received requestRecapRefresh notification")
        fetchRecap(force: true)
    }

    @objc func handleRecapUpdate() {
        AppLog.debug("HomeViewModel: Received recapUpdate notification")
        // No fetchRecap() here to avoid loop.
        // Just update local UI from Global if needed,
        // though fetchRecap already calls updateData.
        // This handles updates from other ViewModels.
        if let obj = Global.shared.recapvalues {
            DispatchQueue.main.async {
                self.updateData(obj)
                self.updateEvents()
            }
        }

        Task {
//            await getLiveStatus()
//            await getVehciles()  // Refresh vehicles too if needed, but status is key
        }
    }

    deinit {
        stopPolling()
        pendingRecapWorkItem?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    func onAppear() {
        fetchRecap()
        getMyProfile()
    Task {
            await getLiveStatus()
            await getVehciles()
            await getCoDrivers()
        }
        // Here you would also initialize BLE scanning if needed,
        // referencing BLEManager.shared logic from StatusVC
    }

    @Published var allViolations: [Violation] = []
    @Published var showViolationsSheet: Bool = false

    // ... (rest of the file) ...

    func getLiveStatus() {
        let urlStr = ApiList.getLogs
        let throttle = apiThrottleIntervals[urlStr] ?? 60
        if let lastTime = lastApiCallTimes[urlStr], Date().timeIntervalSince(lastTime) < throttle { return }
        lastApiCallTimes[urlStr] = Date()

//        let page = ((Global.shared.logsDataVal?.logs?.count ?? 0) / 10) + 1
//        let params = ["page": page]

        APIManager.shared.request(url: ApiList.getLogs, method: .get) { comp in
            // completion
        } success: { response in

            guard let obj = Mapper<logsModel>().map(JSONObject: response) else { return }

//            if page != 1, let newLogs = obj.logs {
//                Global.shared.logsDataVal?.logs?.append(contentsOf: newLogs)
//            } else {
                Global.shared.logsDataVal = obj
//            }

        } failure: { error in

        }
    }

    func getVehciles() async {
        let urlStr = ApiList.allvehicles
        let throttle = apiThrottleIntervals[urlStr] ?? 60
        if let lastTime = lastApiCallTimes[urlStr], Date().timeIntervalSince(lastTime) < throttle { return }
        lastApiCallTimes[urlStr] = Date()

        APIManager.shared.request(url: ApiList.allvehicles, method: .get) { comp in

        } success: { response in

            let obj = Mapper<vehicleModel>().map(JSONObject: response)
            Global.shared.vehicleList = obj?.data ?? []
            //            if Global.shared.vehicleList.count > 0 {
            //                DispatchQueue.main.async {
            //                    self.vehicle = Global.shared.vehicleList[0].id ?? ""
            //                }
            //            }
        } failure: { error in

        }
    }

    func getCoDrivers() async {
        let urlStr = ApiList.getCoDrivers
        let throttle = apiThrottleIntervals[urlStr] ?? 60
        if let lastTime = lastApiCallTimes[urlStr], Date().timeIntervalSince(lastTime) < throttle { return }
        lastApiCallTimes[urlStr] = Date()

        APIManager.shared.request(url: ApiList.getCoDrivers, method: .get) { comp in

        } success: { response in
            let obj = Mapper<CoDriverModel>().map(JSONObject: response)
            Global.shared.coDriverList = obj?.data
        } failure: { error in

        }
    }

    func getMyProfile(completion: (() -> Void)? = nil) {
        let urlStr = ApiList.getMyprofile
        let throttle = apiThrottleIntervals[urlStr] ?? 60
        if let lastTime = lastApiCallTimes[urlStr], Date().timeIntervalSince(lastTime) < throttle {
            completion?()
            return
        }
        lastApiCallTimes[urlStr] = Date()

        APIManager.shared.request(url: ApiList.getMyprofile, method: .get) { comp in
            completion?()
        } success: { response in

            let obj = Mapper<ProfileModel>().map(JSONObject: response)
            Global.shared.myProfile = obj?.data
            DispatchQueue.main.async {
                self.driver = Global.shared.myProfile?.id ?? ""
                NotificationCenter.default.post(name: .profileUpdate, object: nil)
            }
        } failure: { error in
         }

    }

    func getMyProfileAsync() async {
        await withCheckedContinuation { continuation in
            getMyProfile {
                continuation.resume()
            }
        }
    }

    func refreshData() async {
        await withCheckedContinuation { continuation in
            fetchRecap {
                continuation.resume()
            }
        }
        await getLiveStatus()
        await getVehciles()
        await getCoDrivers()
    }

    func fetchRecap(force: Bool = false, completion: (() -> Void)? = nil) {
        let urlStr = ApiList.RecapApi
        let throttle = apiThrottleIntervals[urlStr] ?? 30
        if !force, let lastTime = lastApiCallTimes[urlStr], Date().timeIntervalSince(lastTime) < throttle {
            completion?()
            return
        }
        // Stamp now so all subsequent callers measure from this point.
        lastApiCallTimes[urlStr] = Date()

        APIManager.shared.request(url: ApiList.RecapApi, method: .get, parameters: nil) { comp in
            completion?()
        } success: { response in
            if let obj = Mapper<RecapModel>().map(JSONObject: response) {
                Global.shared.recapvalues = obj
//                DispatchQueue.main.async {
//                    self.updateData(obj)
//                }
                NotificationCenter.default.post(name: .recapUpdate, object: nil)
            }
        } failure: { error in
            AppLog.debug("Recap fetch failed: \(String(describing: error))")
        }
    }

    func updateData(_ data: RecapModel?) {
        guard let data = data else { return }

        // Update Status and Circle Color
        let code = data.last_event?.code?.lowercased() ?? "off"
        self.currentCode = code
        self.currentStatus = getTitles(code)
        updateCircleStatus(code: code)
        self.recapDays = data.recap_days ?? []
        self.allViolations = data.violations ?? []

        if let lastEventVehicle = data.last_event?.vehicle {
            self.vehicle = lastEventVehicle
        }

        // Populate Summary

        // Convert hours_worked from hh:mm:ss to hh:mm
        if let hoursWorked = data.hours_worked {
            let components = hoursWorked.components(separatedBy: ":")
            if components.count >= 2 {
                self.hoursAvailableToday = "\(components[0]):\(components[1])"
            } else {
                self.hoursAvailableToday = hoursWorked
            }
        } else {
            self.hoursAvailableToday = "00:00"
        }

        if let hoursWorked = data.hours_available {
            let components = hoursWorked.components(separatedBy: ":")
            if components.count >= 2 {
                self.hoursAvailableTomorrow = "\(components[0]):\(components[1])"
            } else {
                self.hoursAvailableTomorrow = hoursWorked
            }
        } else {
            self.hoursAvailableTomorrow = "00:00"
        }

        // --- HOS Calculations ---
        var diffsec = 0
        if let vll = data.last_event?.eventdatetime {
            if let diff = differenceHMSFromNow(isoString: vll) {
                diffsec = diff.absSeconds
            }
        }

        // Calculate total recap hours by summing all worked_hours from recap_days
        // worked_hours comes in HH:MM:SS format (e.g., "00:22:44")
        var totalSeconds = 0
        for day in self.recapDays {
            if let workedHours = day.worked_hours {
                let components = workedHours.components(separatedBy: ":")
                if components.count == 3,
                    let hours = Int(components[0]),
                    let minutes = Int(components[1]),
                    let seconds = Int(components[2])
                {
                    totalSeconds += (hours * 3600) + (minutes * 60) + seconds
                }
            }
        }
        self.totalRecapHours = secondsToHoursMinutes(totalSeconds)

        // Countdown/Timer Logic Calculation (Simplified port from StatusVC)
        // ... (Logic for countdown vs counter based on status)
        // Timer / Countdown Logic
        if code.lowercased() == "d" {
            if let vll = data.hos_status?.code_d_sec {
                let secs = Int(28800 - (vll + diffsec))
                countdown.update(seconds: secs)
            }
        } else if (code.lowercased() == "ym") || (code.lowercased() == "on") {
            var newVal = diffsec
            newVal = diffsec + getTotalSecs(data.hos_status)
            AppLog.debug(newVal)
            let secs = Int(50400 - newVal)
            if countdown.mode != .countdown {
                countdown.changeMode(to: .countdown, totalSeconds: secs)
                countdown.update(seconds: secs)
            } else {
                countdown.update(seconds: secs)
            }
        } else if (code.lowercased() == "off") || (code.lowercased() == "sb")
            || (code.lowercased() == "pu")
        {
            var newVal = diffsec
            newVal = diffsec + getTotalSecs(data.hos_status)

            if newVal < 50400 {
                if let vll = data.last_event?.eventdatetime {
                    if let diff = differenceHMSFromNow(isoString: vll) {
                        if diff.isPast {
                            let secs = 1800 - diff.absSeconds
                            if countdown.mode != .countdown {
                                countdown.changeMode(to: .countdown, totalSeconds: secs)
                                countdown.update(seconds: secs)
                            } else {
                                countdown.update(seconds: secs)
                            }
                            AppLog.debug("⏱ \(diff.hours)h \(diff.minutes)m \(diff.seconds)s ago")
                        } else {
                            AppLog.debug("⏳ in \(diff.hours)h \(diff.minutes)m \(diff.seconds)s")
                        }
                    } else {
                        AppLog.debug("Failed to parse date string.")
                    }
                }
            } else {
                if let vll = data.last_event?.eventdatetime {
                    if let diff = differenceHMSFromNow(isoString: vll) {
                        if diff.isPast {
                            let secs = 36000 - diff.absSeconds
                            if countdown.mode != .countdown {
                                countdown.changeMode(to: .countdown, totalSeconds: secs)
                                countdown.update(seconds: secs)
                            } else {
                                countdown.update(seconds: secs)
                            }
                            AppLog.debug("⏱ \(diff.hours)h \(diff.minutes)m \(diff.seconds)s ago")
                        } else {
                            AppLog.debug("⏳ in \(diff.hours)h \(diff.minutes)m \(diff.seconds)s")
                        }
                    } else {
                        AppLog.debug("Failed to parse date string.")
                    }
                }
            }

            // Update progress bar for off/sb/pu statuses
            let totalLimit = newVal < 50400 ? 1800 : 36000
            if let vll = data.last_event?.eventdatetime {
                if let diff = differenceHMSFromNow(isoString: vll) {
                    if diff.isPast {
                        let remainingSecs = max(totalLimit - diff.absSeconds, 0)
                        let progress = Double(remainingSecs) / Double(totalLimit)
                        self.driveProgress = progress
                    }
                }
            }
        } else {
            if countdown.mode != .counter {
                countdown.changeMode(to: .counter, totalSeconds: 0)
                countdown.update(seconds: 0)
            } else {
                countdown.update(seconds: 0)
            }
        }

        // HOS Values Logic
        var driveValueLocal = secondsToHoursMinutes(39600)
        var shiftValueLocal = secondsToHoursMinutes(50400)
        var cycleValueLocal = secondsToHoursMinutes(252000)

        if let vll = data.hos_status?.code_d_sec {
            var secs = Int(39600 - vll)
            if code.lowercased() == "d" {
                secs -= diffsec
            }
            if secs < 0 {
                secs = 0
            }
            driveValueLocal = secondsToHoursMinutes(secs)

            // Calculate drive progress for circular progress bar (reverse mode)
            // Drive (d): 28800 seconds (8 hours) - tracks only drive time
            // On Duty (on) or Yard Move (ym): 50400 seconds (14 hours) - tracks total time
            var totalLimit = 28800  // Default to drive limit
            var consumedSeconds = vll

            if code.lowercased() == "ym" || code.lowercased() == "on" {
                totalLimit = 50400  // 14-hour shift limit
                consumedSeconds = getTotalSecs(data.hos_status)
                consumedSeconds += diffsec
            } else if code.lowercased() == "d" {
                consumedSeconds += diffsec
            }

            let remainingSeconds = max(totalLimit - consumedSeconds, 0)
            let progress = Double(remainingSeconds) / Double(totalLimit)
            self.driveProgress = progress
        }

        if let vll = data.hos_status?.code_d_sec {
            var secsTotal = getTotalSecs(data.hos_status)
            secsTotal += diffsec
            var secs = Int(50400 - secsTotal)
            if secs < 0 {
                secs = 0
            }
            shiftValueLocal = secondsToHoursMinutes(secs)
        }

        if let vll = data.hos_status?.code_d_sec {
            var secsTotal = getONDSecs(data.hos_status)
            if code.lowercased() == "d" || code.lowercased() == "on" {
                secsTotal += diffsec
            }

            var secs = Int(252000 - secsTotal)
            if secs < 0 {
                secs = 0
            }
            cycleValueLocal = secondsToHoursMinutes(secs)
        }

        self.driveValue = driveValueLocal
        self.shiftValue = shiftValueLocal
        self.cycleValue = cycleValueLocal

        // Break Calculation
        var breakCal = 0
        var DrivebreakCal = 0

        if code.lowercased() == "sb" {
            breakCal = diffsec
        }
        if code.lowercased() == "d" {
            DrivebreakCal = diffsec
        }

        let objBreak_comsumed = data.hos_status?.break_consumed ?? 0

        let objBreak = data.last_event?.sb_break ?? 0
        let currentSec = convertTimeToSeconds(timeString: driveValueLocal) ?? 0
        var IntSec = 0
        if currentSec > 28800 {
            if ((objBreak_comsumed > 0) || (code.lowercased() == "d")) {
                IntSec = 28800 - objBreak_comsumed - DrivebreakCal
            }
            else {
                IntSec = 28800 - Int(objBreak) - breakCal
            }
        } else {
            if ((objBreak_comsumed > 0) || (code.lowercased() == "d")) {
                IntSec = currentSec - objBreak_comsumed - DrivebreakCal
            }
            else {
                IntSec = currentSec - Int(objBreak) - breakCal
            }
        }
        print("driveValueLocal ::", driveValueLocal)
        if IntSec < 0 {
            IntSec = 0
        }
        self.breakValue = secondsToHoursMinutes(max(IntSec, 0))

        // Update progress bar for break status
        if code.lowercased() == "sb" {
            let totalLimit = currentSec > 28800 ? 28800 : currentSec
            let remainingBreak = max(IntSec, 0)
            let progress = totalLimit > 0 ? Double(remainingBreak) / Double(totalLimit) : 0.0
            self.driveProgress = progress
        }
    }
    private func updateCircleStatus(code: String) {
        // App Colors need to be mapped. Using SwiftUI Colors for now.
        switch code.lowercased() {
        case "d", "on":
            circleBorderColor = AppColors.statusGreen
        case "ym":
            circleBorderColor = AppColors.statusRed
        case "off", "sb":
            circleBorderColor = AppColors.statusGray
        case "pu":
            circleBorderColor = AppColors.statusDarkGray
        default:
            circleBorderColor = AppColors.statusGray
        }
    }

    private func getTitles(_ code: String) -> String {
        switch code.lowercased() {
        case "off": return "OFF DUTY"
        case "sb": return "SLEEPER BERTH"
        case "d": return "DRIVING"
        case "on": return "ON DUTY"
        case "ym": return "YARD MOVE"
        case "pu": return "PERSONAL USE"
        default: return code.uppercased()
        }
    }

    // MARK: - Helpers
    func getTotalSecs(_ datta: Hos_status?) -> Int {
        var newVal = 0
        if let dSec = datta?.code_d_sec { newVal += dSec }
        if let sb_Sec = datta?.code_sb_sec { newVal += sb_Sec }
        if let on_Sec = datta?.code_on_sec { newVal += on_Sec }
        if let off_Sec = datta?.code_off_sec { newVal += off_Sec }
        return newVal
    }

    func getONDSecs(_ datta: Hos_status?) -> Int {
        var newVal = 0
        if let dSec = datta?.code_d_sec { newVal += dSec }
        if let on_Sec = datta?.code_on_sec { newVal += on_Sec }
        return newVal
    }

    // MARK: - Polling
    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            // logic to check speed/status change
            // Also refresh UI timer display if needed
            self?.fetchRecap()  // Re-fetch to keep synced
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }



    // MARK: - Logout
    @objc private func handleLogout() {
        stopAllTimers()
    }

    func stopAllTimers() {
        timer?.invalidate()
        timer = nil
        pendingRecapWorkItem?.cancel()
        pendingRecapWorkItem = nil
        countdown.reset()
    }

    private func updateEvents() {
        // Update speed from Global shared data
        if let virtualDashboard = Global.shared.virtualDashboardData,
            let currentSpeed = virtualDashboard.speed
        {
            self.speed = "\(currentSpeed)"
        }

        let codeRecap = Global.shared.recapvalues?.last_event?.code ?? "off"
        var code = Global.shared.recapvalues?.last_event?.code ?? "off"

        if ble.connectedPeripheral != nil {
            if codeRecap == "on" || codeRecap == "d" || codeRecap.lowercased() == "off"
                || codeRecap.lowercased() == "sb"
            {
                let currentSpeed = Int(speed) ?? 0
                let currentState: SpeedState = currentSpeed < 5 ? .low : .high

                // If speed state changed, reset counter
                if lastSpeedState != currentState {
                    speedStateCounter = 1  // First occurrence
                    lastSpeedState = currentState
                } else {
                    speedStateCounter += 1  // Increment if state persists
                }

                // If the state has been consistent for 1 checks, trigger the change
                if speedStateCounter == 1 {
                    var shouldUpdate = false
                    switch currentState {
                    case .low:
                        if codeRecap == "on" || codeRecap == "d" {
                            code = "on"
                            shouldUpdate = true
                        }
                    case .high:
                        code = "d"
                        shouldUpdate = true
                    }

                    if shouldUpdate {
                        AppLog.debug("code changes from counter ==>", code)
                        // Immediate Local Update for UI responsiveness
                        DispatchQueue.main.async {
                            self.currentCode = code.lowercased()
                            self.currentStatus = self.getTitles(code)
                            self.updateCircleStatus(code: code)

                            // Post immediate notification for other views
                            let isDriving = (code.lowercased() == "d")
                            NotificationCenter.default.post(
                                name: .drivingStatusChanged, object: isDriving)
                        }

                        self.sendHardwareUpdate(code: code)
                        // Reset counter after update to prevent continuous updates if logic requires
                        speedStateCounter = 0
                        lastSpeedState = nil  // Reset state tracking
                    }
                }
            }
            DispatchQueue.main.async {
                self.currentCode = code.lowercased()
                self.currentStatus = self.getTitles(code)
                self.updateCircleStatus(code: code)
            }
            // Intermediate Event (IM) Logic: Send "IM" every 1 hour while driving
            if codeRecap.lowercased() == "d" {
                if lastIMEventTime == nil {
                    lastIMEventTime = Date() // Initialize when driving starts
                } else if let lastTime = lastIMEventTime, Date().timeIntervalSince(lastTime) >= 3600 {
                    code = "IM"
                    lastIMEventTime = Date() // Reset for next hour
                    AppLog.debug("1 hour driving detected, triggering IM event")
                }
            } else {
                lastIMEventTime = nil // Reset if status changed from driving
            }

            if manualChange != "" {
                code = manualChange
            } else if code == "" {
                code = codeRecap
            }
            if code == "" {
                code = "on"
            }

            self.sendHardwareUpdate(code: code)
        }
    }

    // MARK: - Hardware Update
    func sendHardwareUpdate(code: String) {
        if let lastTime = lastHardwareUpdateTime, Date().timeIntervalSince(lastTime) < 3, lastHardwareUpdateCode == code {
            AppLog.debug("Discarding hardware update, called within 5 seconds with same code")
            return
        }
        lastHardwareUpdateTime = Date()
        lastHardwareUpdateCode = code

        guard let eventData = Global.shared.EventData else {
            AppLog.debug("No event data available for hardware update")
            return
        }

        let latitude = LocationManager.shared.lastLocation?.coordinate.latitude ?? Double(eventData.geolocation.latitude)
        let longitude = LocationManager.shared.lastLocation?.coordinate.longitude ?? Double(eventData.geolocation.longitude)

        let rawOdoKM = Double(eventData.odometer)
        let offsetKM = Double(Global.shared.connectedVehicleOffset) / 0.621371
        let totalOdometerKM = rawOdoKM + offsetKM
        let odometerMiles = String(format: "%.0f", totalOdometerKM * 0.621371)
        let odometerKM = String(format: "%.0f", totalOdometerKM)

        let engineHours = eventData.engineHours

        // Prepare ELD Data (trackerInfoV)
        var eldevice: [String: Any] = [:]
        if let trackerInfo = Global.shared.trackerInfoV {
            // Manually map or use Mapper if available.
            // Using a simple manual map for key fields based on TrackerInfo definition
            //            eldevice["id"] = trackerInfo.id
            //            eldevice["mac_address"] = trackerInfo.macAddress
            //            eldevice["serial_number"] = trackerInfo.serialNumber
            //            eldevice["model"] = trackerInfo.model
            //            eldevice["firmware_version"] = trackerInfo.firmwareVersion
            //            eldevice["vin"] = trackerInfo.vin
            // Add other fields if needed from TrackerInfo

            eldevice.updateValue(trackerInfo.productName, forKey: "eld_type")
            eldevice.updateValue(trackerInfo.mainVersion.version, forKey: "fw_version")
            eldevice.updateValue(trackerInfo.bleVersion.version, forKey: "bleVersion")
            eldevice.updateValue(
                ble.connectedPeripheral?.identifier.uuidString ?? "", forKey: "device_uuid")
            eldevice.updateValue(trackerInfo.serialNumber, forKey: "device_number")

        }

        // Prepare Event JSON (VirtualDashboardData)
        var virtualDashboardJSON = ""
        if let vDashboard = Global.shared.virtualDashboardData {
            if let jsonString = vDashboard.toJSONString() {
                virtualDashboardJSON = jsonString
            }
        }

        let driverId = self.driver
        // Use connected vehicle ID if available, else default vehicle ID
        let vehicleId = Global.shared.connectVehicleDetail?.id ?? self.vehicle
        let vehicleVinNo = Global.shared.trackerInfoV?.vin ?? ""
        let seqID = eventData.sequenceNumber
        let location_notes = LocationManager.shared.currentAddress
        let positioning = "Location generated when connected to ECM"

        var params: [String: Any] = [
            "eventdatetime": "\(Date())",
            "code": code,
            "cert_date": getOnlyDate(Date()),
            "seq_id": seqID,
            "origin": "Auto",
            "status": "Active",
            "driver": driverId,
            "vehicle": vehicleId,
            "odometer": odometerMiles,
            "odometer_km": odometerKM,
            "engine_hours": engineHours,
            "eld_data": eldevice,
            "positioning": positioning,
            "latitude": latitude,
            "longitude": longitude,
            "location_notes": location_notes,
            "location_cal": location_notes,
            "event_notes": self.event_notes,
            "location_source": "Automatic",
            "eventjson": virtualDashboardJSON,
            "vin": vehicleVinNo,
        ]

        // Append event_codes from buffered BLE events
        if ble.connectedPeripheral != nil, !Global.shared.eventCodeBuffer.isEmpty {
            params["event_code"] = Global.shared.eventCodeBuffer
        }

        AppLog.debug("Sending hardware update with params: \(params)")

        APIManager.shared.request(
            url: ApiList.updateHardwareEvent, method: .post, parameters: params
        ) { comp in
            // Completion handler
        } success: { [weak self] response in
            AppLog.debug("Hardware update successful: \(response)")
            Global.shared.eventCodeBuffer.removeAll()
            // Cancel any previous pending recap and schedule a fresh one 5s from now.
            // This collapses rapid back-to-back hardware updates into a single fetchRecap.
            self?.pendingRecapWorkItem?.cancel()
            let work = DispatchWorkItem { [weak self] in
                // force:true — bypass throttle so this post-update fetch always executes
                // and resets the throttle clock from now.
                self?.fetchRecap(force: true)
            }
            self?.pendingRecapWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
        } failure: { error in
            AppLog.debug("Hardware update failed: \(error)")
        }
    }

    func getOnlyDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: - Manual Status Change
    func setManualStatusChange(code: String) {
        self.manualChange = code
        updateEvents()
    }

    func clearManualStatusChange() {
        self.manualChange = ""
    }
}
#if !targetEnvironment(simulator)
    extension PacificTrack.VirtualDashboardData {
        func toJSONString() -> String? {
            var dict: [String: Any] = [:]

            if let val = self.busType { dict["busType"] = val }
            if let val = self.odometerComputed { dict["odometerComputed"] = val }
            if let val = self.engineHoursComputed { dict["engineHoursComputed"] = val }
            if let val = self.currentGear { dict["currentGear"] = val }
            if let val = self.seatbeltOn { dict["seatbeltOn"] = val }
            if let val = self.speed { dict["speed"] = val }
            if let val = self.rpm { dict["rpm"] = val }
            if let val = self.numberOfDTCPending { dict["numberOfDTCPending"] = val }
            if let val = self.oilPressure { dict["oilPressure"] = val }
            if let val = self.oilLevel { dict["oilLevel"] = val }
            if let val = self.oilTemperature { dict["oilTemperature"] = val }
            if let val = self.coolantLevel { dict["coolantLevel"] = val }
            if let val = self.coolantTemperature { dict["coolantTemperature"] = val }
            if let val = self.fuelLevel { dict["fuelLevel"] = val }
            if let val = self.DEFlevel { dict["DEFlevel"] = val }
            if let val = self.engineLoad { dict["engineLoad"] = val }
            if let val = self.barometer { dict["barometer"] = val }
            if let val = self.intakeManifoldTemperature { dict["intakeManifoldTemperature"] = val }
            if let val = self.engineFuelTankTemperature { dict["engineFuelTankTemperature"] = val }
            if let val = self.engineIntercoolerTemperature {
                dict["engineIntercoolerTemperature"] = val
            }
            if let val = self.engineTurboOilTemperature { dict["engineTurboOilTemperature"] = val }
            if let val = self.transmisionOilTemperature { dict["transmisionOilTemperature"] = val }
            if let val = self.fuelLevel2 { dict["fuelLevel2"] = val }
            if let val = self.fuelRate { dict["fuelRate"] = val }
            if let val = self.averageFuelEconomy { dict["averageFuelEconomy"] = val }
            if let val = self.ambientAirTemperature { dict["ambientAirTemperature"] = val }
            if let val = self.odometer { dict["odometer"] = val }
            if let val = self.engineHours { dict["engineHours"] = val }
            if let val = self.idleHours { dict["idleHours"] = val }
            if let val = self.PTOHours { dict["PTOHours"] = val }
            if let val = self.totalIdleFuel { dict["totalIdleFuel"] = val }
            if let val = self.totalFuelUsed { dict["totalFuelUsed"] = val }
            if let val = self.vin { dict["vin"] = val }

            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                return String(data: data, encoding: .utf8)
            } catch {
                AppLog.debug("Error serializing VirtualDashboardData: \(error)")
                return nil
            }
        }
    }
#endif
