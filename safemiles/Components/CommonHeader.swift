import SwiftUI

struct CommonHeader: View {
    let title: String
    var leftIcon: String? = "Menu"
    var rightIcon: String? = ""
    var rightIconColor: Color = .white
    var onLeftTap: (() -> Void)?
    var onRightTap: (() -> Void)?
    
    var body: some View {
        HStack {
            if let leftIcon = leftIcon {
                Button(action: {
                    onLeftTap?()
                }) {
                    Image(leftIcon)
                        .font(AppFonts.iconMedium)
                        .foregroundColor(AppColors.white)
                }
            } else {
                // Keep spacing balanced if needed, or remove
                Image("Menu")
                    .font(AppFonts.iconMedium)
                    .foregroundColor(AppColors.clear)
            }
            
            Spacer()
            
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.white)
            
            Spacer()
            
            if let rightIcon = rightIcon, !rightIcon.isEmpty {
                Button(action: {
                    onRightTap?()
                }) {
                    // Check if it's a system icon
                    if rightIcon == "plus" || rightIcon.contains("circle") || rightIcon.contains("chevron") || rightIcon.contains("arrow") {
                        Image(systemName: rightIcon)
                            .font(AppFonts.iconMedium)
                            .foregroundColor(rightIconColor)
                    } else {
                        Image(rightIcon)
                            .renderingMode(.template)
                            .font(AppFonts.iconMedium)
                            .foregroundColor(rightIconColor)
                    }
                }
            } else {
//                 Image("Menu")
//                     .font(AppFonts.iconMedium)
//                     .foregroundColor(AppColors.clear)
            }
        }
        .padding()
        .background(AppColors.black)
    }
}
