/* 
Copyright (c) 2025 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct ProfileModel : Mappable {
	var data : ProfileData?
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

struct ProfileData : Mappable {
    var id : String?
    var user : User?
    var company_driver_id : String?
    var phone : String?
    var license_country : String?
    var license_state : String?
    var license_number : String?
    var log_setting_exempt : Bool?
    var log_setting_hos_rule : String?
    var log_setting_cargo_type : String?
    var log_setting_restart : String?
    var log_setting_rest_breaak : String?
    var log_setting_short_haul : Bool?
    var log_setting_allow_personal_use : Bool?
    var log_setting_allow_yard_moves : Bool?
    var log_setting_unlimited_trailer : Bool?
    var log_setting_unlimited_shipping : Bool?
    var status : String?
    var sim_card : String?
    var app_os : String?
    var app_version : String?
    var vehicle : VehicleData?
    var company : company?
    var home_terminal_addr : home_terminal_Address?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        user <- map["user"]
        company_driver_id <- map["company_driver_id"]
        phone <- map["phone"]
        license_country <- map["license_country"]
        license_state <- map["license_state"]
        license_number <- map["license_number"]
        log_setting_exempt <- map["log_setting_exempt"]
        log_setting_hos_rule <- map["log_setting_hos_rule"]
        log_setting_cargo_type <- map["log_setting_cargo_type"]
        log_setting_restart <- map["log_setting_restart"]
        log_setting_rest_breaak <- map["log_setting_rest_breaak"]
        log_setting_short_haul <- map["log_setting_short_haul"]
        log_setting_allow_personal_use <- map["log_setting_allow_personal_use"]
        log_setting_allow_yard_moves <- map["log_setting_allow_yard_moves"]
        log_setting_unlimited_trailer <- map["log_setting_unlimited_trailer"]
        log_setting_unlimited_shipping <- map["log_setting_unlimited_shipping"]
        status <- map["status"]
        sim_card <- map["sim_card"]
        app_os <- map["app_os"]
        app_version <- map["app_version"]
        company <- map["company"]
        home_terminal_addr <- map["home_terminal_addr"]
        vehicle <- map["vehicle"]
    }

}


struct home_terminal_Address : Mappable {
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
        state <- map["state"]
        country <- map["country"]
        postal_code <- map["postal_code"]
    }
}



struct company : Mappable {
    var id : String?
    var name : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        
        id <- map["id"]
        name <- map["name"]
    }
}
