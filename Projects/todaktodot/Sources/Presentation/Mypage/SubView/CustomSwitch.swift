//
//  CustomSwitch.swift
//  todaktodot
//
//  Created by 임대진 on 1/27/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class CustomSwitch: UIView {
    
    var onTap: ((Bool) -> Void)?
    private var isOn: Bool = false
    
    private let titleLabel = TDLabel().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
    }
    
    private let trackView = UIView().then {
        $0.backgroundColor = .grayScale200
        $0.layer.cornerRadius = 12
    }
    
    private let thumbView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    private let touchOverlay = UIView()

    init(title: String) {
        self.titleLabel.text = title
        super.init(frame: .zero)
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        flex.direction(.row).alignItems(.center).define {
            $0.addItem(titleLabel)
            
            $0.addItem().grow(1)
            
            $0.addItem(touchOverlay)
                .position(.relative)
                .width(64).height(44)
                .all(0)
                .define {
                    $0.addItem(trackView)
                        .position(.absolute)
                        .width(44).height(24)
                        .all(10)
                    
                    $0.addItem(thumbView)
                        .size(20)
                        .vertically(12)
                }
        }
        
    }
    
    func setSwitch(isOn: Bool) {
        self.isOn = isOn
        updateUI()
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSwitch))
        touchOverlay.addGestureRecognizer(tap)
    }

    private func layoutThumb() {
        let leftValue: CGFloat = isOn
        ? 64 - 20 - 12
            : 12
        self.thumbView.flex.left(leftValue).markDirty()
        UIView.animate(withDuration: 0.2) {
            self.flex.layout()
        }
    }
    
    private func updateUI() {
        trackView.backgroundColor = isOn ? .mainPurple : .grayScale200
        layoutThumb()
    }

    @objc func tapSwitch() {
        onTap?(isOn)
        updateUI()
    }
}
