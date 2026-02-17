import SwiftUI

struct AddEditLogView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel: AddEditLogViewModel
    @State private var showVehiclePicker = false
    
    init(isPresented: Binding<Bool>, event: Events? = nil, log: Logs? = nil) {
        _isPresented = isPresented
        _viewModel = StateObject(wrappedValue: AddEditLogViewModel(event: event, log: log))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.textBlack)
                            .font(.system(size: 20))
                    }
                    
                    Spacer()
                    
                    Text(viewModel.isEditMode ? "Edit Log" : "Add Log")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textBlack)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textGray)
                            .font(.system(size: 24))
                    }
                }
                .padding()
                .background(AppColors.white)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Company (Read-only)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Company")
                                .font(AppFonts.captionText)
                                .foregroundColor(AppColors.textGray)
                            
                            Text(viewModel.company)
                                .font(AppFonts.bodyText)
                                .foregroundColor(AppColors.textBlack)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(AppColors.inputGray)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        // Date/Time Picker
                        VStack(alignment: .leading, spacing: 8) {
                            DatePicker("", selection: $viewModel.selectedTime, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .environment(\.timeZone, getAppTimeZone())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(AppColors.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.textGray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        // Status Selection
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.statusOptions, id: \.self) { status in
                                Button(action: {
                                    viewModel.selectedStatus = status
                                }) {
                                    HStack {
                                        Image(systemName: viewModel.selectedStatus == status ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(viewModel.selectedStatus == status ? AppColors.textBlack : AppColors.textGray)
                                        
                                        Text(status)
                                            .font(AppFonts.bodyText)
                                            .foregroundColor(AppColors.textBlack)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Vehicle Dropdown
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vehicle")
                                .font(AppFonts.captionText)
                                .foregroundColor(AppColors.textGray)
                            
                            Button(action: {
                                if !viewModel.isEditMode {
                                    showVehiclePicker = true
                                }
                            }) {
                                HStack {
                                    Text(viewModel.selectedVehicle?.unit_number ?? "Select Vehicle")
                                        .font(AppFonts.bodyText)
                                        .foregroundColor(viewModel.selectedVehicle == nil ? AppColors.textGray : AppColors.textBlack)
                                    
                                    Spacer()
                                    
                                    if !viewModel.isEditMode {
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppColors.textGray)
                                    }
                                }
                                .padding()
                                .background(viewModel.isEditMode ? AppColors.inputGray : AppColors.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.textGray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .disabled(viewModel.isEditMode)
                        }
                        .padding(.horizontal)
                        
                        // Location Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location")
                                .font(AppFonts.captionText)
                                .foregroundColor(AppColors.textGray)
                            
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(AppColors.blue)
                                
                                TextField("Location", text: $viewModel.location)
                                    .font(AppFonts.bodyText)
                                    .foregroundColor(AppColors.textBlack)
                                
                                Spacer()
                            }
                            .padding()
                            .background(AppColors.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.textGray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Notes Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(AppFonts.captionText)
                                .foregroundColor(AppColors.textGray)
                            
                            TextField("Notes", text: $viewModel.notes)
                                .font(AppFonts.bodyText)
                                .foregroundColor(AppColors.textBlack)
                                .padding()
                                .background(AppColors.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.textGray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Update Button
                        Button(action: {
                            viewModel.saveLog {
                                isPresented = false
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(AppColors.textBlack)
                                    .cornerRadius(8)
                            } else {
                                Text("Update")
                                    .font(AppFonts.buttonTitle)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(AppColors.textBlack)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 20)
                }
                .background(AppColors.background)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showVehiclePicker) {
                VehiclePickerView(
                    selectedVehicle: $viewModel.selectedVehicle,
                    isPresented: $showVehiclePicker
                )
            }
        }
    }
}

// MARK: - Vehicle Picker View
struct VehiclePickerView: View {
    @Binding var selectedVehicle: VehicleData?
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(Global.shared.vehicleList, id: \.id) { vehicle in
                Button(action: {
                    selectedVehicle = vehicle
                    isPresented = false
                }) {
                    HStack {
                        Text(vehicle.unit_number ?? "Unknown")
                            .foregroundColor(AppColors.textBlack)
                        Spacer()
                        if vehicle.id == selectedVehicle?.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.buttonActive)
                        }
                    }
                }
            }
            .navigationTitle("Select Vehicle")
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
}
