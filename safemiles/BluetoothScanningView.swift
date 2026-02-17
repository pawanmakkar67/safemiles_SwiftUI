import SwiftUI
import CoreBluetooth
import PacificTrack // Assuming this is needed for TrackerPeripheral if public

struct BluetoothScanningView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var bleManager = BLEManager.shared
    @State private var showDeviceDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(AppFonts.iconMedium)
                        .foregroundStyle(AppColors.white)
                }
                
                Spacer()
                
                Text("Home")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.white)
                
                Spacer()
                
                NavigationLink(destination: DeviceDetailView(), isActive: $showDeviceDetail) {
                    EmptyView()
                }

                Button(action: {
                    if bleManager.connectedPeripheral?.state == .connected {
                        showDeviceDetail = true
                    }
                }) {
                    Image(systemName: "info.circle")
                        .font(AppFonts.iconMedium)
                        .foregroundStyle(AppColors.white)
                }
            }
            .padding()
            .background(AppColors.black)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Please verify the following items")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textGray)
                            .padding(.bottom, 4)
                        
                        BulletPoint(text: "ELD Mac address entered correctly.")
                        BulletPoint(text: "ELD hardware is properly installed.")
                        BulletPoint(text: "Vehicle power in ON.")
                        BulletPoint(text: "Bluetooth is enabled on mobile device.")
                        BulletPoint(text: "GPS is enabled on mobile device.")
                        
                        Text("To Connect, please select the mac address listed on device")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textGray)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Available Devices
                    Text("Available Devices:")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textGray)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        if bleManager.discoveredPeripherals.isEmpty && bleManager.connectedPeripheral == nil {
                            Text("Scanning...")
                                .font(AppFonts.callout)
                                .foregroundColor(AppColors.textGray)
                                .padding()
                        } else {
                            ForEach(bleManager.discoveredPeripherals, id: \.peripheral.identifier) { tracker in
                                DeviceRow(tracker: tracker) {
                                    bleManager.connect(to: tracker.peripheral)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Continue / Disconnect Button
                        Button(action: {
                            if bleManager.connectedPeripheral?.state == .connected {
                                // Disconnect Action
                                UserDefaults.AlreadyConnected(login: false)
                                bleManager.disconnect()
                                // Logic from errorVC: If manual disconnect, clear cache
                                bleManager.discoveredPeripherals.removeAll()
                            } else {
                                // Continue Disconnected Action
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text(bleManager.connectedPeripheral?.state == .connected ? "DISCONNECT" : "CONTINUE DISCONNECTED")
                                .font(AppFonts.buttonText)
                                .foregroundColor(AppColors.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.black)
                                .cornerRadius(30)
                        }
                        
                        // Rescan Button (Hidden if connected)
                        if bleManager.connectedPeripheral?.state != .connected {
                            Button(action: {
                                bleManager.startScan()
                            }) {
                                Text("RESCAN")
                                    .font(AppFonts.buttonText)
                                    .foregroundColor(AppColors.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(AppColors.black, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Footer Info Card
                    Image("footer_info_card")
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
            }
            .background(AppColors.background)
        }
        .navigationBarHidden(true)
        .onAppear {
            if let connected = bleManager.connectedPeripheral, connected.state == .connected {
                // Already connected logic
            } else {
                bleManager.startScan()
            }
        }
        .onDisappear {
            bleManager.stopScan()
        }
        .onReceive(bleManager.$connectedPeripheral) { peripheral in
            if let peripheral = peripheral, peripheral.state == .connected {
                // Connected Logic
                // Save UUID and Connected State
                UserDefaults.AlreadyConnected(login: true)
                UserDefaults.saveBleUUID(lat: peripheral.identifier.uuidString)
                
                // We no longer dismiss automatically. User stays on screen to see status.
            }
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .foregroundColor(AppColors.textGray)
            Text(text)
                .foregroundColor(AppColors.textGray)
                .font(AppFonts.subheadline)
        }
    }
}

struct DeviceRow: View {
    let tracker: TrackerPeripheral
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(tracker.peripheral.name ?? "Unknown Device")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textBlack)
                
                // Note: iOS does not expose MAC address. 
                // Using identifier or simulated text if not available from TrackerPeripheral wrapper
                // Assuming TrackerPeripheral might handle it, or we just show UUID
                Text("Mac address: \(tracker.peripheral.identifier.uuidString.prefix(17))") 
                    .font(AppFonts.captionText)
                    .foregroundColor(AppColors.textGray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.white)
            .cornerRadius(10)
            .shadow(color: AppColors.blackOpacity05 ?? AppColors.blackOpacity10, radius: 2, x: 0, y: 1) // Safe match
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.grayOpacity20, lineWidth: 1)
            )
        }
    }
}

