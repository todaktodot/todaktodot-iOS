//
//  MakeVoteButton.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class MakeVoteButton: UIButton {
    var isScrolled: Bool = false {
        didSet {
            updateLayout()
        }
    }
    
    private let icon = UIImageView().then {
        $0.image = UIImage(resource: .plus)
    }
    
    private let title = UILabel().then {
        $0.text = "투표 만들기"
        $0.textColor = .white
        $0.font = UIFont.pretenSemiBold(15)
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .mainPurple
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(icon)
        addSubview(title)
    }
    
    private func updateLayout() {
        let isExpanded = !isScrolled
        let maximumX = frame.maxX
        let maximumY = frame.maxY

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut]
        ) { [self] in
            let size = isExpanded ? CGSize(width: 119, height: 40) : CGSize(width: 48, height: 48)
            frame = CGRect(x: maximumX - size.width, y: maximumY - size.height, width: size.width, height: size.height)
            layer.cornerRadius = size.height / 2

            if isExpanded {
                icon.pin.left(16).vCenter().size(16)
                title.pin.after(of: icon).marginLeft(2).right(16).vCenter().width(69).height(18)
            } else {
                icon.pin.center().size(16)
            }
        } completion: { [weak self] _ in
            guard let self else { return }
            self.title.isHidden = !isExpanded
        }
    }
}
