//
//  VoteEmptyCell.swift
//  todaktodot
//
//  Created by 임대진 on 8/30/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then
import RxSwift

final class VoteEmptyCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    var onTapMake: (() -> Void)?
    static let identifier = "VoteEmptyCell"
    
    private let icon = UIImageView().then {
        $0.image = UIImage(resource: .voteEmpty)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "아직 올린 투표가 없어요"
        $0.textColor = .grayScale900
        $0.font = .pretenSemiBold(18)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "궁금했던걸 다른 커플들에게 물어보세요"
        $0.textColor = .grayScale600
        $0.font = .pretenRegular(14)
    }
    
    private let makeButton = UIButton().then {
        $0.setTitle("투표 만들기", for: .normal)
        $0.setTitleColor(.mainPurple, for: .normal)
        $0.layer.cornerRadius = 6
        $0.layer.borderColor = UIColor.mainPurple.cgColor
        $0.layer.borderWidth = 1
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupFlexLayout()
        
        makeButton.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.flex.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupFlexLayout() {
        contentView.flex
            .alignItems(.center)
            .justifyContent(.center)
            .define {
                $0.addItem(icon)
                    .size(64)
                
                $0.addItem(titleLabel)
                    .marginTop(4)
                    .height(25)
                
                $0.addItem(descriptionLabel)
                    .marginTop(4)
                    .height(20)
                
                $0.addItem(makeButton)
                    .margin(16)
                    .width(128)
                    .height(44)
            }
    }
    
    @objc private func onTapButton() {
        onTapMake?()
    }
}
