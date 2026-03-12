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
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordVisible = false
    @Published var isLoading = false
    @Published var isEmailError = false
    @Published var isPasswordError = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // Keychain constants
    private let keychainService = "com.safemiles.auth"
    private let emailAccount = "userEmail"
    private let passwordAccount = "userPassword"
    
    var onLoginSuccess: (() -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // loadCredentials()
        setupValidation()
    }
    
    private func loadCredentials() {
        if let savedEmail = KeychainHelper.shared.readString(service: keychainService, account: emailAccount) {
            self.email = savedEmail
        }
        if let savedPassword = KeychainHelper.shared.readString(service: keychainService, account: passwordAccount) {
            self.password = savedPassword
        }
    }
    
    private func saveCredentials() {
        KeychainHelper.shared.saveString(email, service: keychainService, account: emailAccount)
        KeychainHelper.shared.saveString(password, service: keychainService, account: passwordAccount)
    }
    
    private func setupValidation() {
        $email
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.validateEmail() }
            .store(in: &cancellables)
            
        $password
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.validatePassword() }
            .store(in: &cancellables)
    }
    
    func validateEmail() {
        isEmailError = !email.isEmpty && !isValidEmail(email) && !isValidUsername(email)
    }
    
    func validatePassword() {
        isPasswordError = !password.isEmpty && password.count < 6
    }
    
    var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty && !isEmailError && !isPasswordError
    }
    
    func login() {
        // Reset errors
        validateEmail()
        validatePassword()
        
        if isEmailError || isPasswordError {
            self.errorMessage = "Please fix the errors before logging in"
            self.showError = true
            return
        }
        
        if email.isEmpty || password.isEmpty {
            self.errorMessage = "Please enter both email and password"
            self.showError = true
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
                        // Save credentials to Keychain
                        // self.saveCredentials()
                        
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
