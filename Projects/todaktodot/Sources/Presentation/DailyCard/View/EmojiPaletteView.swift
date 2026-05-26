//
//  EmojiPaletteView.swift
//  todaktodot
//
//  Created by daye on 5/26/26.
//

import UIKit

final class EmojiPaletteView: UIView {
    
    var onEmojiSelected: ((EmojiType) -> Void)?
    var onEmojiDeleted: (() -> Void)?
    private var currentSelectedEmoji: EmojiType?
    
    private let emojiTypes: [EmojiType] = [.good, .heart, .surprise, .cry, .angry, .poop]
    private var emojiButtons: [UIButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 30
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: "E0D3F1").cgColor
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        for (index, type) in emojiTypes.enumerated() {
            let button = UIButton().then {
                $0.setImage(UIImage(named: type.imageName), for: .normal)
                $0.imageView?.contentMode = .scaleAspectFit
                $0.tag = index
                $0.addTarget(self, action: #selector(emojiTapped(_:)), for: .touchUpInside)
            }
            emojiButtons.append(button)
            stackView.addArrangedSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 44),
                button.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 60),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private var selectedDot: UIView?
    
    func showWithJumpAnimation(selectedEmoji: EmojiType? = nil) {
        isHidden = false
        currentSelectedEmoji = selectedEmoji
        
        // 기존 dot 제거
        selectedDot?.removeFromSuperview()
        selectedDot = nil
        
        // 선택된 이모지 아래에 dot 표시
        if let selected = selectedEmoji,
           let index = emojiTypes.firstIndex(of: selected) {
            let dot = UIView().then {
                $0.backgroundColor = .mainPurple
                $0.layer.cornerRadius = 2
            }
            let button = emojiButtons[index]
            button.addSubview(dot)
            dot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 4),
                dot.heightAnchor.constraint(equalToConstant: 4),
                dot.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                dot.bottomAnchor.constraint(equalTo: button.bottomAnchor)
            ])
            selectedDot = dot
        }
        
        for (index, button) in emojiButtons.enumerated() {
            button.alpha = 1
            button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            let delay = Double(index) * 0.03
            UIView.animate(
                withDuration: 0.15,
                delay: delay,
                options: .curveEaseOut
            ) {
                button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseIn) {
                    button.transform = .identity
                }
            }
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
            self.alpha = 1
        }
    }
    
    @objc private func emojiTapped(_ sender: UIButton) {
        let type = emojiTypes[sender.tag]
        if type == currentSelectedEmoji {
            onEmojiDeleted?()
        } else {
            onEmojiSelected?(type)
        }
        dismiss()
    }
}
