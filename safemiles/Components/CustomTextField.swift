import SwiftUI

struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var icon: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var isError: Bool = false
    var useGlassStyle: Bool = false
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Leading Icon
            Image(systemName: icon)
                .font(AppFonts.iconSmall)
                .foregroundStyle(isError ? AppColors.statusRed : (useGlassStyle ? AppColors.white : AppColors.iconBlack))
                .frame(width: 20, height: 20)
            
            // Text Field
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(title)
                        .font(AppFonts.textField)
                        .foregroundStyle(useGlassStyle ? AppColors.white.opacity(0.6) : AppColors.textGray)
                }
                
                Group {
                    if isSecure && !isPasswordVisible {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                    }
                }
                .font(AppFonts.textField)
                .textContentType(isSecure ? .password : .none)
                .textInputAutocapitalization(.never)
                .keyboardType(keyboardType)
                .foregroundStyle(useGlassStyle ? AppColors.white : AppColors.textBlack)
                .accentColor(useGlassStyle ? AppColors.white : AppColors.blue)
            }
            
            // Trailing Actions (Eye or Alert)
            if isError {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(AppFonts.iconSmall)
                    .foregroundStyle(AppColors.statusRed)
                    .frame(width: 20, height: 20)
            } else if isSecure {
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .font(AppFonts.iconSmall)
                        .foregroundStyle(useGlassStyle ? AppColors.white.opacity(0.6) : AppColors.iconGray)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.horizontal)
        .frame(height: 55)
        .background(
            ZStack {
                if useGlassStyle {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial.opacity(0.8))
                        .colorScheme(.dark)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isError ? AppColors.statusRed : .clear, lineWidth: 1)
                        )
                } else {
                    AppColors.textFieldBackground
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
