import SwiftUI

struct DvirView: View {
    @Binding var showSideMenu: Bool
    @StateObject private var viewModel = DvirViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showAddDvir = false
    @State private var showDetail = false
    @State private var selectedDvirData: DivrData?
    
    var body: some View {
        ZStack {
            // Main DVIR List View
            mainListView
                .zIndex(0)
            
            // AddDvirView overlay
            if showAddDvir {
                AddDvirView(onDismiss: {
                    withAnimation {
                        showAddDvir = false
                    }
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
                .onDisappear {
                    print("DEBUG: DvirView - AddDvirView disappeared, refreshing")
                    viewModel.fetchDivrs(refresh: true)
                }
            }
            
            // DvirDetailView overlay
            if showDetail, let data = selectedDvirData {
                DvirDetailView(data: data, dismissToRoot: {
                    withAnimation {
                        showDetail = false
                        selectedDvirData = nil
                    }
                    print("DEBUG: DvirView - Dismiss to root, refreshing")
                    viewModel.fetchDivrs(refresh: true)
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var mainListView: some View {
        VStack(spacing: 0) {
            // Header
            CommonHeader(
                title: "DVIR Detail",
                leftIcon: "Menu",
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
                    // Add DVIR Button
                    Button(action: {
                        withAnimation {
                            showAddDvir = true
                        }
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
                    .padding()
                    // .padding(.top, 10)
                    
                    // List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.dvirData.indices, id: \.self) { index in
                                let data = viewModel.dvirData[index]
                                DvirRow(data: data)
                                    .onTapGesture {
                                        selectedDvirData = data
                                        withAnimation {
                                            showDetail = true
                                        }
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
        .onAppear {
            print("DEBUG: DvirView - onAppear")
            showSideMenu = false
            
            if viewModel.dvirData.isEmpty {
                 print("DEBUG: DvirView - Initial Fetch")
                 viewModel.fetchDivrs(refresh: true)
            }
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
                    .font(AppFonts.bodyText)
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
        formatter.timeZone = getAppTimeZone()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var date = formatter.date(from: dateStr)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: dateStr)
        }
        
        if let validDate = date {
            let displayFormatter = DateFormatter()
            displayFormatter.timeZone = getAppTimeZone()
            displayFormatter.dateFormat = "EEEE MMM d, yyyy"
            return displayFormatter.string(from: validDate)
        }
        return dateStr
    }
}
