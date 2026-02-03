import SwiftUI

struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var icon: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var isError: Bool = false
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Leading Icon
            Image(systemName: icon)
                .font(AppFonts.textField)
                .foregroundStyle(isError ? AppColors.statusRed : AppColors.iconBlack)
            
            // Text Field
            Group {
                if isSecure && !isPasswordVisible {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .font(AppFonts.textField)
            .textContentType(isSecure ? .password : .none)
            .textInputAutocapitalization(.never)
            .keyboardType(keyboardType)
            .foregroundStyle(AppColors.textBlack)
            
            // Trailing Actions (Eye or Alert)
            if isError {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(AppFonts.iconSmall)
                    .foregroundStyle(AppColors.statusRed)
            } else if isSecure {
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .font(AppFonts.iconSmall)
                        .foregroundStyle(AppColors.iconGray)
                }
            }
        }
        .padding()
        .frame(height: 56)
        .background(AppColors.textFieldBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isError ? AppColors.statusRed : AppColors.textFieldBorder, lineWidth: 1)
        )
    }
}
