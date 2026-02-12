//
//  ModalButton.swift
//  todaktodot
//
//  Created by 임대진 on 2/10/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class ModalButton: UIButton {
    private let buttonTitleLabel = TDLabel().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
    }
    
    private let chevron = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .grayScale800
        $0.contentMode = .scaleAspectFit
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
        setupFlexLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [buttonTitleLabel, chevron].forEach {
            addSubview($0)
        }
    }
    
    private func setupFlexLayout() {
        self.flex.direction(.row).alignItems(.center).define {
            $0.addItem(buttonTitleLabel)
            $0.addItem().grow(1)
            $0.addItem(chevron).size(20)
        }
    }
    
    func setTitle(title: String) {
        buttonTitleLabel.text = title
    }
}

