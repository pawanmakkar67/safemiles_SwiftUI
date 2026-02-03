import SwiftUI
import PencilKit

struct AddDvirView: View {
    @StateObject private var viewModel: AddDvirViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Canvas for Binding
    @State private var canvasView = PKCanvasView()
    
    // Sheet States
    @State private var showVehicleDefects = false
    @State private var showTrailerDefects = false
    
    init(dvirData: DivrData? = nil) {
        _viewModel = StateObject(wrappedValue: AddDvirViewModel(dvirData: dvirData))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView {
                VStack(spacing: 20) {
                    inspectionDetailsSection
                    vehicleSection
                    trailerSection
                    signatureSection
                    submitButton
                }
                .padding()
            }
        }
        .background(AppColors.background)
        .navigationBarHidden(true)
        .onAppear {
             // Initial check if we need to load anything
        }
        .onChange(of: viewModel.vehicleDefects) { _ in viewModel.updateStatus() }
        .onChange(of: viewModel.trailerDefects) { _ in viewModel.updateStatus() }
        .onChange(of: viewModel.submitSuccess) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )) { item in
            Alert(title: Text("Alert"), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
        // Sheets
        .sheet(isPresented: $showVehicleDefects) {
            DefectSelectionView(
                title: "Vehicle Defects",
                allDefects: VEHICLE_DEFECTS.allCases.map { $0.rawValue },
                selectedDefects: $viewModel.vehicleDefects
            )
        }
        .sheet(isPresented: $showTrailerDefects) {
             DefectSelectionView(
                title: "Trailer Defects",
                allDefects: TRAILER_DEFECTS.allCases.map { $0.rawValue },
                selectedDefects: $viewModel.trailerDefects
            )
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        CommonHeader(
            title: viewModel.editingDvirId != nil ? "Edit DVIR" : "Add DVIR",
            leftIcon: "chevron.left",
            rightIcon: nil,
            onLeftTap: {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
    
    private var inspectionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Inspection Details")
                .font(AppFonts.sectionHeader)
                .foregroundColor(AppColors.textGray)
            
            // Time
            VStack(alignment: .leading, spacing: 5) {
                Text("Time (Date)")
                    .font(AppFonts.captionText)
                    .foregroundColor(AppColors.textGray)
                DatePicker("", selection: $viewModel.time, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(AppColors.inputGray)
                    .cornerRadius(8)
            }

            // Location
            customTextField(title: "Location", placeholder: "Enter location", text: $viewModel.location, icon: "location")
            
            // Odometer
            customTextField(title: "Odometer", placeholder: "Enter odometer", text: $viewModel.odometer, keyboardType: .numberPad)
            
            // Company
            customTextField(title: "Company", placeholder: "Enter company name", text: $viewModel.company, isDisabled: true)
            
            // Status
            statusPicker
            
            // Remarks
            VStack(alignment: .leading, spacing: 5) {
                Text("Remarks")
                    .font(AppFonts.captionText)
                    .foregroundColor(AppColors.textGray)
                TextEditor(text: $viewModel.remarks)
                    .frame(height: 80)
                    .padding(8)
                    .background(AppColors.inputGray)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: AppColors.textBlack.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var statusPicker: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Status")
                .font(AppFonts.captionText)
                .foregroundColor(AppColors.textGray)
            
            Menu {
                ForEach(viewModel.statusOptions, id: \.self) { option in
                    Button(option) {
                        viewModel.status = option
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.status)
                        .foregroundColor(AppColors.textBlack)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppColors.textGray)
                }
                .padding(12)
                .background(AppColors.inputGray)
                .cornerRadius(8)
            }
        }
    }
    
    private var vehicleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vehicle")
                .font(AppFonts.sectionHeader)
                .foregroundColor(AppColors.textGray)
            
            // Select Vehicle
            VStack(alignment: .leading, spacing: 5) {
                Text("Vehicle")
                    .font(AppFonts.captionText)
                    .foregroundColor(AppColors.textGray)
                
                Menu {
                    ForEach(Global.shared.vehicleList, id: \.id) { vehicle in
                        Button(vehicle.unit_number ?? "") {
                            viewModel.selectedVehicle = vehicle
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedVehicle?.unit_number ?? "Select Vehicle")
                            .foregroundColor(viewModel.selectedVehicle == nil ? AppColors.textGray : AppColors.textBlack)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(AppColors.textGray)
                    }
                    .padding(12)
                    .background(AppColors.inputGray)
                    .cornerRadius(8)
                }
            }
            
            // Vehicle Defects
            Button(action: { showVehicleDefects = true }) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Vehicle Defects")
                        .font(AppFonts.captionText)
                        .foregroundColor(AppColors.textGray)
                    
                    HStack {
                        Text(viewModel.vehicleDefects.isEmpty ? "Select defects..." : viewModel.vehicleDefects.joined(separator: ", "))
                            .lineLimit(1)
                            .foregroundColor(viewModel.vehicleDefects.isEmpty ? AppColors.textGray : AppColors.textBlack)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(AppColors.textGray)
                    }
                    .padding(12)
                    .background(AppColors.inputGray)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: AppColors.textBlack.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var trailerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trailer")
                .font(AppFonts.sectionHeader)
                .foregroundColor(AppColors.textGray)
            
            // Trailers Input
            customTextField(title: "Trailers", placeholder: "e.g. 1, t2", text: $viewModel.trailers)
            
            // Trailer Defects
            Button(action: { showTrailerDefects = true }) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Trailer Defects")
                        .font(AppFonts.captionText)
                        .foregroundColor(AppColors.textGray)
                    
                    HStack {
                        Text(viewModel.trailerDefects.isEmpty ? "Select defects..." : viewModel.trailerDefects.joined(separator: ", "))
                            .lineLimit(1)
                            .foregroundColor(viewModel.trailerDefects.isEmpty ? AppColors.textGray : AppColors.textBlack)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(AppColors.textGray)
                    }
                    .padding(12)
                    .background(AppColors.inputGray)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: AppColors.textBlack.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var signatureSection: some View {
        VStack(alignment: .leading, spacing: 16) {
             Text("Driver Signature")
                .font(AppFonts.sectionHeader)
                .foregroundColor(AppColors.textGray)
            
            SignatureView(canvasView: $canvasView) {
                // Signature updated
            }
            .frame(height: 150)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.textGray.opacity(0.3), lineWidth: 1)
            )
            
            Button("Clear Signature") {
                canvasView.drawing = PKDrawing()
            }
            .font(AppFonts.footnote)
            .foregroundColor(AppColors.textBlack)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: AppColors.textBlack.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var submitButton: some View {
        Button(action: {
            viewModel.signatureImage = canvasView.asImage()
            viewModel.submitDvir()
        }) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("Submit DVIR")
                    .font(AppFonts.buttonText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.buttonActive)
        .foregroundColor(.white)
        .cornerRadius(8)
        .padding(.bottom, 20)
    }
    
    // Helper View Builder
    func customTextField(title: String, placeholder: String, text: Binding<String>, icon: String? = nil, keyboardType: UIKeyboardType = .default, isDisabled: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(AppFonts.captionText)
                .foregroundColor(AppColors.textGray)
            
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppColors.textGray)
                }
                TextField(placeholder, text: text)
                    .font(AppFonts.textField)
                    .keyboardType(keyboardType)
                    .disabled(isDisabled)
                    .foregroundColor(isDisabled ? AppColors.textGray : AppColors.textBlack)
            }
            .padding(12)
            .background(AppColors.textFieldBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.textFieldBorder, lineWidth: 1)
            )
        }
    }
}

// Alert Helper - Keep as is
struct AlertItem: Identifiable {
    var id = UUID()
    var message: String
}

// Defect Selection View - Keep as is
struct DefectSelectionView: View {
    let title: String
    let allDefects: [String]
    @Binding var selectedDefects: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allDefects, id: \.self) { defect in
                    Button(action: {
                        toggleSelection(defect)
                    }) {
                        HStack {
                            Text(defect)
                                .foregroundColor(AppColors.textBlack)
                            Spacer()
                            if selectedDefects.contains(defect) {
                                Image(systemName: "checkmark")
                                .foregroundColor(AppColors.statusGreen)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func toggleSelection(_ defect: String) {
        if let index = selectedDefects.firstIndex(of: defect) {
            selectedDefects.remove(at: index)
        } else {
            selectedDefects.append(defect)
        }
    }
}
