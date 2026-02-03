import SwiftUI

struct RecapSummaryRow: View {
    let title: String
    let middleText: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textBlack) // Grayish title
                .frame(width: 140, alignment: .leading) // Fixed width for alignment like in screenshot
            
            Spacer()
            
            Text(middleText)
                .font(.subheadline)
                .foregroundColor(AppColors.textGray)
            
            Spacer()
            
            Text(value)
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
