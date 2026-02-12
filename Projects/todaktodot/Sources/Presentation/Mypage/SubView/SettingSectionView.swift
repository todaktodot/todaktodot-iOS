//
//  SettingSectionView.swift
//  todaktodot
//
//  Created by 임대진 on 1/27/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then
import RxSwift

final class SettingSectionView: UIView {
    private var disposeBag = DisposeBag()

    private let pushTitleLabel = TDLabel().then {
        $0.text = "푸시 알림"
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
    }

    private let versionTitleLabel = TDLabel().then {
        $0.text = "버전 정보"
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
    }

    private let versionValueLabel = TDLabel().then {
        $0.text = "v 1.0.0"
        $0.font = .pretenRegular(16)
        $0.textColor = .grayScale400
    }
    
    let notiSwitch = CustomSwitch()
    let serviceTermButton = ModalButton().then {
        $0.setTitle(title: "서비스 이용 약관")
    }

    private func divider() -> UIView {
        UIView().then {
            $0.backgroundColor = UIColor.grayScale200
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 16
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16

        flex.paddingHorizontal(20)
            .paddingVertical(16)
            .gap(16)
            .define {
                
                $0.addItem(serviceTermButton)

                $0.addItem(divider())
                    .height(1)
                    .marginHorizontal(-20)

                $0.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .define {
                        $0.addItem(pushTitleLabel)
                        $0.addItem().grow(1)
                        $0.addItem(notiSwitch)
                    }

                $0.addItem(divider()).height(1)
                    .marginHorizontal(-20)

                $0.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .define {
                        $0.addItem(versionTitleLabel)
                        $0.addItem().grow(1)
                        $0.addItem(versionValueLabel)
                    }
            }
    }
}
