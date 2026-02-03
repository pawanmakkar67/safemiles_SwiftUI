
import SwiftUI

struct RulesView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = RulesViewModel()
    @ObservedObject var bleManager = BLEManager.shared
    @State private var showBluetoothScan = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // Common Header
                CommonHeader(
                    title: "Rules",
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
                        
                        // Card 1: Cycle Rules
                        RulesSectionCard(title: "Cycle Rules") {
                            VStack(alignment: .leading, spacing: 16) {
                                RuleField(title: "Cycle Rule", value: viewModel.cycleRule.isEmpty ? "" : viewModel.cycleRule)
                                Divider()
                                RuleField(title: "Restart", value: viewModel.restart.isEmpty ? "" : viewModel.restart)
                                Divider()
                                RuleField(title: "Rest Break", value: viewModel.restBreak.isEmpty ? "" : viewModel.restBreak)
                            }
                        }
                        
                        // Card 2: Cargo & Exceptions
                        RulesSectionCard(title: "Cargo & Exceptions") {
                            VStack(alignment: .leading, spacing: 16) {
                                RuleField(title: "Cargo Type", value: viewModel.cargoType.isEmpty ? "" : viewModel.cargoType)
                                Divider()
                                
                                Toggle(isOn: $viewModel.isShortHaulEnabled) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("16 Hour Short Haul Exception")
                                            .font(AppFonts.bodyText)
                                            .foregroundColor(AppColors.textBlack)
                                        Text("Extended driving window")
                                            .font(AppFonts.captionText)
                                            .foregroundColor(AppColors.textGray)
                                    }
                                }.disabled(true)
                                .tint(.green) // Or appropriate app tint
                            }
                        }
                        
                        // Card 3: Operations
                        RulesSectionCard(title: "Operations") {
                            VStack(alignment: .leading, spacing: 16) {
                                OperationRow(title: "Personal Conveyance", subtitle: "Off-duty driving for personal use", allowed: viewModel.rulesData?.default_log_setting_allow_personal_use ?? true)
                                Divider()
                                OperationRow(title: "Yard Moves", subtitle: "Moving vehicle within facility", allowed: viewModel.rulesData?.default_log_setting_allow_yard_moves ?? true)
                                Divider()
                                OperationRow(title: "Unlimited Trailer", subtitle: "Unloaded trailer movement", allowed: viewModel.rulesData?.default_log_setting_unlimited_trailer ?? true)
                                Divider()
                                OperationRow(title: "Unlimited Shipping Documents", subtitle: "", allowed: viewModel.rulesData?.default_log_setting_unlimited_shipping ?? true)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .background(AppColors.background)
            }
            
            if viewModel.isLoading {
                AppColors.blackOpacity30.ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            viewModel.fetchRules()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Error"), message: Text(viewModel.alertMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

// Helper Components

struct RulesSectionCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textGray)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
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

struct RuleField: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFonts.bodyText)
                .foregroundColor(AppColors.textBlack)
            Text(value)
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textGray)
        }
    }
}

struct OperationRow: View {
    let title: String
    let subtitle: String
    let allowed: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.bodyText)
                    .foregroundColor(AppColors.textBlack)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppFonts.captionText)
                        .foregroundColor(AppColors.textGray)
                }
            }
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: allowed ? "checkmark.circle" : "xmark.circle")
                    .foregroundColor(allowed ? AppColors.green : AppColors.red)
                Text(allowed ? "Allowed" : "Forbidden")
                    .font(AppFonts.captionText)
                    .foregroundColor(AppColors.textGray)
            }
        }
    }
}
