//
//  LoginView.swift
//  safemiles
//
//  Created by pc on 29/01/26.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    enum Field: Hashable {
        case email
        case password
    }
    
    @FocusState private var focusedField: Field?
    @State private var lastFocusedField: Field?
    
    // Callback to notify parent (App) that login is successful
    // We can inject this into the VM, or handle it here via an updated VM property.
    // For MVVM purity, calling VM function which then triggers this is better.
    var onLoginSuccess: () -> Void
    
    var body: some View {
        NavigationView { // Added NavigationView wrapper
            ZStack {
                // Background Image
                Image("loginBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                // Dark Overlay for readability
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    HStack {
                        Image("safemile_logo_ic")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                        Spacer()
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                        .frame(height: 50)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Login Your\nAccount")
                            .font(AppFonts.loginTitle)
                            .foregroundStyle(AppColors.white)
                            .lineSpacing(5)
                        
                        Text("Enter your email and password")
                            .font(AppFonts.loginSubtitle)
                            .foregroundStyle(AppColors.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)
                    
                    // Email Field
                    CustomTextField(
                        title: "Enter your email/username",
                        text: $viewModel.email,
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        isError: viewModel.isEmailError,
                        useGlassStyle: true
                    )
                    .focused($focusedField, equals: .email)
                    
                    // Password Field
                    CustomTextField(
                        title: "Enter password",
                        text: $viewModel.password,
                        icon: "lock",
                        isSecure: true,
                        isError: viewModel.isPasswordError,
                        useGlassStyle: true
                    )
                    .focused($focusedField, equals: .password)
                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: ForgotPasswordView()) {
                            Text("Forget Password ?")
                                .font(AppFonts.footnote)
                                .foregroundStyle(AppColors.white.opacity(0.8))
                        }
                    }
                    .padding(.top, -10)
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial.opacity(0.8))
                                            .colorScheme(.dark)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.clear, lineWidth: 1)
                                            )
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Text("Log in")
                                .font(AppFonts.buttonText)
                                .foregroundStyle(AppColors.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial.opacity(0.8))
                                            .colorScheme(.dark)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.clear, lineWidth: 1)
                                            )
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .disabled(viewModel.isLoading || !viewModel.isFormValid)
                    .opacity(viewModel.isLoading || !viewModel.isFormValid ? 0.5 : 1.0)
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
        .onChange(of: focusedField) { newValue in
            if lastFocusedField == .email && newValue != .email {
                viewModel.validateEmail()
            }
            if lastFocusedField == .password && newValue != .password {
                viewModel.validatePassword()
            }
            lastFocusedField = newValue
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown Error"), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    LoginView(onLoginSuccess: {})
}
