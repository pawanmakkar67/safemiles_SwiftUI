/* 
Copyright (c) 2025 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper



//struct logsData : Mappable {
//    var todays_log : Logs?
//    var logs : [Logs]?
//    var last_event : Last_event?
//    var violation_data : Violation_data?
//
//    init?(map: Map) {
//
//    }
//
//    mutating func mapping(map: Map) {
//
//        todays_log <- map["todays_log"]
//        logs <- map["logs"]
//        last_event <- map["last_event"]
//        violation_data <- map["violation_data"]
//    }
//
//}






/*
Copyright (c) 2026 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct logsModel : Mappable {
    var logs : [Logs]?
    var metadata : Metadata?
    var recap : RecapModel?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        logs <- map["logs"]
        metadata <- map["metadata"]
        recap <- map["recap"]
    }

}


struct Co_driver : Mappable {
    var id : String?
    var first_name : String?
    var last_name : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        first_name <- map["first_name"]
        last_name <- map["last_name"]
    }

}


struct Metadata : Mappable {
    var driver_id : String?
    var timezone : String?
    var start_date : String?
    var end_date : String?
    var company : Company?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        driver_id <- map["driver_id"]
        timezone <- map["timezone"]
        start_date <- map["start_date"]
        end_date <- map["end_date"]
        company <- map["company"]
    }

}

struct Logs : Mappable {
    var date : String?
    var hours_driven : String?
    var events : [Events]?
    var violations : [Violation]?
    var log : Log?
    var last_code : String?
    var vehicle : VehicleData?
    var odometer : Int?
    var engine_hours : Int?
    var distance : Int?
    var mac_address : String?
    var provider : String?
    var home_terminal : Home_terminal?
    var eld_identifier : String?
    var eld_registration : String?
    var unidentified_records : String?
    var diagnose_indicator : String?
    var malfunctioning : String?
    var period_starting_time_24 : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        date <- map["date"]
        hours_driven <- map["hours_driven"]
        events <- map["events"]
        violations <- map["violations"]
        log <- map["log"]
        last_code <- map["last_code"]
        vehicle <- map["vehicle"]
        odometer <- map["odometer"]
        engine_hours <- map["engine_hours"]
        distance <- map["distance"]
        mac_address <- map["mac_address"]
        provider <- map["provider"]
        home_terminal <- map["home_terminal"]
        eld_identifier <- map["eld_identifier"]
        eld_registration <- map["eld_registration"]
        unidentified_records <- map["unidentified_records"]
        diagnose_indicator <- map["diagnose_indicator"]
        malfunctioning <- map["malfunctioning"]
        period_starting_time_24 <- map["24_period_starting_time"]
    }

}

struct Violation : Mappable {
    var id : String?
    var violation_type : String?
    var violation_notes : String?
    var occurred_at : String?
    
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        violation_type <- map["violation_type"]
        violation_notes <- map["violation_notes"]
        occurred_at <- map["occurred_at"]
    }

}


struct Events : Mappable {
    var id : String?
    var code : String?
    var origin : String?
    var eventdatetime : String?
    var latitude : String?
    var longitude : String?
    var location_notes : String?
    var event_notes : String?
    var odometer : Double?
    var last_odometer : Double?
    var engine_hours : String?
    var last_engine_hours : String?
    var sb_break : Int?
    var time_diff : Int?
    var is_last_event : Bool?
    var vehicle : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        code <- map["code"]
        origin <- map["origin"]
        eventdatetime <- map["eventdatetime"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        location_notes <- map["location_notes"]
        event_notes <- map["event_notes"]
        odometer <- map["odometer"]
        last_odometer <- map["last_odometer"]
        engine_hours <- map["engine_hours"]
        last_engine_hours <- map["last_engine_hours"]
        sb_break <- map["sb_break"]
        time_diff <- map["time_diff"]
        is_last_event <- map["is_last_event"]
        vehicle <- map["vehicle"]
    }

}

struct Log : Mappable {
    var id : String?
    var logdate : String?
    var shipping_docs : String?
    var trailers : String?
    var timezone : String?
    var certified : Bool?
    var signature : String?
    var driver : Driver?
    var co_driver : Co_driver?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        logdate <- map["logdate"]
        shipping_docs <- map["shipping_docs"]
        trailers <- map["trailers"]
        timezone <- map["timezone"]
        certified <- map["certified"]
        signature <- map["signature"]
        driver <- map["driver"]
        co_driver <- map["co_driver"]
    }

}

struct Home_terminal : Mappable {
    var id : String?
    var company : String?
    var time_zone : String?
    var period_start_time : String?
    var address_line : String?
    var city : String?
    var state : String?
    var country : String?
    var postal_code : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        company <- map["company"]
        time_zone <- map["time_zone"]
        period_start_time <- map["period_start_time"]
        address_line <- map["address_line"]
        city <- map["city"]
        state <- map["state"]
        country <- map["country"]
        postal_code <- map["postal_code"]
    }

}
