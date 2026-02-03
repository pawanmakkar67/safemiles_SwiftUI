//
//  FontConstants.swift
//  safemiles
//
//  Created by pc on 29/01/26.
//

import SwiftUI

struct AppFonts {
    static var scale: CGFloat { FontManager.shared.currentScaleFactor }
    
    static var loginTitle: Font { .system(size: 36 * scale, weight: .bold) }
    static var loginSubtitle: Font { .system(size: 16 * scale) }
    static var textField: Font { .system(size: 14 * scale) }
    static var iconSmall: Font { .system(size: 20 * scale) }
    static var iconMedium: Font { .system(size: 22 * scale) }
    static var buttonText: Font { .system(size: 18 * scale, weight: .bold) }
    static var footnote: Font { .system(size: 14 * scale, weight: .medium) }
    static var statusButtons: Font { .system(size: 15 * scale, weight: .bold) }
    static var timerText: Font { .system(size: 30 * scale, weight: .bold) }
    
    // New Additions
    static var buttonTitle: Font { .system(size: 16 * scale, weight: .semibold) }
    static var cardTitle: Font { .system(size: 16 * scale, weight: .bold) }
    static var cardSubtitle: Font { .system(size: 14 * scale, weight: .regular) }
    static var bodyText: Font { .system(size: 14 * scale, weight: .regular) }
    static var sectionHeader: Font { .system(size: 14 * scale, weight: .semibold) }
    static var captionText: Font { .system(size: 12 * scale, weight: .regular) }
    
    // Semantic Aliases / Standard UI Replacements
    static var headline: Font { .system(size: 17 * scale, weight: .semibold) }
    static var subheadline: Font { .system(size: 15 * scale, weight: .regular) }
    static var title: Font { .system(size: 28 * scale, weight: .bold) }
    static var title2: Font { .system(size: 22 * scale, weight: .bold) }
    static var title3: Font { .system(size: 20 * scale, weight: .semibold) }
    static var callout: Font { .system(size: 16 * scale, weight: .regular) }
    static var caption: Font { captionText }
    static var caption2: Font { .system(size: 11 * scale, weight: .regular) }
}
