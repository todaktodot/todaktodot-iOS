//
//  GenderButton.swift
//  todaktodot
//
//  Created by 임대진 on 6/30/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then
import RxSwift
import RxRelay

enum Gender {
    case male
    case female
}

final class GenderButton: UIButton {
    private let icon = UIImageView()
    
    var title = TDLabel().then {
        $0.textColor = .grayScale900
        $0.font = .pretenMedium(16)
    }
    
    var isTap = PublishRelay<Void>()
    
    init(gender: Gender) {
        super.init(frame: .zero)
        
        if gender == .male {
            icon.image = UIImage(resource: .male)
            title.text = "남성"
        } else {
            icon.image = UIImage(resource: .female)
            title.text = "여성"
        }
        
        setupButton()
        setupFlexLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupButton() {
        backgroundColor = .white
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayScale200.cgColor
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    private func setupFlexLayout() {
        self.flex
            .height(82)
            .alignItems(.center)
            .define {
                $0.addItem(icon)
                    .size(32)
                    .marginTop(12)

                $0.addItem(title)
                    .marginTop(2)
                    .marginBottom(12)
        }
    }
    
    @objc private func didTap() {
        isTap.accept(())
    }
}

