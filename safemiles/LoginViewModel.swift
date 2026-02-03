//
//  LoginViewModel.swift
//  safemiles
//
//  Created by pc on 29/01/26.
//

import Foundation
import SwiftUI
import Combine
import ObjectMapper
import Alamofire

class LoginViewModel: ObservableObject {
    @Published var email = "tourtravel@gmail.com"
    @Published var password = "Tour@5588Travel#"
    @Published var isPasswordVisible = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    @Published var isEmailError = false
    @Published var isPasswordError = false
    
    // Callback to notify parent (App) that login is successful
    // In a real app, this might be handled via a global AppState or Coordinator
    var onLoginSuccess: (() -> Void)?
    
    var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    func login() {
        // Reset errors
        isEmailError = false
        isPasswordError = false
        
        var hasError = false
        
        // Basic validation
        if email.isEmpty {
            self.errorMessage = "Please enter email or username"
            self.showError = true
            self.isEmailError = true
            hasError = true
        }
        
        if password.isEmpty {
            self.errorMessage = "Please enter password"
            self.showError = true
            self.isPasswordError = true
            hasError = true
        }
        
        if hasError { return }
        
        // Validate specifically for Email OR Username
        if !isValidEmail(email) && !isValidUsername(email) {
            self.errorMessage = "Please enter a valid email or username"
            self.showError = true
            self.isEmailError = true
            return
        }
        
        self.isLoading = true
        let params = ["email_or_username": email.lowercased(), "password": password]
        
        APIManager.shared.request(url: ApiList.loginAPI, method: .post, parameters: params) { _ in
            // Completion callback (optional handling)
        } success: { response in
            // Ensure UI updates on main thread
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let obj = Mapper<userModel>().map(JSONObject: response) {
                    if obj.success == true {
                        // Save user data
                        UserDefaults.setLoginUser(obj)
                        UserDefaults.setUserID(token: obj.data?.id ?? "")
                        UserDefaults.setUserToken(token: obj.data?.access_token ?? "")
                        UserDefaults.setTimezone(token: obj.data?.timezone ?? "")
                        UserDefaults.AlreadyLogin(login: true)
                        UserDefaults.standard.synchronize()
                        
                        // Notify success
                        self.onLoginSuccess?()
                    } else {
                        self.errorMessage = obj.message ?? "Unknown error"
                        self.showError = true
                    }
                } else {
                    self.errorMessage = "Failed to parse response"
                    self.showError = true
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error ?? "Unknown error"
                self.showError = true
            }
        }
    }
    
    func togglePasswordVisibility() {
        isPasswordVisible.toggle()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        // Username rule: alphanumeric, maybe underscores, min 3 chars
        let usernameRegEx = "^[a-zA-Z0-9_]{3,20}$"
        let usernamePred = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernamePred.evaluate(with: username)
    }
}
