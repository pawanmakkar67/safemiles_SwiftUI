
import SwiftUI
import Combine
import ObjectMapper
import Alamofire
import CoreBluetooth

class SelectVehicleViewModel: ObservableObject {
    @Published var vehicles: [VehicleData] = []
    @Published var searchQuery: String = ""
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false
    
    // Filtered list based on search query
    var filteredVehicles: [VehicleData] {
        if searchQuery.isEmpty {
            return vehicles
        } else {
            return vehicles.filter { vehicle in
                let name = vehicle.unit_number?.lowercased() ?? ""
                let model = vehicle.vehicle_model?.lowercased() ?? ""
                return name.contains(searchQuery.lowercased()) || model.contains(searchQuery.lowercased())
            }
        }
    }
    
    private let ble = BLEManager.shared
    
    init() {
        self.vehicles = Global.shared.vehicleList
        if self.vehicles.isEmpty {
            fetchVehicles()
        }
    }
    
    func fetchVehicles() {
        isLoading = true
        APIManager.shared.request(url: ApiList.allvehicles, method: .get) { [weak self] _ in
            
        } success: { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let obj = Mapper<vehicleModel>().map(JSONObject: response) {
                    let list = obj.data ?? []
                    Global.shared.vehicleList = list
                    self?.vehicles = list
                }
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.alertMessage = error
                self?.showAlert = true
            }
        }
    }
    
    func connect(to vehicle: VehicleData) {
        guard let eldUUID = vehicle.eld?.device_uuid, !eldUUID.isEmpty else {
            self.alertMessage = "Device UUID is missing for this vehicle."
            self.showAlert = true
            return
        }
        
        let targetUUID = eldUUID.lowercased()
        
        if ble.connectedPeripheral != nil {
            // Already connected logic - maybe disconnect first? or Alert?
            // Legacy code checks if connectedPeripheral == nil
            self.alertMessage = "Using vehicle: \(vehicle.unit_number ?? "")"
            self.showAlert = true
            // In a real scenario we might check if the connected one IS this one.
            return 
        }
        
        // Scan logic from legacy
        if !ble.discoveredPeripherals.isEmpty {
            if let targetDevice = ble.discoveredPeripherals.first(where: { $0.peripheral.identifier.uuidString.lowercased() == targetUUID }) {
                ble.connect(to: targetDevice.peripheral)
                // Connection might take time, listen to callback in View or Manager
            } else {
                self.alertMessage = "Device not found in range. Scanning..."
                self.showAlert = true
                // Ensure scanning is active
                if ble.state == .poweredOn {
                    ble.startScan()
                }
            }
        } else {
             self.alertMessage = "Scanning for devices..."
             self.showAlert = true
             if ble.state == .poweredOn {
                ble.startScan()
             }
        }
    }
}
