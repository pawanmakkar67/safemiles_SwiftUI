import SwiftUI
import CoreBluetooth

struct HomeView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var bleManager = BLEManager.shared
    @State private var selectedSegment = 0 // 0: Overview, 1: Recap
    @State private var showBluetoothScan = false
    
    var body: some View {
        NavigationView { // Ensure navigation context if not already present, though MainTabView likely needs it. 
            // Check if MainTabView uses NavigationView. If not, we might need one here or at root.
            // Given the snippet, VStack is root. Adding NavigationLink inside.
            VStack(spacing: 0) {
                NavigationLink(destination: BluetoothScanningView(), isActive: $showBluetoothScan) {
                }
                // Common Header
                CommonHeader(
                    title: "Home",
                    leftIcon: "line.3.horizontal",
                    rightIcon: "antenna.radiowaves.left.and.right",
                    rightIconColor: bleManager.connectedPeripheral?.state == .connected ? AppColors.green : AppColors.white,
                    onLeftTap: {
                        withAnimation {
                            showSideMenu = true
                        }
                    },
                    onRightTap: {
                        // Bluetooth action
                        showBluetoothScan = true
                    }
                )
                
                // Segmented Control (Overview / Recap)
                HStack(spacing: 0) {
                    SegmentButton(title: "Overview", isSelected: selectedSegment == 0) { selectedSegment = 0 }
                    SegmentButton(title: "Recap", isSelected: selectedSegment == 1) { selectedSegment = 1 }
                }
                .background(AppColors.white)
                
                ScrollView {
                    if selectedSegment == 0 {
                        VStack(spacing: 20) {
                            // Circular Progress Ring
                            ZStack {
                                // Background Ring
                                Circle()
                                    .stroke(AppColors.ringBackground, lineWidth: 15)
                                    .frame(width: 200, height: 200)
                                
                                // Progress Ring
                                Circle()
                                    .trim(from: 0, to: 0.5) // Example value, needs calculation if dynamic
                                    .stroke(
                                        viewModel.circleBorderColor, // Use dynamic color
                                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 200, height: 200)
                                
                                // Inner Dark Circle
                                Circle()
                                    .fill(AppColors.textBlack) // Dark background
                                    .frame(width: 150, height: 150)
                                    .shadow(color: AppColors.textBlack.opacity(0.3), radius: 10, x: 0, y: 4)
                                
                                VStack(spacing: 4) {
                                    Text(viewModel.timerString)
                                        .font(AppFonts.timerText)
                                        .foregroundStyle(AppColors.white)
                                    Text("hours")
                                        .font(AppFonts.footnote)
                                        .foregroundStyle(AppColors.gray)
                                    Text(viewModel.currentStatus)
                                        .font(AppFonts.footnote)
                                        .fontWeight(.medium)
                                        .foregroundStyle(AppColors.white)
                                }
                            }
                            .padding(.top, 40)
                            
                            // Status Cards (Horizontal Scroll)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    StatusCard(
                                        title: "DRIVE",
                                        icon: "truck.box.fill",
                                        status: viewModel.currentCode == "d" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "d",
                                        statusCode: "d"
                                    )
                                    StatusCard(
                                        title: "OFF",
                                        icon: "truck.box.fill",
                                        status: viewModel.currentCode == "off" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "off",
                                        statusCode: "off"
                                    )
                                    StatusCard(
                                        title: "ON\nDuty",
                                        icon: "truck.box.fill",
                                        status: viewModel.currentCode == "on" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "on",
                                        statusCode: "on"
                                    )
                                    StatusCard(
                                        title: "Yard\nMoves",
                                        icon: "truck.box.fill",
                                        status: viewModel.currentCode == "ym" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "ym",
                                        statusCode: "ym"
                                    )
                                    StatusCard(
                                        title: "Sleeper",
                                        icon: "bed.double.fill",
                                        status: viewModel.currentCode == "sb" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "sb",
                                        statusCode: "sb"
                                    )
                                    StatusCard(
                                        title: "Personal\nUse",
                                        icon: "figure.walk",
                                        status: viewModel.currentCode == "pu" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "pu",
                                        statusCode: "pu"
                                    )
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10) // Shadow spacing
                            }
                            
                            // HOS List
                            VStack(spacing: 0) {
                                Text("Hours Of Service")
                                    .font(AppFonts.headline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 8)
                                    .background(AppColors.sectionHeaderBackground)
                                
                                HOSRow(title: "DRIVE", subtitle: "11-Hour Driving Limit", value: viewModel.driveValue)
                                HOSRow(title: "SHIFT", subtitle: "14-Hour Driving Limit", value: viewModel.shiftValue)
                                HOSRow(title: "BREAK", subtitle: "30 Minutes Driving Limit", value: viewModel.breakValue)
                                HOSRow(title: "CYCLE", subtitle: "USA 70/8", value: viewModel.cycleValue)
                            }
                            .background(AppColors.white)
                        }
                        .padding(.bottom, 20)
                    } else {
                        // Recap View
                        VStack(spacing: 0) {
                            ForEach(viewModel.recapDays, id: \.day) { day in
                                RecapRow(
                                    day: getDayName(from: day.date ?? ""),
                                    date: getFormattedDate(from: day.date ?? ""),
                                    hours: formatRecapTime(day.worked_hours)
                                )
                            }
                            
                            Divider().padding(.vertical, 5)
                            
                            // Summary Rows
                            RecapSummaryRow(title: "Total", middleText: "Last \(viewModel.recapDays.count) Days", value: viewModel.totalRecapHours)
                            RecapSummaryRow(title: "Hours Worked Today", middleText: viewModel.todayDateStr, value: viewModel.hoursWorkedToday)
                            RecapSummaryRow(title: "Hours Available Today", middleText: viewModel.todayDateStr, value: viewModel.hoursAvailableToday)
                            RecapSummaryRow(title: "Hours Available Tomorrow", middleText: viewModel.tomorrowDateStr, value: viewModel.hoursAvailableTomorrow)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    }
                }
                .background(AppColors.background)
            }
            .onAppear {
                showSideMenu = false
                showBluetoothScan = false
                viewModel.onAppear()
            }
        }
    }
    
    func formatRecapTime(_ time: String?) -> String {
        guard let time = time, !time.isEmpty else { return "00:00" }
        let parts = time.components(separatedBy: ":")
        if parts.count >= 2 {
            return "\(parts[0]):\(parts[1])"
        }
        return time
    }
}
