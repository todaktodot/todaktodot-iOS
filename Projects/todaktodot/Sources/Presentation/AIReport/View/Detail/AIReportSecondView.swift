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

final class AIReportSecondView: UIView {
    private var descriptionTexts: [String?] = []
    private var subTitles = ["요약", "경제관", "생활관", "연애관"]
    
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
    
    private let reportBackgroundView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .white
    }
    
    private let imageView = UIImageView(image: UIImage(resource: .bookFill))
    
    func configure(detail: AIReportDetail, hiddenTitle: Bool) {
        if let myNickname = UserdefaultKey.nicknameInfo?.userNickname, let partnerNickname = UserdefaultKey.nicknameInfo?.anotherUserNickname {
            descriptionTexts = detail.insight.map {
                $0?.replacingNicknames([("A", myNickname), ("B", partnerNickname)])
            }
        } else {
            descriptionTexts = detail.insight
        }
        setupViews()
        
        if hiddenTitle {
            titleLabel.removeFromSuperview()
        }
    }
    
    private func subTitleLabel(text: String) -> TDLabel {
        TDLabel().then {
            $0.text = text
            $0.font = .pretenSemiBold(16)
            $0.textColor = .grayScale900
        }
    }
    
    private func descriptionLabel(text: String?) -> TDLabel {
        TDLabel().then {
            $0.text = text ?? "답변 내용이 없어요."
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
        }
    }
    
    private func setupViews() {
        
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
            
            $0.addItem()
                .define {
                    for (title, text) in zip(subTitles, descriptionTexts) {
                        $0.addItem(subTitleLabel(text: title))
                            .marginTop(8)
                        $0.addItem(descriptionLabel(text: text))
                    }
                }
        }
        
        reportBackgroundView.flex.layout(mode: .adjustHeight)
    }
}
