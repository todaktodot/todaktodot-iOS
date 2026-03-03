//
//  AIReportFirstView.swift
//  SharedLibraries
//
//  Created by 임대진 on 1/20/26.
//

import UIKit
import PinLayout
import FlexLayout
import Then
import Lottie

final class AIReportFirstView: UIView {
    private var detail: AIReportDetail? = nil
    private var isInteration: Bool = true
    private let syncBoxBackground = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let dateLabel = TDLabel().then {
        $0.text = "2025년 9월 29일 - 10월 5일"
        $0.font = .pretenMedium(14)
        $0.textColor = .white
    }
    
    private let syncDescriptionLabel = TDLabel().then {
        $0.text = "우리의 싱크로율"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .white
    }
    
    private let talkDescriptionLabel = TDLabel().then {
        $0.text = "대화 누적 자산"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale800
    }
    
    private let talkCountLabel = TDLabel().then {
        $0.text = "000개"
        $0.font = .pretenSemiBold(28)
        $0.textColor = .grayScale800
        $0.textAlignment = .right
    }
    
    private let syncPercentLabel = TDLabel().then {
        $0.text = "000%"
        $0.font = .pretenMedium(68)
        $0.textColor = .white
        $0.textAlignment = .right
    }
    
    private let progressBackground = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let talkCountBackground = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let syncCountAnimator = CountUpAnimator()
    private let talkCountAnimator = CountUpAnimator()
    private let circleProgress = CircleProgressView()
    private let progressView1 = CustomProgressBar(type: .economy)
    private let progressView2 = CustomProgressBar(type: .life)
    private let progressView3 = CustomProgressBar(type: .couple)
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupData(isInteration: isInteration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(detail: AIReportDetail, isInteration: Bool) {
        self.detail = detail
        self.isInteration = isInteration
    }
    
    private func setupData(isInteration: Bool) {
        guard let detail else { return }
        if isInteration {
            syncCountAnimator.start(to: Double(detail.totalSyncRate)) { [weak self] value in
                self?.syncPercentLabel.text = "\(value)%"
            }
            talkCountAnimator.start(to: Double(detail.totalDailycardAnswerCnt)) { [weak self] value in
                self?.talkCountLabel.text = "\(value)개"
            }
        } else {
            syncPercentLabel.text = "\(detail.totalSyncRate)%"
            talkCountLabel.text = "\(detail.totalDailycardAnswerCnt)개"
        }
        
        syncBoxBackground.image =
        detail.totalSyncRate > 67 ? UIImage(resource: .purpleBoxHigh) :
        detail.totalSyncRate > 33 ? UIImage(resource: .purpleBoxMedium) : UIImage(resource: .purpleBoxLow)
        
        dateLabel.text = "\(detail.startDt) ~ \(detail.endDt)"
        progressView1.setProgress(detail.economySyncRate, animated: isInteration)
        progressView2.setProgress(detail.lifeSyncRate, animated: isInteration)
        progressView3.setProgress(detail.loveSyncRate, animated: isInteration)
        circleProgress.setProgress(detail.dailycardAnswerRate, animated: isInteration)
    }
    
    private func setupViews() {
        
        self.flex.define {
            $0.addItem(syncBoxBackground)
                .marginTop(20)
                .width(100%)
                .aspectRatio(1)
            
            $0.addItem(progressBackground)
                .marginTop(16)
                .width(100%)
                .height(194)
            
            $0.addItem().grow(1).direction(.row).marginTop(16).define {
                $0.addItem(circleProgress)
                    .grow(1)
                    .aspectRatio(1)
                
                $0.addItem().grow(1)
                    .width(17)
                
                $0.addItem(talkCountBackground)
                    .grow(1)
                    .aspectRatio(1)
            }
        }
        
        syncBoxBackground.flex.paddingHorizontal(20).define {
            $0.addItem(dateLabel)
                .marginTop(20)
            
            $0.addItem().grow(1)
            
            $0.addItem()
                .marginBottom(22)
                .direction(.row)
                .alignItems(.end)
                .justifyContent(.spaceBetween)
                .define {
                    $0.addItem(syncDescriptionLabel)
                    $0.addItem(syncPercentLabel)
                }
        }
        
        progressBackground.flex.paddingHorizontal(20).define {
            $0.addItem(progressView1)
                .marginTop(20)
            
            $0.addItem(progressView2)
                .marginTop(16)
            
            $0.addItem(progressView3)
                .marginTop(16)
                .marginBottom(28)
        }
        
        talkCountBackground.flex.padding(20).define {
            $0.addItem(talkDescriptionLabel)
            
            $0.addItem().grow(1)
            
            $0.addItem(talkCountLabel)
                .alignSelf(.end)
        }
    }
}
