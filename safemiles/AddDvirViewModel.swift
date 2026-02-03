import SwiftUI
import Combine
import ObjectMapper
import Alamofire
import CoreLocation

class AddDvirViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Form Fields
    @Published var time: Date = Date()
    @Published var location: String = ""
    @Published var odometer: String = ""
    @Published var company: String = ""
    @Published var status: String = "Vehicle Condition Satisfactory"
    @Published var remarks: String = ""
    
    @Published var selectedVehicle: VehicleData?
    @Published var vehicleDefects: [String] = []
    
    @Published var trailers: String = ""
    @Published var trailerDefects: [String] = []
    
    @Published var signatureImage: UIImage?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var submitSuccess: Bool = false
    
    // Data Sources
    let statusOptions = ["Vehicle Condition Satisfactory", "Has Defects", "Defects Corrected", "Defects Need Not Be Corrected"]
    
    // Edit Mode
    var editingDvirId: String?
    
    // Location
    private let locationManager = CLLocationManager()
    
    init(dvirData: DivrData? = nil) {
        super.init()
        if let data = dvirData {
            self.editingDvirId = data.id
            preFillData(data)
        } else {
            setupInitialData()
            setupLocation() // Only auto-detect location for new reports
        }
    }
    
    private func preFillData(_ data: DivrData) {
        // Pre-fill time
        if let dateStr = data.dvir_date_time {
             let formatter = ISO8601DateFormatter()
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
        self.odometer = data.odometer ?? ""
        self.company = Global.shared.myProfile?.company?.name ?? ""
        self.status = data.status ?? "Vehicle Condition Satisfactory"
        self.remarks = data.remarks ?? ""
        self.trailers = data.trailers?.joined(separator: ", ") ?? ""
        
        if let vehicleId = data.vehicle?.id {
            self.selectedVehicle = Global.shared.vehicleList.first(where: { $0.id == vehicleId })
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
        self.odometer = Global.shared.odometer
        self.company = Global.shared.myProfile?.company?.name ?? ""
    }
    
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        locationManager.stopUpdatingLocation()
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(loc) { placemarks, error in
            if let place = placemarks?.first {
                var addressString = ""
                if let subThoroughfare = place.subThoroughfare { addressString += subThoroughfare + " " }
                if let thoroughfare = place.thoroughfare { addressString += thoroughfare + ", " }
                if let locality = place.locality { addressString += locality + ", " }
                if let administrativeArea = place.administrativeArea { addressString += administrativeArea }
                
                DispatchQueue.main.async {
                    if self.location.isEmpty { // Only set if empty
                         self.location = addressString
                    }
                }
            }
        }
    }
    
    func updateStatus() {
        let hasDefects = !vehicleDefects.isEmpty || !trailerDefects.isEmpty
        
        // Remove "Vehicle Condition Satisfactory" if defects exist
        if hasDefects {
            if status == "Vehicle Condition Satisfactory" {
                status = "Has Defects"
            }
        } else {
            // If no defects, default back if currently "Has Defects" or similar? 
            // The logic in snippet:
            // if (DefectsField.text == "" && Defect2Field.text == "") -> "Vehicle Condition Satisfactory"
            if status == "Has Defects" {
                status = "Vehicle Condition Satisfactory"
            }
        }
    }
    
    func submitDvir() {
        guard validate() else { return }
        
        isLoading = true
        
        // Format Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateSelected = dateFormatter.string(from: time)
        
        // Trailers Array
        let trailersArr = trailers.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        // Params
        var params: [String: Any] = [
            "dvir_time": dateSelected,
            "location": location,
            "odometer": odometer,
            "status": status,
            "remarks": remarks,
            "trailer_defects": trailerDefects,
            "vehicle": selectedVehicle?.id ?? "",
            "vehicle_defects": vehicleDefects,
            "trailers": trailersArr
        ]
        
        // Only include signature if it's new/changed. If editing and no new signature, maybe backend keeps old?
        // But our validate() requires signature. User must re-sign.
        params["signature_image"] = signatureImage ?? UIImage()
        
        print("Submitting DVIR Params: \(params)")

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
                self?.errorMessage = error?.description ?? "Unknown error"
            }
        }
    }
    
    func validate() -> Bool {
        if selectedVehicle == nil {
            errorMessage = "Please select a vehicle"
            return false
        }
        if location.isEmpty {
            errorMessage = "Please enter location"
            return false
        }
        if signatureImage == nil {
            errorMessage = "Please sign the report"
            return false
        }
        // Add other validations as needed
        return true
    }
}
