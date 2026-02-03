/* 
Copyright (c) 2025 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct DivrModel : Mappable {
	var data : [DivrData]?
	var success : Bool?
	var message : String?
    var total_count : Int?

	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		data <- map["data"]
		success <- map["success"]
		message <- map["message"]
        total_count <- map["total_count"]
	}

}

struct createDivr : Mappable {
    var data : DivrData?
    var success : Bool?
    var message : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        data <- map["data"]
        success <- map["success"]
        message <- map["message"]
    }

}

struct DivrData : Mappable {
    var id : String?
    var driver : Driver?
    var vehicle : VehicleData?
    var signature_image : String?
    var dvir_date_time : String?
    var location : String?
    var odometer : String?
    var vehicle_defects : [String]?
    var trailer_defects : [String]?
    var remarks : String?
    var status : String?
    var trailers: [String]?
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        driver <- map["driver"]
        vehicle <- map["vehicle"]
        signature_image <- map["signature_image"]
        dvir_date_time <- map["dvir_date_time"]
        location <- map["location"]
        odometer <- map["odometer"]
        vehicle_defects <- map["vehicle_defects"]
        trailer_defects <- map["trailer_defects"]
        remarks <- map["remarks"]
        status <- map["status"]
        trailers <- map["trailers"]
    }

}
