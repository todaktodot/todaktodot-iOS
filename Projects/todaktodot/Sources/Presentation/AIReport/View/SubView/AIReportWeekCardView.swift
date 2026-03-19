//
//  AIReportWeekCardView.swift
//  todaktodot
//
//  Created by 임대진 on 1/24/26.
//

import UIKit
import CoreText
import FlexLayout
import PinLayout
import Then

final class AIReportWeekCardView: UIView {
    enum State {
        case active
        case inactive
    }
    
    var onTap: ((Int) -> Void)?
    private var isTapEnabled = true
    
    private var week: Int?
    private var reportId: Int?
    private let titleLabel = UILabel().then {
        let baseFont = UIFont.pretenSemiBold(18)
        let descriptor = baseFont.fontDescriptor.addingAttributes([
            .featureSettings: [
                [
                    UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                    UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector
                ]
            ]
        ])
        $0.font = UIFont(descriptor: descriptor, size: 18)
    }
    
    private let dotView = UIView().then {
        $0.backgroundColor = .mainPurple
        $0.layer.cornerRadius = 2
    }
    
    private let subtitleLabel = TDLabel().then {
        $0.text = "생성된 AI 리포트가 없어요"
        $0.font = .pretenRegular(12)
        $0.textColor = .grayScale400
    }
    
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right")).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let topBlurView = UIVisualEffectView(
        effect: UIBlurEffect(style: .light)
    )
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
        
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(month: Int, week: Int, isActive: Bool, reportId id: Int? = nil) {
        self.week = week
        titleLabel.text = "\(month)월 \(week)주차"
        reportId = id
        applyState(isActive)
        
        dotView.flex.display(isActive ? .flex : .none)
        subtitleLabel.flex.display(isActive ? .none : .flex)
        
        titleLabel.flex.markDirty()
        dotView.flex.markDirty()
        subtitleLabel.flex.markDirty()
        
        if isActive {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(weekCardTapped))
            addGestureRecognizer(tapGesture)
        }
    }

    private func setupUI() {
        layer.cornerRadius = 20
        
        flex.define {
            $0.addItem().direction(.row).paddingHorizontal(20).define {
                $0.addItem(titleLabel)
                    .marginTop(20)
                
                $0.addItem(dotView)
                    .size(4)
                    .marginLeft(4)
                    .marginTop(20)
                
                $0.addItem(subtitleLabel)
                    .marginLeft(8)
                    .marginTop(20)
                
                $0.addItem().grow(1)
                
                $0.addItem(chevron)
                    .size(16)
                    .marginTop(20)
            }
            
            $0.addItem().grow(1)
        }
    }

    private func applyState(_ isActive: Bool) {
        if isActive {
            backgroundColor = .subPurple
            titleLabel.textColor = .grayScale900
            chevron.tintColor  = .grayScale800
        } else {
            backgroundColor = .grayScale100
            titleLabel.textColor = .grayScale400
            chevron.tintColor  = .grayScale400
        }
        
        layer.shadowColor = UIColor(hex: "774F9E").cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 20
    }
    
    @objc private func weekCardTapped() {
        guard let reportId, isTapEnabled else { return }
        
        isTapEnabled = false
        onTap?(reportId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isTapEnabled = true
        }
    }
}
