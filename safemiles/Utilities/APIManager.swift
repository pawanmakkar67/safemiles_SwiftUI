//
//  APIManager.swift
//  Jobs
//
//  Created by KAMAL BALKARAN on 05/05/19.
//  Copyright © 2019 Raman Kant. All rights reserved.
//

import Alamofire
import Foundation
import UIKit
import ObjectMapper

class APIManager {

    static let shared = APIManager()

    private init() {}

    func request(
        url: String, method: HTTPMethod, parameters: Parameters? = nil, tryAgain: Bool = true,
        completionCallback: @escaping (AnyObject) -> Void,
        success successCallback: @escaping (AnyObject) -> Void,
        failure failureCallback: @escaping (String?) -> Void
    ) {

        var url1 = url

        let strToken = UserDefaults.getUserToken()

        var headers: HTTPHeaders = [:]
        if strToken != "" {
            headers = [
                "Authorization": "Bearer " + strToken
            ]
        }

        AppLog.debug(url1)
        AppLog.debug("c ", strToken)
        AppLog.debug(parameters as Any)
        URLCache.shared.removeAllCachedResponses()

        AF.request(
            url1, method: method, parameters: parameters, encoding: URLEncoding.default,
            headers: headers
        ).cURLDescription { curl in
            AppLog.debug("cURL Request:\n\(curl)")
        }.responseJSON { (response) in

            AppLog.debug(response.value as Any)
            AppLog.debug("Status Code: \(response.response?.statusCode ?? 0)")


            completionCallback(response as AnyObject)
            let controller = UIApplication.topViewController()

            if self.isResponseValid(response: response) {
                //                if controller is MaintanceModeVC {
                //                    controller?.dismiss(animated: false, completion: nil)
                //                }
                if (response.value as AnyObject)["api_status"] as? String == "404" {
                    //                    UserDefaults.removeAllKeys()
                    //                    MoveToController.sharedInstance.logoutVC()
                } else {

                    switch response.result {
                    case .success(let responseJSON):
                        successCallback(responseJSON as AnyObject)
                    case .failure(let error):
                        failureCallback(error.localizedDescription)
                    }
                }
            } else {
                let maintenanceMsg = (response.value as AnyObject)["message"] as? String ?? ""
                let error = self.getErrorForResponse(response: response)
                if response.response?.statusCode == 503 {
                    //                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    //                    let maintenanceVC = storyboard.instantiateViewController(withIdentifier: "MaintanceModeVC") as? MaintanceModeVC
                    //                    maintenanceVC?.msg = maintenanceMsg
                    //                    maintenanceVC?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    //                    maintenanceVC?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    //                    maintenanceVC?.showOnTop()
                    //                    return
                }

                if response.response?.statusCode == 401 || response.response?.statusCode == 402 {
                    if url != ApiList.loginAPI {
                        self.refreshToken { success in
                            if success {
                                self.request(
                                    url: url, method: method, parameters: parameters,
                                    tryAgain: tryAgain, completionCallback: completionCallback,
                                    success: successCallback, failure: failureCallback)
                            } else {
                                failureCallback(error)
                            }
                        }
                        return
                    }
                    failureCallback(error)
                    return
                }

                else if response.response?.statusCode == 404 {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SessionExpiredNotification"), object: nil)
                    failureCallback(error)
                    return
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

    func upload(
        url: String, method: HTTPMethod, parameters: Parameters? = nil,
        completionCallback: @escaping (AnyObject) -> Void,
        success successCallback: @escaping (AnyObject) -> Void,
        failure failureCallback: @escaping (String?) -> Void
    ) {

        let strToken = UserDefaults.getUserToken()

        let headers: HTTPHeaders = [
            //   "Content-Type": "application/json",
            "Connection": "Keep-Alive",
            "Authorization": "Bearer " + strToken,
        ]
        var url1 = url
        AppLog.debug(parameters as Any)
        AppLog.debug(url1)
        AppLog.debug(strToken)

      

        AF.upload(
            multipartFormData: { multipartFormData in
                if let parameters = parameters {
                    for (key, value) in parameters {
                        self.appendMultipart(formData: multipartFormData, key: key, value: value)
                    }
                }

            },
            to: url1,

            method: method,
            headers: headers
        ).cURLDescription { curl in
            AppLog.debug("cURL Upload Request:\n\(curl)")
        }
        .responseJSON { (response) in

            AppLog.debug(response.value as Any)
            AppLog.debug("Status Code: \(response.response?.statusCode ?? 0)")

            if let dict = response.value as? [String: Any],
                dict["code"] as? String == "token_not_valid"
            {
                NotificationCenter.default.post(
                    name: NSNotification.Name("SessionExpiredNotification"), object: nil)
                return
            }

            completionCallback(response as AnyObject)

            if self.isResponseValid(response: response) {
                switch response.result {
                case .success(let responseJSON):
                    successCallback(responseJSON as AnyObject)
                case .failure(let error):
                    failureCallback(error.localizedDescription)
                }
            } else {
                let error = self.getErrorForResponse(response: response)

                if response.response?.statusCode == 401 || response.response?.statusCode == 402 {
                    if url != ApiList.loginAPI {
                        self.refreshToken { success in
                            if success {
                                self.upload(
                                    url: url, method: method, parameters: parameters,
                                    completionCallback: completionCallback,
                                    success: successCallback, failure: failureCallback)
                            } else {
                                failureCallback(error)
                            }
                        }
                        return
                    }
                    failureCallback(error)
                    return
                }

                if response.response?.statusCode == 404 {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SessionExpiredNotification"), object: nil)
                    failureCallback(error)
                    return
                }

                failureCallback(error)
            }
        }
    }

    func uploadMultiple(
        url: String, method: HTTPMethod, parameters: Parameters? = nil,
        completionCallback: @escaping (AnyObject) -> Void,
        success successCallback: @escaping (AnyObject) -> Void,
        failure failureCallback: @escaping (String?) -> Void
    ) {

        let strToken = UserDefaults.getUserToken()

        let headers: HTTPHeaders = [
            //   "Content-Type": "application/json",
            "Connection": "Keep-Alive",
            "Authorization": "Bearer " + strToken,
        ]
        var url1 = url
        AppLog.debug(parameters as Any)
        AppLog.debug(url1)
        AppLog.debug(strToken)

        AF.upload(
            multipartFormData: { multipartFormData in
                if let parameters = parameters {
                    for (key, value) in parameters {
                        self.appendMultipart(formData: multipartFormData, key: key, value: value)
                    }
                }

            },
            to: url1,

            method: method,
            headers: headers
        ).cURLDescription { curl in
            AppLog.debug("cURL Multiple Upload Request:\n\(curl)")
        }
        .responseJSON { (response) in

            AppLog.debug(response.value as Any)
            AppLog.debug("Status Code: \(response.response?.statusCode ?? 0)")

            if let dict = response.value as? [String: Any],
                dict["code"] as? String == "token_not_valid"
            {
                NotificationCenter.default.post(
                    name: NSNotification.Name("SessionExpiredNotification"), object: nil)
                return
            }

            completionCallback(response as AnyObject)

            if self.isResponseValid(response: response) {
                switch response.result {
                case .success(let responseJSON):
                    successCallback(responseJSON as AnyObject)
                case .failure(let error):
                    failureCallback(error.localizedDescription)
                }
            } else {
                let error = self.getErrorForResponse(response: response)

                if response.response?.statusCode == 401 || response.response?.statusCode == 402 {
                    if url != ApiList.loginAPI {
                        self.refreshToken { success in
                            if success {
                                self.uploadMultiple(
                                    url: url, method: method, parameters: parameters,
                                    completionCallback: completionCallback,
                                    success: successCallback, failure: failureCallback)
                            } else {
                                failureCallback(error)
                            }
                        }
                        return
                    }
                    failureCallback(error)
                    return
                }

                if response.response?.statusCode == 404 {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SessionExpiredNotification"), object: nil)
                    failureCallback(error)
                    return
                }

                failureCallback(error)
            }
        }
    }

    func uploadMutlipleImages(
        url: String, method: HTTPMethod, parameters: Parameters? = nil,
        completionCallback: @escaping (AnyObject) -> Void,
        success successCallback: @escaping (AnyObject) -> Void,
        failure failureCallback: @escaping (String?) -> Void
    ) {

        let strToken = UserDefaults.getUserToken()

        let headers: HTTPHeaders = [
            //   "Content-Type": "application/json",
            "Connection": "Keep-Alive",
            "Authorization": "Bearer " + strToken,
        ]


        //          AMProgressHUD.show()
        let queue = DispatchQueue(
            label: "com.cnoon.manager-response-queue",
            attributes: DispatchQueue.Attributes.concurrent)

        AF.upload(
            multipartFormData: { (multipartFormData) in

                if let parameters = parameters {
                    for (key, value) in parameters {
                        self.appendMultipart(formData: multipartFormData, key: key, value: value)
                    }
                }
            }, to: url,
            method: method,
            headers: headers
        ).cURLDescription { curl in
            AppLog.debug("cURL Multiple Images Upload Request:\n\(curl)")
        }
        .responseJSON { (response) in

            AppLog.debug(response.value as Any)
            AppLog.debug("Status Code: \(response.response?.statusCode ?? 0)")

            if let dict = response.value as? [String: Any],
                dict["code"] as? String == "token_not_valid"
            {
                NotificationCenter.default.post(
                    name: NSNotification.Name("SessionExpiredNotification"), object: nil)
                return
            }

            completionCallback(response as AnyObject)

            if self.isResponseValid(response: response) {
                switch response.result {
                case .success(let responseJSON):
                    successCallback(responseJSON as AnyObject)
                case .failure(let error):
                    failureCallback(error.localizedDescription)
                }
            } else {
                let error = self.getErrorForResponse(response: response)

                if response.response?.statusCode == 401 || response.response?.statusCode == 402 {
                    if url != ApiList.loginAPI {
                        self.refreshToken { success in
                            if success {
                                self.uploadMutlipleImages(
                                    url: url, method: method, parameters: parameters,
                                    completionCallback: completionCallback,
                                    success: successCallback, failure: failureCallback)
                            } else {
                                failureCallback(error)
                            }
                        }
                        return
                    }
                    failureCallback(error)
                    return
                }

                if response.response?.statusCode == 404 {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SessionExpiredNotification"), object: nil)
                    failureCallback(error)
                    return
                }

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
        } else if let isSuccess = (response.value as AnyObject)["success"] as? Int {
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

    func requestAuthorization(
        url: String, method: HTTPMethod, parameters: Parameters? = nil, authorizationn: String,
        tryAgain: Bool = true, completionCallback: @escaping (AnyObject) -> Void,
        success successCallback: @escaping (AnyObject) -> Void,
        failure failureCallback: @escaping (String?) -> Void
    ) {

        var url1 = url

        let strToken = UserDefaults.getUserToken() ?? ""
        let headers: HTTPHeaders = [
            "Authorization": authorizationn
        ]

        AppLog.debug(url1)
        AppLog.debug("token: ", strToken)
        AppLog.debug(parameters as Any)

        URLCache.shared.removeAllCachedResponses()

        AF.request(
            url1, method: method, parameters: parameters, encoding: URLEncoding.default,
            headers: headers
        ).cURLDescription { curl in
            AppLog.debug("cURL Authorization Request:\n\(curl)")
        }.responseJSON { (response) in

            AppLog.debug(response.value as Any)
            AppLog.debug("Status Code: \(response.response?.statusCode ?? 0)")

            if let dict = response.value as? [String: Any],
                dict["code"] as? String == "token_not_valid"
            {
                NotificationCenter.default.post(
                    name: NSNotification.Name("SessionExpiredNotification"), object: nil)
                return
            }

            completionCallback(response as AnyObject)
            let controller = UIApplication.topViewController()

            if self.isResponseValid(response: response) {
                switch response.result {
                case .success(let responseJSON):
                    successCallback(responseJSON as AnyObject)
                case .failure(let error):
                    failureCallback(error.localizedDescription)
                }
            } else {
                let error = self.getErrorForResponse(response: response)

                if response.response?.statusCode == 401 || response.response?.statusCode == 402 {
                    if url != ApiList.loginAPI {
                        self.refreshToken { success in
                            if success {
                                self.requestAuthorization(
                                    url: url, method: method, parameters: parameters,
                                    authorizationn: authorizationn, tryAgain: tryAgain,
                                    completionCallback: completionCallback,
                                    success: successCallback, failure: failureCallback)
                            } else {
                                failureCallback(error)
                            }
                        }
                        return
                    }
                    failureCallback(error)
                    return
                }

                if response.response?.statusCode == 404 {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SessionExpiredNotification"), object: nil)
                    failureCallback(error)
                    return
                }

                failureCallback(error)

            }
        }
    }

    private func refreshToken(completion: @escaping (Bool) -> Void) {
        let refreshToken = UserDefaults.getUserRefreshToken()
        if refreshToken.isEmpty {
            completion(false)
            return
        }

        let params: [String: Any] = ["refresh": refreshToken]
        let url = ApiList.refreshTokenAPI
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                if let statusCode = response.response?.statusCode,
                    statusCode >= 200 && statusCode < 300
                {
                    if let responseValue = response.value as? [String: Any],
                       let model = Mapper<RefreshTokenModel>().map(JSON: responseValue),
                       let data = model.data {
                        
                        if let accessToken = data.access {
                            UserDefaults.setUserToken(token: accessToken)
                        }
                        
                        if let newRefreshToken = data.refresh {
                            UserDefaults.setUserRefreshToken(token: newRefreshToken)
                        }
                        
                        
                        AppLog.debug("Token refreshed successfully and saved.")
                        completion(true)
                        return
                    }
                } else if response.response?.statusCode == 401 {
                    AppLog.debug("Refresh token expired or invalid. Posting SessionExpiredNotification.")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SessionExpiredNotification"), object: nil)
                }
                
                AppLog.debug("Refresh token failed with status: \(response.response?.statusCode ?? 0)")
                completion(false)
            }
    }

    private func appendMultipart(formData: MultipartFormData, key: String, value: Any) {
        if let image = value as? UIImage {
            if let imageData = image.jpegData(compressionQuality: 0.6) {
                let timestamp = Date().timeIntervalSince1970
                formData.append(imageData, withName: key, fileName: "\(timestamp).jpg", mimeType: "image/jpeg")
            }
        } else if let images = value as? [UIImage] {
            for (index, image) in images.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 0.6) {
                    formData.append(imageData, withName: "\(key)[]", fileName: "\(Date().timeIntervalSince1970)_\(index).jpg", mimeType: "image/jpeg")
                }
            }
        } else if let dict = value as? [String: Any] {
            for (subKey, subValue) in dict {
                appendMultipart(formData: formData, key: "\(key)[\(subKey)]", value: subValue)
            }
        } else if let array = value as? [Any] {
            for (index, element) in array.enumerated() {
                appendMultipart(formData: formData, key: "\(key)[\(index)]", value: element)
            }
        } else {
            let stringValue = "\(value)"
            if let data = stringValue.data(using: .utf8) {
                formData.append(data, withName: key)
            }
        }
    }
}
