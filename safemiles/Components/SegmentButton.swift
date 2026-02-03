import SwiftUI

struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(isSelected ? AppColors.textBlack : .gray)
                    .padding(.vertical, 12)
                
                Rectangle()
                    .fill(isSelected ? AppColors.textBlack : .clear)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
