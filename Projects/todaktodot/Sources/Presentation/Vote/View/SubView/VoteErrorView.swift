//
//  VoteErrorView.swift
//  todaktodot
//
//  Created by 임대진 on 8/30/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class VoteErrorView: UIView {
    private let icon = UIImageView().then {
        $0.image = UIImage(resource: .lightWarning)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "잠시 불러오지 못했어요"
        $0.textColor = .grayScale900
        $0.font = .pretenSemiBold(18)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "네트워크 상태를 확인하고 다시 시도해주세요"
        $0.textColor = .grayScale600
        $0.font = .pretenRegular(14)
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        icon.pin
            .hCenter()
            .top()
            .size(64)
        
        titleLabel.pin
            .hCenter()
            .top(68)
            .height(25)
            .sizeToFit()
        
        descriptionLabel.pin
            .hCenter()
            .top(97)
            .height(20)
            .sizeToFit()
    }
    
    private func setupUI() {
        addSubview(icon)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
    }
}

