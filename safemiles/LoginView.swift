//
//  LoginView.swift
//  safemiles
//
//  Created by pc on 29/01/26.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    // Callback to notify parent (App) that login is successful
    // We can inject this into the VM, or handle it here via an updated VM property.
    // For MVVM purity, calling VM function which then triggers this is better.
    var onLoginSuccess: () -> Void
    
    var body: some View {
        NavigationView { // Added NavigationView wrapper
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Spacer()
                        .frame(height: 100)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Login Your\nAccount")
                            .font(AppFonts.loginTitle)
                            .foregroundStyle(AppColors.textBlack)
                            .lineSpacing(5)
                        
                        Text("Enter your email and password")
                            .font(AppFonts.loginSubtitle)
                            .foregroundStyle(AppColors.textGray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)
                    
                    // Email Field
                    CustomTextField(
                        title: "Enter your email/username",
                        text: $viewModel.email,
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        isError: viewModel.isEmailError
                    )
                    
                    // Password Field
                    CustomTextField(
                        title: "Enter password",
                        text: $viewModel.password,
                        icon: "lock",
                        isSecure: true,
                        isError: viewModel.isPasswordError
                    )
                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: ForgotPasswordView()) {
                            Text("Forget Password ?")
                                .font(AppFonts.footnote)
                                .foregroundStyle(AppColors.blackOpacity60)
                        }
                    }
                    .padding(.top, -10)
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.buttonTextWhite))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppColors.buttonInactive)
                                .cornerRadius(16)
                        } else {
                            Text("Log in")
                                .font(AppFonts.buttonText)
                                .foregroundStyle(AppColors.buttonTextWhite)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(viewModel.isFormValid ? AppColors.buttonActive : AppColors.buttonInactive)
                                .cornerRadius(16)
                        }
                    }
                    .disabled(viewModel.isLoading || !viewModel.isFormValid)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationBarHidden(true) // Hide nav bar on login screen
        }
        .onAppear {
            viewModel.onLoginSuccess = onLoginSuccess
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown Error"), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    LoginView(onLoginSuccess: {})
}
