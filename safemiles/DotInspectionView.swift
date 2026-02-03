
import SwiftUI

struct DotInspectionView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = DotInspectionViewModel()
    @ObservedObject var bleManager = BLEManager.shared
    @State private var showBluetoothScan = false
    @State private var showSendLogs = false
    @State private var showEmailLogs = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // Common Header
                CommonHeader(
                    title: "Dot Inspection",
                    leftIcon: "line.3.horizontal",
                    onLeftTap: {
                        withAnimation {
                            showSideMenu = true
                        }
                    },
                    onRightTap: {
                        showBluetoothScan = true
                    }
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Card 1: Inspect Logs
                        DotInspectionCard(title: "Inspect Logs For Previous 7 Days + Today") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select 'Begin Inspection' and hand your phone to officer")
                                    .font(AppFonts.bodyText)
                                    .foregroundColor(AppColors.textBlack)
                                
                                Button(action: {
                                    viewModel.beginInspection()
                                }) {
                                    if viewModel.isLoading {
                                         ProgressView().tint(.white)
                                    } else {
                                        Text("Begin Inspection")
                                            .font(AppFonts.headline)
                                            .foregroundColor(AppColors.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                    }
                                }
                                .background(AppColors.black)
                                .cornerRadius(8)
                                
                                Text("Press and hold to set an access code")
                                    .font(AppFonts.captionText)
                                    .foregroundColor(AppColors.textGray)
                            }
                        }
                        
                        // Card 2: Send Logs
                        DotInspectionCard(title: "Send Logs for HDS cycle") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Send your logs to the officer if they request")
                                    .font(AppFonts.bodyText)
                                    .foregroundColor(AppColors.textBlack)
                                
                                NavigationLink(destination: SendLogsView(), isActive: $showSendLogs) {
                                    EmptyView()
                                }

                                Button(action: {
                                    showSendLogs = true
                                }) {
                                    Text("Send Logs")
                                        .font(AppFonts.headline)
                                        .foregroundColor(AppColors.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                                .background(AppColors.black)
                                .cornerRadius(8)
                            }
                        }
                        
                        // Card 3: Email Logs
                        DotInspectionCard(title: "Email Logs As PDF") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Email logs for the 24 hour period and previous days for one HOS cycle as PDF")
                                    .font(AppFonts.bodyText)
                                    .foregroundColor(AppColors.textBlack)
                                
                                NavigationLink(destination: EmailLogsView(), isActive: $showEmailLogs) {
                                    EmptyView()
                                }
                                
                                Button(action: {
                                    showEmailLogs = true
                                }) {
                                    Text("Email Logs")
                                        .font(AppFonts.headline)
                                        .foregroundColor(AppColors.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                                .background(AppColors.black)
                                .cornerRadius(8)
                            }
                        }
                        
                        // Footer Info
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "info.circle")
                                .font(AppFonts.iconSmall)
                                .foregroundColor(AppColors.textGray)
                            
                            Text("Safemiles certifies that use of the safemiles app with ELD device complies with all requirements for ELD as defined in federal motor carrier safety regulation 49 CFR part 395 Subpart B/")
                                .font(AppFonts.captionText) // Small font
                                .foregroundColor(AppColors.textGray)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding()
                        .background(AppColors.background) // Very light gray background
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.grayOpacity20, lineWidth: 1)
                        )
                        .padding(.horizontal)

                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .background(AppColors.background)
            }
            
            if viewModel.isLoading {
                AppColors.blackOpacity30.ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            showSideMenu = false
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// Reusable Card Component
struct DotInspectionCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text(title)
                .font(AppFonts.subheadline) // Or slightly larger depending on exact match
                .foregroundColor(AppColors.textGray)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Content
            VStack(alignment: .leading) {
                content
            }
            .padding()
        }
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: AppColors.blackOpacity10, radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
