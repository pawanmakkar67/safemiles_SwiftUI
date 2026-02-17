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
    
    var isEditMode: Bool = false
    private var currentEventID: String = ""
    private var locationManager = CLLocationManager()
    
    let statusOptions = ["Off Duty", "Sleeper", "Driving", "On Duty", "Personal Use", "Yard Moves"]
    
    init(event: Events? = nil, log: Logs? = nil) {
        super.init()
        
        // Set company
        company = Global.shared.myProfile?.company?.name ?? ""
        
        // If editing existing event
        if let event = event {
            isEditMode = true
            currentEventID = event.id ?? ""
            location = event.location_notes ?? ""
            selectedStatus = getStatusName(event.code ?? "off")
            
            // Parse time from event datetime
            if let eventDateTime = event.eventdatetime {
                selectedTime = parseTimeFromISO(eventDateTime)
            }
        } else {
            // New event - setup location and default vehicle
            setupLocationManager()
            
            if let firstVehicle = Global.shared.vehicleList.first {
                selectedVehicle = firstVehicle
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
        guard !location.isEmpty else {
            print("Location is required")
            return
        }
        
        guard let selectedVehicle = selectedVehicle else {
            print("Vehicle is required")
            return
        }
        
        isLoading = true
        
        // Convert selectedTime to UTC ISO8601 format
        let combinedDateTime = changeStringToDateddmmyyyyfull(selectedTime)
        
        // Map status to code
        let statusCode = getStatusCode(selectedStatus)
        
        var params: [String: Any] = [
            "eventdatetime": combinedDateTime,
            "code": statusCode,
            "origin": "Driver",
            "status": "Active",
            "vehicle": selectedVehicle.id ?? "",
            "positioning": "Location generated when connected to ECM",
            "event_notes": notes,
            "location_cal": location
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
                print("Error updating log: \(error ?? "Unknown error")")
            }
        } else {
            // POST request for adding new event
            APIManager.shared.request(url: ApiList.updateHardwareEvent, method: .post, parameters: params) { [weak self] _ in
                self?.isLoading = false
            } success: { [weak self] response in
                self?.isLoading = false
                NotificationCenter.default.post(name: .logsUpdate, object: nil)
                onSuccess()
            } failure: { [weak self] error in
                self?.isLoading = false
                print("Error adding log: \(error ?? "Unknown error")")
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
        print("Location Manager failed: \(error)")
    }
    
    // MARK: - Helper Functions
    private func changeStringToDateddmmyyyyfull(_ timeStr: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = formatter.string(from: timeStr)
        print(date)
        return date
    }
}
