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

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        logs <- map["logs"]
        metadata <- map["metadata"]
    }

}


struct Metadata : Mappable {
    var driver_id : String?
    var timezone : String?
    var start_date : String?
    var end_date : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        driver_id <- map["driver_id"]
        timezone <- map["timezone"]
        start_date <- map["start_date"]
        end_date <- map["end_date"]
    }

}


struct Logs : Mappable {
    var date : String?
    var hours_driven : String?
    var events : [Events]?
    var violations : [String]?
    var log : Log?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        date <- map["date"]
        hours_driven <- map["hours_driven"]
        events <- map["events"]
        violations <- map["violations"]
        log <- map["log"]
    }

}


struct Events : Mappable {
    var id : String?
    var code : String?
    var eventdatetime : String?
    var latitude : Double?
    var longitude : Double?
    var location_notes : String?
    var odometer : Double?
    var last_odometer : Double?
    var engine_hours : Double?
    var last_engine_hours : Double?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        code <- map["code"]
        eventdatetime <- map["eventdatetime"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        location_notes <- map["location_notes"]
        odometer <- map["odometer"]
        last_odometer <- map["last_odometer"]
        engine_hours <- map["engine_hours"]
        last_engine_hours <- map["last_engine_hours"]
    }

}

struct Log : Mappable {
    var id : String?
    var logdate : String?
    var signature : String?
    var certified : Bool?
    var trailers : String?
    var shipping_docs : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        logdate <- map["logdate"]
        signature <- map["signature"]
        certified <- map["certified"]
        trailers <- map["trailers"]
        shipping_docs <- map["shipping_docs"]
    }

}
