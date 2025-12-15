//
//  UILabel +.swift
//  todaktodot
//
//  Created by 임대진 on 12/3/25.
//

import UIKit

extension UILabel {
    func setTextWithLineHeight(text: String?, multiplier: CGFloat, textAlignment: NSTextAlignment = .left) {
        guard let labelText = text ?? self.text else { return }
        
        let attributedString = NSMutableAttributedString(string: labelText)
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineHeightMultiple = multiplier
        
        let range = NSRange(location: 0, length: attributedString.length)
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        self.attributedText = attributedString
    }
}
