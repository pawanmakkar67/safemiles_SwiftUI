/* 
Copyright (c) 2025 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct vehicleModel : Mappable {
	var data : [VehicleData]?
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

struct VehicleData : Mappable {
    var id : String?
    var unit_number : String?
    var vehicle_make : String?
    var vehicle_model : String?
    var vehicle_year : String?
    var vin : String?
    var fuel : String?
    var eld_connection_interface : String?
    var license_plate_country : String?
    var license_plate_state : String?
    var license_plate_number : String?
    var status : String?
    var company : String?
    var eld : ELDDATA?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        unit_number <- map["unit_number"]
        vehicle_make <- map["vehicle_make"]
        vehicle_model <- map["vehicle_model"]
        vehicle_year <- map["vehicle_year"]
        vin <- map["vin"]
        fuel <- map["fuel"]
        eld_connection_interface <- map["eld_connection_interface"]
        license_plate_country <- map["license_plate_country"]
        license_plate_state <- map["license_plate_state"]
        license_plate_number <- map["license_plate_number"]
        status <- map["status"]
        company <- map["company"]
        eld <- map["eld_data"]
    }

}


struct ELDDATA : Mappable {
    var id : String?
    var bleVersion : String?
    var device_number : String?
    var mac_address : String?
    var eld_type : String?
    var eld_status : String?
    var malfunctions : String?
    var fw_version : String?
    var target_version : String?
    var device_uuid : String?
    var vehicle : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        bleVersion <- map["bleVersion"]
        device_number <- map["device_number"]
        mac_address <- map["mac_address"]
        eld_type <- map["eld_type"]
        eld_status <- map["eld_status"]
        malfunctions <- map["malfunctions"]
        fw_version <- map["fw_version"]
        target_version <- map["target_version"]
        device_uuid <- map["device_uuid"]
        vehicle <- map["vehicle"]
    }

}
