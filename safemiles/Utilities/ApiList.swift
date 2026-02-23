//
//  ApiList.swift
//  ELD
//
//  Created by Tejinder on 19/08/25.
//

import SwiftUI
import PacificTrack

//let BASEURL = "https://api.thesafemiles.com/api/v1/"
//let MainBASEURL = "https://thesafemiles.com/"
//let MainBASEURL1 = "https://thesafemiles.com/"

let BASEURL = "https://sgapi.thesafemiles.com/api/v1/"
let MainBASEURL = "https://sgapi.thesafemiles.com/"
let MainBASEURL1 = "https://sgapi.thesafemiles.com/"

struct ApiList {
    static let loginAPI = BASEURL + "accounts/login/"
    static let getRules = BASEURL + "company/app/rules/"
    static let getLogs = BASEURL + "hos/previous-logs/"                              // change
    static let getCoDrivers = BASEURL + "drivers/app/codrivers/"
    static let getMyprofile = BASEURL + "drivers/app/my-profile/"
    static let Divrs = BASEURL + "drivers/dvirs/"
    static let statusLogs = BASEURL + "drivers/app/logs/"
    static let allvehicles = BASEURL + "company/vehicles/"
    static let updateHardwareEvent = BASEURL + "hos/events/"                      // url changed
    static let manualPDF = MainBASEURL + "media/user_manuals/Mobile_app_user_manual.pdf"
    static let instructionsPDF = MainBASEURL + "media/information_packets/Safe_miles_inspection_mode.pdf"
    static let saveForms = BASEURL + "hos/logs/"               // url + payload changed
    static let RecapApi = BASEURL + "hos/recap/"
    static let sendLogs = BASEURL + "drivers/app/send-logs/"
    static let sendEmail = BASEURL + "drivers/app/email-logs/"
    static let getVehicleDetails = BASEURL + "company/get-vehicle/"
    
}



final class Global {
    static let shared = Global()
    var recapvalues : RecapModel?
    var logsDataVal: logsModel? {
            didSet {
                NotificationCenter.default.post(
                    name: .logsDataUpdated,
                    object: logsDataVal
                )
            }
        }
    var vehicleList = [VehicleData]()
    var coDriverList : [CoDriverData]?
    var connectVehicleDetail : VehicleDetailsModel?
    var myProfile : ProfileData?
    var odometer = ""
    var logsTotalCount = 0
    var virtualDashboardData : PacificTrack.VirtualDashboardData? {
        didSet {
            NotificationCenter.default.post(
                name: .telematicsUpdated,
                object: virtualDashboardData
            )
        }
    }
    
    var EventData : EventFrame? {
        didSet {
            NotificationCenter.default.post(
                name: .telematicsUpdated,
                object: virtualDashboardData
            )
        }
    }
    
    var trackerInfoV : TrackerInfo?
    
    private init() {}
}


extension Notification.Name {
    static let logsDataUpdated = Notification.Name("logsDataUpdated")
    static let recapUpdate = Notification.Name("recapUpdate")
    static let logsUpdate = Notification.Name("logsUpdate")
    static let telematicsUpdated = Notification.Name("telematicsUpdated")
    static let dvirUpdated = Notification.Name("dvirUpdated")
}
