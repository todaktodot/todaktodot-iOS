//
//  VoteFilterButton.swift
//  todaktodot
//
//  Created by 임대진 on 8/19/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class VoteFilterButton: UIButton {
    
    private let sliderView = UIImageView().then {
        $0.image = UIImage(resource: .slider)
    }
    
    private let nameLabel = UILabel().then {
        $0.text = "필터"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale700
    }
    
    private let countLabel = UILabel().then {
        $0.font = .pretenSemiBold(10)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.backgroundColor = .mainPurple
        $0.clipsToBounds = true
        $0.text = "\(2)"
    }
    var temp = true
    
    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayScale200.cgColor
        
        setupFlexLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFlexLayout() {
        self.flex
            .direction(.row)
            .alignItems(.center)
            .padding(8)
            .define {
                $0.addItem(sliderView)
                    .size(16)
                $0.addItem(nameLabel)
                    .marginLeft(2)
                $0.addItem(countLabel)
                    .marginLeft(2)
                    .size(16)
                    .cornerRadius(8)
            }
        
        countLabel.flex.display(.none)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func updateFilter() {
        temp.toggle()
        if temp {
            backgroundColor = .white
            layer.borderColor = UIColor.grayScale200.cgColor
            nameLabel.textColor = .grayScale700
            sliderView.image = UIImage(resource: .slider)
            
            countLabel.flex.display(.none)
        } else {
            countLabel.text = "\(2)"
            backgroundColor = .lightPurple
            layer.borderColor = UIColor.mainPurple.cgColor
            nameLabel.textColor = .mainPurple
            sliderView.image = UIImage(resource: .sliderPurple)
            
            countLabel.flex.display(.flex)
        }
    }
}
