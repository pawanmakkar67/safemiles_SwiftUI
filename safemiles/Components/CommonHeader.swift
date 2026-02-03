import SwiftUI

struct CommonHeader: View {
    let title: String
    var leftIcon: String? = "line.3.horizontal"
    var rightIcon: String? = "antenna.radiowaves.left.and.right"
    var rightIconColor: Color = .white
    var onLeftTap: (() -> Void)?
    var onRightTap: (() -> Void)?
    
    var body: some View {
        HStack {
            if let leftIcon = leftIcon {
                Button(action: {
                    onLeftTap?()
                }) {
                    Image(systemName: leftIcon)
                        .font(AppFonts.iconMedium)
                        .foregroundColor(AppColors.white)
                }
            } else {
                // Keep spacing balanced if needed, or remove
                Image(systemName: "line.3.horizontal")
                    .font(AppFonts.iconMedium)
                    .foregroundColor(AppColors.clear)
            }
            
            Spacer()
            
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.white)
            
            Spacer()
            
            if let rightIcon = rightIcon {
                Button(action: {
                    onRightTap?()
                }) {
                    Image(systemName: rightIcon) // Use appropriate bluetooth icon
                        .font(AppFonts.iconMedium)
                        .foregroundColor(rightIconColor)
                }
            } else {
                 Image(systemName: "line.3.horizontal")
                     .font(AppFonts.iconMedium)
                     .foregroundColor(AppColors.clear)
            }
        }
        .padding()
        .background(AppColors.black)
    }
}
