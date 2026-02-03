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

enum CoupleStage: String, CaseIterable, Codable{
    case dating = "DATING"
    case living = "LIVING_TOGETHER"
    case engaged = "PREPARING_MARRIAGE"
    case newlywed = "NEWLYWED"
    case married = "MARRIED"

    var title: String {
        switch self {
        case .dating: return "❤️ 연애중이예요"
        case .living: return "🏠 동거중이예요"
        case .engaged: return "💝 결혼 준비중이에요"
        case .newlywed: return "👩‍❤️‍👨 신혼이에요"
        case .married: return "💍 부부에요"
        }
    }
}

final class CoupleStepSelectView: UIView {

    private let root = UIView()
    private let buttons: [UIButton]
    private let disposeBag = DisposeBag()

    let isSelected = BehaviorRelay<CoupleStage?>(value: nil)
    
    override init(frame: CGRect) {

        buttons = CoupleStage.allCases.enumerated().map { index, step in
            
            let btn = PaddingButton(text: step.title)
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
                self?.isSelected.accept(CoupleStage.allCases[index])
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
