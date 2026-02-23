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
    
    private let firstMetDateTitleLabel = TDLabel().then {
        $0.text = "처음 만난 날"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .white
    }
    
    private let sinceMetDateTitleLabel = TDLabel().then {
        $0.text = "우리가 만난지"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .white
    }
    
    private let stageTitleLabel = TDLabel().then {
        $0.text = "우리의 관계"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .white
    }
    
    private let firstMetDate = TDLabel().then {
        $0.font = .pretenRegular(16)
        $0.textColor = .white
    }
    
    private let sinceMetDate = TDLabel().then {
        $0.font = .pretenRegular(16)
        $0.textColor = .white
    }
    
    private let stage = TDLabel().then {
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
                    .justifyContent(.spaceBetween)
                    .define {
                        $0.addItem(firstMetDateTitleLabel)
                        $0.addItem(firstMetDate)
                    }
                
                $0.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .justifyContent(.spaceBetween)
                    .define {
                        $0.addItem(sinceMetDateTitleLabel)
                        $0.addItem(sinceMetDate)
                    }
                
                $0.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .justifyContent(.spaceBetween)
                    .define {
                        $0.addItem(stageTitleLabel)
                        $0.addItem(stage)
                    }
            }
    }
    
    func setOurInfo(info: CoupleInfo) {
        firstMetDate.text = info.firstMetDate
        sinceMetDate.text = info.sinceMetDate
        stage.text = info.stage
        
        firstMetDate.flex.markDirty()
        sinceMetDate.flex.markDirty()
        stage.flex.markDirty()
    }
}
