/*
Copyright (c) 2026 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct RecapModel : Mappable {
    var message : String?
    var recap_days : [Recap_days]?
    var hos_status : Hos_status?
    var last_event : Last_event?
    var cycle_start_local : String?
    var hours_available : String?
    var hours_worked : String?
    var violations : [Violation]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        message <- map["message"]
        recap_days <- map["recap_days"]
        hos_status <- map["hos_status"]
        last_event <- map["last_event"]
        cycle_start_local <- map["cycle_start_local"]
        hours_available <- map["hours_available"]
        hours_worked <- map["hours_worked"]
        violations <- map["violation"]
    }

}

struct Recap_days : Mappable {
    var day : String?
    var date : String?
    var worked_hours : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        day <- map["day"]
        date <- map["date"]
        worked_hours <- map["worked_hours"]
    }

}


struct Company : Mappable {
    var id : String?
    var name : String?
    var dot_number : String?
    var address : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        name <- map["name"]
        dot_number <- map["dot_number"]
        address <- map["address"]
    }

}

struct User : Mappable {
    var username : String?
    var email : String?
    var first_name : String?
    var last_name : String?
    var id : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        username <- map["username"]
        email <- map["email"]
        first_name <- map["first_name"]
        last_name <- map["last_name"]
        id <- map["id"]
    }

}

struct Driver : Mappable {
    var id : String?
    var user : User?
    var company : Company?
    var vehicle : VehicleData?
    var timezone : String?
    var terminal_address : String?
    var company_driver_id : String?
    var license_number : String?
    var license_state : String?
    var log_setting_exempt : Bool?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        user <- map["user"]
        company <- map["company"]
        vehicle <- map["vehicle"]
        timezone <- map["timezone"]
        terminal_address <- map["terminal_address"]
        company_driver_id <- map["company_driver_id"]
        license_number <- map["license_number"]
        license_state <- map["license_state"]
        log_setting_exempt <- map["log_setting_exempt"]
    }

}


struct Hos_status : Mappable {
    var driver : Driver?
    var date : String?
    var latitude : Double?
    var longitude : Double?
    var code_on_sec : Int?
    var code_d_sec : Int?
    var code_sb_sec : Int?
    var code_off_sec : Int?
    var cycle : String?
    var drive : String?
    var break1 : String?
    var shift : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        driver <- map["driver"]
        date <- map["date"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        code_on_sec <- map["code_on_sec"]
        code_d_sec <- map["code_d_sec"]
        code_sb_sec <- map["code_sb_sec"]
        code_off_sec <- map["code_off_sec"]
        cycle <- map["cycle"]
        drive <- map["drive"]
        break1 <- map["break"]
        shift <- map["shift"]
    }

}


struct Last_event : Mappable {
    var id : String?
    var entry_by : String?
    var eventdatetime : String?
    var code : String?
    var origin : String?
    var status : String?
    var odometer : Double?
    var engine_hours : Double?
    var last_odometer : Double?
    var last_engine_hours : Double?
    var positioning : String?
    var latitude : Double?
    var longitude : Double?
    var location_notes : String?
    var event_notes : String?
    var is_deleted : Bool?
    var timezone : String?
    var seq_id : Int?
    var is_split_utilised : Bool?
    var driver : String?
    var vehicle : String?
    var eldevice : String?
    var sb_break : Int?

    
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        entry_by <- map["entry_by"]
        eventdatetime <- map["eventdatetime"]
        code <- map["code"]
        origin <- map["origin"]
        status <- map["status"]
        odometer <- map["odometer"]
        engine_hours <- map["engine_hours"]
        last_odometer <- map["last_odometer"]
        last_engine_hours <- map["last_engine_hours"]
        positioning <- map["positioning"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        location_notes <- map["location_notes"]
        event_notes <- map["event_notes"]
        is_deleted <- map["is_deleted"]
        timezone <- map["timezone"]
        seq_id <- map["seq_id"]
        is_split_utilised <- map["is_split_utilised"]
        driver <- map["driver"]
        vehicle <- map["vehicle"]
        eldevice <- map["eldevice"]
        sb_break <- map["sb_break"]

    }

}
