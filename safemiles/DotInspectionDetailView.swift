
import SwiftUI
import Foundation

struct DotInspectionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: DotInspectionDetailViewModel
    @Binding var showSideMenu: Bool

    init(logsViewModel: LogsViewModel, showSideMenu: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: DotInspectionDetailViewModel(logsViewModel: logsViewModel))
        _showSideMenu = showSideMenu
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            
            // Common Header
            CommonHeader(
                title: "Dot Inspection",
                leftIcon: "left",
                onLeftTap: {
                    presentationMode.wrappedValue.dismiss()
                },
                onRightTap: {

                }
            )
            
            HStack {
                Text("Inspection")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textBlack)
                
                Spacer()
                
                // Date Picker Button
                Menu {
                    ForEach(viewModel.logsViewModel.availableDates, id: \.self) { date in
                        Button(action: {
                            viewModel.logsViewModel.selectedDate = date
                            viewModel.logsViewModel.updateCurrentLog()
                        }) {
                            Text(viewModel.formatDisplayDate(date))
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.formatDisplayDate(viewModel.logsViewModel.selectedDate))
                            .font(AppFonts.bodyText)
                            .foregroundColor(AppColors.textBlack)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textGray)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.grayOpacity30, lineWidth: 1)
                    )
                }
            }
            .padding()
            .background(AppColors.grayOpacity10)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Driver Info Section
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(label: "Driver:", value: viewModel.driverName)
                        InfoRow(label: "Co-Driver:", value: viewModel.coDriverName)
                        InfoRow(label: "Main Office Address:", value: viewModel.officeAddress)
                        InfoRow(label: "Truck/Tractor:", value: viewModel.truckTractor)
                        InfoRow(label: "Driver License:", value: viewModel.licenseNumber)
                        InfoRow(label: "Driver License State:", value: viewModel.licenseState)
                        InfoRow(label: "ELD Registration ID:", value: viewModel.eldRegistrationId)
                        InfoRow(label: "Provider:", value: viewModel.provider)
                    }
                    .padding()
                    .background(AppColors.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Log Graph
                    VStack {
                        LogbookGraphView(segments: viewModel.logsViewModel.dutySegments)
                            .frame(height: 150)
                            .padding(.vertical,12)
                        .padding(.horizontal,7)
                        .background(AppColors.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//                    .padding(.horizontal)
                    
                    // Totals Section
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            TotalItem(label: "Total Miles:", value: viewModel.totalMiles)
                            TotalItem(label: "Sleeper:", value: viewModel.formatDuration(seconds: viewModel.statusTotals[.sleeper] ?? 0))
                            TotalItem(label: "On Duty:", value: viewModel.formatDuration(seconds: viewModel.statusTotals[.on] ?? 0))
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 8) {
                            TotalItem(label: "Off Duty:", value: viewModel.formatDuration(seconds: viewModel.statusTotals[.off] ?? 0))
                            TotalItem(label: "Driving:", value: viewModel.formatDuration(seconds: viewModel.statusTotals[.driving] ?? 0))
                        }
                    }
                    .padding()
                    .background(AppColors.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Cycle Total:")
                            .font(AppFonts.headline)
                        Spacer()
                        Text(viewModel.cycleTotal)
                            .font(AppFonts.headline)
                            .bold()
                    }
                    .padding(.horizontal, 25)
                    
                    // Events Table
                    GeometryReader { geometry in
                        let totalWidth = geometry.size.width
                        VStack(spacing: 0) {
                            // Table Header
                            HStack(spacing: 0) {
                                TableHeaderCell(text: "Status", width: totalWidth * 0.17)
                                TableHeaderCell(text: "Start", width: totalWidth * 0.13)
                                TableHeaderCell(text: "Duration", width: totalWidth * 0.17)
                                TableHeaderCell(text: "Location", width: totalWidth * 0.23)
                                TableHeaderCell(text: "Notes", width: totalWidth * 0.13)
                                TableHeaderCell(text: "Odometer", width: totalWidth * 0.17)
                            }
                            .background(AppColors.grayOpacity10)
                            
                            // Table Rows
                            if let events = viewModel.logsViewModel.currentLog?.events {
                                ForEach(events.indices, id: \.self) { index in
                                    let event = events[index]
                                    let duration = convertSecondsToHoursAndMinutes(event.time_diff ?? 0)
                                    let durationStr = "\(duration.hours)h \(duration.minutes)m"
                                    
                                    HStack(spacing: 0) {
                                        TableCell(text: viewModel.getStatusTitle(mapCodeToStatus(event.code)), width: totalWidth * 0.17)
                                        TableCell(text: viewModel.formatTime(event.eventdatetime), width: totalWidth * 0.13)
                                        TableCell(text: durationStr, width: totalWidth * 0.17)
                                        TableCell(text: event.location_notes ?? "-", width: totalWidth * 0.23)
                                        TableCell(text: "-", width: totalWidth * 0.13) // Notes
                                        TableCell(text: String(format: "%.0f", event.odometer ?? 0), width: totalWidth * 0.17)
                                    }
                                    .border(AppColors.grayOpacity20, width: 0.5)
                                }
                            }
                        }
                    }
                    .frame(height: CGFloat((viewModel.logsViewModel.currentLog?.events?.count ?? 0) * 60 + 40)) // 40 for header + 60 per row
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.grayOpacity30, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Signature Placeholder
                    VStack {
                        Spacer()
                        Divider()
                            .frame(width: 250)
                        Text("Driver's Signature")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textGray)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                }
                .padding(.top)
            }
        }
        .onAppear {
            if viewModel.logsViewModel.availableDates.isEmpty {
                viewModel.logsViewModel.fetchLogs(refresh: true)
            }
        }
        .navigationBarHidden(true)
        .background(AppColors.background)
    }
    
    func mapCodeToStatus(_ code: String?) -> DutyStatus {
        switch code?.lowercased() {
        case "d": return .driving
        case "on": return .on
        case "sb": return .sleeper
        case "off": return .off
        case "login": return .login
        case "ym": return .yardMove
        default: return .off
        }
    }
}

// Support Views for table
struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(AppFonts.bodyText)
                .foregroundColor(AppColors.textGray)
                .frame(width: 140, alignment: .leading)
            Spacer()
            Text(value)
                .font(AppFonts.bodyText)
                .foregroundColor(AppColors.textBlack)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct TotalItem: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.bodyText)
                .foregroundColor(AppColors.textGray)
            Spacer()
            Text(value)
                .font(AppFonts.bodyText)
                .foregroundColor(AppColors.textBlack)
                .bold()
        }
        .frame(width: 150)
    }
}

struct TableHeaderCell: View {
    let text: String
    let width: CGFloat
    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold)) // Maintain reduced size for better fit
            .padding(5)
            .frame(width: width, height: 40, alignment: .leading)
            .border(AppColors.grayOpacity30, width: 0.5)
    }
}

struct TableCell: View {
    let text: String
    let width: CGFloat
    var body: some View {
        Text(text)
            .font(.system(size: 9)) // Maintain reduced size for better fit
            .padding(5)
            .frame(width: width, height: 60, alignment: .topLeading)
            .multilineTextAlignment(.leading)
    }
}
