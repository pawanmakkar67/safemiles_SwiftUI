import SwiftUI

struct DvirView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = DvirViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showAddDvir = false
    @State private var selectedDvir: DivrData?
    @State private var showDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                CommonHeader(
                    title: "DVIR",
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
                
                // Content
                ZStack {
                    AppColors.background
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 16) {
                        // Navigation Links
                        NavigationLink(destination: AddDvirView(), isActive: $showAddDvir) {
                             EmptyView()
                        }
                        
                        // Detail Link
                        if let data = selectedDvir {
                             NavigationLink(destination: DvirDetailView(data: data), isActive: $showDetail) {
                                  EmptyView()
                             }
                        }
                        
                        // Add DVIR Button
                        Button(action: {
                            showAddDvir = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add DVIR")
                            }
                            .font(AppFonts.buttonTitle)
                            .foregroundColor(AppColors.textBlack)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.white)
                            .cornerRadius(8)
                            .shadow(color: AppColors.blackOpacity10, radius: 2, x: 0, y: 1)
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                        
                        // List
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.dvirData.indices, id: \.self) { index in
                                    let data = viewModel.dvirData[index]
                                    DvirRow(data: data)
                                        .onTapGesture {
                                            self.selectedDvir = data
                                            self.showDetail = true
                                        }
                                        .onAppear {
                                            if index == viewModel.dvirData.count - 2 {
                                                viewModel.loadMore()
                                            }
                                        }
                                }
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                        .padding()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                        .refreshable {
                             viewModel.fetchDivrs(refresh: true)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            showSideMenu = false
            viewModel.fetchDivrs(refresh: true)
            showAddDvir = false
        }
        
    }
}


struct DvirRow: View {
    let data: DivrData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Vehicle & Trailer Info
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    let vehicleNum = data.vehicle?.unit_number ?? ""
                    let trailerStr = data.trailers?.joined(separator: ", ") ?? ""
                    let dateStr = formatDate(data.dvir_date_time)
                    
                    Text("Vehicle : \(vehicleNum) | Trailers : \(trailerStr)")
                        .font(AppFonts.cardTitle)
                        .foregroundColor(AppColors.textBlack)
                    
                    Text(dateStr)
                        .font(AppFonts.cardSubtitle)
                        .foregroundColor(AppColors.textGray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.iconGray)
                    .font(.system(size: 14))
            }
            
            Divider()
                .background(AppColors.grayOpacity20)
            
            // Status Section
            statusView
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: AppColors.textBlack.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    var statusView: some View {
        let vehicleDefectsCount = data.vehicle_defects?.count ?? 0
        let trailerDefectsCount = data.trailer_defects?.count ?? 0
        let totalDefects = vehicleDefectsCount + trailerDefectsCount
        
        return HStack(spacing: 8) {
            if totalDefects == 0 {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(AppColors.statusGreen)
                Text("Passed - No Issues")
                    .font(AppFonts.bodyText)
                    .foregroundColor(AppColors.textGray)
            } else {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(AppColors.statusRed)
                Text("\(totalDefects) Defects Found")
                    .font(AppFonts.bodyText)
                    .foregroundColor(AppColors.statusRed)
            }
        }
    }
    
    func formatDate(_ dateStr: String?) -> String {
        guard let dateStr = dateStr else { return "" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var date = formatter.date(from: dateStr)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: dateStr)
        }
        
        if let validDate = date {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "EEEE MMM d, yyyy"
            return displayFormatter.string(from: validDate)
        }
        return dateStr
    }
}
