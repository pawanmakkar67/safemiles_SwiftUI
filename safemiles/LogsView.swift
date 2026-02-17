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
                rightIcon: "plus",
                onLeftTap: {
                    withAnimation {
                        showSideMenu = true
                    }
                },
                onRightTap: {
                    showAddLog = true
                }
            )
            
            // Date Selector
            // DateSelectorView logic updated to use available dates
            DateSelectorView(selectedDate: $viewModel.selectedDate, availableDates: viewModel.availableDates, logs: viewModel.logsData?.logs)
                .padding(.vertical, 8)
            
            // Tabs (Event, Form, Certify)
            Picker("Tabs", selection: $selectedTab) {
                Text("Event").tag(0)
                Text("Form").tag(1)
                Text("Certify").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
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
                .foregroundColor(AppColors.textBlack)
            
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
