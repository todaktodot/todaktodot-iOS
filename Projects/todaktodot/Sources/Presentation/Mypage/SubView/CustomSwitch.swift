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

    private var isOn: Bool
    private let thumbView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }

    var onTap: ((Bool) -> Void)?

    init(isOn: Bool = false) {
        self.isOn = isOn
        super.init(frame: .zero)
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutThumb()
    }

    private func setupUI() {
        flex.width(44).height(24).define { flex in
            flex.addItem(thumbView)
                .size(20)
                .left(2)
                .vertically(2)
        }

        self.backgroundColor = isOn ? .mainPurple : .grayScale200
        self.layer.cornerRadius = 12
    }

    private func layoutThumb() {
        let x: CGFloat = isOn
            ? bounds.width - 20 - 2
            : 2

        let apply = {
            self.thumbView.frame.origin.x = x
        }
        UIView.animate(withDuration: 0.2, animations: apply)
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSwitch))
        addGestureRecognizer(tap)
    }
    
    private func updateUI() {
        backgroundColor = isOn ? .mainPurple : .grayScale200
        layoutThumb()
    }
    
    func toggleSwitch() {
        isOn.toggle()
        updateUI()
    }

    @objc func tapSwitch() {
        onTap?(isOn)
    }
}
