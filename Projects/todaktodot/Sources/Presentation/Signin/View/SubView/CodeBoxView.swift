//
//  CodeBoxView.swift
//  todaktodot
//
//  Created by 임대진 on 12/2/25.
//

import UIKit
import Then
import FlexLayout

final class CodeBoxView: UIView {
    private let charLabel = UILabel().then {
        $0.tintColor = .mainPurple
        $0.textColor = .mainPurple
        $0.textAlignment = .center
        $0.font = .pretenMedium(24)
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        layer.borderWidth = 1
        layer.cornerRadius = 6
        layer.borderColor = UIColor.grayScale200.cgColor
        
        flex.alignItems(.center).define {
            $0.addItem(charLabel)
                .width(44)
                .height(48)
        }
        
        addSubview(charLabel)
        charLabel.pin.all()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(char: Character?, isMyCode: Bool? = false) {
        if let char = char {
            charLabel.text = String(char).uppercased()
        } else {
            charLabel.text = ""
        }
        charLabel.flex.markDirty()
        
        if let isMyCode = isMyCode, isMyCode {
            backgroundColor = .lightPurple
            layer.borderWidth = 0
        }
    }
    
    func setActive(_ isActive: Bool) {
        layer.borderColor = isActive ? UIColor.mainPurple.cgColor : UIColor.grayScale200.cgColor
    }
}
