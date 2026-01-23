//
//  AIReportSecondView.swift
//  SharedLibraries
//
//  Created by 임대진 on 1/20/26.
//

import UIKit
import PinLayout
import FlexLayout
import Then
import Lottie

class AIReportSecondView: UIView {
    
    private let titleLabel = TDLabel().then {
        $0.text = "AI가 두 분의 대화를\n더 자세히 분석해보았어요"
        $0.font = .pretenSemiBold(24)
        $0.textColor = .grayScale900
        $0.numberOfLines = 2
    }
    
    private let reportTitleLabel = TDLabel().then {
        $0.text = "AI 인사이트"
        $0.font = .pretenSemiBold(18)
        $0.textColor = .grayScale900
    }
    
    private let reportResultLabel = TDLabel().then {
        $0.text = "이번 주 A와 B는 서로 다른 관점을 가지면서도 핵심 가치에서는 놀라울 정도로 일치하는 모습을 보였어요. 특히 연애관에서는 상당한 싱크로율을 보이며, 서로를 배려하는 마음이 답변 곳곳에 드러났어요. 경제관에서는 실용성과 낭만 사이에서 서로 다른 균형점을 찾고 있지만, 이런 차이가 오히려 서로에게 새로운 시각을 제공하고 있습니다. 생활관 부분에서 가장 많은 차이를 보였는데, 이는 각자의 생활 패턴과 우선순위가 다르기 때문으로 보여요."
        $0.font = .pretenRegular(16)
        $0.textColor = .grayScale800
        $0.numberOfLines = 0
    }
    
    private let reportBackgroundView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .white
    }
    
    private let imageView = UIImageView(image: UIImage(resource: .bookFill))
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        self.flex.define {
            $0.addItem(titleLabel)
                .marginTop(20)
            
            $0.addItem(reportBackgroundView)
                .marginTop(28)
                .marginBottom(4)
        }
        
        reportBackgroundView.flex.padding(20).define {
            $0.addItem()
                .direction(.row).define {
                    $0.addItem(imageView)
                        .size(28)
                    $0.addItem(reportTitleLabel)
                        .marginLeft(4)
                }
            
            $0.addItem(reportResultLabel)
                .marginTop(8)
        }
        
        reportBackgroundView.flex.layout(mode: .adjustHeight)
    }
    
    func hiddenTitleLabel() {
        titleLabel.removeFromSuperview()
    }
}
