//
//  CustomProgressBar.swift
//  todaktodot
//
//  Created by 임대진 on 1/21/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout

final class CustomProgressBar: UIView {
    enum ProgressBarType {
        case economy, life, couple
    }
    
    private let trackView = UIView().then {
        $0.backgroundColor = .grayScale100
    }
    
    private let progressView = UIView().then {
        $0.backgroundColor = .mainPurple
        $0.frame = CGRect(x: 0, y: 0, width: 0, height: 10)
    }
    
    private let labelBackgroundView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let label = TDLabel().then {
        $0.font = .pretenSemiBold(16)
        $0.textColor = .grayScale800
    }
    
    private let progressLabel = TDLabel().then {
        $0.text = "000%"
        $0.font = .pretenRegular(16)
        $0.textColor = .grayScale800
        $0.textAlignment = .right
    }

    private let barHeight: CGFloat = 10

    init(type: ProgressBarType) {
        super.init(frame: .zero)
        setupViews()
        
        switch type {
        case .economy:
            label.text = "💸 경제관"
        case .life:
            label.text = "🏠 생활관"
        case .couple:
            label.text = "💜 연애관"
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        clipsToBounds = true
        
        self.flex.define {
            $0.addItem(labelBackgroundView)
                .height(24)
            
            $0.addItem(trackView)
                .height(barHeight)
                .marginTop(4)
        }
        
        labelBackgroundView.flex.direction(.row).define {
            $0.addItem(label)
            $0.addItem().grow(1)
            $0.addItem(progressLabel)
        }
        
        trackView.addSubview(progressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        trackView.layer.cornerRadius = barHeight / 2
        progressView.layer.cornerRadius = barHeight / 2
    }

    func setProgress(_ value: CGFloat, animated: Bool) {
        progressLabel.text = "\(Int(value * 100))%"
        
        let width = (UIScreen.main.bounds.width - 80) * value
        
        if animated {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut) {
                self.progressView.frame = CGRect(x: 0, y: 0, width: width, height: 10)
            }
        } else {
            progressView.frame = CGRect(x: 0, y: 0, width: width, height: 10)
        }
    }
}
