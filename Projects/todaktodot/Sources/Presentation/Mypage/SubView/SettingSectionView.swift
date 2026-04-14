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
import KakaoSDKTalk

final class SettingSectionView: UIView {
    private var disposeBag = DisposeBag()

    private let versionTitleLabel = TDLabel().then {
        $0.text = "버전 정보"
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
    }

    private let versionValueLabel = TDLabel().then {
        $0.text = "v \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")"
        $0.font = .pretenRegular(16)
        $0.textColor = .grayScale400
    }
    
    private let feedbackButton = ModalButton().then {
        $0.setTitle(title: "피드백 보내기")
    }
    
    let infoNotiSwitch = CustomSwitch(title: "정보성 알림")
    let advertiesmentNotiSwitch = CustomSwitch(title: "광고성 알림 수신 동의")
    let marketingNotiSwitch = CustomSwitch(title: "마케팅 수신 동의")
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
        feedbackButton.addTarget(self, action: #selector(feedbackTap(_:)), for: .touchUpInside)
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
        let rowHeight: CGFloat = 58

        flex.paddingHorizontal(20)
            .define {
                
                $0.addItem(serviceTermButton)
                    .height(rowHeight)

                $0.addItem(divider())
                    .height(1)
                    .marginHorizontal(-20)
                
                $0.addItem(feedbackButton)
                    .height(rowHeight)

                $0.addItem(divider())
                    .height(1)
                    .marginHorizontal(-20)

                $0.addItem(infoNotiSwitch)
                    .height(rowHeight)
                
                $0.addItem(divider()).height(1)
                    .marginHorizontal(-20)
                
                $0.addItem(advertiesmentNotiSwitch)
                    .height(rowHeight)
                
                $0.addItem(divider()).height(1)
                    .marginHorizontal(-20)
                
                $0.addItem(marketingNotiSwitch)
                    .height(rowHeight)
                
                $0.addItem(divider()).height(1)
                    .marginHorizontal(-20)

                $0.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .height(rowHeight)
                    .define {
                        $0.addItem(versionTitleLabel)
                        $0.addItem().grow(1)
                        $0.addItem(versionValueLabel)
                    }
            }
    }
    
    @objc private func feedbackTap(_ sender: UIButton) {
        TalkApi.shared.chatChannel(channelPublicId: "_kSidX") { _ in
        }
    }
}
