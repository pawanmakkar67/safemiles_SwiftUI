import SwiftUI

struct RecapRow: View {
    let day: String
    let date: String
    let hours: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(day)
                    .font(.headline)
                    .foregroundColor(AppColors.textBlack)
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textGray)
            }
            Spacer()
            Text(hours)
                .font(.title3)
                .foregroundColor(AppColors.textBlack)
        }
        .padding()
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
}
