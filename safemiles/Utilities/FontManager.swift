
import SwiftUI
import Combine

class FontManager: ObservableObject {
    static let shared = FontManager()
    
    // Scale levels: -3 to +3 (Total 7 levels)
    // -3: 0.85 (-15%)
    // -2: 0.90 (-10%)
    // -1: 0.95 (-5%)
    //  0: 1.00 (Standard)
    // +1: 1.05 (+5%)
    // +2: 1.10 (+10%)
    // +3: 1.15 (+15%)
    
    @Published var scaleIndex: Int {
        didSet {
            UserDefaults.standard.set(scaleIndex, forKey: "user_font_scale_index")
        }
    }
    
    var currentScaleFactor: CGFloat {
        let base: CGFloat = 1.0
        let step: CGFloat = 0.05
        return base + (CGFloat(scaleIndex) * step)
    }
    
    private init() {
        self.scaleIndex = UserDefaults.standard.integer(forKey: "user_font_scale_index")
        // Default integer is 0, which is perfect for our center index
    }
    
    func increaseFontSize() {
        if scaleIndex < 4 {
            scaleIndex += 2
        }
    }
    
    func decreaseFontSize() {
        if scaleIndex > -4 {
            scaleIndex -= 2
        }
    }
}
