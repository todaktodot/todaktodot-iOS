//
//  MypageViewContorller.swift
//  todaktodot
//
//  Created by 임대진 on 1/24/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout

final class MypageViewContorller: CustomBackViewController {
    weak var coordinator: MypageCoordinator?
    private let contentView = UIView()
    private let infoContainerView = UIView().then {
        $0.backgroundColor = .mainPurple
        $0.layer.cornerRadius = 16
    }
    
    private let settingContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let backgroundView = UIImageView().then {
        $0.image = UIImage(resource: .mypageBackground)
    }
    
    private let myImageView = UIImageView().then {
        $0.image = UIImage(resource: .me)
        $0.contentMode = .scaleAspectFit
    }
    
    private let heartImageView = UIImageView().then {
        $0.image = UIImage(resource: .mypageHeart)
        $0.contentMode = .scaleAspectFit
    }
    
    private let partnerImageView = UIImageView().then {
        $0.image = UIImage(resource: .partner)
        $0.contentMode = .scaleAspectFit
    }
    
    private let myNicknameLabel = TDLabel().then {
        $0.text = "내닉네임"
        $0.font = .pretenSemiBold(18)
        $0.textColor = .grayScale900
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let partherNinameLabel = TDLabel().then {
        $0.text = "연인닉네임들어갑니다"
        $0.font = .pretenSemiBold(18)
        $0.textColor = .grayScale900
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let nicknameEditButton = ImageTextButton(horizonPadding: 8, verticalPadding: 4, spacing: 2, imageSize: 12, imageFirst: false).then {
        $0.customText.text = "닉네임 수정"
        $0.customText.font = .pretenMedium(12)
        $0.customText.textColor = .grayScale600
        
        $0.customImage.image = UIImage(resource: .pencil)
        $0.customImage.tintColor = .grayScale600
        
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 13
    }
    
    private let coupleDisconnectButton = UIButton().then {
        $0.setTitle("커플 해제", for: .normal)
        $0.titleLabel?.font = .pretenRegular(16)
        $0.setTitleColor(.grayScale600, for: .normal)
    }
    
    private let logoutButton = UIButton().then {
        $0.setTitle("로그 아웃", for: .normal)
        $0.titleLabel?.font = .pretenRegular(16)
        $0.setTitleColor(.grayScale600, for: .normal)
    }
    
    private let withdrawalButton = UIButton().then {
        $0.setTitle("계정 탈퇴", for: .normal)
        $0.titleLabel?.font = .pretenRegular(16)
        $0.setTitleColor(.grayScale600, for: .normal)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        title = "마이페이지"
        
        setupViews()
        setupFlexLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(contentView)
        view.addSubview(heartImageView)
    }
    
    private func setupFlexLayout() {
        contentView.flex.define {
            $0.addItem()
                .marginTop(28)
                .gap(11)
                .direction(.row)
                .alignItems(.start)
                .justifyContent(.center)
                .define {
                    $0.addItem()
                        .width(140)
                        .alignItems(.center)
                        .define {
                            $0.addItem(myImageView)
                            $0.addItem(myNicknameLabel)
                                .marginTop(4)
                            $0.addItem(nicknameEditButton)
                                .marginTop(4)
                        }
                    
                    $0.addItem()
                        .width(140)
                        .alignItems(.center)
                        .define {
                            $0.addItem(partnerImageView)
                            $0.addItem(partherNinameLabel)
                                .marginTop(4)
                        }
                }
            $0.addItem(infoContainerView)
                .marginTop(24)
                .height(167)
                .marginHorizontal(20)
            
            $0.addItem(settingContainerView)
                .marginTop(20)
                .height(170)
                .marginHorizontal(20)
            
            $0.addItem()
                .marginTop(20)
                .marginHorizontal(20)
                .direction(.row)
                .alignItems(.center)
                .justifyContent(.spaceEvenly)
                .define {
                    $0.addItem(coupleDisconnectButton)
                    
                    $0.addItem()
                        .width(1)
                        .height(10)
                        .backgroundColor(.grayScale900.withAlphaComponent(0.15))
                    
                    $0.addItem(logoutButton)
                    
                    $0.addItem(UIView())
                        .width(1)
                        .height(10)
                        .backgroundColor(.grayScale900.withAlphaComponent(0.15))
                    
                    $0.addItem(withdrawalButton)
                }
        }
    }
    
    private func layoutViews() {
        backgroundView.pin
            .all()
        
        contentView.pin
            .top(view.pin.safeArea)
            .horizontally()
            .bottom()
        
        heartImageView.pin
            .top(view.pin.safeArea + 52)
            .hCenter()
            .height(24)
            .width(64)
        
        contentView.flex.layout()
    }
}

extension MypageViewContorller: CustomBackViewControllerDelegate {
    func navigateBack() {
        coordinator?.navigateBack()
    }
}
