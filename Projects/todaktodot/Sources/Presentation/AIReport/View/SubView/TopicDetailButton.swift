//
//  TopicDetailButton.swift
//  todaktodot
//
//  Created by 임대진 on 1/23/26.
//

import UIKit

import UIKit
import Then
import FlexLayout
import PinLayout

class TopicDetailButton: UIButton {
    private let dateLabel = TDLabel().then {
        $0.font = .pretenSemiBold(16)
        $0.textColor = .grayScale900
    }
    
    private let topicLabel = TDLabel().then {
        $0.font = .pretenRegular(14)
        $0.textColor = .grayScale800
    }
    
    private let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right")).then {
        $0.tintColor  = .grayScale800
    }

    init(frame: CGRect = .zero, date: String, topic: String) {
        
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 16
        self.dateLabel.text = date
        self.topicLabel.text = topic
        
        setupFlexLayout()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFlexLayout() {
        self.flex.direction(.row).alignItems(.center).paddingHorizontal(20).paddingVertical(15).define {
            $0.addItem(dateLabel)
            
            $0.addItem(topicLabel)
                .marginLeft(12)
            
            $0.addItem().grow(1)
            
            $0.addItem(chevronImageView)
        }
    }
    
    private func layoutViews() {
        self.flex.layout()
    }
}

