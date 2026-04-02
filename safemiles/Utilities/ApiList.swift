//
//  ApiList.swift
//  ELD
//
//  Created by Tejinder on 19/08/25.
//

import SwiftUI

#if !targetEnvironment(simulator)
    import PacificTrack
#endif

//let BASEURL = "https://api.thesafemiles.com/api/v1/"
//let MainBASEURL = "https://thesafemiles.com/"
//let MainBASEURL1 = "https://thesafemiles.com/"

//let MainBASEURL = "https://sgapi.thesafemiles.com/"
//let MainBASEURL1 = "https://sgapi.thesafemiles.com/"

let MainBASEURL = "http://38.137.14.92:5001/"
let MainBASEURL1 = "http://38.137.14.92:5001/"

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

final class Global {
    static let shared = Global()
    var recapvalues: RecapModel? {
        didSet {
            NotificationCenter.default.post(name: .recapUpdate, object: nil)
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
    var connectVehicleDetail: VehicleDetailsModel? {
        didSet {
            NotificationCenter.default.post(name: .vehicleUpdate, object: nil)
        }
    }
    var myProfile: ProfileData? {
        didSet {
            NotificationCenter.default.post(name: .profileUpdate, object: nil)
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
            NotificationCenter.default.post(
                name: .telematicsUpdated,
                object: virtualDashboardData
            )
        }
    }

    var trackerInfoV: TrackerInfo?

    private init() {}
}

extension Notification.Name {
    static let logsDataUpdated = Notification.Name("logsDataUpdated")
    static let recapUpdate = Notification.Name("recapUpdate")
    static let requestRecapRefresh = Notification.Name("requestRecapRefresh")
    static let logsUpdate = Notification.Name("logsUpdate")
    static let telematicsUpdated = Notification.Name("telematicsUpdated")
    static let dvirUpdated = Notification.Name("dvirUpdated")
    static let vehicleUpdate = Notification.Name("vehicleUpdate")
    static let profileUpdate = Notification.Name("profileUpdate")
}
