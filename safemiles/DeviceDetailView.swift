import SwiftUI
import PacificTrack

struct DeviceDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var eventData: EventFrame?
    @State private var virtualDashboardData: VirtualDashboardData?
    @State private var trackerInfo: TrackerInfo?
    @State private var isMoreDetailsExpanded: Bool = true
    
    // Timer for auto-refresh
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            CommonHeader(
                title: "Device Details",
                leftIcon: "left",
                onLeftTap: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Device Info Section
                    if let event = eventData {
                        DeviceInfoCard(event: event)
                    } else {
                        // Placeholder if no event data yet
                        DeviceInfoPlaceholder()
                    }
                    
                    // More Details Header
                    Button(action: {
                        withAnimation {
                            isMoreDetailsExpanded.toggle()
                        }
                    }) {
                        VStack(spacing: 5) {
                            Text("More Details")
                                .font(.headline)
                                .foregroundColor(AppColors.textGray)
                            Image(systemName: isMoreDetailsExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(AppColors.textGray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    if isMoreDetailsExpanded {
                        if let vData = virtualDashboardData {
                            DashboardParametersCard(data: vData)
                        } else {
                            DashboardParametersPlaceholder()
                        }
                    }
                }
                .padding()
            }
            .background(AppColors.background)
        }
        .navigationBarHidden(true)
        .onAppear {
            startUpdating()
        }
        .onDisappear {
            stopUpdating()
        }
    }
    
    func startUpdating() {
        updateData()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateData()
        }
    }
    
    func stopUpdating() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateData() {
        self.eventData = Global.shared.EventData
        self.virtualDashboardData = Global.shared.virtualDashboardData
        self.trackerInfo = Global.shared.trackerInfoV
    }
}

// MARK: - Subviews

struct DeviceInfoCard: View {
    let event: EventFrame
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                DataRow(label: "Event:", value: "#\(event.sequenceNumber) \(event.getValue(forKey: "E") ?? "")")
                Divider()
                DataRow(label: "Date/Time:", value: formatDate(event.datetime))
                Divider()
                DataRow(label: "Lat/Long:", value: String(format: "%.4f / %.4f", event.geolocation.latitude, event.geolocation.longitude))
                Divider()
                DataRow(label: "Heading:", value: "\(event.geolocation.heading)")
                Divider()
                DataRow(label: "Sat.Status:", value: event.geolocation.isLocked ? "Locked" : "Not Locked")
                Divider()
            }
            Group {
                DataRow(label: "Odometer:", value: "\(event.odometer) km")
                Divider()
                DataRow(label: "Velocity:", value: "\(event.velocity) km/h")
                Divider()
                DataRow(label: "Engine Hours:", value: String(format: "%.1f", event.engineHours))
                Divider()
                DataRow(label: "RPM:", value: "\(event.rpm)")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        formatter.timeZone = getAppTimeZone()
        return formatter.string(from: date)
    }
}

struct DeviceInfoPlaceholder: View {
    var body: some View {
        VStack(spacing: 0) {
            DataRow(label: "Event:", value: "--")
            Divider()
            DataRow(label: "Date/Time:", value: "--")
            Divider()
            DataRow(label: "Lat/Long:", value: "--")
            Divider()
            DataRow(label: "Heading:", value: "--")
            Divider()
            DataRow(label: "Sat.Status:", value: "--")
            Divider()
            DataRow(label: "Odometer:", value: "--")
            Divider()
            DataRow(label: "Velocity:", value: "--")
            Divider()
            DataRow(label: "Engine Hours:", value: "--")
            Divider()
            DataRow(label: "RPM:", value: "--")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct DashboardParametersCard: View {
    let data: VirtualDashboardData
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Row
            HStack {
                Text("Parameters")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Text("Value")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            
            // Rows
            Group {
                ParamRow(label: "Bus", value: "-") // Not in vData provided snippet
                ParamRow(label: "Gear", value: data.currentGear.map { "\($0)" } ?? "-")
                ParamRow(label: "SeatBelt", value: data.seatbeltOn == true ? "Yes" : "No")
                ParamRow(label: "Brake Pedal", value: "-") // Not in snippet
                ParamRow(label: "Speed", value: data.speed.map { "\($0) km/h" } ?? "-")
                ParamRow(label: "Retarder", value: "-") // Not in snippet
                ParamRow(label: "RPM", value: data.rpm.map { "\($0)" } ?? "-")
                ParamRow(label: "DTC#", value: data.numberOfDTCPending.map { "\($0)" } ?? "-")
                ParamRow(label: "Oil Pressure", value: data.oilPressure.map { "\($0) kPa" } ?? "-")
                ParamRow(label: "Oil Level", value: data.oilLevel.map { "\($0) %" } ?? "-")
            }
            
            Group {
                ParamRow(label: "Coolant Level", value: data.coolantLevel.map { "\($0) %" } ?? "-")
                ParamRow(label: "Coolant Temp", value: data.coolantTemperature.map { "\($0) C" } ?? "-")
                ParamRow(label: "Fuel Level", value: data.fuelLevel.map { "\($0) %" } ?? "-")
                ParamRow(label: "Engine Load", value: data.engineLoad.map { "\($0) %" } ?? "-")
                ParamRow(label: "Fuel Rate", value: data.fuelRate.map { "\($0) L/h" } ?? "-")
                ParamRow(label: "Total Fuel Used", value: data.totalFuelUsed.map { "\($0) L" } ?? "-")
                ParamRow(label: "Odometer", value: data.odometer.map { "\($0) km" } ?? "-")
                ParamRow(label: "Engine Hours", value: data.engineHours.map { "\($0) h" } ?? "-")
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.bottom, 20)
    }
}

struct DashboardParametersPlaceholder: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Parameters")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Text("Value")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            
            Text("No Data Available")
                .foregroundColor(.gray)
                .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.bottom, 20)
    }
}


struct DataRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textBlack)
            Spacer()
            // Dotted leader simulation or just space
            Text(value)
                .font(.subheadline)
                .foregroundColor(AppColors.textGray)
        }
        .padding(.vertical, 8)
    }
}

struct ParamRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundColor(AppColors.textBlack)
                Spacer()
                Text(value)
                    .font(.body)
                    .foregroundColor(AppColors.textGray)
            }
            .padding()
            
            Divider()
                .padding(.leading)
        }
    }
}
