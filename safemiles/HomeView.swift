import SwiftUI
import CoreBluetooth

struct HomeView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var bleManager = BLEManager.shared
    @State private var selectedSegment = 0 // 0: Overview, 1: Recap
    @State private var showBluetoothScan = false
    
    var body: some View {
        // NavigationView removed to rely on parent NavigationView
            // Check if MainTabView uses NavigationView. If not, we might need one here or at root.
            // Given the snippet, VStack is root. Adding NavigationLink inside.
            VStack(spacing: 0) {
                NavigationLink(destination: BluetoothScanningView(), isActive: $showBluetoothScan) {
                }
                // Common Header
                CommonHeader(
                    title: "Home",
                    leftIcon: "Menu",
                    rightIcon: "ble",
                    rightIconColor: bleManager.connectedPeripheral?.state == .connected ? AppColors.statusGreen : AppColors.white,
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
                                    .trim(from: 0, to: viewModel.driveProgress)
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
                                    .onTapGesture {
                                        if viewModel.currentCode != "d" {
                                            viewModel.selectedStatusUpdateCode = "d"
                                            withAnimation {
                                                viewModel.showStatusUpdateModal = true
                                            }
                                        }
                                    }
                                    
                                    StatusCard(
                                        title: "OFF",
                                        icon: "truck.box.fill",
                                        status: viewModel.currentCode == "off" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "off",
                                        statusCode: "off"
                                    )
                                    .onTapGesture {
                                        if viewModel.currentCode != "off" {
                                            viewModel.selectedStatusUpdateCode = "off"
                                            withAnimation {
                                                viewModel.showStatusUpdateModal = true
                                            }
                                        }
                                    }
                                    StatusCard(
                                        title: "ON\nDuty",
                                        icon: "truck.box.fill",
                                        status: viewModel.currentCode == "on" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "on",
                                        statusCode: "on"
                                    )
                                    .onTapGesture {
                                        if viewModel.currentCode != "on" {
                                            viewModel.selectedStatusUpdateCode = "on"
                                            withAnimation {
                                                viewModel.showStatusUpdateModal = true
                                            }
                                        }
                                    }
                                    
                                    StatusCard(
                                        title: "Yard\nMoves",
                                        icon: "truck.box.fill",
                                        status: viewModel.currentCode == "ym" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "ym",
                                        statusCode: "ym"
                                    )
                                    .onTapGesture {
                                        if viewModel.currentCode != "ym" {
                                            viewModel.selectedStatusUpdateCode = "ym"
                                            withAnimation {
                                                viewModel.showStatusUpdateModal = true
                                            }
                                        }
                                    }
                                    
                                    StatusCard(
                                        title: "Sleeper",
                                        icon: "bed.double.fill",
                                        status: viewModel.currentCode == "sb" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "sb",
                                        statusCode: "sb"
                                    )
                                    .onTapGesture {
                                        if viewModel.currentCode != "sb" {
                                            viewModel.selectedStatusUpdateCode = "sb"
                                            withAnimation {
                                                viewModel.showStatusUpdateModal = true
                                            }
                                        }
                                    }
                                    
                                    StatusCard(
                                        title: "Personal\nUse",
                                        icon: "figure.walk",
                                        status: viewModel.currentCode == "pu" ? "ACTIVE" : "START",
                                        isActive: viewModel.currentCode == "pu",
                                        statusCode: "pu"
                                    )
                                    .onTapGesture {
                                        if viewModel.currentCode != "pu" {
                                            viewModel.selectedStatusUpdateCode = "pu"
                                            withAnimation {
                                                viewModel.showStatusUpdateModal = true
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10) // Shadow spacing
                            }
                            
                            // Violation Alert
                            if !viewModel.allViolations.isEmpty {
                                Button(action: {
                                    viewModel.showViolationsSheet = true
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "exclamationmark.circle")
                                            .font(AppFonts.iconSmall)
                                            .foregroundColor(AppColors.statusRed)
                                        
                                        Text("Violation Alert : \(viewModel.allViolations.count) violations recorded")
                                            .font(AppFonts.bodyText)
                                            .foregroundColor(AppColors.textBlack)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "square.and.arrow.up")
                                            .font(AppFonts.callout)
                                            .foregroundColor(AppColors.textGray)
                                    }
                                    .padding()
                                    .background(AppColors.statusRed.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.statusRed, lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal)
                                .sheet(isPresented: $viewModel.showViolationsSheet) {
                                    ViolationsView(violations: viewModel.allViolations)
                                        .presentationDetents([.medium])
                                        .presentationDragIndicator(.visible)

                                }
                            }
                            
                            // HOS List
                            VStack(spacing: 0) {
                                Text("Hours Of Service")
                                    .font(AppFonts.buttonText)
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
                            
                            Divider().padding(0)
                            
                            // Summary Rows
                            RecapSummaryRow(title: "Total", middleText: "Last \(viewModel.recapDays.count) Days", value: viewModel.totalRecapHours)
                            RecapSummaryRow(title: "Hours Worked", middleText: viewModel.todayDateStr, value: viewModel.hoursAvailableToday)
                            RecapSummaryRow(title: "Hours Available", middleText: viewModel.tomorrowDateStr, value: viewModel.hoursAvailableTomorrow)
                        }
                        .padding(20)
                        .cornerRadius(8)
//                        .padding(.bottom, 20)
                    }
                }
                .background(AppColors.background)
            }
            .onAppear {
                showSideMenu = false
                showBluetoothScan = false
                viewModel.onAppear()
            }
            .overlay(
                Group {
                    if viewModel.showStatusUpdateModal {
                        StatusUpdateView(selectedCode: viewModel.selectedStatusUpdateCode, isPresented: $viewModel.showStatusUpdateModal)
                    }
                }
            )

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
