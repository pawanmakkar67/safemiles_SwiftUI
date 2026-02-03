
import SwiftUI

struct EmailLogsView: View {
    @StateObject private var viewModel = EmailLogsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            CommonHeader(
                title: "Email Logs",
                leftIcon: "chevron.left",
                rightIcon: nil,
                onLeftTap: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Card Container
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Recipient Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recipient email")
                                .font(AppFonts.captionText)
                                .foregroundColor(AppColors.textGray)
                            
                            TextField("Enter email address", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .standardTextField()
                        }
                        
                        // Send Button
                        Button(action: {
                            viewModel.sendEmail {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Send")
                                    .font(AppFonts.buttonText)
                                    .foregroundColor(AppColors.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(AppColors.black)
                        .cornerRadius(8)
                        .padding(.top, 10)
                        
                    }
                    .padding(20)
                    .background(AppColors.white)
                    .cornerRadius(12)
                    .shadow(color: AppColors.blackOpacity05 ?? AppColors.blackOpacity10, radius: 5, x: 0, y: 2)
                    .padding()
                    
                    Spacer()
                }
            }
            .background(AppColors.background)
        }
        .navigationBarHidden(true)
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.alertMessage.map { AlertItem(message: $0) } },
            set: { _ in viewModel.alertMessage = nil }
        )) { item in
            Alert(title: Text("Alert"), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
    }
}
