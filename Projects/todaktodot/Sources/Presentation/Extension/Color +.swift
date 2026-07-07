//
//  Color +.swift
//  todaktodot
//
//  Created by daye on 11/26/25.
//

import UIKit
import SwiftUI

struct TodotColors {
    
    // MARK: - Grayscale
    struct Grayscale {
        static let grayScale900 = UIColor(hex: "111111")     // Title text
        static let grayScale800 = UIColor(hex: "2D2D2D")     // Sub text
        static let grayScale700 = UIColor(hex: "404040")
        static let grayScale600 = UIColor(hex: "666666")     // Caption
        static let grayScale500 = UIColor(hex: "808080")
        static let grayScale400 = UIColor(hex: "979797")     // Disabled text/bg
        static let grayScale300 = UIColor(hex: "BFBFBF")
        static let grayScale200 = UIColor(hex: "E6E6E6")     // Line
        static let grayScale100 = UIColor(hex: "F2F2F2")     // Background
        static let grayScale50 = UIColor(hex: "F8F8F8")
        static let white = UIColor(hex: "FFFFFF")            // White background
    }
    
    // MARK: - Brand Colors
    struct Brand {
        static let mainPurple = UIColor(hex: "7740AE")       // Main Purple
        static let subPurple = UIColor(hex: "E0D3F1")        // Sub Purple
        static let darkPurple = UIColor(hex: "4E3772")       // Dark Purple
        static let lightPurple = UIColor(hex: "F5F2F8")      // Light Purple
        static let cardPurple = UIColor(hex: "E0D3F1")
        static let lightCardPurple = UIColor(hex: "F5F2F8")
    }
    
    // MARK: - Button Colors
    struct Button {
        static let purpleButton1 = UIColor(hex: "7740AE")
        static let purpleButton2 = UIColor(hex: "7D52A9")
        static let grayButton = UIColor(hex: "979797")
    }
    
    // MARK: - System Colors
    struct System {
        static let red = UIColor(hex: "FF3B30")              // Error
        static let redError = UIColor(hex: "E93528")              // Error
        static let green = UIColor(hex: "34C759")            // Success
    }
    
    // MARK: - Semantic Colors (위에 정의된 색상 참조)
    struct Text {
        static let title = Grayscale.grayScale900
        static let subtitle = Grayscale.grayScale800
        static let caption = Grayscale.grayScale600
        static let disabled = Grayscale.grayScale400
        static let placeholder = Grayscale.grayScale400
        static let error = System.red
        static let success = System.green
    }
    
    struct Background {
        static let primary = Grayscale.white
        static let secondary = Grayscale.grayScale100
        static let disabled = Grayscale.grayScale400
    }
    
    struct Line {
        static let `default` = Grayscale.grayScale200
        static let disabled = Grayscale.grayScale400
    }
}

// MARK: - UIColor Extensions (TodotColors 구조체를 참조하여 접근성 향상)
extension UIColor {
    
    // MARK: Brand Colors
    static let mainPurple = TodotColors.Brand.mainPurple
    static let subPurple = TodotColors.Brand.subPurple
    static let darkPurple = TodotColors.Brand.darkPurple
    static let lightPurple = TodotColors.Brand.lightPurple
    static let cardPurple = TodotColors.Brand.cardPurple
    static let lightCardPurple = TodotColors.Brand.lightCardPurple
    
    // MARK: Grayscale
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
    
    // MARK: Semantic Text Colors
    static let titleText = TodotColors.Text.title
    static let subtitleText = TodotColors.Text.subtitle
    static let captionText = TodotColors.Text.caption
    static let disabledText = TodotColors.Text.disabled
    
    // MARK: Semantic Background & Line Colors
    static let primaryBackground = TodotColors.Background.primary
    static let secondaryBackground = TodotColors.Background.secondary
    static let defaultLine = TodotColors.Line.default
    
    // MARK: System Colors
    static let errorColor = TodotColors.System.red
    static let redErrorColor = TodotColors.System.redError
    static let successColor = TodotColors.System.green
    static let whiteColor = TodotColors.Grayscale.white
}

extension UIColor {

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}
