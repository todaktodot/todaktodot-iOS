//
//  makeVoteButton.swift
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
            setupLayout()
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
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(icon)
        addSubview(title)
    }
    
    private func setupLayout() {
        if isScrolled {
//            UIView.animate(withDuration: 0.2) { [self] in
                self.pin
                    .size(48)
                
                layer.cornerRadius = 24
                
                icon.pin
                    .center()
                    .size(16)
                
                title.isHidden = true
//            }
        } else {
//            UIView.animate(withDuration: 0.2) { [self] in
                title.isHidden = false
                
                self.pin
                    .width(119)
                    .height(40)
                
                layer.cornerRadius = 20
                
                icon.pin
                    .left(16)
                    .vCenter()
                    .size(16)
                
                title.pin
                    .after(of: icon)
                    .marginLeft(2)
                    .right(16)
                    .vCenter()
                    .width(69)
                    .height(18)
//            }
        }
    }
}

