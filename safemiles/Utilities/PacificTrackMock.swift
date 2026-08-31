#if targetEnvironment(simulator)
import Foundation
import CoreBluetooth

// Mock PacificTrack namespace
public enum PacificTrack {
    public struct VirtualDashboardData {
        public var speed: Double?
        public var rpm: Int?
        public var odometer: Double?
        public var currentGear: Int?
        public var seatbeltOn: Bool?
        public var numberOfDTCPending: Int?
        public var oilPressure: Double?
        public var oilLevel: Double?
        public var coolantLevel: Double?
        public var coolantTemperature: Double?
        public var fuelLevel: Double?
        public var engineLoad: Double?
        public var fuelRate: Double?
        public var totalFuelUsed: Double?
        public var engineHours: Double?
        public var busType: String?
        public var odometerComputed: Double?
        public var engineHoursComputed: Double?
        public var oilTemperature: Double?
        public var DEFlevel: Double?
        public var barometer: Double?
        public var intakeManifoldTemperature: Double?
        public var engineFuelTankTemperature: Double?
        public var engineIntercoolerTemperature: Double?
        public var engineTurboOilTemperature: Double?
        public var transmisionOilTemperature: Double?
        public var fuelLevel2: Double?
        public var averageFuelEconomy: Double?
        public var ambientAirTemperature: Double?
        public var idleHours: Double?
        public var PTOHours: Double?
        public var totalIdleFuel: Double?
        public var vin: String?
        
        public init() {}
        
        public func toJSONString() -> String? {
            return nil
        }
    }
}

// Global typealiases for easier access
public typealias VirtualDashboardData = PacificTrack.VirtualDashboardData
public typealias TrackerInfo = PacificTrackMock.TrackerInfo
public typealias VirtualDashboardReport = PacificTrackMock.VirtualDashboardReport
public typealias EventFrame = PacificTrackMock.EventFrame
public typealias EventType = PacificTrackMock.EventType
public typealias SPNEventFrame = PacificTrackMock.SPNEventFrame
public typealias TrackerServiceError = PacificTrackMock.TrackerServiceError
public typealias TrackerUpgradeError = PacificTrackMock.TrackerUpgradeError

// Using a separate enum for other mock types
public enum PacificTrackMock {
    public enum EventType: Int {
        case unknown = 0
    }

    public struct Version {
        public var version: String = "1.0.0"
        public init() {}
    }
    
    public struct TrackerInfo {
        public var vin: String?
        public var serialNumber: String = ""
        public var productName: String = ""
        public var mainVersion: Version = Version()
        public var bleVersion: Version = Version()
        public init() {}
    }

    public struct VirtualDashboardReport {
        public init() {}
    }

    public struct Geolocation {
        public var latitude: Double = 0.0
        public var longitude: Double = 0.0
        public var heading: Double = 0.0
        public var isLocked: Bool = false
        public init() {}
    }

    public struct EventFrame {
        public var sequenceNumber: Int = 0
        public var eventType: EventType = .unknown
        public var datetime: Date = Date()
        public var geolocation: Geolocation = Geolocation()
        public var odometer: Double = 0.0
        public var velocity: Double = 0.0
        public var engineHours: Double = 0.0
        public var rpm: Int = 0
        
        public init() {}
        
        public func getValue(forKey key: String) -> String? { nil }
        // Adding getValue(forTag:) just in case
        public func getValue(forTag tag: String) -> String? { nil }
    }

    public struct SPNEventFrame {
        public init() {}
    }

    public enum TrackerServiceError: Error {
        case mockError
    }

    public enum TrackerUpgradeError: Error {
        case mockError
    }
}

// Mock Delegate
public protocol TrackerServiceDelegate: AnyObject {
    func trackerService(_ trackerService: TrackerService, didSync trackerInfo: TrackerInfo)
    func trackerService(_ trackerService: TrackerService, didReceieveVirtualDashboardReport virtualDashboardReport: VirtualDashboardReport)
    func trackerService(_ trackerService: TrackerService, didRetrieve event: EventFrame, processed: @escaping ((Bool) -> Void))
    func trackerService(_ trackerService: TrackerService, didReceive event: EventFrame, processed: @escaping ((Bool) -> Void))
    func trackerService(_ trackerService: TrackerService, didReceiveSPN spnEvent: SPNEventFrame, processed: @escaping ((Bool) -> Void))
    func trackerService(_ trackerService: TrackerService, onError error: TrackerServiceError)
    func trackerService(_ trackerService: TrackerService, onFirmwareUpgradeProgress progress: Float)
    func trackerService(_ trackerService: TrackerService, onFirmwareUpgradeFailed error: TrackerUpgradeError)
    func trackerService(_ trackerService: TrackerService, onFirmwareUpgradeCompleted completed: Bool)
}

// Mock Service
public class TrackerService {
    public static let sharedInstance = TrackerService()
    public weak var delegate: TrackerServiceDelegate?
    public var virtualDashboardData = VirtualDashboardData()
    
    public init() {}
    
    public func handle(trackerPeripheral: CBPeripheral) {}
    public func stopHandling() -> CBPeripheral? { nil }
}
#endif
