import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ForgotPasswordViewModel()
    
    enum Field: Hashable {
        case email
    }
    
    @FocusState private var focusedField: Field?
    @State private var lastFocusedField: Field?
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 25) {
                
                // Back Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("left")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(AppColors.textBlack)
                }
                .padding(.top, 10)
                
                Spacer()
                    .frame(height: 16)
                
                // Title Area
                VStack(alignment: .leading, spacing: 10) {
                    Text("Forgot\nPassword?")
                        .font(AppFonts.loginTitle)
                        .foregroundStyle(AppColors.textBlack)
                        .lineSpacing(5)
                    
                    Text("Enter your email to receive a reset link.")
                        .font(AppFonts.loginSubtitle)
                        .foregroundStyle(AppColors.textGray)
                }
                .padding(.bottom, 20)
                
                // Email Field
                CustomTextField(
                    title: "Enter your email/username",
                    text: $viewModel.email,
                    icon: "envelope",
                    keyboardType: .emailAddress,
                    isError: viewModel.isEmailError
                )
                .focused($focusedField, equals: .email)

                // Forgot Password Button
                Button(action: {
                    viewModel.resetPassword()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppColors.black)
                            .cornerRadius(16)
                    } else {
                        Text("Forgot Password")
                            .font(AppFonts.buttonText)
                            .foregroundStyle(AppColors.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppColors.black)
                            .cornerRadius(16)
                    }
                }
                .disabled(viewModel.isLoading || !viewModel.isFormValid)
                .opacity(viewModel.isLoading || !viewModel.isFormValid ? 0.5 : 1.0)
                .padding(.top, 10)
                
                // Back to Login Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to login")
                        .font(AppFonts.buttonText)
                        .foregroundStyle(AppColors.textGray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.textGray.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(16)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
        .onChange(of: focusedField) { newValue in
            if lastFocusedField == .email && newValue != .email {
                viewModel.validateEmail()
            }
            lastFocusedField = newValue
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown Error"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $viewModel.isSuccess) {
            Alert(
                title: Text("Success"),
                message: Text(viewModel.alertMessage ?? "Successfully sent reset instructions"),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    ForgotPasswordView()
}
