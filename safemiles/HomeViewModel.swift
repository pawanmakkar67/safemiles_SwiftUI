import SwiftUI
import Combine
import ObjectMapper
import CoreBluetooth
import Alamofire

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
    
    // Timer Logic
    private var timer: Timer?
    private var refreshTimer: Timer?
    private var countdown = FlexibleTimer(totalSeconds: 0)
    
    // Status Logic
    private var speedStateCounter = 0
    private var lastSpeedState: String? // Simplified speed state
    
    init() {
        startPolling()
        startAutoRefresh()
        
        // Initialize Countdown Tick Handler
        countdown.start(tick: { [weak self] remaining in
            DispatchQueue.main.async {
                self?.timerString = secondsToHoursMinutes(remaining)
            }
        })
    }
    
    deinit {
        stopPolling()
        stopAutoRefresh()
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
    
     func getLiveStatus() async {
      
         let params: [String: Any] = ["limit": 15]
         
         APIManager.shared.request(url: ApiList.getLogs, method: .get) { comp in
             
         } success: { response in
                          let obj = Mapper<logsModel>().map(JSONObject: response)
//                          Global.shared.logsDataVal = obj?.logs
//                          Global.shared.logsTotalCount = obj?.total_count ?? 0

         } failure: { error in
             
         }


//         APIManager.shared.request(url: ApiList.getLogs,method: .get, parameters: params) { comp in
//             
//         } success: { response in
//             
//         } failure: { error in
//             
//         }
    }
    
    func getVehciles() async {
        
        APIManager.shared.request(url: ApiList.allvehicles, method: .get) { comp in
            
        } success: { response in
            
            let obj = Mapper<vehicleModel>().map(JSONObject: response)
            Global.shared.vehicleList = obj?.data ?? []
            if Global.shared.vehicleList.count > 0 {
                DispatchQueue.main.async {
                    self.vehicle = Global.shared.vehicleList[0].id ?? ""
                }
            }
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
        
        // Populate Summary
//        self.totalRecapHours = String(format: "%.2f", data.total_recap_hours ?? 0.0)
//        self.hoursAvailableToday = String(format: "%.2f", data.hours_available_today ?? 0.0)
//        self.hoursAvailableTomorrow = String(format: "%.2f", data.hours_available_tomorrow ?? 0.0)
        
        // Today's Worked Hours Logic
        let todayStr = getOnlyDate(Date())
        if let todayEntry = data.recap_days?.first(where: { $0.date == todayStr }) {
            let time = todayEntry.worked_hours ?? "00:00"
            let parts = time.components(separatedBy: ":")
            if parts.count >= 2 {
                self.hoursWorkedToday = "\(parts[0]):\(parts[1])"
            } else {
                self.hoursWorkedToday = time
            }
        } else {
            self.hoursWorkedToday = "00:00"
        }
        
        self.todayDateStr = getFormattedDate(from: todayStr)
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            self.tomorrowDateStr = getFormattedDate(from: getOnlyDate(tomorrow))
        }
        
        // --- HOS Calculations ---
        var diffsec = 0
        if let vll = data.last_event?.eventdatetime {
            if let diff = differenceHMSFromNow(isoString: vll) {
                diffsec = diff.absSeconds
            }
        }
        
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
//            let objBreak = data.last_event?.sb_break ?? 0
//            let currentSec = convertTimeToSeconds(timeString: driveValueLocal) ?? 0
//            var IntSec = 0
//            if currentSec > 28800 {
//                IntSec = 28800 - Int(objBreak) - breakCal
//            } else {
//                IntSec = currentSec - Int(objBreak) - breakCal
//            }
//            
//            if (IntSec < 0) {
//                IntSec = 0
//            }
//            self.breakValue = secondsToHoursMinutes(max(IntSec, 0))
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
        // ... (Hardware update logic can be ported here if needed)
    }
}
