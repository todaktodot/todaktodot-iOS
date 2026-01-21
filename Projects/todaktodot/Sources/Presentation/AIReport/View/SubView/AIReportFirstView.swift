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

class AIReportFirstView: UIView {
    private let syncBoxBackground = UIImageView().then {
        $0.image = UIImage(resource: .purpleBoxHigh)
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
        $0.text = "0개"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .grayScale800
    }
    
    // 폰트 크기때문에 UILabel 유지
    private let syncPercentLabel = UILabel().then {
        $0.text = "78%"
        $0.font = .pretenMedium(68)
        $0.textColor = .white
    }
    
    private let progressBackground = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let talkCountBackground = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let circleProgress = CircleProgressView()
    private let progressView1 = CustomProgressBar(type: .economy)
    private let progressView2 = CustomProgressBar(type: .life)
    private let progressView3 = CustomProgressBar(type: .couple)
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupViews()
        
        progressView1.setProgress(0.7, animated: true)
        progressView2.setProgress(0.55, animated: true)
        progressView3.setProgress(0.8, animated: true)
        setCount(127)
        circleProgress.setProgress(0.78, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
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

extension AIReportFirstView {
    func setCount(_ count: Int) {
        let text = "\(count)개"
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttribute(.font, value: UIFont.pretenSemiBold(28), range: NSRange(location: 0, length: text.count - 1))
        attributed.addAttribute(.font, value: UIFont.pretenMedium(18), range: NSRange(location: text.count - 1, length: 1))

        talkCountLabel.attributedText = attributed
    }
}
