import SwiftUI

struct CommonHeader: View {
    let title: String
    var leftIcon: String? = "Menu"
    var rightIcon: String? = ""
    var rightIconColor: Color = .white
    var onLeftTap: (() -> Void)?
    var onRightTap: (() -> Void)?
    
    private var safeAreaTop: CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        return keyWindow?.safeAreaInsets.top ?? 0
    }
    
    var body: some View {
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
                Image("Menu")
                    .font(AppFonts.iconMedium)
                    .foregroundColor(AppColors.clear)
                    .padding(8)
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
            }
        }
        .padding(.horizontal)
        .padding(.top, safeAreaTop)
        .padding(.bottom, 12)
        .background(AppColors.ThemeBlack)
        .ignoresSafeArea(.all, edges: .top)
    }
}
