//
//  OurInfoView.swift
//  todaktodot
//
//  Created by 임대진 on 1/27/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class OurInfoView: UIView {
    
    let settingButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "gearshape"), for: .normal)
        $0.tintColor = .white.withAlphaComponent(0.6)
    }
    
    private let cardTitleLabel = TDLabel().then {
        $0.text = "우리의 정보"
        $0.font = .pretenMedium(14)
        $0.textColor = .white
    }
    
    private let firstTitleLabel = TDLabel().then {
        $0.text = "처음 만난 날"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .white
    }
    
    private let secondTitleLabel = TDLabel().then {
        $0.text = "우리가 만난지"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .white
    }
    
    private let thirdTitleLabel = TDLabel().then {
        $0.text = "우리의 관계"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .white
    }
    
    private let firstValueLabel = TDLabel().then {
        $0.text = "24년 9월 1일"
        $0.font = .pretenRegular(16)
        $0.textColor = .white
    }
    
    private let secondValueLabel = TDLabel().then {
        $0.text = "1년 1개월 1일"
        $0.font = .pretenRegular(16)
        $0.textColor = .white
    }
    
    private let thirdValueLabel = TDLabel().then {
        $0.text = "💝 결혼 준비중이에요"
        $0.font = .pretenRegular(16)
        $0.textColor = .white
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupUI() {
        backgroundColor = .mainPurple
        layer.cornerRadius = 16

        flex.paddingHorizontal(20)
            .paddingVertical(18)
            .gap(12)
            .define {
                $0.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .define {
                        $0.addItem(cardTitleLabel)
                        $0.addItem().grow(1)
                        $0.addItem(settingButton)
                            .size(20)
                    }
                
                $0.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .define {
                        $0.addItem(firstTitleLabel)
                        $0.addItem().grow(1)
                        $0.addItem(firstValueLabel)
                    }
                
                $0.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .define {
                        $0.addItem(secondTitleLabel)
                        $0.addItem().grow(1)
                        $0.addItem(secondValueLabel)
                    }
                
                $0.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .define {
                        $0.addItem(thirdTitleLabel)
                        $0.addItem().grow(1)
                        $0.addItem(thirdValueLabel)
                    }
            }
    }
}
