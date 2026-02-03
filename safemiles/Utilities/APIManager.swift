//
//  APIManager.swift
//  Jobs
//
//  Created by KAMAL BALKARAN on 05/05/19.
//  Copyright © 2019 Raman Kant. All rights reserved.
//

import Foundation
import  Alamofire
import UIKit

class APIManager {
    
    static let shared = APIManager()

    private init() {}
    
    
    func request(url:String,method:HTTPMethod,parameters:Parameters?=nil,tryAgain:Bool=true,completionCallback:@escaping (AnyObject) -> Void ,success successCallback: @escaping (AnyObject) -> Void ,failure failureCallback: @escaping (String?) -> Void) {
        
        var url1 = url

        let strToken = UserDefaults.getUserToken()
        
        var headers: HTTPHeaders = [:]
        if (strToken != "") {
            headers = [
                "Authorization": "Bearer " + strToken
            ]
        }
        
        print(url1)
        print("c ", strToken)
        print(parameters as Any)
        URLCache.shared.removeAllCachedResponses()
        
        AF.request(url1, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            print(response.value as Any)
            
            completionCallback(response as AnyObject)
            let controller = UIApplication.topViewController()
            
            if self.isResponseValid(response: response) {
//                if controller is MaintanceModeVC {
//                    controller?.dismiss(animated: false, completion: nil)
//                }
                if (response.value as AnyObject)["api_status"] as? String  == "404" {
//                    UserDefaults.removeAllKeys()
//                    MoveToController.sharedInstance.logoutVC()
                }
                else {
                    
                    switch response.result {
                    case .success(let responseJSON):
                        successCallback(responseJSON as AnyObject)
                    case .failure(let error):
                        failureCallback(error.localizedDescription)
                    }
                }
            } else {
                let maintenanceMsg = (response.value as AnyObject)["message"] as? String ?? ""
                let error =  self.getErrorForResponse(response: response)
                if response.response?.statusCode == 503 {
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let maintenanceVC = storyboard.instantiateViewController(withIdentifier: "MaintanceModeVC") as? MaintanceModeVC
//                    maintenanceVC?.msg = maintenanceMsg
//                    maintenanceVC?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//                    maintenanceVC?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//                    maintenanceVC?.showOnTop()
//                    return
                }
                
                
                if response.response?.statusCode == 401 {
//                    if GlobalUserDetail != nil {
//                        AppDelegate().authenticationAlert(error: error ?? "")
//                        return
//                    }
                }
                if response.response?.statusCode == 404 {
//                    UserDefaults.removeAllKeys()
//                    MoveToController.sharedInstance.logOut(UIApplication.topViewController()!)
                }
                
                if tryAgain {
//                    if let statusCode = response.response?.statusCode,
//                        statusCode < 200 || statusCode >= 300 {
//                        AppDelegate().alertSimpleShowWithTryAgainCompletion {
//                            failureCallback("TryAgain")
//                        }
//                        return
//                    }
                }
                
                
                failureCallback(error)
                
            }
        }
    }

    
    func upload(url:String,method:HTTPMethod,parameters:Parameters?=nil,completionCallback:@escaping (AnyObject) -> Void ,success successCallback: @escaping (AnyObject) -> Void ,failure failureCallback: @escaping (String?) -> Void) {
        
        let strToken = UserDefaults.getUserToken()

        let headers: HTTPHeaders = [
            //   "Content-Type": "application/json",
            "Connection": "Keep-Alive",
            "Authorization": "Bearer " + strToken
        ]
        var url1 = url
        print(parameters as Any)
        print(url1)
        print(strToken)
        AF.upload(
            multipartFormData: { multipartFormData in
                
                if let parameters = parameters {
                    for (key, value) in parameters {
                        
                        if value is UIImage {
                            let item = value as! UIImage
                            //                            for  item in value as! [UIImage] {
                            if let imageData = item.jpegData(compressionQuality: 0.6) {
                                let timestamp = Date().timeIntervalSince1970

                                multipartFormData.append(imageData, withName: key, fileName: "\(timestamp).png", mimeType: "image/png")
                            }
                            //                            }
                        }
                        
                        let stringValue = "\(value)"
                        multipartFormData.append((stringValue.data(using: .utf8))!, withName: key)
                    }
                }
                
                
        },
            to: url1,

            method: method,
            headers: headers)
            .responseJSON { (response) in
                
                print(response.value as Any)
                completionCallback(response as AnyObject)
                
                if self.isResponseValid(response: response) {
                    switch response.result {
                    case .success(let responseJSON):
                        successCallback(responseJSON as AnyObject)
                    case .failure(let error):
                        failureCallback(error.localizedDescription)
                    }
                } else {
                    let error =  self.getErrorForResponse(response: response)
                    failureCallback(error)
                }
        }
    }
    
    
    
    func uploadMultiple(url:String,method:HTTPMethod,parameters:Parameters?=nil,completionCallback:@escaping (AnyObject) -> Void ,success successCallback: @escaping (AnyObject) -> Void ,failure failureCallback: @escaping (String?) -> Void) {
        
        let strToken = UserDefaults.getUserToken()

        let headers: HTTPHeaders = [
            //   "Content-Type": "application/json",
            "Connection": "Keep-Alive",
            "Authorization": "Bearer " + strToken
        ]
        var url1 = url
        print(parameters as Any)
        print(url1)
        print(strToken)
        AF.upload(
            multipartFormData: { multipartFormData in
                
//                if let parameters = parameters {
//                    for (key, value) in parameters {
//
//                        if value is UIImage {
//                            let item = value as! UIImage
//                            //                            for  item in value as! [UIImage] {
//                            if let imageData = item.jpegData(compressionQuality: 0.6) {
//
//                                multipartFormData.append(imageData, withName: key, fileName: "\(Date()).jpg", mimeType: "image/jpeg")
//                            }
//                            //                            }
//                        }
//
//                        let stringValue = "\(value)"
//                        multipartFormData.append((stringValue.data(using: .utf8))!, withName: key)
//                    }
//                }
                
                if let parameters = parameters {
                    for (key, value) in parameters {

                      if value is Array<UIImage> {
                           // let item = value as! UIImage
                           for  item in value as! [UIImage] {
                            if let imageData = item.jpegData(compressionQuality: 0.6) {

                                multipartFormData.append(imageData, withName: key + "[]", fileName: "\(Date()).jpg", mimeType: "image/jpeg")
                            }
                       }
                        }
                      else if value is UIImage {
                          let item = value as! UIImage
                          //                            for  item in value as! [UIImage] {
                          if let imageData = item.jpegData(compressionQuality: 0.6) {

                              multipartFormData.append(imageData, withName: key, fileName: "filename.jpg", mimeType: "image/jpeg")
                          }
                          //                            }
                      }
                        let stringValue = "\(value)"
                        multipartFormData.append((stringValue.data(using: .utf8))!, withName: key)
                    }
                }
                
                
        },
            to: url1,

            method: method,
            headers: headers)
            .responseJSON { (response) in
                
                print(response.value as Any)
                completionCallback(response as AnyObject)
                
                if self.isResponseValid(response: response) {
                    switch response.result {
                    case .success(let responseJSON):
                        successCallback(responseJSON as AnyObject)
                    case .failure(let error):
                        failureCallback(error.localizedDescription)
                    }
                } else {
                    let error =  self.getErrorForResponse(response: response)
                    failureCallback(error)
                }
        }
    }
    
    func uploadMutlipleImages(url:String,method:HTTPMethod,parameters:Parameters?=nil,completionCallback:@escaping (AnyObject) -> Void ,success successCallback: @escaping (AnyObject) -> Void ,failure failureCallback: @escaping (String?) -> Void) {

        let strToken = UserDefaults.getUserToken()

        let headers: HTTPHeaders = [
            //   "Content-Type": "application/json",
            "Connection": "Keep-Alive",
            "Authorization": "Bearer " + strToken
        ]
        
//          AMProgressHUD.show()
        let queue = DispatchQueue(label: "com.cnoon.manager-response-queue", attributes: DispatchQueue.Attributes.concurrent)
        
        AF.upload(multipartFormData: { (multipartFormData) in

                  if let parameters = parameters {
                      for (key, value) in parameters {

                        if value is Array<UIImage> {
                             // let item = value as! UIImage
                             for  item in value as! [UIImage] {
                              if let imageData = item.jpegData(compressionQuality: 0.6) {

                                  multipartFormData.append(imageData, withName: key + "[]", fileName: "\(Date()).jpg", mimeType: "image/jpeg")
                              }
                         }
                          }
                        else if value is UIImage {
                            let item = value as! UIImage
                            //                            for  item in value as! [UIImage] {
                            if let imageData = item.jpegData(compressionQuality: 0.6) {

                                multipartFormData.append(imageData, withName: key, fileName: "filename.jpg", mimeType: "image/jpeg")
                            }
                            //                            }
                        }
                          let stringValue = "\(value)"
                          multipartFormData.append((stringValue.data(using: .utf8))!, withName: key)
                      }
                  }
        },             to: url,
        method: method,
        headers: headers)
        .responseJSON { (response) in

            print(response.value as Any)
            completionCallback(response as AnyObject)

            
            if self.isResponseValid(response: response) {
                switch response.result {
                case .success(let responseJSON):
                    successCallback(responseJSON as AnyObject)
                case .failure(let error):
                    failureCallback(error.localizedDescription)
                }
            } else {
                let error =  self.getErrorForResponse(response: response)
                failureCallback(error)

            }
            
        }
      }
    
    //MARK:- Validation (Check response is valid or not)
    //MARK:-
     private func isResponseValid(response: AFDataResponse<Any>) -> Bool {
        if let statusCode = response.response?.statusCode, statusCode < 200 || statusCode >= 300 {
            return false
        }
        
        if let isSuccess = (response.value as AnyObject)["success"] as? Bool {
            return isSuccess
        } else if let isSuccess = (response.value as AnyObject)["success"] as? String {
            if isSuccess == "1" {
                return true
            } else {
                return false
            }
        }
        else if let isSuccess = (response.value as AnyObject)["success"] as? Int {
            if isSuccess == 1 {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
     func getErrorForResponse(response: AFDataResponse<Any>) -> String? {
        switch response.result {
        case .success(let responseJSON):
            if let responseDictionary = responseJSON as? [String: Any] {
                if let errorMessage = responseDictionary["message"] as? String {
                      return errorMessage
                }
                
                if let errorMessage = responseDictionary["response"] as? String {
                    return errorMessage
                }

                return responseDictionary.description
            }
            return nil
        case .failure(let errorObj):
            return errorObj.localizedDescription
        }
    }
 
    func requestAuthorization(url:String,method:HTTPMethod,parameters:Parameters?=nil,authorizationn: String,tryAgain:Bool=true,completionCallback:@escaping (AnyObject) -> Void ,success successCallback: @escaping (AnyObject) -> Void ,failure failureCallback: @escaping (String?) -> Void) {
        
        var url1 = url
        
        let strToken = UserDefaults.getUserToken() ?? ""
        let headers: HTTPHeaders = [
            "Authorization": authorizationn
        ]
        
        print(url1)
        print("token: ", strToken)
        print(parameters as Any)
        URLCache.shared.removeAllCachedResponses()
        
        AF.request(url1, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            print(response.value as Any)
            
            completionCallback(response as AnyObject)
            let controller = UIApplication.topViewController()
            
            if self.isResponseValid(response: response) {
//                if controller is MaintanceModeVC {
//                    controller?.dismiss(animated: false, completion: nil)
//                }
                switch response.result {
                case .success(let responseJSON):
                    successCallback(responseJSON as AnyObject)
                case .failure(let error):
                    failureCallback(error.localizedDescription)
                }
            } else {
                let maintenanceMsg = (response.value as AnyObject)["message"] as? String ?? ""
                let error =  self.getErrorForResponse(response: response)
                if response.response?.statusCode == 503 {
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let maintenanceVC = storyboard.instantiateViewController(withIdentifier: "MaintanceModeVC") as? MaintanceModeVC
//                    maintenanceVC?.msg = maintenanceMsg
//                    maintenanceVC?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//                    maintenanceVC?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//                    maintenanceVC?.showOnTop()
//                    return
                }
                
                
                if response.response?.statusCode == 401 {
//                    if GlobalUserDetail != nil {
//                        AppDelegate().authenticationAlert(error: error ?? "")
//                        return
//                    }
                }
                
                if tryAgain {
//                    if let statusCode = response.response?.statusCode,
//                        statusCode < 200 || statusCode >= 300 {
//                        AppDelegate().alertSimpleShowWithTryAgainCompletion {
//                            failureCallback("TryAgain")
//                        }
//                        return
//                    }
                }
                
                
                failureCallback(error)
                
            }
        }
    }
}



//class APIManagerNew {
//    static let shared = APIManagerNew()
//    private init() {}
//
//    func request<T: Decodable>(
//        url: String,
//        method: HTTPMethod = .get,
//        parameters: Parameters? = nil,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        let token = UserDefaults.getUserToken()
//        var headers: HTTPHeaders = [:]
//        if !token.isEmpty {
//            headers.add(name: "Authorization", value: "Bearer \(token)")
//        }
//
//        AF.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers)
//            .validate()
//            .responseDecodable(of: T.self) { response in
//                switch response.result {
//                case .success(let decoded):
//                    completion(.success(decoded))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//    }
//}
