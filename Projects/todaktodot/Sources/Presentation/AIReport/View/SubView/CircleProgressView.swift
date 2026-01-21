//
//  CircleProgressView.swift
//  todaktodot
//
//  Created by 임대진 on 1/21/26.
//

import UIKit
import Then
import FlexLayout

final class CircleProgressView: UIView {

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    private let percentLabel = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.textColor = .white
    }
    
    private var radius: CGFloat {
        return min(bounds.width, bounds.height) / 2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .darkPurple
        layer.cornerRadius = 16

        trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.15).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 8

        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 8
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
        addSubview(percentLabel)
        
        flex.alignItems(.center).define {
            $0.addItem().grow(1)
            $0.addItem(percentLabel)
            $0.addItem().grow(1)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi

        let radius = min(bounds.width, bounds.height) / 2 - trackLayer.lineWidth / 2 - 20

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }

    func setProgress(_ value: CGFloat, animated: Bool) {
        let clamped = max(0, min(value, 1))

        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.presentation()?.strokeEnd ?? 0
            animation.toValue = clamped
            animation.duration = 0.6
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)

            progressLayer.strokeEnd = clamped
            progressLayer.add(animation, forKey: "progress")
        } else {
            progressLayer.strokeEnd = clamped
        }
        
        let numCount = String(Int(value * 100)).count
        let text = "대화 참여율\n\(Int(value * 100))%"
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttribute(.font, value: UIFont.pretenMedium(14), range: NSRange(location: 0, length: text.count - 3))
        attributed.addAttribute(.font, value: UIFont.pretenSemiBold(28), range: NSRange(location: text.count - (numCount + 1), length: numCount))
        attributed.addAttribute(.font, value: UIFont.pretenMedium(18), range: NSRange(location: text.count - 1, length: 1))

        percentLabel.attributedText = attributed
    }
}
