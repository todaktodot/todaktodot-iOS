//
//  AIReportThirdView.swift
//  SharedLibraries
//
//  Created by 임대진 on 1/20/26.
//

import UIKit
import PinLayout
import FlexLayout
import Then
import Lottie//

final class AIReportThirdView: UIView {
    var onTapTopic: ((Int) -> Void)?
    
    private let titleLabel = TDLabel().then {
        $0.text = "어떤 부분에서\n생각이 같았고, 또 달랐을까요?"
        $0.font = .pretenSemiBold(24)
        $0.textColor = .grayScale900
        $0.numberOfLines = 2
    }
    
    private let positiveTitleLabel = TDLabel().then {
        $0.text = "비슷했던 주제"
        $0.font = .pretenSemiBold(18)
        $0.textColor = .grayScale900
    }
    
    private let negativeTitleLabel = TDLabel().then {
        $0.text = "대화가 더 필요한 주제"
        $0.font = .pretenSemiBold(18)
        $0.textColor = .grayScale900
    }
    
    private var similarTopics: [TopicDetailButton] = []
    private var differentTopics: [TopicDetailButton] = []
    
    func configure(detail: AIReportDetail, hiddenTitle: Bool) {
        similarTopics = detail.similarSubjectList.map {
            TopicDetailButton(date: $0.issuedDt.toKRFomatterEMMDD(), topic: "\($0.mode) · \($0.subject)", coupleCardId: $0.coupleCardId)
        }
        
        differentTopics = detail.differentSubjectList.map {
            TopicDetailButton(date: $0.issuedDt.toKRFomatterEMMDD(), topic: "\($0.mode) · \($0.subject)", coupleCardId: $0.coupleCardId)
        }
        
        setupViews()
        
        if hiddenTitle {
            titleLabel.removeFromSuperview()
        }
    }
    
    private func setupViews() {
        
        self.flex.define {
            $0.addItem(titleLabel)
                .marginTop(20)
            
            $0.addItem(positiveTitleLabel)
                .marginTop(28)
            
            $0.addItem().marginTop(12).gap(8).define { item in
                similarTopics.forEach { topic in
                    topic.addTarget(self, action: #selector(buttonTap(_:)), for: .touchUpInside)
                    item.addItem(topic)
                }
            }
            
            $0.addItem(negativeTitleLabel)
                .marginTop(28)
            
            $0.addItem().marginTop(12).gap(8).define { item in
                differentTopics.forEach { topic in
                    topic.addTarget(self, action: #selector(buttonTap(_:)), for: .touchUpInside)
                    item.addItem(topic)
                }
            }
        }
    }
    
    @objc private func buttonTap(_ sender: TopicDetailButton) {
        onTapTopic?(sender.coupleCardId)
    }
}
