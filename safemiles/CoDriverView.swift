
import SwiftUI

struct CoDriverView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = CoDriverViewModel()
    @ObservedObject var bleManager = BLEManager.shared
    @State private var showBluetoothScan = false
    
    // Callback to handle logout/reset action
    var onLogout: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // Common Header
                CommonHeader(
                    title: "Co-Driver",
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
                    VStack(spacing: 20) {
                        
                        // Main Card
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // 1. Select Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Select Your Co-Driver")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Menu {
                                    ForEach(viewModel.coDrivers, id: \.id) { driver in
                                        Button(action: {
                                            viewModel.selectCoDriver(driver)
                                        }) {
                                            Text("\(driver.user?.first_name ?? "") \(driver.user?.last_name ?? "")")
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(viewModel.selectedCoDriver != nil ?
                                             "\(viewModel.selectedCoDriver?.user?.first_name ?? "") \(viewModel.selectedCoDriver?.user?.last_name ?? "")" :
                                                "Select")
                                        .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground)) // Light gray bg
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            
                            Divider()
                            
                            // 2. Switch Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Switch Driver")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("You will become co-driver. Your co-driver will stay driver")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            // 3. Switch Button
                            Button(action: {
                                viewModel.switchDriver()
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                } else {
                                    Text("Switch")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                            }
                            .background(Color.black)
                            .cornerRadius(8)
                            .padding(.top, 10)
                            
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .onReceive(viewModel.$shouldLogout) { shouldLogout in
            if shouldLogout {
                onLogout()
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMsg != nil },
            set: { _ in viewModel.errorMsg = nil }
        )) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMsg ?? "Unknown error"), dismissButton: .default(Text("OK")))
            
        }
        .onAppear {
            showSideMenu = false
        }
    }

}
