//
//  UserDefaultExt.swift
//  WaiterApp
//
//  Created by Qode Maker on 24/05/19.
//  Copyright © 2019 Qode Maker. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation




private enum SettingsKey:String {
    case user = "SettingsKey"
}


private enum userDefaultKeys:String {
    case user = "userDetail"
    case userToken = "userToken"
    case userAlreadyLogin = "isAlreadyLogin"
    case userID = "userID"
    case userLocation = "userLocation"
    case userTheme = "userTheme"
    case alreadyConnected = "alreadyConnected"
    case bleUUID = "bleUUID"
    case timezone = "timeZone"
    case connectedvehicle = "connectedvehicle"

}

private func getArchived(data:Any) -> Data {
    
    var encodedData = Data()
    if let data = data as? String {
        encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
    } else  if let data = data as? Int {
        encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
    }
    else  if let data = data as? [String:Any] {
        encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
    }
    else  if let data = data as? [String:AnyObject] {
        encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
    }

    return encodedData
}

private func getUnArchived(data:Data?) -> Any? {
    
    if data != nil {
        let decodedData = NSKeyedUnarchiver.unarchiveObject(with: data!)
        return decodedData
    }
    return nil
}

extension UserDefaults {
    static func setUserToken(token:String) {
        standard.set(token, forKey: userDefaultKeys.userToken.rawValue)
    }
    static func setTimezone(token:String) {
        standard.set(token, forKey: userDefaultKeys.timezone.rawValue)
    }
    static func getTimezone() -> String {
        return standard.value(forKey: userDefaultKeys.timezone.rawValue) as? String ?? "America/Chicago"
    }
    
    
    static func getUserToken() -> String {
        return standard.value(forKey: userDefaultKeys.userToken.rawValue) as? String ?? ""
    }
    
    static func setUserID(token:String) {
        standard.set(token, forKey: userDefaultKeys.userID.rawValue)
    }
    
    
    static func getUserID() -> String {
        return standard.value(forKey: userDefaultKeys.userID.rawValue) as? String ?? ""
    }
    
    static func setLoginUser(_ user: userModel?) {
        if user != nil {
            if let userJSON = Mapper<userModel>().toJSONString(user!) {
                standard.set(getArchived(data: userJSON), forKey: userDefaultKeys.user.rawValue)
            }
        }
    }
    
    static func getLoginUser() -> userModel? {
        if let userJSON =  getUnArchived(data: standard.value(forKey: userDefaultKeys.user.rawValue) as? Data) as? String {
            return Mapper<userModel>().map(JSONString: userJSON)
        }
        return nil
    }
    
    static func setConnectvehicle(_ user: VehicleDetailsModel?) {
        if user != nil {
            if let userJSON = Mapper<VehicleDetailsModel>().toJSONString(user!) {
                standard.set(getArchived(data: userJSON), forKey: userDefaultKeys.connectedvehicle.rawValue)
            }
        }
    }
    
    static func getConnectvehicle() -> VehicleDetailsModel? {
        if let userJSON =  getUnArchived(data: standard.value(forKey: userDefaultKeys.connectedvehicle.rawValue) as? Data) as? String {
            return Mapper<VehicleDetailsModel>().map(JSONString: userJSON)
        }
        return nil
    }
    
    
    
    
    static func removeLoginUser() {
        UserDefaults.standard.removeObject(forKey: userDefaultKeys.user.rawValue)
        UserDefaults.standard.removeObject(forKey: userDefaultKeys.userToken.rawValue)
        UserDefaults.standard.removeObject(forKey: userDefaultKeys.userID.rawValue)
        UserDefaults.standard.removeObject(forKey: userDefaultKeys.userLocation.rawValue)
        UserDefaults.standard.removeObject(forKey: userDefaultKeys.alreadyConnected.rawValue)
        UserDefaults.standard.removeObject(forKey: userDefaultKeys.userLocation.rawValue)
        UserDefaults.standard.removeObject(forKey: userDefaultKeys.userTheme.rawValue)
        UserDefaults.standard.removeObject(forKey: userDefaultKeys.bleUUID.rawValue)


        
        UserDefaults.AlreadyLogin(login: false)
        UserDefaults.standard.synchronize()
    }
    

    static func setUserLocation(_ user :CLLocation?)  {
        if user != nil {
            let jsonn =  ["lat": user!.coordinate.latitude, "lon": user!.coordinate.longitude]

            standard.set(getArchived(data: jsonn), forKey: userDefaultKeys.userLocation.rawValue)

        }
    }
    static func getUserLocation() -> [String:Any]? {
        if let userJSON =  getUnArchived(data: standard.value(forKey: userDefaultKeys.userLocation.rawValue) as? Data) as? [String:Any], userJSON != nil {
            return userJSON
        }
        return nil
    }
    

//    static func saveLanguage(name: String) {
//        standard.set(name, forKey: "language")
//    }
//
//    static func getLanguage() -> String {
//        return standard.value(forKey: "language") as? String ?? "en"
//    }
    
    static func saveTheme(theme:String) {
        standard.set(theme, forKey: userDefaultKeys.userTheme.rawValue)
    }
    
    static func getTheme() -> String {
        return standard.value(forKey: userDefaultKeys.userTheme.rawValue) as? String ?? ""
    }
    

  
    
    static func setSettings(_ user: [[String:String]]) {
        standard.set(user, forKey: SettingsKey.user.rawValue)
        
    }
    
    
    static func getSettingsArray() -> [[String:String]]? {
        if let arr =  standard.value(forKey: SettingsKey.user.rawValue) as? [[String:String]] {
            return arr
        }
        return nil
    }
    
    static func removeAllKeys() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        UserDefaults.standard.synchronize()
    }
    
    static func removeSettings() {
        standard.removeObject(forKey: SettingsKey.user.rawValue)
    }
    
    

    
    
    static func AlreadyLogin(login:Bool) {
        standard.set(login, forKey: userDefaultKeys.userAlreadyLogin.rawValue)
        
    }
    static func isAlreadyLogin() -> Bool {
        return standard.bool(forKey: userDefaultKeys.userAlreadyLogin.rawValue)
        
    }
    
    
    static func AlreadyConnected(login:Bool) {
        standard.set(login, forKey: userDefaultKeys.alreadyConnected.rawValue)
        
    }
    static func isAlreadyConnected() -> Bool {
        return standard.bool(forKey: userDefaultKeys.alreadyConnected.rawValue)
        
    }
    //Cuurent Lat Long
    static func saveBleUUID(lat:String) {
        standard.set(lat, forKey: userDefaultKeys.bleUUID.rawValue)
    }
    
    static func getBleUUID() -> String {
        return standard.value(forKey: userDefaultKeys.bleUUID.rawValue) as? String ?? ""
    }

    //Cuurent Lat Long
    static func saveCurrentLat(lat:String) {
        standard.set(lat, forKey: "currentlat")
    }
    
    static func getCurrentLat() -> String {
        return standard.value(forKey: "currentlat") as? String ?? ""
    }
    
    static func saveCurrentLong(long:String) {
        standard.set(long, forKey: "currentLong")
    }
    
    static func getCurrentLong() -> String {
        return standard.value(forKey: "currentLong") as? String ?? ""
    }
    

}


