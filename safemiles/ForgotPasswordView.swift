import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 25) {
                
                // Back Button (Custom Action or standard nav?)
                // Since this will be pushed, we might benefit from navigationBarHidden and a custom back or just standard.
                // Design shows "Back to login" button at bottom, so implies this screen is a destination.
                // Let's assume custom header or no header for now to match clean look.
                
                Spacer()
                    .frame(height: 60)
                
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
                    title: "example@gmail.com",
                    text: $email,
                    icon: "envelope",
                    keyboardType: .emailAddress,
                    isError: false // Bind to validation state if/when implemented
                )

                // Forgot Password Button
                Button(action: {
                    // Action to reset password
                }) {
                    Text("Forgot Password")
                        .font(AppFonts.buttonText)
                        .foregroundStyle(AppColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.black)
                        .cornerRadius(16)
                }
                .padding(.top, 10)
                
                // Back to Login Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to login")
                        .font(AppFonts.buttonText) // Assuming same size or slightly smaller? Image shows similar.
                        .foregroundStyle(AppColors.textGray) // Gray text based on image
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
    }
}

#Preview {
    ForgotPasswordView()
}
