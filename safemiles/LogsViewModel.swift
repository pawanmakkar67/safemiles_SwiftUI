import SwiftUI
import ObjectMapper
import Alamofire
import Foundation
import Combine

enum DutyStatus: String {
    case off = "off"
    case sleeper = "sb"
    case driving = "d"
    case on = "on"
}

struct DutySegment: Identifiable {
    let id = UUID()
    var status: DutyStatus
    var startHour: Float
    var endHour: Float
    var isDotted: Bool
}

class LogsViewModel: ObservableObject {
    @Published var logsData: logsModel?
    @Published var selectedDate: Date = Date()
    @Published var availableDates: [Date] = []
    @Published var currentLog: Logs?
    @Published var dutySegments: [DutySegment] = []
    @Published var isLoading = false
    
    init() {
        // Observe Global changes if needed, but for now we fetch directly
        self.logsData = Global.shared.logsDataVal
        updateCurrentLog()
    }
    
    func fetchLogs(refresh: Bool = false) {
        isLoading = true
        
        // Pagination logic might need adjustment if total_count is not available directly on logsModel or needs to be calculated
        // logsModel struct shows logs array. 
        // User removed total_count from logsModel in one view but it's not in the file I just read? 
        // Wait, the file I read for logsModel struct (lines 60-74) ONLY has logs and metadata. No total_count.
        // So I should remove total_count logic or rely on array count if not paginated server side the same way.
        // Assuming page 1 for now or simple fetch.
        
        let page = refresh ? 1 : ((Global.shared.logsDataVal?.logs?.count ?? 0) / 10) + 1
        let params = ["page": page]
        
        APIManager.shared.request(url: ApiList.getLogs, method: .get, parameters: params) { comp in
            // completion
        } success: { response in
            self.isLoading = false
            
            guard let obj = Mapper<logsModel>().map(JSONObject: response) else { return }
            
            if page != 1, let newLogs = obj.logs {
                Global.shared.logsDataVal?.logs?.append(contentsOf: newLogs)
            } else {
                Global.shared.logsDataVal = obj
            }
            
            // Global.shared.logsTotalCount = obj.total_count ?? 0 // Removed as per model change
            
            DispatchQueue.main.async {
                self.logsData = Global.shared.logsDataVal
                self.extractAvailableDates()
                
                // Select first available date if current selection is not valid or just default to recent
                if self.selectedDate == Date(), let firstDate = self.availableDates.first {
                     self.selectedDate = firstDate
                }
                
                self.updateCurrentLog()
            }
            
        } failure: { error in
            self.isLoading = false
            print("Fetch logs failed: \(String(describing: error))")
        }
    }
    
    func updateCurrentLog() {
        guard let logs = logsData?.logs else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDateStr = dateFormatter.string(from: selectedDate)
        
        self.currentLog = logs.first(where: { $0.date == selectedDateStr })
        
        // If not found, maybe show empty state or last available? 
        // For now, let's keep it nil if not found.
        
        calculateDutySegments()
    }
    
    func extractAvailableDates() {
        guard let logs = logsData?.logs else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dates = logs.compactMap { dateFormatter.date(from: $0.date ?? "") }
        self.availableDates = dates.sorted(by: { $0 < $1 })
    }
    
    func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
            updateCurrentLog()
        }
    }
    
    private func calculateDutySegments() {
        dutySegments.removeAll()
//        guard let log = currentLog else {
//            // Default: OFF for 24h if no log
//            dutySegments = [DutySegment(status: .off, startHour: 0, endHour: 24, isDotted: false)]
//            return
//        }
//        
//        let allEvents = log.events ?? []
//        // Filter out 'login' events for the graph as requested
//        let events = allEvents.filter { $0.code?.lowercased() != "login" }
//        let lastCode = log.log ?? "off"
//        
//        if events.isEmpty {
//            addInitialEvents(code: lastCode, initialTime: log.last_eventdatetime ?? "", noEvents: true)
//            return
//        }
//        
//        // Ported Logic from EventVC
//        for (index, value) in events.enumerated() {
//            var currentValue: EventsModel? = value
//            var nextValue: EventsModel?
//            
//            if events.count == 1 {
//                nextValue = events[index]
//            } else if (index + 1) < events.count {
//                nextValue = events[index + 1]
//            } else if (index == events.count - 1) {
//                // Last element
//            }
//            
//            // Add initial segment if first event is not at 00:00
//            if index == 0 {
//                addInitialEvents(code: lastCode, initialTime: currentValue?.eventdatetime ?? "")
//            }
//            
//            guard let currentCode = currentValue?.code else { continue }
//            
//            let startHour = getHourWithMinutes(from: currentValue?.eventdatetime)
//            var endHour: Float = 0.0
//            
//            // Determine End Hour
//            if index == events.count - 1 {
//                endHour = 24.0 // Or current time if Today? simplified to 24 for now, can refine.
//                if Calendar.current.isDateInToday(selectedDate) {
//                    endHour = getCurrentHourInCDT()
//                }
//            } else {
//                 endHour = getHourWithMinutes(from: nextValue?.eventdatetime)
//            }
//            
//            if events.count == 1 {
//                endHour = 24.0
//                if Calendar.current.isDateInToday(selectedDate) {
//                    endHour = getCurrentHourInCDT()
//                }
//            }
//            
//            // Map Code to Status
//            var status: DutyStatus = .off
//            var isDotted = false
//            
//            switch currentCode {
//            case "on", "login", "Active":
//                status = .on
//            case "ym":
//                status = .on
//                isDotted = true
//            case "sb":
//                status = .sleeper
//            case "d":
//                status = .driving
//            case "off":
//                status = .off
//            case "pu":
//                status = .off
//                isDotted = true
//            default:
//                status = .off
//            }
//            
//            dutySegments.append(DutySegment(status: status, startHour: startHour, endHour: endHour, isDotted: isDotted))
//        }
    }
    
    private func addInitialEvents(code: String, initialTime: String, noEvents: Bool = false) {
        let startHour: Float = 0.0
        var endHour: Float = 24.0
        
        if !noEvents {
            endHour = getHourWithMinutes(from: initialTime)
        }
        
        var status: DutyStatus = .off
        var isDotted = false
        
        switch code {
        case "on", "login", "Active":
            status = .on
        case "ym":
            status = .on
            isDotted = true
        case "sb":
            status = .sleeper
        case "d":
            status = .driving
        case "off":
            status = .off
        case "pu":
            status = .off
            isDotted = true
        default:
            status = .off
        }
        
        dutySegments.append(DutySegment(status: status, startHour: startHour, endHour: endHour, isDotted: isDotted))
    }
    
    // Helper Helpers
    private func getHourWithMinutes(from dateStr: String?) -> Float {
        guard let dateStr = dateStr else { return 0.0 }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var date = formatter.date(from: dateStr)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: dateStr)
        }
        
        guard let validDate = date else { return 0.0 }
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: validDate)
        let minute = calendar.component(.minute, from: validDate)
        
        return Float(hour) + (Float(minute) / 60.0)
    }
    
    private func getCurrentHourInCDT() -> Float {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return Float(hour) + (Float(minute) / 60.0)
    }
    func saveForm(vehicleId: String, coDriverId: String, trailers: [String], shippingDocs: [String], completion: @escaping (Bool, String) -> Void) {
        guard let log = currentLog, let logId = log.log?.id else {
            completion(false, "No log selected")
            return
        }
        
        let params: [String: Any] = [
            "log_id": logId,
            "logdate": log.date ?? "",
            "vehicle": vehicleId,
            "co_driver": coDriverId,
            "shipping_docs": shippingDocs,
            "trailers": trailers
        ]
        
        isLoading = true
        APIManager.shared.request(url: ApiList.saveForms + logId + "/", method: .patch, parameters: params) { comp in
            // completion
        } success: { response in
            self.isLoading = false
            // Assuming SuccessModel structure based on typical response, but using generic check for now or just checking success
            // If SuccessModel is available use it. For now, creating a simple check.
            if let success = response["success"] as? Bool, success == true {
                 completion(true, response["message"] as? String ?? "Saved Successfully")
                 // Refresh logs to show updated data
                 self.fetchLogs(refresh: true)
            } else {
                 completion(false, response["message"] as? String ?? "Unknown error")
            }
        } failure: { error in
            self.isLoading = false
            completion(false, error?.debugDescription ?? "Network error")
        }
    }
    func certifyLog(signature: Data, completion: @escaping (Bool, String) -> Void) {
        guard let log = currentLog, let logId = log.log?.id else {
            completion(false, "No log selected")
            return
        }
        
        // Convert signature data to Base64
        let signatureBase64 = signature.base64EncodedString()
        
        let params: [String: Any] = [
            "log_id": logId,
            "signature": signatureBase64,
            "logdate": log.date ?? ""
        ]
        
        isLoading = true
        APIManager.shared.upload(url: ApiList.signatireVerify + logId + "/", method: .patch, parameters: params) { comp in
             // completion progress
        } success: { response in
            self.isLoading = false
            if let success = response["success"] as? Bool, success == true {
                 completion(true, response["message"] as? String ?? "Certified Successfully")
                 self.fetchLogs(refresh: true)
            } else {
                 completion(false, response["message"] as? String ?? "Unknown error")
            }
        } failure: { error in
            self.isLoading = false
            completion(false, error?.debugDescription ?? "Network error")
        }
    }
}
