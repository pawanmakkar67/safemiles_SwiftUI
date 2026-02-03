import SwiftUI

struct StatusCard: View {
    let title: String
    let icon: String
    let status: String
    let isActive: Bool
    let statusCode: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(title)
                    .font(AppFonts.statusButtons)
                    .foregroundColor(AppColors.textBlack)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Image(systemName: icon)
                    .font(AppFonts.iconSmall)
                    .foregroundColor(AppColors.textBlack)
                    .padding(8)
                    .background(AppColors.iconBackgroundLight) // Light blue bg for icon
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Spacer()
            
            Text(status)
                .font(AppFonts.statusButtons)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isActive ? AppColors.cardBackgroundActive : AppColors.white)
                .foregroundColor(isActive ? AppColors.textBlack : .gray)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isActive ? AppColors.clear : AppColors.textGray, lineWidth: 1)
                )
        }
        .padding(16)
        .frame(width: 140, height: 130)
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: AppColors.blackOpacity10, radius: 5, x: 0, y: 2)
    }
}
