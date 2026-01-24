//
//  LastWeekAIReportView.swift
//  SharedLibraries
//
//  Created by 임대진 on 1/16/26.
//
import UIKit
import PinLayout
import FlexLayout
import Then
import Lottie

final class LastWeekAIReportView: UIView {
    private let dateLabel = TDLabel().then {
        $0.text = "2025년 9월 29일 - 10월 5일"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale600
    }
    
    private let heartLottie = LottieAnimationView(name: "heartdot").then {
        $0.loopMode = .playOnce
    }
    
    private let dotDescriptionLabel = TDLabel().then {
        $0.text = "7개의 Dot으로 연결된 우리의 일주일"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .mainPurple
    }
    
    private let titleLabel = TDLabel().then {
        $0.text = "주간 AI 리포트가\n도착했어요"
        $0.font = .pretenSemiBold(24)
        $0.textColor = .grayScale900
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let descriptionBoldLabel = TDLabel().then {
        $0.text = "매주 월요일 8시에 신규 AI 리포트가 생성돼요"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale900
    }
    
    private let descriptionLabel = TDLabel(headIndent: 18).then {
        $0.text = """
        •   월요일 기준 저번주 일주일 간 나와 연인이 작성한 답변을 AI가 분석해줘요
        •   둘 다 답변 완료한 내용 기반으로 생성돼요
        •   싱크로율, 참여율, 비슷했던 답변, 달랐던 답변 등을 확인해보세요!
        """
        $0.font = .pretenRegular(14)
        $0.textColor = .grayScale600
        $0.numberOfLines = 0
    }
    
    private let descriptionBackground = UIView().then {
        $0.backgroundColor = .grayScale100
        $0.layer.cornerRadius = 16
    }
    
    let reportDetailButton = ImageTextButton(horizonPadding: 69.5, verticalPadding: 12, spacing: 8, imageSize: 28).then {
        $0.customText.text = "AI 리포트 확인하기"
        $0.customText.font = .pretenSemiBold(16)
        $0.customText.textColor = .white
        
        $0.customImage.image = UIImage(resource: .speechbubble)
        $0.backgroundColor = .mainPurple
        $0.layer.cornerRadius = 6
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        setupViews()
        heartLottie.play()
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flex.layout(mode: .adjustHeight)
    }
    
    func setupViews() {
        self.flex.alignItems(.center).define {
            $0.addItem(dateLabel)
                .marginTop(24)
            
            $0.addItem(heartLottie)
                .marginTop(8)
                .size(120)
            
            $0.addItem(dotDescriptionLabel)
                .marginTop(4)
            
            $0.addItem(titleLabel)
                .marginTop(8)
            
            $0.addItem(reportDetailButton)
                .marginTop(16)
            
            $0.addItem(descriptionBackground)
                .marginTop(20)
                .marginHorizontal(20)
                .marginBottom(20)
        }
        
        descriptionBackground.flex.padding(16).define {
            $0.addItem(descriptionBoldLabel)
            $0.addItem(descriptionLabel)
                .marginTop(4)
                .marginLeft(4)
        }
    }
}
