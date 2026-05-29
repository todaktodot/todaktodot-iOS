//
//  InAppNotificationView.swift
//  todaktodot
//
//  Created by 임대진 on 3/4/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class InAppNotificationView: UIView {
    private let title = TDLabel().then {
        $0.font = .pretenSemiBold(16)
        $0.textColor = .white
    }
    
    private let body = TDLabel().then {
        $0.font = .pretenRegular(14)
        $0.textColor = .white
    }
    
    init(title: String, body: String) {
        self.title.text = title
        self.body.text = body
        super.init(frame: .zero)
        backgroundColor = .darkPurple
        layer.cornerRadius = 10
        
        setupFlexLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flex.layout(mode: .adjustHeight)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = bounds.contains(point)
        print("📌 InAppPush point inside: \(inside), bounds: \(bounds), point: \(point)")
        return inside
    }
    
    private func setupFlexLayout() {
        self.flex.define {
            $0.addItem(title)
                .marginTop(15)
                .marginLeft(20)
            $0.addItem(body)
                .marginTop(3)
                .marginBottom(15)
                .marginLeft(20)
        }
        title.isUserInteractionEnabled = false
        body.isUserInteractionEnabled = false
    }
    
    private func layoutViews() {
        self.flex.layout()
    }
    
}

