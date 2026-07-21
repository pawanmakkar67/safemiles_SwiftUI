import SwiftUI
import CoreBluetooth
import Combine

struct HomeView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var bleManager = BLEManager.shared
    @ObservedObject var global = Global.shared // Observe global singleton directly
    
    @State private var selectedSegment = 0 // 0: Overview, 1: Recap
    @State private var showBluetoothScan = false
    @State private var isDriving = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationLink(destination: BluetoothScanningView(), isActive: $showBluetoothScan) {
                }
                
                // Common Header
                CommonHeader(
                    title: global.getHeaderTitle(), // Bind directly to global state
                    leftIcon: isDriving ? nil : "Menu",
                    rightIcon: "ble",
                    rightIconColor: bleManager.connectedPeripheral?.state == .connected ? AppColors.statusGreen : AppColors.white,
                    onLeftTap: {
                        if !isDriving {
                            withAnimation {
                                showSideMenu = true
                            }
                        }
                    },
                    onRightTap: {
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
                        OverviewTabView(viewModel: viewModel)
                    } else {
                        RecapTabView(viewModel: viewModel)
                    }
                }
                .refreshable { await viewModel.refreshData() }
                .background(AppColors.background)
            }
            .overlay(
                Group {
                    if viewModel.showStatusUpdateModal {
                        StatusUpdateView(selectedCode: viewModel.selectedStatusUpdateCode, isPresented: $viewModel.showStatusUpdateModal)
                    }
                }
            )
        }
        .onAppear {
            showBluetoothScan = false
            if let obj = Global.shared.recapvalues {
                viewModel.updateData(obj)
                if let code = obj.last_event?.code?.lowercased() {
                    isDriving = (code == "d")
                }
            }
            viewModel.onAppear()
        }
        .onReceive(NotificationCenter.default.publisher(for: .drivingStatusChanged).receive(on: RunLoop.main)) { note in
            if let status = note.object as? Bool {
                withAnimation { isDriving = status }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .recapUpdate).receive(on: RunLoop.main)) { _ in
            if let code = Global.shared.recapvalues?.last_event?.code?.lowercased() {
                withAnimation { isDriving = (code == "d") }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .profileUpdate).receive(on: RunLoop.main)) { _ in
        }
        .onReceive(NotificationCenter.default.publisher(for: .vehicleUpdate).receive(on: RunLoop.main)) { _ in
        }
    }
}

// MARK: - Overview Tab
struct OverviewTabView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject private var global = Global.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // BLE Event Type Ticker
            EventTypeTicker(activeRawValue: global.latestEventRawValue)
                .padding(.top, 16)
            
            // Circular Progress Ring
            ZStack {
                Circle()
                    .stroke(AppColors.ringBackground, lineWidth: 15)
                    .frame(width: 210, height: 210)
                
                Circle()
                    .trim(from: 0, to: viewModel.driveProgress)
                    .stroke(
                        viewModel.circleBorderColor,
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 210, height: 210)
                
                Circle()
                    .fill(AppColors.textBlack)
                    .frame(width: 180, height: 180)
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
            .padding(.top, 16)
            
            // Status Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    StatusCard(title: "DRIVE", icon: "drive_ic", status: viewModel.currentCode == "d" ? "ACTIVE" : "START", isActive: viewModel.currentCode == "d", statusCode: "d")
                        .contentShape(Rectangle())
                        .onTapGesture { if viewModel.currentCode != "d" { viewModel.selectedStatusUpdateCode = "d"; withAnimation { viewModel.showStatusUpdateModal = true } } }
                    
                    StatusCard(title: "OFF", icon: "off_ic", status: viewModel.currentCode == "off" ? "ACTIVE" : "START", isActive: viewModel.currentCode == "off", statusCode: "off")
                        .contentShape(Rectangle())
                        .onTapGesture { if viewModel.currentCode != "off" { viewModel.selectedStatusUpdateCode = "off"; withAnimation { viewModel.showStatusUpdateModal = true } } }
                    
                    StatusCard(title: "ON\nDuty", icon: "on_ic", status: viewModel.currentCode == "on" ? "ACTIVE" : "START", isActive: viewModel.currentCode == "on", statusCode: "on")
                        .contentShape(Rectangle())
                        .onTapGesture { if viewModel.currentCode != "on" { viewModel.selectedStatusUpdateCode = "on"; withAnimation { viewModel.showStatusUpdateModal = true } } }
                    
                    StatusCard(title: "Yard\nMoves", icon: "ym_ic", status: viewModel.currentCode == "ym" ? "ACTIVE" : "START", isActive: viewModel.currentCode == "ym", statusCode: "ym")
                        .contentShape(Rectangle())
                        .onTapGesture { if viewModel.currentCode != "ym" { viewModel.selectedStatusUpdateCode = "ym"; withAnimation { viewModel.showStatusUpdateModal = true } } }
                    
                    StatusCard(title: "Sleeper", icon: "sb_ic", status: viewModel.currentCode == "sb" ? "ACTIVE" : "START", isActive: viewModel.currentCode == "sb", statusCode: "sb")
                        .contentShape(Rectangle())
                        .onTapGesture { if viewModel.currentCode != "sb" { viewModel.selectedStatusUpdateCode = "sb"; withAnimation { viewModel.showStatusUpdateModal = true } } }
                    
                    StatusCard(title: "Personal\nUse", icon: "pu_ic", status: viewModel.currentCode == "pu" ? "ACTIVE" : "START", isActive: viewModel.currentCode == "pu", statusCode: "pu")
                        .contentShape(Rectangle())
                        .onTapGesture { if viewModel.currentCode != "pu" { viewModel.selectedStatusUpdateCode = "pu"; withAnimation { viewModel.showStatusUpdateModal = true } } }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            
            // Violation Alert
            if !viewModel.allViolations.isEmpty {
                Button(action: { viewModel.showViolationsSheet = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle").font(AppFonts.iconSmall).foregroundColor(AppColors.statusRed)
                        Text("Violation Alert : \(viewModel.allViolations.count) violations recorded").font(AppFonts.bodyText).foregroundColor(AppColors.textBlack)
                        Spacer()
                        Image("violationArrow").font(AppFonts.callout).foregroundColor(AppColors.textGray)
                    }
                    .padding()
                    .background(AppColors.statusRed.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.statusRed, lineWidth: 1))
                }
                .padding(.horizontal)
                .sheet(isPresented: $viewModel.showViolationsSheet) {
                    ViolationsView(violations: viewModel.allViolations).sheetDetentsMedium().presentationDragIndicatorVisible()
                }
            }
            
            // HOS List
            VStack(spacing: 0) {
                Text("Hours Of Service - US (70 hours/ 8 Days)").font(AppFonts.buttonText).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 8).background(AppColors.sectionHeaderBackground)
                HOSRow(title: "DRIVE", subtitle: "11-Hour Driving Limit", value: viewModel.driveValue)
                HOSRow(title: "SHIFT", subtitle: "14-Hour Driving Limit", value: viewModel.shiftValue)
                HOSRow(title: "BREAK", subtitle: "30 Minutes Driving Limit", value: viewModel.breakValue)
                HOSRow(title: "CYCLE", subtitle: "USA 70/8", value: viewModel.cycleValue)
            }
            .background(AppColors.white)
        }
        .padding(.bottom, 20)
    }
}

// MARK: - BLE Event Type Ticker
/// Scrolling horizontal ticker showing all 16 PacificTrack EventType cases.
/// The item matching `activeRawValue` (latest BLE event) is highlighted in green
/// and auto-scrolled into view. When idle, items cycle automatically.
struct EventTypeTicker: View {
    let activeRawValue: Int?

    /// All 16 EventType cases keyed by raw value.
    private let eventLabels: [(raw: Int, name: String)] = [
        (0,  "Power On"),
        (1,  "Power Off"),
        (2,  "Ignition On"),
        (3,  "Ignition Off"),
        (4,  "Engine On"),
        (5,  "Engine Off"),
        (6,  "Trip Start"),
        (7,  "Trip Stop"),
        (8,  "Periodic"),
        (9,  "BT Connected"),
        (10, "BT Disconnected"),
        (11, "BUS Connected"),
        (12, "BUS Disconnected"),
        (13, "Harsh Accel"),
        (14, "Harsh Braking"),
        (15, "Harsh Cornering"),
    ]

    @State private var tickerIndex: Int = 0
    @State private var idleTimer: Timer? = nil

    /// The item currently shown — active BLE event takes priority, otherwise idle cycle.
    private var displayedItem: (raw: Int, name: String) {
        if let raw = activeRawValue, let match = eventLabels.first(where: { $0.raw == raw }) {
            return match
        }
        return eventLabels[tickerIndex]
    }

    var body: some View {
        let item = displayedItem
        let isLive = activeRawValue != nil

        HStack(spacing: 6) {
            Text("#\(item.raw)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(isLive ? AppColors.statusGreen : AppColors.textGray)
            Text(item.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isLive ? AppColors.textBlack : AppColors.textGray)
        }
        .id(item.raw)                              // triggers transition on change
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal:   .move(edge: .leading).combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.35), value: item.raw)
        .frame(maxWidth: .infinity, alignment: .center)
        .onAppear { startIdleTicker() }
        .onChange(of: activeRawValue) { newVal in
            if newVal != nil {
                idleTimer?.invalidate()
                idleTimer = nil
            } else {
                startIdleTicker()
            }
        }
    }

    private func startIdleTicker() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.35)) {
                tickerIndex = (tickerIndex + 1) % eventLabels.count
            }
        }
    }
}

// MARK: - Recap Tab
struct RecapTabView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.recapDays, id: \.day) { day in
                RecapRow(day: getDayName(from: day.date ?? ""), date: getFormattedDate(from: day.date ?? ""), hours: formatRecapTime(day.worked_hours))
            }
            Divider().padding(0)
            RecapSummaryRow(title: "Total", middleText: "Last \(viewModel.recapDays.count) Days", value: viewModel.totalRecapHours)
            RecapSummaryRow(title: "Hours Worked", middleText: viewModel.todayDateStr, value: viewModel.hoursAvailableToday)
            RecapSummaryRow(title: "Hours Available", middleText: viewModel.tomorrowDateStr, value: viewModel.hoursAvailableTomorrow)
        }
        .padding(20)
        .cornerRadius(8)
    }
    
    private func formatRecapTime(_ time: String?) -> String {
        guard let time = time, !time.isEmpty else { return "00:00" }
        let parts = time.components(separatedBy: ":")
        if parts.count >= 2 { return "\(parts[0]):\(parts[1])" }
        return time
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(showSideMenu: .constant(false))
    }
}
