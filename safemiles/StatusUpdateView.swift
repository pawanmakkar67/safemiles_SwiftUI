import SwiftUI

struct StatusUpdateView: View {
    @StateObject var viewModel: StatusUpdateViewModel
    @Binding var isPresented: Bool
    
    // Initializer to inject dependencies
    init(selectedCode: String, isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: StatusUpdateViewModel(selectedCode: selectedCode))
        _isPresented = isPresented
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Dimmed Background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            // Modal Content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(getTitles(viewModel.selectedCode))
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textBlack)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textBlack)
                            .font(AppFonts.iconSmall)
                    }
                }
                .padding()
                .padding(.top,20)
                
                // Progress/Limit (Placeholder based on screenshot "5/11 Hours")
                // Assuming this is static or derived. For now hardcoding or leaving as placeholder UI
                // The screenshot shows "5/11 Hours" under the title.
                HStack {
                    Text("") // This needs to be dynamic based on rules if required, but user didn't specify.
                        .font(AppFonts.footnote)
                        .foregroundColor(AppColors.textGray)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Location Row
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(AppColors.blue) // Assuming blue for location pin
                        .font(AppFonts.iconSmall)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Location", text: $viewModel.locationText)
                            .font(AppFonts.textField)
                            .foregroundColor(AppColors.textBlack)
                            .disabled(true)
                        
                        Divider()
                    }
                    

                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Notes Field
                VStack {
                    TextField("Notes", text: $viewModel.notesText)
                        .font(AppFonts.textField)
                        .padding()
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColors.textGray.opacity(0.5), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                
                // Update Button
                Button(action: {
                    viewModel.updateStatus(onSuccess: {
                        withAnimation {
                            isPresented = false
                        }
                    })
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.buttonActive)
                            .cornerRadius(10)
                    } else {
                        Text("Update")
                            .font(AppFonts.buttonTitle)
                            .foregroundColor(AppColors.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.buttonActive)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
                
            }
            .background(AppColors.white)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .shadow(radius: 10)
            .transition(.move(edge: .bottom))
        }
        .textInputAutocapitalization(.never) // Optional polish
        .edgesIgnoringSafeArea(.bottom) // Ensure it goes to the edge
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Alert"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func getTitles(_ code: String) -> String {
        switch code.lowercased() {
        case "off": return "OFF DUTY"
        case "sb": return "Sleeper Berth"
        case "d": return "DRIVING"
        case "on": return "ON DUTY"
        case "ym": return "YARD MOVE"
        case "pu": return "PERSONAL USE"
        default: return code.uppercased()
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
