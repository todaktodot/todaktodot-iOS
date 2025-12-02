//
//  Color +.swift
//  todaktodot
//
//  Created by markany on 11/26/25.
//

import UIKit
import SwiftUI

// MARK: - Color Extensions
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
    
    static let grayScale900 = TodotColors.Grayscale.grayScale900
    static let grayScale800 = TodotColors.Grayscale.grayScale800
    static let grayScale700 = TodotColors.Grayscale.grayScale700
    static let grayScale600 = TodotColors.Grayscale.grayScale600
    static let grayScale500 = TodotColors.Grayscale.grayScale500
    static let grayScale400 = TodotColors.Grayscale.grayScale400
    static let grayScale300 = TodotColors.Grayscale.grayScale300
    static let grayScale200 = TodotColors.Grayscale.grayScale200
    static let grayScale100 = TodotColors.Grayscale.grayScale100
    static let grayScale50 = TodotColors.Grayscale.grayScale50
    
    static let cardPurple = UIColor(hex: "E0D3F1")
    static let lightCardPurple = UIColor(hex: "F5F2F8")
}

// MARK: - Todot Design System
struct TodotColors {
    
    // MARK: - Brand Colors
    struct Brand {
        static let mainPurple = UIColor(hex: "6C5CE7")      // Main Purple
        static let subPurple = UIColor(hex: "A29BFE")       // Sub Purple
        static let darkPurple = UIColor(hex: "5A4FCF")      // Dark Purple
        static let lightPurple = UIColor(hex: "DDD6FE")     // Light Purple
    }
    
    // MARK: - Grayscale
    struct Grayscale {
        static let grayScale900 = UIColor(hex: "111111")        // Title text
        static let grayScale800 = UIColor(hex: "2D2D2D")        // Sub text
        static let grayScale700 = UIColor(hex: "404040")
        static let grayScale600 = UIColor(hex: "666666")        // Caption
        static let grayScale500 = UIColor(hex: "808080")
        static let grayScale400 = UIColor(hex: "979797")        // Disabled text/bg
        static let grayScale300 = UIColor(hex: "BFBFBF")
        static let grayScale200 = UIColor(hex: "E6E6E6")        // Line
        static let grayScale100 = UIColor(hex: "F2F2F2")        // Background
        static let grayScale50 = UIColor(hex: "F8F8F8")
        static let white = UIColor(hex: "FFFFFF")           // White background
    }
    
    struct Button {
        static let purpleButton1 = UIColor(hex: "7740AE")
        static let purpleButton2 = UIColor(hex: "7D52A9")
        static let grayButton = UIColor(hex: "979797")
    }
    
    // MARK: - System Colors
    struct System {
        static let red = UIColor(hex: "FF3B30")             // Error
        static let green = UIColor(hex: "34C759")           // Success
    }
    
    // MARK: - Semantic Colors
    struct Text {
        static let title = Grayscale.grayScale900               // #111111
        static let subtitle = Grayscale.grayScale800            // #2D2D2D
        static let caption = Grayscale.grayScale600             // #666666
        static let disabled = Grayscale.grayScale400            // #979797
        static let placeholder = Grayscale.grayScale400         // #979797
        static let error = System.red
        static let success = System.green
    }
    
    struct Background {
        static let primary = Grayscale.white                // #FFFFFF
        static let secondary = Grayscale.grayScale100           // #F2F2F2
        static let disabled = Grayscale.grayScale400            // #979797
    }
    
    struct Line {
        static let `default` = Grayscale.grayScale200           // #E6E6E6
        static let disabled = Grayscale.grayScale400            // #979797
    }
}

// MARK: - SwiftUI Color Extensions
extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
    
    // Brand Colors
    static let mainPurple = Color(hex: "6C5CE7")
    static let subPurple = Color(hex: "A29BFE")
    static let darkPurple = Color(hex: "5A4FCF")
    static let lightPurple = Color(hex: "DDD6FE")
    static let cardPurple = Color(hex: "E0D3F1")
    static let lightCardPurple = Color(hex: "F5F2F8")
    
    // Text Colors
    static let titleText = Color(hex: "111111")
    static let subtitleText = Color(hex: "2D2D2D")
    static let captionText = Color(hex: "666666")
    static let disabledText = Color(hex: "979797")
    
    // Background Colors
    static let primaryBg = Color(hex: "FFFFFF")
    static let secondaryBg = Color(hex: "F2F2F2")
    
    // Line Colors
    static let defaultLine = Color(hex: "E6E6E6")
    
    // System Colors
    static let errorColor = Color(hex: "FF3B30")
    static let successColor = Color(hex: "34C759")
}

// MARK: - Typography
struct TodotTypography {
    
    // Font Sizes
    static let size64: CGFloat = 64
    static let size48: CGFloat = 48
    static let size28: CGFloat = 28
    static let size24: CGFloat = 24
    static let size20: CGFloat = 20
    static let size12: CGFloat = 12
    
    // Font Styles
    struct Title {
        static let large = UIFont.systemFont(ofSize: 64, weight: .bold)
        static let medium = UIFont.systemFont(ofSize: 48, weight: .bold)
        static let small = UIFont.systemFont(ofSize: 28, weight: .bold)
    }
    
    struct Body {
        static let large = UIFont.systemFont(ofSize: 24, weight: .regular)
        static let medium = UIFont.systemFont(ofSize: 20, weight: .regular)
        static let small = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    struct Caption {
        static let `default` = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
}

// MARK: - SwiftUI Font Extensions
extension Font {
    static let titleLarge = Font.system(size: 64, weight: .bold)
    static let titleMedium = Font.system(size: 48, weight: .bold)
    static let titleSmall = Font.system(size: 28, weight: .bold)
    
    static let bodyLarge = Font.system(size: 24, weight: .regular)
    static let bodyMedium = Font.system(size: 20, weight: .regular)
    static let bodySmall = Font.system(size: 12, weight: .regular)
    
    static let caption = Font.system(size: 12, weight: .medium)
}

// MARK: - Usage Examples
/*
 
 // UIKit 사용법:
 label.textColor = TodotColors.Text.title
 view.backgroundColor = TodotColors.Background.primary
 button.setTitleColor(TodotColors.Brand.mainPurple, for: .normal)
 
 // SwiftUI 사용법:
 Text("제목")
     .foregroundColor(.titleText)
     .font(.titleLarge)
 
 Rectangle()
     .fill(Color.mainPurple)
 
 */
