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

class AIReportThirdView: UIView {
    
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
            
            $0.addItem(positiveTitleLabel)
                .marginTop(28)
            
            $0.addItem().marginTop(12).gap(8).define {
                for _ in 0..<4 {
                    $0.addItem(TopicDetailButton(date: "금 9/12", topic: "커피모드 · 경제관"))
                }
            }
            
            $0.addItem(negativeTitleLabel)
                .marginTop(28)
            
            $0.addItem().marginTop(12).gap(8).define {
                for _ in 0..<4 {
                    $0.addItem(TopicDetailButton(date: "금 9/12", topic: "커피모드 · 경제관"))
                }
            }
        }
    }
    
    func hiddenTitleLabel() {
        titleLabel.removeFromSuperview()
    }
}
