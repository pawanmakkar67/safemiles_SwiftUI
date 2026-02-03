import SwiftUI

struct LogsView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = LogsViewModel()
    @State private var selectedTab = 0 // 0: Event, 1: Form, 2: Certify
    // Removed local state @State private var showSideMenu = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                CommonHeader(
                    title: "Logs", // Dynamic title could be date
                    leftIcon: "line.3.horizontal",
                    rightIcon: "antenna.radiowaves.left.and.right",
                    onLeftTap: {
                        withAnimation {
                            showSideMenu = true
                        }
                    },
                    onRightTap: {
                        // Handle Bluetooth
                    }
                )
                
                // Date Selector
                // DateSelectorView logic updated to use available dates
                DateSelectorView(selectedDate: $viewModel.selectedDate, availableDates: viewModel.availableDates)
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
        }
        .onAppear {
            showSideMenu = false
            viewModel.fetchLogs()
        }
        .onChange(of: viewModel.selectedDate) { _ in
            viewModel.updateCurrentLog()
        }
    }
}

struct DateSelectorView: View {
    @Binding var selectedDate: Date
    let availableDates: [Date]
    

    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(availableDates, id: \.self) { date in
                    DateCell(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Text(getDay(date))
                .font(AppFonts.captionText)
                .foregroundColor(isSelected ? AppColors.white : AppColors.textGray)
            
            Text(getDateNumber(date))
                .font(AppFonts.headline)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? AppColors.white : AppColors.textBlack)
                .padding(8)
                .background(isSelected ? AppColors.buttonActive : AppColors.clear)
                .clipShape(Circle())
        }
        .frame(width: 50)
    }
    
    func getDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    func getDateNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
