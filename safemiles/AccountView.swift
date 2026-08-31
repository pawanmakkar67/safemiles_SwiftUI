
import SwiftUI
import FirebaseCrashlytics

struct AccountView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = AccountViewModel()
    @ObservedObject var bleManager = BLEManager.shared
    @ObservedObject var fontManager = FontManager.shared // Observe updates
    @State private var showBluetoothScan = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // Navigation to Bluetooth Scanning
                NavigationLink(destination: BluetoothScanningView(), isActive: $showBluetoothScan) {
                    EmptyView()
                }
                
                // Common Header
                CommonHeader(
                    title: "Account",
                    leftIcon: "Menu",
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
                    VStack(spacing: 0) {
                        // List Items
                        AccountRow(title: "Email", value: viewModel.email)
                        AccountRow(title: "Name", value: viewModel.name)
                        AccountRow(title: "Phone", value: viewModel.phone)
                        AccountRow(title: "License Number", value: viewModel.license)
                        AccountRow(title: "Carrier", value: viewModel.carrier)
                        AccountRow(title: "Office Address", value: viewModel.officeAddress) // Legacy mapped city to office address
                        AccountRow(title: "Home Terminal Address", value: viewModel.terminalAddress)
                        
                        // Font Scaler
                        FontSizeRow()
                        
                        // Footer Info Box
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "info.circle")
                                .font(AppFonts.iconSmall)
                                .foregroundColor(AppColors.textGray)
                            
                            Text("Please contact your fleet manager to change your account information.")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.textGray)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding()
                        .background(AppColors.NoteBackground)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.grayOpacity20, lineWidth: 1)
                        )
                        .padding(20)
                        
                        #if DEBUG
                        Button(action: {
                            Crashlytics.crashlytics().log("User tapped Test Crashlytics Crash button")
                            Crashlytics.crashlytics().setCustomValue("AccountView", forKey: "crash_origin")
                            fatalError("Crashlytics Test Crash triggered from AccountView")
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("Test Crashlytics Crash")
                                    .font(AppFonts.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        #endif
                        
                        Spacer()
                    }
                    .padding(.top, 10)
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
            viewModel.fetchProfile()
        }
    }
}

struct AccountRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(title)
                    .font(AppFonts.bodyText)
                    .foregroundColor(AppColors.textGray)
                    .frame(width: 120, alignment: .leading) // Fixed width for alignment like screenshot
                
                Spacer()
                
                Text(value)
                    .font(AppFonts.bodyText)
                    .foregroundColor(AppColors.textBlack)
                    .multilineTextAlignment(.trailing)
            }
            .padding()
            .background(AppColors.clear) // Screenshot has white rows
            
            Divider()
                .padding(.leading, 20) // Indented separator
        }
    }
}
