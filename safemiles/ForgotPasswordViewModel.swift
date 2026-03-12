//
//  ForgotPasswordViewModel.swift
//  safemiles
//
//  Created by pc on 29/01/26.
//

import Foundation
import SwiftUI
import Combine
import Alamofire

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var isEmailError = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isSuccess = false
    @Published var alertMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        $email
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.validateEmail() }
            .store(in: &cancellables)
    }
    
    func validateEmail() {
        isEmailError = !email.isEmpty && !isValidEmail(email) && !isValidUsername(email)
    }
    
    var isFormValid: Bool {
        return !email.isEmpty && !isEmailError
    }
    
    func resetPassword() {
        validateEmail()
        
        if isEmailError {
            self.errorMessage = "Please enter a valid email or username"
            self.showError = true
            return
        }
        
        if email.isEmpty {
            self.errorMessage = "Please enter your email or username"
            self.showError = true
            return
        }
        
        self.isLoading = true
        let params: [String: Any] = ["email": email]
        
        APIManager.shared.request(url: ApiList.forgotPassword, method: .post, parameters: params) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        } success: { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let dict = response as? [String: Any], let status = dict["status"] as? Int {
                    if status == 1 {
                        self?.isSuccess = true
                        self?.alertMessage = dict["message"] as? String ?? "Password reset instructions have been sent to your email."
                    } else {
                        self?.errorMessage = dict["message"] as? String ?? "User not found"
                        self?.showError = true
                    }
                } else {
                    // Fallback to previous logic or handle unexpected format
                    self?.isSuccess = true
                    self?.alertMessage = "Password reset instructions have been sent to your email."
                }
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.errorMessage = error ?? "Failed to send reset instructions. Please try again."
                self?.showError = true
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        let usernameRegEx = "^[a-zA-Z0-9_]{3,20}$"
        let usernamePred = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernamePred.evaluate(with: username)
    }
}
