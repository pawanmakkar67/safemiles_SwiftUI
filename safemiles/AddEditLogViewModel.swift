import SwiftUI
import CoreLocation
import Combine
import Alamofire

class AddEditLogViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var selectedTime: Date = Date()
    @Published var selectedStatus: String = "Off Duty"
    @Published var selectedVehicle: VehicleData?
    @Published var location: String = ""
    @Published var notes: String = ""
    @Published var company: String = ""
    @Published var isLoading: Bool = false
    @Published var odometer: String = ""
    @Published var engineHours: String = ""
    
    @Published var isLocationError: Bool = false
    @Published var isVehicleError: Bool = false
    @Published var isOdometerError: Bool = false
    @Published var isEngineHoursError: Bool = false
    @Published var alertMessage: String = ""
    @Published var alertTitle: String = ""
    @Published var showAlert: Bool = false
    
    var isEditMode: Bool = false
    private var currentEventID: String = ""
    private var locationManager = CLLocationManager()
    
    let statusOptions = ["Off Duty", "Sleeper", "Driving", "On Duty", "Personal Use", "Yard Moves"]
    
    init(event: Events? = nil, log: Logs? = nil) {
        super.init()
        
        // Set company
        company = Global.shared.myProfile?.company?.name ?? ""
        
        if let firstVehicle = Global.shared.vehicleList.first {
            selectedVehicle = firstVehicle
        }

        
        
        // If editing existing event
        if let event = event {
            isEditMode = true
            currentEventID = event.id ?? ""
            location = event.location_notes ?? ""
            notes = event.event_notes ?? ""
            selectedStatus = getStatusName(event.code ?? "off")
            
            // Parse time from event datetime
            if let eventDateTime = event.eventdatetime {
                selectedTime = parseTimeFromISO(eventDateTime)
            }
            
            if let odo = event.odometer {
                odometer = "\(Int(odo))"
            }
            
            if let engH = event.engine_hours {
                engineHours = "\(engH)"
            }
        } else {
            // New event - setup location and default vehicle
            setupLocationManager()
            
            if let firstVehicle = Global.shared.vehicleList.first {
                selectedVehicle = firstVehicle
            }
            
            // Set selectedTime to the log date (at current time)
            if let dateStr = log?.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = getAppTimeZone()
                if let date = formatter.date(from: dateStr) {
                    let now = Date()
                    let calendar = Calendar.current
                    var components = calendar.dateComponents(in: getAppTimeZone(), from: date)
                    let nowComponents = calendar.dateComponents(in: getAppTimeZone(), from: now)
                    components.hour = nowComponents.hour
                    components.minute = nowComponents.minute
                    components.second = nowComponents.second
                    
                    if let finalDate = calendar.date(from: components) {
                        selectedTime = finalDate
                    }
                }
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func saveLog(onSuccess: @escaping () -> Void) {
        guard validate() else { return }
        
        isLoading = true
        
        // Convert selectedTime to UTC ISO8601 format
        let combinedDateTime = changeStringToDateddmmyyyyfull(selectedTime)
        
        // Map status to code
        let statusCode = getStatusCode(selectedStatus)
        
        let params: [String: Any] = [
            "eventdatetime": combinedDateTime,
            "code": statusCode,
            "origin": "Driver",
            "status": "Active",
            "vehicle": selectedVehicle?.vehicle_id ?? "",
            "positioning": "Location generated when connected to ECM",
            "event_notes": notes,
            "location_cal": location,
            "location_notes": location,
            "odometer": Double(odometer) ?? 0.0,
            "engine_hours": Double(engineHours) ?? 0.0,
            "driver_id": Global.shared.logsDataVal?.metadata?.driver_id ?? ""
        ]
        
        if isEditMode {
            // PATCH request for updating existing event
            APIManager.shared.request(url: ApiList.updateHardwareEvent + currentEventID + "/", method: .patch, parameters: params) { [weak self] _ in
                self?.isLoading = false
            } success: { [weak self] response in
                self?.isLoading = false
                NotificationCenter.default.post(name: .logsUpdate, object: nil)
                onSuccess()
            } failure: { [weak self] error in
                self?.isLoading = false
                self?.alertTitle = "Error"
                self?.alertMessage = error ?? "Failed to update log."
                self?.showAlert = true
                AppLog.debug("Error updating log: \(error ?? "Unknown error")")
            }
        } else {
            // POST request for adding new event
            APIManager.shared.request(url: ApiList.addHardwareEvent, method: .post, parameters: params) { [weak self] _ in
                self?.isLoading = false
            } success: { [weak self] response in
                self?.isLoading = false
                NotificationCenter.default.post(name: .logsUpdate, object: nil)
                onSuccess()
            } failure: { [weak self] error in
                self?.isLoading = false
                self?.alertTitle = "Error"
                self?.alertMessage = error ?? "Failed to add log."
                self?.showAlert = true
                AppLog.debug("Error adding log: \(error ?? "Unknown error")")
            }
        }
    }
    
    private func parseTimeFromISO(_ isoString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = getAppTimeZone()
        
        if let date = formatter.date(from: isoString) {
            return date
        }
        return Date()
    }
    
    private func getStatusCode(_ status: String) -> String {
        switch status {
        case "Off Duty": return "off"
        case "Sleeper": return "sb"
        case "Driving": return "d"
        case "On Duty": return "on"
        case "Personal Use": return "pu"
        case "Yard Moves": return "ym"
        default: return "off"
        }
    }
    
    private func getStatusName(_ code: String) -> String {
        switch code.lowercased() {
        case "off": return "Off Duty"
        case "sb": return "Sleeper"
        case "d": return "Driving"
        case "on": return "On Duty"
        case "pu": return "Personal Use"
        case "ym": return "Yard Moves"
        default: return "Off Duty"
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let _ = error { return }
            
            if let placemark = placemarks?.first {
                var addressParts: [String] = []
                
                if let subThoroughfare = placemark.subThoroughfare { addressParts.append(subThoroughfare) }
                if let thoroughfare = placemark.thoroughfare { addressParts.append(thoroughfare) }
                if let locality = placemark.locality { addressParts.append(locality) }
                if let administrativeArea = placemark.administrativeArea { addressParts.append(administrativeArea) }
                if let country = placemark.country { addressParts.append(country) }
                
                let addressString = addressParts.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    if self.location.isEmpty {
                        self.location = addressString
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppLog.debug("Location Manager failed: \(error)")
    }
    
    // MARK: - Helper Functions
    private func changeStringToDateddmmyyyyfull(_ timeStr: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = formatter.string(from: timeStr)
        AppLog.debug(date)
        return date
    }
    
    func validate() -> Bool {
        isLocationError = false
        isVehicleError = false
        isOdometerError = false
        isEngineHoursError = false
        
        var isValid = true
        
        if location.trimmingCharacters(in: .whitespaces).isEmpty {
            isLocationError = true
            isValid = false
        }
        
        var calendar = Calendar.current
        calendar.timeZone = getAppTimeZone()
        
        if calendar.compare(selectedTime, to: Date(), toGranularity: .minute) == .orderedDescending {
            alertTitle = "Invalid Time"
            alertMessage = "Event time cannot be in the future."
            showAlert = true
            return false
        }
        
        if selectedVehicle == nil {
            isVehicleError = true
            isValid = false
        }
        
        if odometer.trimmingCharacters(in: .whitespaces).isEmpty {
            isOdometerError = true
            isValid = false
        }
        
        if engineHours.trimmingCharacters(in: .whitespaces).isEmpty {
            isEngineHoursError = true
            isValid = false
        }
        
        if !isValid {
            alertTitle = "Mandatory Fields"
            alertMessage = "Please fill in all mandatory fields highlighted in red."
            showAlert = true
        }
        
        return isValid
    }
}
