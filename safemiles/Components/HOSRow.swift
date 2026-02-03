import SwiftUI

struct HOSRow: View {
    let title: String
    let subtitle: String
    let value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textBlack)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textGray)
            }
            Spacer()
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textBlack)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        Divider()
    }
}
