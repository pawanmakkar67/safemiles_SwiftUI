import Foundation
import CoreBluetooth
import Combine
import SwiftUI
import PacificTrack
import ObjectMapper
import Alamofire

/// Tracker Peripheral Wrapper
struct TrackerPeripheral {
    let peripheral: CBPeripheral
    let rssi: NSNumber
}

/// Centralized BLE Manager
class BLEManager: NSObject, ObservableObject, TrackerServiceDelegate {
    
    static let shared = BLEManager()
    
    @Published var state: CBManagerState = .unknown
    @Published var discoveredPeripherals = [TrackerPeripheral]()
    @Published var connectedPeripheral: CBPeripheral?
    
    private var lastFetchedVin: String?
    
    var centralManager: CBCentralManager!
    
    private override init() {
        super.init()
        // Use background queue for BLE
        let queue = DispatchQueue(label: "com.yourapp.ble", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: queue, options: [
            CBCentralManagerOptionRestoreIdentifierKey: "BLEManagerRestoreIdentifier"
        ])
    }
    
    // MARK: - BLE Actions
    
    func startScan() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: [CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")], options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        // Stop handling via TrackerService first
        if let peripheral = TrackerService.sharedInstance.stopHandling() {
            centralManager.cancelPeripheralConnection(peripheral)
        } else if let peripheral = connectedPeripheral {
            // Fallback if stopHandling returns nil
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func handleDiscovered(peripheral: CBPeripheral, rssi: NSNumber) {
        DispatchQueue.main.async {
            // Avoid duplicates
            if !self.discoveredPeripherals.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
                self.discoveredPeripherals.append(TrackerPeripheral(peripheral: peripheral, rssi: rssi))
            }
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        handleDiscovered(peripheral: peripheral, rssi: RSSI)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.state = central.state
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.connectedPeripheral = peripheral
            self.updateTrackerDelegate()
            // Let TrackerService handle the peripheral
            TrackerService.sharedInstance.handle(trackerPeripheral: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            if self.connectedPeripheral?.identifier == peripheral.identifier {
                self.connectedPeripheral = nil
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("Restoring state: \(dict)")
        
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral],
           let first = peripherals.first {
            DispatchQueue.main.async {
                self.connectedPeripheral = first
                self.updateTrackerDelegate()
                TrackerService.sharedInstance.handle(trackerPeripheral: first)
            }
            print("Restored connected peripheral: \(first.identifier)")
        } else if let services = dict["kCBRestoredScanServices"] as? [CBUUID] {
             print("Restored scan services: \(services)")
             central.scanForPeripherals(withServices: services, options: nil)
             
             let serviceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
             let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [serviceUUID])
             
             if let peripheral = peripherals.first {
                 print("Retrieved already connected peripheral: \(peripheral.identifier)")
                 // Ensure we stop handling before disconnecting/reconnecting logic
                 _ = TrackerService.sharedInstance.stopHandling()
                 centralManager.cancelPeripheralConnection(peripheral)
                 
                 DispatchQueue.main.async {
                     self.connectedPeripheral = nil
                 }
                 // Reset delegate if needed or just continue
             }
        }
        
        if central.state == .poweredOn {
            startScan()
        }
    }
}

// MARK: - Bluetooth Validation & Settings Navigation
extension BLEManager {
    
    /// Check whether Bluetooth is ON. If not, optionally show alert and route to settings.
    func validateBluetoothStatus(
        from viewController: UIViewController,
        showAlert: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        let state = centralManager.state
        
        switch state {
        case .poweredOn:
            completion?(true)
        default:
            completion?(false)
            if showAlert {
                DispatchQueue.main.async {
                    self.showBluetoothSettingsAlert(from: viewController)
                }
            }
        }
    }
    
    private func showBluetoothSettingsAlert(from viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Bluetooth is Off",
            message: "Please enable Bluetooth in Settings to continue using this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            self.openBluetoothSettings()
        }))
        
        viewController.present(alert, animated: true)
    }
    
    private func openBluetoothSettings() {
        if let url = URL(string: "App-Prefs:root=Bluetooth"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func updateTrackerDelegate() {
        TrackerService.sharedInstance.delegate = self
    }
}

// MARK: - TrackerServiceDelegate
extension BLEManager {
    
    func trackerService(_ trackerService: TrackerService, didSync trackerInfo: TrackerInfo) {
        print("Tracker Synced: \(trackerInfo.productName)")
        refreshDeviceInfo(withTrackerInfo: trackerInfo)
    }
    
    func trackerService(_ trackerService: TrackerService, didReceieveVirtualDashboardReport virtualDashboardReport: VirtualDashboardReport) {
        let virtualDashboardData = trackerService.virtualDashboardData
        
        // Update Global Shared Data
        DispatchQueue.main.async {
            Global.shared.virtualDashboardData = virtualDashboardData
            
            // Also update odometer as per user snippet
            if let odometer = virtualDashboardData.odometer {
                 Global.shared.odometer = "\(odometer)"
            }
        }
        
        print("Virtual Dashboard Updated: Speed: \(virtualDashboardData.speed ?? 0), RPM: \(virtualDashboardData.rpm ?? 0)")
        
        // Note: The user's snippet had a lot of dictionary updates (eldevice, virtualDashboard). 
        // Assuming those are legacy or external dictionaries. 
        // For the SwiftUI views (DeviceDetailView), they rely on Global.shared.
    }
    
    func trackerService(_ trackerService: TrackerService, didRetrieve event: EventFrame, processed: ((Bool) -> Void)) {
        // Handle stored events if needed
        processed(true)
    }

    func trackerService(_ trackerService: TrackerService, didReceive event: EventFrame, processed: ((Bool) -> Void)) {
        DispatchQueue.main.async {
            Global.shared.EventData = event
        }
        
        let eventTypeTag = event.getValue(forTag: "E") ?? ""
        print("Event Received: #\(event.sequenceNumber) \(eventTypeTag)")
        
        // Fetch vehicle details when event data is received
        Task {
            await self.getVehicleDetails()
        }
        
        // Notify system that event is processed
        processed(true)
    }
    
    func trackerService(_ trackerService: TrackerService, didReceiveSPN spnEvent: SPNEventFrame, processed: ((Bool) -> Void)) {
        processed(true)
    }
    
    func trackerService(_ trackerService: TrackerService, onError error: TrackerServiceError) {
        print("Tracker Service Error: \(error)")
    }
    
    func trackerService(_ trackerService: TrackerService, onFirmwareUpgradeProgress progress: Float) {
        // Handle firmware progress if needed
    }
    
    func trackerService(_ trackerService: TrackerService, onFirmwareUpgradeFailed error: TrackerUpgradeError) {
        // Handle failure
    }
    
    func trackerService(_ trackerService: TrackerService, onFirmwareUpgradeCompleted completed: Bool) {
        // Handle completion
    }
    
    // MARK: - Helper Methods
    
    func refreshDeviceInfo(withTrackerInfo trackerInfo: TrackerInfo) {
        DispatchQueue.main.async {
            Global.shared.trackerInfoV = trackerInfo
        }
        
        print("Device Info Updated: \(trackerInfo.serialNumber)")
        
        // If there are other specific dictionary updates required (like 'eldevice' or 'virtualDashboard' dictionaries 
        // mentioned in the snippet), they should be added here if those variables are accessible.
        // For now, updating Global.shared is the critical part for the new views.
    }
    
    // MARK: - Vehicle Details API
    
    func getVehicleDetails() async {
        // Get VIN from EventData
        guard let eventData = Global.shared.trackerInfoV,
              let vehicleVinNo = eventData.vin,
              !vehicleVinNo.isEmpty,
              vehicleVinNo != lastFetchedVin else {
            return
        }
        
        lastFetchedVin = vehicleVinNo
        
        let vehicleUrl = ApiList.getVehicleDetails + vehicleVinNo + "/"
        
        APIManager.shared.request(url: vehicleUrl, method: .get) { comp in
            // Completion handler
        } success: { response in
            let obj = Mapper<VehicleDetailsModel>().map(JSONObject: response)
            Global.shared.connectVehicleDetail = obj
            UserDefaults.setConnectvehicle(obj)
            print("Vehicle details fetched successfully for VIN: \(vehicleVinNo)")
        } failure: { error in
            print("Failed to fetch vehicle details: \(error)")
        }
    }
}
