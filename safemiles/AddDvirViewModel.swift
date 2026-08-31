import SwiftUI
import Combine
import ObjectMapper
import Alamofire
import CoreLocation
#if !targetEnvironment(simulator)
import PacificTrack
#endif

class AddDvirViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Form Fields
    @Published var time: Date = Date()
    @Published var location: String = ""
    @Published var odometer: String = ""
    @Published var company: String = ""
    @Published var status: String = "Vehicle Condition Satisfactory"
    @Published var remarks: String = ""
    
    var vehicleOffset: String {
        let offset = selectedVehicle?.offset ?? Global.shared.connectedVehicleOffset
        return offset != 0 ? "(\(offset))" : ""
    }
    
    @Published var selectedVehicle: VehicleData? {
        didSet {
            if editingDvirId == nil {
                setupInitialData()
            }
        }
    }
    @Published var vehicleDefects: [String] = []
    
    @Published var trailers: [String] = []
    @Published var trailerDefects: [String] = []
    
    @Published var signatureImage: UIImage?
    
    @Published var isLoading: Bool = false
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var submitSuccess: Bool = false
    
    // Error Flags
    @Published var isVehicleError: Bool = false
    @Published var isOdometerError: Bool = false
    @Published var isRemarksError: Bool = false
    @Published var isSignatureError: Bool = false
    
    // Data Sources
    let statusOptions = ["Vehicle Condition Satisfactory", "Has Defects", "Defects Corrected", "Defects Need Not Be Corrected"]
    
    // Edit Mode
    var editingDvirId: String?
    
    // Location
    private let locationManager = CLLocationManager()
    
    init(dvirData: DivrData? = nil) {
        AppLog.debug("DEBUG: AddDvirViewModel - init")
        super.init()
        if let data = dvirData {
            AppLog.debug("DEBUG: AddDvirViewModel - init with existing data: \(data.id ?? "unknown")")
            self.editingDvirId = data.id
            preFillData(data)
        } else {
            AppLog.debug("DEBUG: AddDvirViewModel - init new report")
            setupInitialData()
            setupLocation() // Only auto-detect location for new reports
        }
    }
    
    private func preFillData(_ data: DivrData) {
        // Pre-fill time
        if let dateStr = data.dvir_date_time {
             let formatter = ISO8601DateFormatter()
             formatter.timeZone = getAppTimeZone()
             formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
             if let date = formatter.date(from: dateStr) {
                 self.time = date
             } else {
                 // Try without fractional seconds
                 formatter.formatOptions = [.withInternetDateTime]
                 if let date = formatter.date(from: dateStr) {
                     self.time = date
                 }
             }
        }
        
        self.location = data.location ?? ""
        self.odometer = data.odometer.map { String(format: "%.1f", (Double($0) ?? 0.0) * 0.621371) } ?? ""
        self.company = Global.shared.myProfile?.company?.name ?? ""
        self.status = data.status ?? "Vehicle Condition Satisfactory"
        self.remarks = data.remarks ?? ""
        self.trailers = data.trailers ?? []
        
        if let vehicleId = data.vehicle?.vehicle_id {
            self.selectedVehicle = Global.shared.vehicleList.first(where: { $0.vehicle_id == vehicleId })
        }
        
        self.vehicleDefects = data.vehicle_defects ?? []
        self.trailerDefects = data.trailer_defects ?? []
        
        // We cannot pre-fill the signature image from a URL easily back into UIImage for re-submission 
        // without downloading it. For now, we might require re-signing or assume the backend handles "no signature sent = keep old".
        // However, the form requires a signature. 
        // Let's assume user must re-sign or we skip validation if editing?
        // User requirements didn't specify. I'll leave signature empty and require re-sign for now as it's legal doc.
    }
    
    private func setupInitialData() {
        let rawOdoKM = Global.shared.virtualDashboardData?.odometer ?? 0.0
        let offsetMiles = Double(selectedVehicle?.offset ?? Global.shared.connectedVehicleOffset)
        let offsetKM = offsetMiles / 0.621371
        let totalOdometerKM = rawOdoKM + offsetKM
        self.odometer = String(format: "%.1f", totalOdometerKM * 0.621371)
        self.company = Global.shared.myProfile?.company?.name ?? ""
    }
    
    private func setupLocation() {
        AppLog.debug("DEBUG: AddDvirViewModel - setupLocation started")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private var hasResolvedLocation = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last, !hasResolvedLocation else { return }
        AppLog.debug("DEBUG: AddDvirViewModel - didUpdateLocations: \(loc.coordinate)")
        
        // Stop updating immediately to prevent further delegate calls
        locationManager.stopUpdatingLocation()
        hasResolvedLocation = true
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(loc) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let place = placemarks?.first {
                var addressString = ""
                if let subThoroughfare = place.subThoroughfare { addressString += subThoroughfare + " " }
                if let thoroughfare = place.thoroughfare { addressString += thoroughfare + ", " }
                if let locality = place.locality { addressString += locality + ", " }
                if let administrativeArea = place.administrativeArea { addressString += administrativeArea }
                
                DispatchQueue.main.async {
                    AppLog.debug("DEBUG: AddDvirViewModel - Location resolved: \(addressString)")
                    if self.location.isEmpty { // Only set if empty
                         self.location = addressString
                    }
                }
            }
        }
    }
    
    func updateStatus() {
        AppLog.debug("DEBUG: AddDvirViewModel - updateStatus called")
        let hasDefects = !vehicleDefects.isEmpty || !trailerDefects.isEmpty
        AppLog.debug("DEBUG: AddDvirViewModel - hasDefects: \(hasDefects) (Vehicle: \(vehicleDefects.count), Trailer: \(trailerDefects.count))")
        
        // Remove "Vehicle Condition Satisfactory" if defects exist
        if hasDefects {
            if status == "Vehicle Condition Satisfactory" {
                AppLog.debug("DEBUG: AddDvirViewModel - Changing status to 'Has Defects'")
                status = "Has Defects"
            }
        } else {
            // If no defects, default back if currently "Has Defects" or similar? 
            // The logic in snippet:
            // if (DefectsField.text == "" && Defect2Field.text == "") -> "Vehicle Condition Satisfactory"
            if status == "Has Defects" {
                AppLog.debug("DEBUG: AddDvirViewModel - Changing status back to 'Vehicle Condition Satisfactory'")
                status = "Vehicle Condition Satisfactory"
            }
        }
    }
    
    func submitDvir() {
        guard validate() else { return }
        
        isLoading = true
        
        // Format Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateSelected = dateFormatter.string(from: time)

        // Odometer is entered in miles in UI, which already includes offset if it was auto-populated
        let finalOdoMiles = odometer
        let odoKM = (Double(odometer) ?? 0.0) / 0.621371
        let finalOdoKM = String(format: "%.0f", odoKM)

        // Params
        var params: [String: Any] = [
            "dvir_date_time": dateSelected,
            "location": location,
            "odometer": finalOdoMiles,
            "odometer_km": finalOdoKM,
            "status": status,
            "remarks": remarks,
            "trailer_defects": trailerDefects,
            "vehicle": selectedVehicle?.vehicle_id ?? "",
            "vehicle_defects": vehicleDefects,
            "trailers": trailers
        ]
        
        // Only include signature if it's new/changed. If editing and no new signature, maybe backend keeps old?
        // But our validate() requires signature. User must re-sign.
        params["signature_image"] = signatureImage ?? UIImage()
        
        AppLog.debug("Submitting DVIR Params: \(params)")

        var url = ApiList.Divrs
        var method: HTTPMethod = .post
        
        if let id = editingDvirId {
            url = ApiList.Divrs + "\(id)/"
            method = .patch // Using PATCH for updates
        }

        APIManager.shared.upload(url: url, method: method, parameters: params) { [weak self] completion in
                 DispatchQueue.main.async {
                     self?.isLoading = false
                 }
        } success: { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.submitSuccess = true
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.alertMessage = error?.description ?? "Unknown error"
                self?.showAlert = true
            }
        }
    }
    
    func validate() -> Bool {
        // Reset Error Flags
        isVehicleError = false
        isOdometerError = false
        isRemarksError = false
        isSignatureError = false
        
        var isValid = true
        
        if selectedVehicle == nil {
            isVehicleError = true
            isValid = false
        }
        
        if odometer.isEmpty {
            isOdometerError = true
            isValid = false
        }
        
        if remarks.trimmingCharacters(in: .whitespaces).isEmpty {
            isRemarksError = true
            isValid = false
        }
        
        if signatureImage == nil {
            isSignatureError = true
            isValid = false
        }
        
        if !isValid {
            alertMessage = "Please fill in all mandatory fields highlighted in red."
            showAlert = true
        }
        
        return isValid
    }
}
