//
//  AIReportLoadingView.swift
//  todaktodot
//
//  Created by 임대진 on 1/21/26.
//

import UIKit
import PinLayout
import FlexLayout
import Then
import Lottie

final class AIReportLoadingView: UIView {
    private let background = UIImageView().then {
        $0.image = UIImage(resource: .aiReportLoadingBackground)
    }
    
    private let lottie = LottieAnimationView(name: "loading").then {
        $0.loopMode = .loop
    }
    
    private let label = TDLabel().then {
        $0.text = "우리의 AI 리포트가\n만들어지고 있어요"
        $0.font = .pretenSemiBold(24)
        $0.textColor = .grayScale900
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupFlexLayout()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    private func setupViews() {
        addSubview(background)
    }
    
    private func setupFlexLayout() {
        background.flex.alignItems(.center).define {
            $0.addItem().grow(1)
            
            $0.addItem(lottie)
                .size(160)
            
            $0.addItem(label)
            
            $0.addItem().grow(1)
        }
        
        lottie.play()
    }
    
    private func layoutViews() {
        background.pin.all()
        
        background.flex.layout()
    }
}
