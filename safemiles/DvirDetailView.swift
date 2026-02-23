import SwiftUI
import Alamofire
import ObjectMapper

struct DvirDetailView: View {

    let initialData: DivrData
    @State private var data: DivrData
    @Environment(\.presentationMode) var presentationMode
    @State private var showEditView = false
    @State private var isNavigatingToEdit = false
    var dismissToRoot: (() -> Void)?
    
    init(data: DivrData, dismissToRoot: (() -> Void)? = nil) {
        self.initialData = data
        _data = State(initialValue: data)
        self.dismissToRoot = dismissToRoot
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            CommonHeader(
                title: "DVIR",
                leftIcon: "left",
                onLeftTap: {
                    if let dismissToRoot = dismissToRoot {
                        dismissToRoot()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                onRightTap: {
                     // Bluetooth action
                }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    // Sub Header: Vehicle & Trailer
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Vehicle : \(data.vehicle?.unit_number ?? "") | Trailers : \(data.trailers?.joined(separator: ", ") ?? "")")
                                .font(AppFonts.cardTitle)
                                .foregroundColor(AppColors.textBlack)
                            
                            Spacer()
                            
                            Menu {
                                Button(action: {
                                    isNavigatingToEdit = true
                                    showEditView = true
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive, action: {
                                    deleteDivr()
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(AppColors.textBlack)
                                    .padding(8) // Increase touch target
                            }
                        }
                        
                        Text(formatDate(data.dvir_date_time))
                            .font(AppFonts.cardSubtitle)
                            .foregroundColor(AppColors.textGray)
                            .padding(.leading, 20) // Indent to align with title text
                    }
                    .padding()
                    
                    // Inspection Details Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Inspection Details")
                            .font(AppFonts.sectionHeader)
                            .foregroundColor(AppColors.textGray)
                        
                        detailRow(title: "Date & Time", value: formatDateTime(data.dvir_date_time))
                        Divider()
                        detailRow(title: "Odometer", value: "\(data.odometer ?? "-") \("miles")") // Unit placeholder
                        Divider()
                        detailRow(title: "Location", value: data.location ?? "-")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: AppColors.textBlack.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Vehicle Card (Defects)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Vehicle")
                                .font(AppFonts.sectionHeader)
                                .foregroundColor(AppColors.textGray)
                            Spacer()
                            
                            let defects = data.vehicle_defects?.count ?? 0
                            statusBadge(defects: defects)
                        }
                        
                        HStack {
                            Text("Vehicle Number")
                                .font(AppFonts.bodyText)
                                .foregroundColor(AppColors.textGray)
                            Spacer()
                            Text(data.vehicle?.unit_number ?? "-")
                                .font(AppFonts.bodyText)
                                .foregroundColor(AppColors.textBlack)
                        }
                        
                        if let defects = data.vehicle_defects, !defects.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Defects (\(defects.count))")
                                     .font(AppFonts.captionText)
                                     .foregroundColor(AppColors.textGray)
                                
                                ForEach(defects, id: \.self) { defect in
                                    defectRow(text: defect)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: AppColors.textBlack.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Trailer Card (Defects)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Trailer")
                                .font(AppFonts.sectionHeader)
                                .foregroundColor(AppColors.textGray)
                            Spacer()
                            
                            let defects = data.trailer_defects?.count ?? 0
                            statusBadge(defects: defects)
                        }
                         
                        HStack {
                            Text("Trailer Number")
                                .font(AppFonts.bodyText)
                                .foregroundColor(AppColors.textGray)
                            Spacer()
                            Text(data.trailers?.joined(separator: ", ") ?? "-")
                                .font(AppFonts.bodyText)
                                .foregroundColor(AppColors.textBlack)
                        }
                        
                        if let defects = data.trailer_defects, !defects.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Defects (\(defects.count))")
                                     .font(AppFonts.captionText)
                                     .foregroundColor(AppColors.textGray)
                                
                                ForEach(defects, id: \.self) { defect in
                                    defectRow(text: defect)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: AppColors.textBlack.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Remarks Card
                    if let remarks = data.remarks, !remarks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Remarks")
                                .font(AppFonts.sectionHeader)
                                .foregroundColor(AppColors.textGray)
                            
                            Text(remarks)
                                .font(AppFonts.bodyText)
                                .foregroundColor(AppColors.textGray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: AppColors.textBlack.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    Spacer().frame(height: 20)
                }
            }
            
            // Hidden Navigation Link for Edit
            NavigationLink(destination: AddDvirView(dvirData: data), isActive: $showEditView) {
                EmptyView()
            }
            .hidden()
        }
        .background(AppColors.background)
        .navigationBarHidden(true)
        .onAppear {
            fetchDetail()
        }

    }
    
    // MARK: - Subviews & Helpers
    
    func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppFonts.bodyText)
                .foregroundColor(AppColors.textGray)
            Spacer()
            Text(value)
                .font(AppFonts.bodyText)
                .foregroundColor(AppColors.textBlack)
        }
    }
    
    func statusBadge(defects: Int) -> some View {
        Text(defects == 0 ? "No defect" : "Defects")
            .font(AppFonts.caption2)
            .foregroundColor(defects == 0 ? AppColors.textGray : AppColors.statusRed) // Or textWhite based on bg
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(defects == 0 ? AppColors.inputGray : AppColors.statusRed.opacity(0.1))
            .cornerRadius(12)
    }
    
    func defectRow(text: String) -> some View {
        HStack {
            Image(systemName: "xmark.circle")
                .foregroundColor(AppColors.statusRed)
                .font(AppFonts.bodyText)
            Text(text)
                .font(AppFonts.bodyText)
                .foregroundColor(AppColors.statusRed) // Or dark gray
            Spacer()
        }
        .padding(12)
        .background(AppColors.statusRed.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.statusRed.opacity(0.2), lineWidth: 1)
        )
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
    
     func formatDateTime(_ dateStr: String?) -> String {
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
            displayFormatter.dateFormat = "hh:mm a"
            let timeStr = displayFormatter.string(from: validDate)
            let abbr = getAbbreviation(displayFormatter.timeZone)
            return "\(timeStr) \(abbr)"
        }
        return dateStr
    }
    
    func fetchDetail() {
        guard let id = data.id else { return }
        
        APIManager.shared.request(url: ApiList.Divrs + id + "/", method: .get, parameters: nil) { comp in
        } success: { response in
             if let obj = Mapper<createDivr>().map(JSONObject: response), let refreshedData = obj.data {
                 self.data = refreshedData
             }
        } failure: { error in
            print("Fetch detail failed: \(String(describing: error))")
        }
    }
    
    func deleteDivr() {
        guard let id = data.id else { return }
        APIManager.shared.upload(url: ApiList.Divrs + id + "/", method: .delete, parameters: nil) { comp in
            
        } success: { response in
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        } failure: { error in
            print("Delete failed: \(String(describing: error))")
        }
    }
}
