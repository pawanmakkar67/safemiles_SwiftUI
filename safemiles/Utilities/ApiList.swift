//
//  ApiList.swift
//  ELD
//
//  Created by Tejinder on 19/08/25.
//

import SwiftUI
import Combine

#if !targetEnvironment(simulator)
    import PacificTrack
#endif

//let BASEURL = "https://api.thesafemiles.com/api/v1/"
let MainBASEURL = "https://api.thesafemiles.com/"
let MainBASEURL1 = "https://thesafemiles.com/"
//let MainBASEURL = "https://manuel-fleysome-ophelia.ngrok-free.dev/"


//let MainBASEURL = "https://sgapi.thesafemiles.com/"
//let MainBASEURL1 = "https://sgapi.thesafemiles.com/"

//let MainBASEURL = "http://38.137.14.92:5001/"
//let MainBASEURL1 = "http://38.137.14.92:5001/"

let BASEURL = "\(MainBASEURL)api/v1/"

struct AlertItem: Identifiable {
    var id: String { message }
    var message: String
}

struct ApiList {
    static let loginAPI = BASEURL + "accounts/login/"
    static let getRules = BASEURL + "company/app/rules/"
    static let getLogs = BASEURL + "hos/previous-logs/"  // change
    static let getCoDrivers = BASEURL + "drivers/app/codrivers/"
    static let getMyprofile = BASEURL + "drivers/app/my-profile/"
    static let Divrs = BASEURL + "drivers/dvirs/"
    static let statusLogs = BASEURL + "drivers/app/logs/"
    static let allvehicles = BASEURL + "company/vehicles/"
    static let updateHardwareEvent = BASEURL + "hos/events/"  // url changed
    static let addHardwareEvent = BASEURL + "hos/events/add/"  // url changed
    static let saveForms = BASEURL + "hos/logs/"  // url + payload changed
    static let RecapApi = BASEURL + "hos/recap/"
    static let sendLogs = BASEURL + "hos/eld/transfer/"
    static let sendEmail = BASEURL + "drivers/app/email-logs/"
    static let getVehicleDetails = BASEURL + "company/get-vehicle/"
    static let forgotPassword = BASEURL + "accounts/forget-password/"
    static let refreshTokenAPI = BASEURL + "accounts/token/refresh/"
    static let instructionsPDF =
        "https://safemilesbucket.s3.us-east-1.amazonaws.com/information_packets/Safemiles_instruction_manual.pdf"
    static let manualPDF =
        "https://safemilesbucket.s3.us-east-1.amazonaws.com/user_manuals/Safemiles_User_Manual.pdf"

}

final class Global: ObservableObject {
    static let shared = Global()
    @Published var recapvalues: RecapModel? {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .recapUpdate, object: nil)
            }
        }
    }
var logsDataVal: logsModel? {
        didSet {
            NotificationCenter.default.post(
                name: .logsDataUpdated,
                object: logsDataVal
            )
        }
    }
    var vehicleList = [VehicleData]()
    var coDriverList: [CoDriverData]?
    @Published var connectVehicleDetail: VehicleDetailsModel? {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .vehicleUpdate, object: nil)
            }
        }
    }
    @Published var myProfile: ProfileData? {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .profileUpdate, object: nil)
            }
        }
    }
    var odometer = ""
    var logsTotalCount = 0
    var virtualDashboardData: PacificTrack.VirtualDashboardData? {

        didSet {
            NotificationCenter.default.post(
                name: .telematicsUpdated,
                object: virtualDashboardData
            )
        }
    }

    var EventData: EventFrame? {
        didSet {
            if let raw = EventData?.eventType.rawValue {
                let dateStr = ISO8601DateFormatter().string(from: Date())
                if let index = eventCodeBuffer.firstIndex(where: { ($0["code"] as? Int) == raw }) {
                    eventCodeBuffer[index]["date"] = dateStr
                } else {
                    eventCodeBuffer.append(["code": raw, "date": dateStr])
                }
                latestEventRawValue = raw
            }
            NotificationCenter.default.post(
                name: .telematicsUpdated,
                object: virtualDashboardData
            )
        }
    }
    /// Buffer of recent BLE events: [["code": eventCode, "date": "isoDate"]]
    @Published var eventCodeBuffer: [[String: Any]] = []
    
    /// The raw value of the single most recent event (for UI display)
    @Published var latestEventRawValue: Int? = nil

    var trackerInfoV: TrackerInfo?

    func reset() {
        recapvalues = nil
        logsDataVal = nil
        vehicleList = []
        coDriverList = nil
        connectVehicleDetail = nil
        myProfile = nil
        odometer = ""
        logsTotalCount = 0
        virtualDashboardData = nil
        EventData = nil
        trackerInfoV = nil
        eventCodeBuffer = []
        latestEventRawValue = nil
    }

    func getHeaderTitle() -> String {
        // Source 1: Recap API Response (Recap-first as requested)
        if let recap = recapvalues {
            let firstName = recap.hos_status?.driver?.user?.first_name ?? ""
            let lastName = recap.hos_status?.driver?.user?.last_name ?? ""
            let unitNumber = recap.hos_status?.driver?.vehicle?.unit_number ?? ""

            let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            if !fullName.isEmpty {
                return unitNumber.isEmpty ? fullName : "\(fullName) - \(unitNumber)"
            } else if !unitNumber.isEmpty {
                return unitNumber
            }
        }

        // Source 2: Profile Fallback
        if let profile = myProfile {
            let firstName = profile.user?.first_name ?? ""
            let lastName = profile.user?.last_name ?? ""
            let unitNumber = profile.vehicle?.unit_number ?? ""

            let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            if !fullName.isEmpty {
                return unitNumber.isEmpty ? fullName : "\(fullName) - \(unitNumber)"
            } else if !unitNumber.isEmpty {
                return unitNumber
            }
        }
        
        // Source 3: Connected Vehicle Only
        if let vehicleUnit = connectVehicleDetail?.unit_number, !vehicleUnit.isEmpty {
            return vehicleUnit
        }

        return "Home"
    }

    private init() {}
}

extension Notification.Name {
    static let logsDataUpdated = Notification.Name("logsDataUpdated")
    static let recapUpdate = Notification.Name("recapUpdate")
    static let requestRecapRefresh = Notification.Name("requestRecapRefresh")
    static let drivingStatusChanged = Notification.Name("drivingStatusChanged")
    static let logsUpdate = Notification.Name("logsUpdate")
    static let telematicsUpdated = Notification.Name("telematicsUpdated")
    static let dvirUpdated = Notification.Name("dvirUpdated")
    static let vehicleUpdate = Notification.Name("vehicleUpdate")
    static let profileUpdate = Notification.Name("profileUpdate")
}
