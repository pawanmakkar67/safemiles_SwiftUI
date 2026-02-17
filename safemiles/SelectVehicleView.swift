
import SwiftUI

struct SelectVehicleView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = SelectVehicleViewModel()
    @ObservedObject var bleManager = BLEManager.shared
    @State private var showBluetoothScan = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // Common Header
                CommonHeader(
                    title: "Select Vehicle",
                    leftIcon: "Menu",
                    onLeftTap: {
                        withAnimation {
                            showSideMenu = true
                        }
                    },
                    onRightTap: {
                        showBluetoothScan = true
                        // Or maybe simple scan toggle? The legacy code starts scan on viewWillAppear.
                        // We can assume BluetoothScanningView handles scanning or displaying devices.
                    }
                )
                
                // Search Bar
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search vehicles...", text: $viewModel.searchQuery)
                            .font(AppFonts.textField)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(AppColors.textFieldBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.textFieldBorder, lineWidth: 1)
                    )
                    .padding()
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredVehicles, id: \.id) { vehicle in
                            VehicleRowCard(vehicle: vehicle)
                                .onTapGesture {
                                    viewModel.connect(to: vehicle)
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            showSideMenu = false
            if Global.shared.vehicleList.isEmpty {
                viewModel.fetchVehicles()
            }
            // Start BLE scan if not connected
            if bleManager.connectedPeripheral == nil {
                bleManager.startScan()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Alert"), message: Text(viewModel.alertMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

struct VehicleRowCard: View {
    let vehicle: VehicleData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(vehicle.unit_number ?? "Unknown Unit")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(vehicle.vehicle_model ?? vehicle.vehicle_make ?? "Unknown Model")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
             RoundedRectangle(cornerRadius: 8)
                 .stroke(Color.gray.opacity(0.2), lineWidth: 1)
         )
    }
}
