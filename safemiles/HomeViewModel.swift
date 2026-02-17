import SwiftUI
import Combine
import ObjectMapper
import CoreBluetooth
import Alamofire
import PacificTrack

class HomeViewModel: ObservableObject {
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
    
    // Drive Progress (0.0 to 1.0 for circular progress bar)
    @Published var driveProgress: Double = 0.0
    
    // Status Update Modal
    @Published var showStatusUpdateModal: Bool = false
    @Published var selectedStatusUpdateCode: String = ""
    
    // Timer Logic
    private var timer: Timer?
    private var refreshTimer: Timer?
    private var countdown = FlexibleTimer(totalSeconds: 0)
    
    // Status Logic
    private var speedStateCounter = 0
    private var lastSpeedState: SpeedState?
    private var manualChange: String = ""
    
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
        startPolling()
        startAutoRefresh()
        
        // Initialize Countdown Tick Handler
        countdown.start(tick: { [weak self] remaining in
            DispatchQueue.main.async {
                self?.timerString = secondsToHoursMinutes(remaining)
            }
        })
        
        // Notification Observers
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecapUpdate), name: .recapUpdate, object: nil)
    }
    
    @objc func handleRecapUpdate() {
        print("HomeViewModel: Received recapUpdate notification")
        fetchRecap()
        Task {
            await getLiveStatus()
            await getVehciles() // Refresh vehicles too if needed, but status is key
        }
    }
    
    deinit {
        stopPolling()
        stopAutoRefresh()
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
    
    func getLiveStatus() async {
      
         let page = ((Global.shared.logsDataVal?.logs?.count ?? 0) / 10) + 1
         let params = ["page": page]
         
         APIManager.shared.request(url: ApiList.getLogs, method: .get, parameters: params) { comp in
             // completion
         } success: { response in
             
             guard let obj = Mapper<logsModel>().map(JSONObject: response) else { return }
             
             if page != 1, let newLogs = obj.logs {
                 Global.shared.logsDataVal?.logs?.append(contentsOf: newLogs)
             } else {
                 Global.shared.logsDataVal = obj
             }

         } failure: { error in
             
         }
    }
    
    func getVehciles() async {
        
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
        APIManager.shared.request(url: ApiList.getCoDrivers, method: .get) { comp in
            
        } success: { response in
            let obj = Mapper<CoDriverModel>().map(JSONObject: response)
            Global.shared.coDriverList = obj?.data
        } failure: { error in
            
        }
    }
    
    func getMyProfile() {
        
        APIManager.shared.request(url: ApiList.getMyprofile, method: .get) { comp in
            
        } success: { response in
            
            let obj = Mapper<ProfileModel>().map(JSONObject: response)
            Global.shared.myProfile = obj?.data
            DispatchQueue.main.async {
                self.driver = Global.shared.myProfile?.id ?? ""
            }
        } failure: { error in
            
        }
        
    }
    
    func fetchRecap() {
        APIManager.shared.request(url: ApiList.RecapApi, method: .get, parameters: nil) { _ in
        } success: { response in
            if let obj = Mapper<RecapModel>().map(JSONObject: response) {
                Global.shared.recapvalues = obj
                DispatchQueue.main.async {
                    self.updateData(obj)
                }
            }
        } failure: { error in
            print("Recap fetch failed: \(String(describing: error))")
        }
    }
    
    private func updateData(_ data: RecapModel?) {
        guard let data = data else { return }
        
        // Update Status and Circle Color
        let code = data.last_event?.code ?? "off"
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
                   let seconds = Int(components[2]) {
                    totalSeconds += (hours * 3600) + (minutes * 60) + seconds
                }
            }
        }
        self.totalRecapHours = secondsToHoursMinutes(totalSeconds)
        
        // Countdown/Timer Logic Calculation (Simplified port from StatusVC)
        // ... (Logic for countdown vs counter based on status)
            // Timer / Countdown Logic
            if (code.lowercased() == "d")  {
                if let vll = data.hos_status?.code_d_sec {
                    let secs = Int(28800 - (vll + diffsec))
                    countdown.update(seconds: secs)
                }
            }
            else if ((code.lowercased() == "ym" ) || (code.lowercased() == "on")) {
                var newVal = diffsec
                newVal = diffsec + getTotalSecs(data.hos_status)
                print(newVal)
                let secs = Int(50400 - newVal)
                if countdown.mode != .countdown {
                    countdown.changeMode(to: .countdown, totalSeconds: secs)
                    countdown.update(seconds: secs)
                }
                else {
                    countdown.update(seconds: secs)
                }
            }
            else if ((code.lowercased() == "off") || (code.lowercased() == "sb")  || (code.lowercased() == "pu"))   {
                var newVal = diffsec
                newVal = diffsec + getTotalSecs(data.hos_status)
                
                if (newVal < 50400) {
                    if let vll = data.last_event?.eventdatetime {
                        if let diff = differenceHMSFromNow(isoString: vll) {
                            if diff.isPast {
                                let secs = 1800 - diff.absSeconds
                                if countdown.mode != .countdown {
                                    countdown.changeMode(to: .countdown, totalSeconds: secs)
                                    countdown.update(seconds: secs)
                                }
                                else {
                                    countdown.update(seconds: secs)
                                }
                                print("⏱ \(diff.hours)h \(diff.minutes)m \(diff.seconds)s ago")
                            } else {
                                print("⏳ in \(diff.hours)h \(diff.minutes)m \(diff.seconds)s")
                            }
                        } else {
                            print("Failed to parse date string.")
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
                                }
                                else {
                                    countdown.update(seconds: secs)
                                }
                                print("⏱ \(diff.hours)h \(diff.minutes)m \(diff.seconds)s ago")
                            } else {
                                print("⏳ in \(diff.hours)h \(diff.minutes)m \(diff.seconds)s")
                            }
                        } else {
                            print("Failed to parse date string.")
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
            }
            else {
                if countdown.mode != .counter {
                    countdown.changeMode(to: .counter, totalSeconds: 0)
                    countdown.update(seconds: 0)
                }
                else {
                    countdown.update(seconds: 0)
                }
            }
            
            
            // HOS Values Logic
            var driveValueLocal =  secondsToHoursMinutes(39600)
            var shiftValueLocal =  secondsToHoursMinutes(50400)
            var cycleValueLocal =  secondsToHoursMinutes(252000)
            
            if let vll = data.hos_status?.code_d_sec {
                var secs = Int(39600 - vll)
                if (code.lowercased() == "d")  {
                    secs -= diffsec
                }
                if (secs < 0) {
                    secs = 0
                }
                driveValueLocal =  secondsToHoursMinutes(secs)
                
                // Calculate drive progress for circular progress bar (reverse mode)
                // Drive (d): 28800 seconds (8 hours) - tracks only drive time
                // On Duty (on) or Yard Move (ym): 50400 seconds (14 hours) - tracks total time
                var totalLimit = 28800 // Default to drive limit
                var consumedSeconds = vll
                
                if (code.lowercased() == "ym" || code.lowercased() == "on") {
                    totalLimit = 50400 // 14-hour shift limit
                    consumedSeconds = getTotalSecs(data.hos_status)
                    consumedSeconds += diffsec
                } else if (code.lowercased() == "d") {
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
                if (secs < 0) {
                    secs = 0
                }
                shiftValueLocal =  secondsToHoursMinutes(secs)
            }
            
            if let vll = data.hos_status?.code_d_sec {
                var secsTotal = getONDSecs(data.hos_status)
                if (code.lowercased() == "d" || code.lowercased() == "on")  {
                    secsTotal += diffsec
                }
                
                var secs = Int(252000 - secsTotal)
                if (secs < 0) {
                    secs = 0
                }
                cycleValueLocal =  secondsToHoursMinutes(secs)
            }
            
            self.driveValue = driveValueLocal
            self.shiftValue = shiftValueLocal
            self.cycleValue = cycleValueLocal
            
            // Break Calculation
            var breakCal = 0
            if (code.lowercased() == "sb")  {
                breakCal = diffsec
            }
            let objBreak = data.last_event?.sb_break ?? 0
            let currentSec = convertTimeToSeconds(timeString: driveValueLocal) ?? 0
            var IntSec = 0
            if currentSec > 28800 {
                IntSec = 28800 - Int(objBreak) - breakCal
            } else {
                IntSec = currentSec - Int(objBreak) - breakCal
            }
            
            if (IntSec < 0) {
                IntSec = 0
            }
            self.breakValue = secondsToHoursMinutes(max(IntSec, 0))
            
            // Update progress bar for break status
            if (code.lowercased() == "sb") {
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
    func getTotalSecs(_ datta : Hos_status?)  -> Int {
        var newVal = 0
        if let dSec = datta?.code_d_sec { newVal += dSec }
        if let sb_Sec = datta?.code_sb_sec { newVal += sb_Sec }
        if let on_Sec = datta?.code_on_sec { newVal += on_Sec }
        if let off_Sec = datta?.code_off_sec { newVal += off_Sec }
        return newVal
    }

    func getONDSecs(_ datta : Hos_status?)  -> Int {
        var newVal = 0
        if let dSec = datta?.code_d_sec { newVal += dSec }
        if let on_Sec = datta?.code_on_sec { newVal += on_Sec }
        return newVal
    }
    
    // MARK: - Polling
    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
             self?.updateEvents() // logic to check speed/status change
             // Also refresh UI timer display if needed
             self?.fetchRecap() // Re-fetch to keep synced
        }
    }
    
    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.fetchRecap()
        }
    }
    
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private func updateEvents() {
        // Update speed from Global shared data
        if let virtualDashboard = Global.shared.virtualDashboardData,
           let currentSpeed = virtualDashboard.speed {
            self.speed = "\(currentSpeed)"
        }
        
        let codeRecap = Global.shared.recapvalues?.last_event?.code ?? "off"
        var code = Global.shared.recapvalues?.last_event?.code ?? "off"
        
        if ble.connectedPeripheral != nil {
            if (codeRecap == "on" || codeRecap == "d" || codeRecap.lowercased() == "off" || codeRecap.lowercased() == "sb") {
                let currentSpeed = Int(speed) ?? 0
                let currentState: SpeedState = currentSpeed < 5 ? .low : .high

                // If speed state changed, reset counter
                if lastSpeedState != currentState {
                    speedStateCounter = 1 // First occurrence
                    lastSpeedState = currentState
                } else {
                    speedStateCounter += 1 // Increment if state persists
                }
                
                // If the state has been consistent for 2 checks, trigger the change
                if speedStateCounter == 2 {
                    var shouldUpdate = false
                    switch currentState {
                    case .low:
                        if (codeRecap == "on" || codeRecap == "d") {
                            code = "on"
                            shouldUpdate = true
                        }
                    case .high:
                        code = "d"
                        shouldUpdate = true
                    }
                    
                    if shouldUpdate {
                        print("code changes from counter ==>", code)
                        self.sendHardwareUpdate(code: code)
                        // Reset counter after update to prevent continuous updates if logic requires
                        speedStateCounter = 0
                        lastSpeedState = nil // Reset state tracking
                    }
                }
            }
            
            if manualChange != "" {
                code = manualChange
            }
            else if code == "" {
                code = codeRecap
            }
            if code == "" {
                code = "on"
            }
            
            self.sendHardwareUpdate(code: code)
        }
    }
    
    // MARK: - Hardware Update
    // MARK: - Hardware Update
    func sendHardwareUpdate(code: String) {
        guard let eventData = Global.shared.EventData else {
            print("No event data available for hardware update")
            return
        }
        
        let latitude = eventData.geolocation.latitude
        let longitude = eventData.geolocation.longitude
        let odometer = eventData.odometer
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
            eldevice.updateValue(ble.connectedPeripheral?.identifier.uuidString ?? "", forKey: "device_uuid")
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
        let location_notes = "Automatic" // Placeholder or resolved address
        let positioning = "Location generated when connected to ECM"

        let params: [String: Any] = [
            "eventdatetime": "\(Date())",
            "code": code,
            "cert_date": getOnlyDate(Date()),
            "seq_id": seqID,
            "origin": "Auto",
            "status": "Active",
            "driver": driverId,
            "vehicle": vehicleId,
            "odometer": odometer,
            "engine_hours": engineHours,
            "eld_data": eldevice,
            "positioning": positioning,
            "latitude": latitude,
            "longitude": longitude,
            "location_notes": location_notes,
            "location_cal": location_notes,
            "location_source": "Automatic",
            "eventjson": virtualDashboardJSON,
            "vin": vehicleVinNo
        ]
        
        print("Sending hardware update with params: \(params)")
        
        APIManager.shared.request(url: ApiList.updateHardwareEvent, method: .post, parameters: params) { comp in
            // Completion handler
        } success: { response in
            print("Hardware update successful: \(response)")
            // Refresh recap after successful update
            DispatchQueue.main.async {
                self.fetchRecap()
            }
        } failure: { error in
            print("Hardware update failed: \(error)")
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
        if let val = self.engineIntercoolerTemperature { dict["engineIntercoolerTemperature"] = val }
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
            print("Error serializing VirtualDashboardData: \(error)")
            return nil
        }
    }
}
