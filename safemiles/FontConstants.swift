//
//  FontConstants.swift
//  safemiles
//
//  Created by pc on 29/01/26.
//

import SwiftUI

struct AppFonts {
    static var scale: CGFloat { FontManager.shared.currentScaleFactor }
    
    // Helper function to create custom fonts with scaling
    private static func arimoFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold:
            fontName = "Arimo-Bold"
        case .semibold:
            fontName = "Arimo-SemiBold"
        case .medium:
            fontName = "Arimo-Medium"
        default:
            fontName = "Arimo-Regular"
        }
        return .custom(fontName, size: size * scale)
    }
    
    static var loginTitle: Font { arimoFont(size: 36, weight: .bold) }
    static var loginSubtitle: Font { arimoFont(size: 16) }
    static var textField: Font { arimoFont(size: 14) }
    static var iconSmall: Font { arimoFont(size: 20) }
    static var iconMedium: Font { arimoFont(size: 22) }
    static var iconLarge: Font { arimoFont(size: 60, weight: .bold) }
    static var buttonText: Font { arimoFont(size: 18, weight: .bold) }
    static var footnote: Font { arimoFont(size: 14, weight: .medium) }
    static var statusButtons: Font { arimoFont(size: 15, weight: .bold) }
    static var timerText: Font { arimoFont(size: 30, weight: .bold) }
    
    // New Additions
    static var buttonTitle: Font { arimoFont(size: 16, weight: .semibold) }
    static var cardTitle: Font { arimoFont(size: 16, weight: .bold) }
    static var cardSubtitle: Font { arimoFont(size: 14) }
    static var bodyText: Font { arimoFont(size: 14) }
    static var sectionHeader: Font { arimoFont(size: 14, weight: .semibold) }
    static var captionText: Font { arimoFont(size: 12) }
    
    // Semantic Aliases / Standard UI Replacements
    static var headline: Font { arimoFont(size: 17, weight: .semibold) }
    static var subheadline: Font { arimoFont(size: 15) }
    static var title: Font { arimoFont(size: 28, weight: .bold) }
    static var title2: Font { arimoFont(size: 22, weight: .bold) }
    static var title3: Font { arimoFont(size: 20, weight: .semibold) }
    static var callout: Font { arimoFont(size: 16) }
    static var caption: Font { captionText }
    static var caption2: Font { arimoFont(size: 11) }
}
