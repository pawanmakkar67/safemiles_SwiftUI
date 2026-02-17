
import SwiftUI

struct SendLogsView: View {
    @StateObject private var viewModel = SendLogsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            CommonHeader(
                title: "Send Logs",
                leftIcon: "left",
                rightIcon: nil,
                onLeftTap: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Card Container
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Transfer Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Transfer Type")
                                .font(AppFonts.captionText)
                                .foregroundColor(AppColors.textGray)
                            
                            Menu {
                                ForEach(viewModel.transferOptions, id: \.self) { option in
                                    Button(option) {
                                        viewModel.transferType = option
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.transferType)
                                        .foregroundColor(AppColors.textBlack)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppColors.textGray)
                                }
                                .padding(12)
                                .background(AppColors.textFieldBackground)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.grayOpacity20, lineWidth: 1)
                                )
                            }
                        }
                        
                        // Comment
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Comment (Optional)")
                                .font(AppFonts.captionText)
                                .foregroundColor(AppColors.textGray)
                            
                            TextField("Add any notes for the officer...", text: $viewModel.comment, axis: .vertical)
                                .frame(height: 100, alignment: .topLeading)
                                .standardTextField()
                              
                        }
                        
                        // Send Button
                        Button(action: {
                            viewModel.sendLogs {
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
