//
//  DashedBorderView.swift
//  todaktodot
//
//  Created by 임대진 on 1/27/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class DashedBorderView: UIView {
    private let dashedLayer = CAShapeLayer()
    
    private let iconView = UIImageView().then {
        $0.image = UIImage(resource: .gloomy)
        $0.contentMode = .scaleAspectFit
    }
    
    private let label = TDLabel().then {
        $0.text = "연인과 연결되지 않았어요"
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale600
    }
    
    private let connectButton = UIButton().then {
        $0.setTitle("커플 연결", for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(14)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .mainPurple
        $0.layer.cornerRadius = 6
    }
    
    init() {
        super.init(frame: .zero)
        setupFlexLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupDashedBorder()
    }
    
    private func setupFlexLayout() {
        self.flex
            .alignItems(.center)
            .paddingHorizontal(20)
            .height(160)
            .define {
            $0.addItem(iconView)
                .marginTop(16)
                .size(36)
            
            $0.addItem(label)
                .marginTop(4)
            
            $0.addItem(connectButton)
                .marginTop(16)
                .height(44)
                .width(100%)
                .marginBottom(20)
        }
    }
    
    private func setupDashedBorder() {
            dashedLayer.frame = bounds
            dashedLayer.fillColor = UIColor.clear.cgColor
            dashedLayer.strokeColor = UIColor.subPurple.cgColor
            dashedLayer.lineWidth = 1
            dashedLayer.lineDashPattern = [4, 4]
            dashedLayer.lineCap = .round
            dashedLayer.path = UIBezierPath(
                roundedRect: bounds,
                cornerRadius: 16
            ).cgPath

            layer.insertSublayer(dashedLayer, at: 0)
        }
}


