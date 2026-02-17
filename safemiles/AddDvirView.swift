import SwiftUI
import PencilKit

struct AddDvirView: View {
    @StateObject private var viewModel: AddDvirViewModel
    @Environment(\.presentationMode) var presentationMode
    var onDismiss: (() -> Void)? = nil
    
    // Canvas for Binding
    @State private var canvasView = PKCanvasView()
    
    // Sheet States
    @State private var showVehicleDefects = false
    @State private var showTrailerDefects = false
    
    init(dvirData: DivrData? = nil, onDismiss: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: AddDvirViewModel(dvirData: dvirData))
        self.onDismiss = onDismiss
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
             print("DEBUG: AddDvirView - onAppear")
        }
        .onDisappear {
             print("DEBUG: AddDvirView - onDisappear")
        }

        .onChange(of: viewModel.submitSuccess) { success in
            if success {
                if let onDismiss = onDismiss {
                    onDismiss()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )) { item in
            Alert(title: Text("Alert"), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
        // Sheets
        .sheet(isPresented: $showVehicleDefects, onDismiss: { viewModel.updateStatus() }) {
            DefectSelectionView(
                title: "Vehicle Defects",
                allDefects: VEHICLE_DEFECTS.allCases.map { $0.rawValue },
                selectedDefects: $viewModel.vehicleDefects
            )
        }
        .sheet(isPresented: $showTrailerDefects, onDismiss: { viewModel.updateStatus() }) {
             DefectSelectionView(
                title: "Trailer Defects",
                allDefects: TRAILER_DEFECTS.allCases.map { $0.rawValue },
                selectedDefects: $viewModel.trailerDefects
            )
        }
        .onChange(of: showVehicleDefects) { isShowing in
            print("DEBUG: AddDvirView - showVehicleDefects changed to: \(isShowing)")
        }
        .onChange(of: showTrailerDefects) { isShowing in
            print("DEBUG: AddDvirView - showTrailerDefects changed to: \(isShowing)")
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        CommonHeader(
            title: viewModel.editingDvirId != nil ? "Edit DVIR" : "Add DVIR",
            leftIcon: "left",
            onLeftTap: {
                if let onDismiss = onDismiss {
                    onDismiss()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
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
                    .environment(\.timeZone, getAppTimeZone())
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
            
            // Trailers Input (simple text field)
            VStack(alignment: .leading, spacing: 8) {
                Text("Trailers")
                    .font(AppFonts.captionText)
                    .foregroundColor(AppColors.textGray)
                
                TextField("e.g. T123, T456", text: Binding(
                    get: { viewModel.trailers.joined(separator: ", ") },
                    set: { newValue in
                        viewModel.trailers = newValue.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                    }
                ))
                .font(AppFonts.bodyText)
                .padding(12)
                .background(AppColors.inputGray)
                .cornerRadius(8)
            }
            
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
    
    @State private var workingSelection: [String] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Spacer()
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textBlack)
                Spacer()
                Button("Done") {
                    selectedDefects = workingSelection
                    presentationMode.wrappedValue.dismiss()
                }
                .font(AppFonts.buttonText)
                .foregroundColor(AppColors.textBlack) // Or primary color
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.gray.opacity(0.2), radius: 2, x: 0, y: 2)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(allDefects, id: \.self) { defect in
                        Button(action: {
                            toggleSelection(defect)
                        }) {
                            HStack {
                                Text(defect)
                                    .foregroundColor(AppColors.textBlack)
                                    .padding(.vertical, 12) // Add padding for touch target
                                Spacer()
                                if workingSelection.contains(defect) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.statusGreen)
                                }
                            }
                            .padding(.horizontal)
                            .contentShape(Rectangle()) // Ensure entire row is tappable
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.leading) 
                    }
                }
            }
        }
        .onAppear {
            print("DEBUG: DefectSelectionView - onAppear")
            workingSelection = selectedDefects
        }
        .onDisappear {
            print("DEBUG: DefectSelectionView - onDisappear")
        }
    }
    
    func toggleSelection(_ defect: String) {
        if let index = workingSelection.firstIndex(of: defect) {
            workingSelection.remove(at: index)
        } else {
            workingSelection.append(defect)
        }
    }
}
