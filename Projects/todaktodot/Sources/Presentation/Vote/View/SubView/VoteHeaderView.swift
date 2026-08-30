//
//  VoteHeaderView.swift
//  todaktodot
//
//  Created by 임대진 on 8/19/26.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa
import Then
import ReactorKit

final class VoteHeaderView: UIView {

    let filterButton = VoteFilterButton()

    let latestButton = UIButton(type: .custom).then {
        $0.setTitle("최신순", for: .normal)
        $0.setTitleColor(.grayScale400, for: .normal)
        $0.setTitleColor(.grayScale900, for: .disabled)
        $0.titleLabel?.font = .pretenMedium(14)
        $0.isEnabled = false
    }

    let popularButton = UIButton(type: .custom).then {
        $0.setTitle("인기순", for: .normal)
        $0.setTitleColor(.grayScale400, for: .normal)
        $0.setTitleColor(.grayScale900, for: .disabled)
        $0.titleLabel?.font = .pretenMedium(14)
        $0.isEnabled = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        setupFlexLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        flex.layout()
    }
    
    private func setupFlexLayout() {
        self.flex
            .direction(.row)
            .alignItems(.center)
            .paddingHorizontal(20)
            .define {
                $0.addItem(filterButton)
                $0.addItem()
                    .grow(1)
                $0.addItem(latestButton)
                    .width(46)
                $0.addItem(popularButton)
                    .width(46)
            }
    }
    
    func updateSort(isLatest: Bool) {
        latestButton.isEnabled = !isLatest
        popularButton.isEnabled = isLatest
    }
}
