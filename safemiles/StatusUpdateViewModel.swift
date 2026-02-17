import SwiftUI
import CoreLocation
import Combine
import ObjectMapper
import Alamofire

class StatusUpdateViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var selectedCode: String = ""
    @Published var locationText: String = ""
    @Published var notesText: String = ""
    @Published var isLoading: Bool = false
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    private var locationManager = CLLocationManager()
    
    init(selectedCode: String) {
        self.selectedCode = selectedCode
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateStatus(onSuccess: @escaping () -> Void) {
        guard !selectedCode.isEmpty else {
            alertMessage = "please select status to update"
            showAlert = true
            return
        }
        
        guard !locationText.isEmpty else {
            alertMessage = "please enter location"
            showAlert = true
            return
        }
        
        // Date formatting to UTC ISO8601
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dateT = dateFormatter.string(from: Date()) 
        
        let vehicleiD = Global.shared.myProfile?.vehicle?.id ?? ""
        
        var params: [String: Any] = [
            "eventdatetime": dateT,
            "code": selectedCode,
            "origin": "Driver",
            "status": "Active",
            "positioning": "Location generated when connected to ECM",
            "event_notes": notesText,
            "location_notes": locationText,
            "location_cal": locationText,
            "cert_date": getOnlyDate(Date())
        ]

        
        if let connectedVehicle = vehicleiD as? String, vehicleiD != "" {
            params["vehicle"] = connectedVehicle
        }
        
        isLoading = true
        
        APIManager.shared.request(url: ApiList.updateHardwareEvent, method: .post, parameters: params) { [weak self] _ in
            self?.isLoading = false
        } success: { [weak self] response in
            self?.isLoading = false
            NotificationCenter.default.post(name: .recapUpdate, object: nil)
            onSuccess()
        } failure: { [weak self] error in
            self?.isLoading = false
            self?.alertMessage = error ?? "Unknown error"
            self?.showAlert = true
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation() // Stop after getting a fix
        
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
                // if let postalCode = placemark.postalCode { addressParts.append(postalCode) } // Optional
                
                let addressString = addressParts.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    if self.locationText.isEmpty { // Only auto-fill if empty
                        self.locationText = addressString
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed: \(error)")
    }
}
