import SwiftUI

struct FormsView: View {
    @ObservedObject var viewModel: LogsViewModel
    
    // Form State
    @State private var vehicleId: String = ""
    @State private var vehicleNumber: String = ""
    @State private var coDriverId: String = ""
    @State private var coDriverName: String = ""
    @State private var trailers: [String] = []
    @State private var shippingDocs: [String] = []
    
    @State private var showVehiclePicker = false
    @State private var showCoDriverPicker = false
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var isCertified: Bool {
        return viewModel.currentLog?.log?.certified != false
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // DRIVER (Read Only)
                FormCard(
                    title: "DRIVER",
                    value: getDriverName(),
                    isReadOnly: true
                )
                
                // VEHICLES
                FormCard(
                    title: "VEHICLES",
                    value: vehicleNumber.isEmpty ? "Select Vehicle" : vehicleNumber,
                    isReadOnly: isCertified,
                    onEdit: {
                        showVehiclePicker = true
                    }
                )
                .sheet(isPresented: $showVehiclePicker) {
                    SelectionPicker(
                        title: "Select Vehicle",
                        items: Global.shared.vehicleList,
                        currentItemId: vehicleId
                    ) { selected in
                        vehicleId = selected.id ?? ""
                        vehicleNumber = selected.unit_number ?? ""
                    }
                }
                
                // TRAILERS
                DynamicListField(
                    title: "TRAILERS",
                    placeholder: "e.g. T123",
                    items: $trailers,
                    isReadOnly: isCertified
                )
                .padding(.horizontal, -16) // Compensate for outer padding
                
                // SHIPPING DOCUMENTS
                DynamicListField(
                    title: "SHIPPING DOCUMENTS",
                    placeholder: "e.g. BOL-12345",
                    items: $shippingDocs,
                    isReadOnly: isCertified
                )
                .padding(.horizontal, -16) // Compensate for outer padding
                
                
                // CO-DRIVER
                FormCard(
                    title: "CO-DRIVER",
                    value: coDriverName.isEmpty ? "None" : coDriverName,
                    isReadOnly: isCertified,
                    onEdit: {
                        showCoDriverPicker = true
                    }
                )
                .sheet(isPresented: $showCoDriverPicker) {
                    CoDriverPicker(
                        title: "Select Co-Driver",
                        items: Global.shared.coDriverList ?? [],
                        currentItemId: coDriverId
                    ) { selected in
                        coDriverId = selected.id ?? ""
                        let first = selected.user?.first_name ?? ""
                        let last = selected.user?.last_name ?? ""
                        coDriverName = "\(first) \(last)"
                    }
                }
                
                if !isCertified {
                    Button(action: saveForm) {
                        Text("Save")
                            .font(AppFonts.buttonText)
                            .foregroundColor(AppColors.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.buttonActive)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                }
                
            }
            .padding()
        }
        .background(AppColors.background)
        .onAppear {
            loadInitialData()
        }
        .onChange(of: viewModel.currentLog?.log?.id) { _ in
            loadInitialData()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func loadInitialData() {
        guard let log = viewModel.currentLog else { return }
        
//        vehicleId = log.vehicle?.id ?? ""
//        vehicleNumber = log.vehicle?.unit_number ?? ""
//        
        // CoDriver logic might need explicit co_driver field from log if available, 
        // currently assuming it's not directly in Logs struct but might be saved?
        // Checking Logs struct... it has no explicit co_driver field in basic struct but save params use it.
        // Assuming implementation might need to fetch or use what's available. 
        // For now, initializing empty or if we had it.
        // The reference shows 'selectedCoDriver' is internal state.
        
//        trailers = log.log?.trailers?.joined(separator: ", ") ?? ""
//        shippingDocs = log.log?.shipping_docs?.joined(separator: ", ") ?? ""
    }
    
    func saveForm() {
        viewModel.saveForm(
            vehicleId: vehicleId,
            coDriverId: coDriverId,
            trailers: trailers,
            shippingDocs: shippingDocs
        ) { success, message in
            alertMessage = message
            showAlert = true
        }
    }
    
    func getDriverName() -> String {
        guard let user = Global.shared.myProfile?.user else { return "Unknown" }
                let first = user.first_name ?? ""
                let last = user.last_name ?? ""
                let name = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
                return name.isEmpty ? (user.username ?? "Unknown") : name
    }
}

// MARK: - Helper Views

struct FormCard: View {
    let title: String
    let value: String
    var isReadOnly: Bool = false
    var onEdit: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.captionText)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textBlack)
            
            HStack {
                Text(value)
                    .font(AppFonts.bodyText)
                    .foregroundColor(AppColors.textGray)
                
                Spacer()
                
                if !isReadOnly {
                    Button(action: { onEdit?() }) {
                        Image(systemName: "pencil")
                            .foregroundColor(AppColors.buttonActive)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: AppColors.blackOpacity05 ?? Color.black.opacity(0.05), radius: 2, x: 0, y: 1) // Safe fallback if not defined
        .onTapGesture {
            if !isReadOnly {
                onEdit?()
            }
        }
    }
}

struct EditableFormCard: View {
    let title: String
    @Binding var text: String
    var isReadOnly: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.captionText)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textBlack)
            
            HStack {
                if isReadOnly {
                    Text(text.isEmpty ? "None" : text)
                        .font(AppFonts.bodyText)
                        .foregroundColor(AppColors.textGray)
                    Spacer()
                } else {
                    TextField("None", text: $text)
                        .font(AppFonts.textField)
                        .foregroundColor(AppColors.textBlack)
                    
                    Image(systemName: "pencil")
                        .foregroundColor(AppColors.buttonActive)
                }
            }
        }
        .padding()
        .background(AppColors.textFieldBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.textFieldBorder, lineWidth: 1)
        )
    }
}

// Simple Picker Wrapper
struct SelectionPicker: View {
    let title: String
    let items: [VehicleData]
    let currentItemId: String
    let onSelect: (VehicleData) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(items, id: \.id) { item in
                Button(action: {
                    onSelect(item)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(item.unit_number ?? "Unknown")
                            .foregroundColor(AppColors.textBlack)
                        Spacer()
                        if item.id == currentItemId {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.buttonActive)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarItems(trailing: Button("Close") { presentationMode.wrappedValue.dismiss() })
        }
    }
}

struct CoDriverPicker: View {
    let title: String
    let items: [CoDriverData]
    let currentItemId: String
    let onSelect: (CoDriverData) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(items, id: \.id) { item in
                Button(action: {
                    onSelect(item)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        let name = "\(item.user?.first_name ?? "") \(item.user?.last_name ?? "")"
                        Text(name)
                            .foregroundColor(AppColors.textBlack)
                        Spacer()
                        if item.id == currentItemId {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.buttonActive)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarItems(trailing: Button("Close") { presentationMode.wrappedValue.dismiss() })
        }
    }
}

// MARK: - Dynamic List Field Component
struct DynamicListField: View {
    let title: String
    let placeholder: String
    @Binding var items: [String]
    var isReadOnly: Bool = false
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFonts.captionText)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textBlack)
            
            if !isReadOnly {
                // Input Row with ADD button
                HStack(spacing: 8) {
                    TextField(placeholder, text: $inputText)
                        .font(AppFonts.bodyText)
                        .padding(12)
                        .background(AppColors.inputGray)
                        .cornerRadius(8)
                    
                    Button(action: addItem) {
                        Text("ADD")
                            .font(AppFonts.buttonTitle)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.0, green: 0.7, blue: 0.7))
                            .cornerRadius(8)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                }
            }
            
            // List of added items
            if !items.isEmpty {
                VStack(spacing: 8) {
                    ForEach(items.indices, id: \.self) { index in
                        HStack {
                            Text(items[index])
                                .font(AppFonts.bodyText)
                                .foregroundColor(AppColors.textBlack)
                            
                            Spacer()
                            
                            if !isReadOnly {
                                Button(action: {
                                    deleteItem(at: index)
                                }) {
                                    Text("Delete")
                                        .font(AppFonts.buttonTitle)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(AppColors.statusRed)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(12)
                        .background(AppColors.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.grayOpacity20, lineWidth: 1)
                        )
                    }
                }
            } else if isReadOnly {
                Text("None")
                    .font(AppFonts.bodyText)
                    .foregroundColor(AppColors.textGray)
                    .padding(12)
            }
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: AppColors.blackOpacity05 ?? Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func addItem() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        items.append(trimmed)
        inputText = ""
    }
    
    private func deleteItem(at: Int) {
        items.remove(at: at)
    }
}
