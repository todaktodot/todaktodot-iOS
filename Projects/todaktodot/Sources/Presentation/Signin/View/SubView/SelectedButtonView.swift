//
//  SelectedButtonView.swift
//  todaktodot
//
//  Created by 임대진 on 12/12/25.
//

import UIKit
import RxSwift
import RxRelay
import FlexLayout
import PinLayout

final class SelectedButtonView: UIView {

    private let root = UIView()
    private let buttons: [UIButton]
    private let disposeBag = DisposeBag()

    let isSelected = BehaviorRelay<Bool>(value: false)

    override init(frame: CGRect) {
        let items = ["❤️ 연애중이예요", "🏠 동거중이예요", "💝 결혼 준비중이에요", "👩‍❤️‍👨 신혼이에요", "💍 부부에요"]

        buttons = items.enumerated().map { index, item in
            
            let btn = PaddingButton(text: item)
            btn.tag = index
            
            return btn
        }

        super.init(frame: frame)
        setupUI()
        bind()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(root)

        root.flex.direction(.column).gap(12).define { flex in
            buttons.forEach { btn in
                flex.addItem(btn).height(56)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        root.pin.all()
        root.flex.layout()
    }

    private func bind() {
        let mergedTap = Observable.merge(
            buttons.map { btn in btn.rx.tap.map { btn.tag } }
        )

        mergedTap
            .subscribe(onNext: { [weak self] index in
                self?.updateUI(index)
                self?.isSelected.accept(true)
            })
            .disposed(by: disposeBag)
    }

    private func updateUI(_ index: Int) {
        for (i, btn) in buttons.enumerated() {
            if i == index {
                let btn = btn as? PaddingButton
                btn?.textLabel.textColor = .mainPurple
                btn?.layer.borderWidth = 1
                btn?.layer.borderColor = UIColor.mainPurple.cgColor
            } else {
                let btn = btn as? PaddingButton
                btn?.textLabel.textColor = .grayScale900
                btn?.layer.borderWidth = 0
            }
        }
    }
}
