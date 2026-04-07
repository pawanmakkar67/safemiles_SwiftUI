import SwiftUI

struct CommonHeader: View {
    var title: String
    var leftIcon: String? = "Menu"
    var rightIcon: String? = ""
    var rightIconColor: Color = .white
    var onLeftTap: (() -> Void)?
    var onRightTap: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Title (Centered in the screen width)
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.white)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            // Icons (HStack for positioning)
            HStack {
                if let leftIcon = leftIcon {
                    Button(action: {
                        onLeftTap?()
                    }) {
                        Image(leftIcon)
                            .font(AppFonts.iconMedium)
                            .foregroundColor(AppColors.white)
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                } else {
                    // Placeholder to maintain balance if needed, but ZStack handles it.
                    Color.clear.frame(width: 44, height: 44)
                }
                
                Spacer()
                
                if let rightIcon = rightIcon, !rightIcon.isEmpty {
                    Button(action: {
                        onRightTap?()
                    }) {
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
                    .padding(8)
                    .contentShape(Rectangle())
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            AppColors.ThemeBlack
                .ignoresSafeArea(.all, edges: .top)
        )
    }
}
