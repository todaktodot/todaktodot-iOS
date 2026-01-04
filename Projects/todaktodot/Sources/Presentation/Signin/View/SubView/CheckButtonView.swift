//
//  CheckButtonView.swift
//  todaktodot
//
//  Created by 임대진 on 12/14/25.
//

import UIKit
import RxSwift
import FlexLayout
import PinLayout
import RxCocoa
import Then

// ex)
// private let agreeButton = CheckButton()
// agreeButton.configure(isBackground: true, title: "유의사항을 모두 확인했으며, 이에 동의합니다.")
// agreeButton.setState(isSelected: self.onTabCheckButton)

class CheckButtonView: UIView {
    
    private var isBackground = false
    private let disposeBag = DisposeBag()
    private let title = TDLabel().then {
        $0.textColor = .grayScale900
    }
    
    let icon = UIButton().then {
        $0.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        $0.tintColor = .grayScale400
    }
    
    let chevronButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        $0.setImage(UIImage(systemName: "chevron.right")?.withConfiguration(config), for: .normal)
        $0.tintColor = .black
    }
    
    init(frame: CGRect = .zero, titleFont: UIFont = .pretenRegular(14)) {
        self.title.font = titleFont
        super.init(frame: frame)
        self.setupViews()
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.flex.direction(.row).alignItems(.center).define {
            $0.addItem(icon)
                .marginLeft(16)
            
            $0.addItem(title)
                .marginLeft(8)
            
            $0.addItem().grow(1)
            
            $0.addItem(chevronButton)
                .marginRight(16)
        }
    }
    
    func configure(isBackground: Bool, title: String) {
        self.title.text = title
        if isBackground {
            self.chevronButton.isHidden = true
            self.isBackground = isBackground
            self.backgroundColor = .lightPurple
            self.layer.cornerRadius = 8
        } else {
            self.layer.borderWidth = 0
            self.backgroundColor = .white
        }
    }
    
    func setState(isSelected: Bool) {
        UIView.animate(withDuration: 0.1) {
            switch isSelected {
            case true:
                self.icon.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                self.icon.tintColor = .mainPurple
            case false:
                self.icon.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
                self.icon.tintColor = .grayScale200
            }
        }
    }
}
