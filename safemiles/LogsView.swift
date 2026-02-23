import SwiftUI

struct LogsView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = LogsViewModel()
    @State private var selectedTab = 0 // 0: Event, 1: Form, 2: Certify
    @State private var showAddLog = false
    // Removed local state @State private var showSideMenu = false
    
    var body: some View {
        // NavigationView removed to rely on parent NavigationView
        VStack(spacing: 0) {
            // Header
            CommonHeader(
                title: "Logs", // Dynamic title could be date
                leftIcon: "Menu",
                rightIcon: "arrow.clockwise",
                onLeftTap: {
                    withAnimation {
                        showSideMenu = true
                    }
                },
                onRightTap: {
                    viewModel.fetchLogs(refresh: true)
                }
            )
            
            // Date Selector
            // DateSelectorView logic updated to use available dates
            DateSelectorView(selectedDate: $viewModel.selectedDate, availableDates: viewModel.availableDates, logs: viewModel.logsData?.logs)
                .padding(.vertical, 12)
            
            // Tabs (Event, Form, Certify)
            // Custom Tabs (Event, Form, Certify)
            HStack(spacing: 0) {
                ForEach(["Event", "Form", "Certify"], id: \.self) { tab in
                    Button(action: {
                        withAnimation {
                            if tab == "Event" { selectedTab = 0 }
                            else if tab == "Form" { selectedTab = 1 }
                            else { selectedTab = 2 }
                        }
                    }) {
                        Text(tab)
                            .font(AppFonts.buttonText)
                            .foregroundColor(isSelected(tab) ? AppColors.textBlack : AppColors.textGray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40) // Increased height
                            .background(
                                isSelected(tab) ? AppColors.white : AppColors.clear
                            )
                            .cornerRadius(8)
                            .shadow(color: isSelected(tab) ? Color.black.opacity(0.1) : Color.clear, radius: 2, x: 0, y: 1)
                    }
                }
            }
            .padding(4)
            .background(AppColors.grayOpacity20) // Background for the whole tab bar
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 10)

            
            // Content
            if selectedTab == 0 {
                EventsView(viewModel: viewModel)
            } else if selectedTab == 1 {
                FormsView(viewModel: viewModel)
            } else if selectedTab == 2 {
                CertifyView(viewModel: viewModel)
            }
        }
        .navigationBarHidden(true)
        .background(AppColors.background)
        .onAppear {
            showSideMenu = false
            viewModel.fetchLogs()
        }
        .onChange(of: viewModel.selectedDate) { _ in
            viewModel.updateCurrentLog()
        }
        .sheet(isPresented: $showAddLog) {
            AddEditLogView(
                isPresented: $showAddLog,
                event: nil,
                log: viewModel.currentLog
            )
        }
    }
    
    private func isSelected(_ tab: String) -> Bool {
        if tab == "Event" { return selectedTab == 0 }
        if tab == "Form" { return selectedTab == 1 }
        if tab == "Certify" { return selectedTab == 2 }
        return false
    }
}

struct DateSelectorView: View {
    @Binding var selectedDate: Date
    let availableDates: [Date]
    let logs: [Logs]?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(availableDates, id: \.self) { date in
                    DateCell(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        log: getLogForDate(date)
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    func getLogForDate(_ date: Date) -> Logs? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = getAppTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)
        return logs?.first(where: { $0.date == dateStr })
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let log: Logs?
    
    var body: some View {
        VStack {
            Text(getDay(date))
                .font(AppFonts.captionText)
                .foregroundColor(AppColors.textBlack).padding(.bottom,5)
            
            Text(getDateNumber(date))
                .font(AppFonts.headline)
                .fontWeight(.bold)
                .foregroundColor(dateTextColor)
                .frame(width: 50, height: 50)
                .background(dateBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // Determine status priority: selected > violations > uncertified > default
    var dateStatus: DateStatus {
        if isSelected {
            return .selected
        } else if let log = log {
            if let violations = log.violations, !violations.isEmpty {
                return .hasViolations
            } else if let certified = log.log?.certified, !certified {
                return .uncertified
            }
        }
        return .normal
    }
    
    var dayTextColor: Color {
        switch dateStatus {
        case .selected:
            return AppColors.buttonActive
        case .hasViolations:
            return AppColors.statusRed
        case .uncertified:
            return AppColors.orange
        case .normal:
            return AppColors.textGray
        }
    }
    
    var dateTextColor: Color {
        switch dateStatus {
        case .selected:
            return AppColors.buttonTextWhite
        case .hasViolations:
            return AppColors.statusRed
        case .uncertified:
            return AppColors.orange
        case .normal:
            return AppColors.textGray
        }
    }
    
    var dateBackground: Color {
        return isSelected ? AppColors.textBlack : AppColors.clear
    }
    
    var borderColor: Color {
        switch dateStatus {
        case .selected:
            return AppColors.textBlack
        case .hasViolations:
            return AppColors.statusRed
        case .uncertified:
            return AppColors.orange
        case .normal:
            return AppColors.textGray.opacity(0.3)
        }
    }
    
    func getDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = getAppTimeZone()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    func getDateNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = getAppTimeZone()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

enum DateStatus {
    case selected
    case hasViolations
    case uncertified
    case normal
}
