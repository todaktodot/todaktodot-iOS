//
//  AIReportWeekCardView.swift
//  todaktodot
//
//  Created by 임대진 on 1/24/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class AIReportWeekCardView: UIView {
    enum State {
        case active
        case inactive
    }
    
    var onTap: (() -> Void)?
    
    private let titleLabel = UILabel().then {
        $0.font = .pretenSemiBold(18)
    }
    private let dotView = UIView().then {
        $0.backgroundColor = .mainPurple
        $0.layer.cornerRadius = 4
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
    
    init(title: String, state: State) {
        super.init(frame: .zero)
        setupUI(title: title, state: state)
        
        if state == .active {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(weekCardTapped))
            addGestureRecognizer(tapGesture)
        }   
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupUI(title: String, state: State) {
        layer.cornerRadius = 20
        
        titleLabel.text = title
        
        flex.define {
            $0.addItem().direction(.row).paddingHorizontal(20).define {
                $0.addItem(titleLabel)
                    .marginTop(20)
                
                if state == .active {
                    $0.addItem(dotView)
                        .size(4)
                        .marginLeft(4)
                        .marginTop(20)
                } else {
                    $0.addItem(subtitleLabel)
                        .marginLeft(8)
                        .marginTop(20)
                }
                
                $0.addItem().grow(1)
                
                $0.addItem(chevron)
                    .size(16)
                    .marginTop(20)
            }
            
            $0.addItem().grow(1)
        }

        applyState(state)
    }

    private func applyState(_ state: State) {
        switch state {
        case .active:
            backgroundColor = .subPurple
            chevron.tintColor  = .grayScale800

        case .inactive:
            backgroundColor = .grayScale100
            titleLabel.textColor = .grayScale400
            chevron.tintColor  = .grayScale400
            
            layer.shadowColor = UIColor(hex: "774F9E").cgColor
            layer.shadowOpacity = 0.15
            layer.shadowOffset = CGSize(width: 0, height: -2)
            layer.shadowRadius = 20
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc private func weekCardTapped() {
        onTap?()
    }
}
