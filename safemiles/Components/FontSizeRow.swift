
import SwiftUI

struct FontSizeRow: View {
    @ObservedObject var fontManager = FontManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Font Size")
                    .font(AppFonts.bodyText)
                    .foregroundColor(AppColors.textGray)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        fontManager.decreaseFontSize()
                    }) {
                        Image(systemName: "textformat.size.smaller")
                            .font(AppFonts.iconMedium)
                            .foregroundColor(fontManager.scaleIndex > -4 ? AppColors.textBlack : AppColors.grayOpacity20)
                    }
                    .disabled(fontManager.scaleIndex <= -4)
                    
                    Text("Standard") // Dynamic label based on index? Or just bars
                        .font(AppFonts.bodyText)
                        .foregroundColor(AppColors.textBlack)
                        .opacity(0.0) // Hidden for spacing or maybe use bars
                        .overlay(
                            HStack(spacing: 4) {
                                ForEach(-2...2, id: \.self) { index in
                                    Circle()
                                        .fill(index == (fontManager.scaleIndex/2) ? AppColors.buttonActive : AppColors.grayOpacity20)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        )
                    
                    Button(action: {
                        fontManager.increaseFontSize()
                    }) {
                        Image(systemName: "textformat.size.larger")
                            .font(AppFonts.iconMedium)
                            .foregroundColor(fontManager.scaleIndex < 4 ? AppColors.textBlack : AppColors.grayOpacity20)
                    }
                    .disabled(fontManager.scaleIndex >= 4)
                }
            }
            .padding()
            .background(AppColors.white)
            
            Divider()
                .padding(.leading, 20)
        }
    }
}
