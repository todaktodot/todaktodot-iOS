//
//  MypageViewController.swift
//  todaktodot
//
//  Created by 임대진 on 1/24/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxSwift

final class MypageViewController: CustomBackViewController {
    weak var coordinator: MypageCoordinator?
    private var disposeBag = DisposeBag()
    private var connected = true
    
    private let contentView = UIView()
    
    private let backgroundView = UIImageView()
    
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
    
    private let notYetConnectedView = DashedBorderView()
    private let ourInfoView = OurInfoView()
    private let settingSectionView = SettingSectionView()
    
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
        $0.setTitle("로그아웃", for: .normal)
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
        bindActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(contentView)
        view.addSubview(heartImageView)
        
        backgroundView.image = UIImage(resource: connected ? .mypageBackground : .mypageSubBackground)
    }
    
    private func setupFlexLayout() {
        contentView.flex.define {
            if connected {
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
                $0.addItem(ourInfoView)
                    .marginTop(24)
                    .marginHorizontal(20)
            } else {
                $0.addItem(notYetConnectedView)
                    .marginTop(28)
                    .marginHorizontal(20)
            }
            
            $0.addItem(settingSectionView)
                .marginTop(20)
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
        
        if connected {
            heartImageView.pin
                .top(view.pin.safeArea + 52)
                .hCenter()
                .height(24)
                .width(64)
        }
        
        contentView.flex.layout()
    }
    
    private func bindActions() {
        coupleDisconnectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAlert(icon: UIImage(resource: .warning), title: "정말 커플 연결을 해제하시겠어요?", description: "즉시 연결이 해제되며\n그동안 작성하신 기록은 모두 삭제되어\n되돌릴 수 없으니 신중히 결정해주세요",primaryButtonTitle: "커플 해제", primaryButtonAction: {
                    self?.showAlert(icon: UIImage(resource: .check), title: "정상적으로 커플 연결이 해제됐어요\n다시 로그인이 필요해요", primaryButtonTitle: "확인", primaryButtonAction: {})
                    self?.coordinator?.showSigninFlow()
                }, secondaryButtonTitle: "취소")
                
            })
            .disposed(by: disposeBag)
        
        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAlert(icon: UIImage(resource: .warning), title: "로그아웃 시 서비스 사용이\n제한돼요. 그래도 로그아웃할까요?", primaryButtonTitle: "로그아웃", primaryButtonAction: {
                    self?.showAlert(icon: UIImage(resource: .check), title: "정상적으로 로그아웃 되었어요", primaryButtonTitle: "확인", primaryButtonAction: {})
                    self?.coordinator?.showSigninFlow()
                }, secondaryButtonTitle: "취소")
                
            })
            .disposed(by: disposeBag)
        
        withdrawalButton.rx.tap
            .subscribe(onNext: { [weak self] in
                
                self?.showAlert(icon: UIImage(resource: .warning), title: "계정 탈퇴 시 서비스 사용이\n제한돼요. 그래도 탈퇴할까요?", primaryButtonTitle: "탈퇴", primaryButtonAction: {
                    self?.showAlert(icon: UIImage(resource: .check), title: "정상적으로 탈퇴 되었어요", primaryButtonTitle: "확인", primaryButtonAction: {})
                    self?.coordinator?.showSigninFlow()
                }, secondaryButtonTitle: "취소")
                
            })
            .disposed(by: disposeBag)
        
        nicknameEditButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showNickname()
            })
            .disposed(by: disposeBag)
        
        ourInfoView.settingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showCoupleInfo()
            })
            .disposed(by: disposeBag)
        
        settingSectionView.arrowButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showTerms()
            })
            .disposed(by: disposeBag)
        
        settingSectionView.notiSwitch.onTap = { [weak self] isOn in
            guard let self else { return }
            if isOn {
                showAlert(icon: UIImage(resource: .warning), title: "푸시 알림을 끄시겠어요?", description: "•  상대방이 답변해도 바로 알 수 없어요\n•  서로의 답변이 공개되도 알 수 없어요\n•  상대방의 쿡 찌르기를 받을 수 없어요", primaryButtonTitle: "알림 유지하기", primaryButtonAction: {}, secondaryButtonTitle: "알림 끄기", secondaryButtonAction: {
                    self.settingSectionView.notiSwitch.toggleSwitch()
                })
            } else {
                settingSectionView.notiSwitch.toggleSwitch()
            }
        }
    }
}

extension MypageViewController: CustomBackViewControllerDelegate {
    func navigateBack() {
        coordinator?.navigateBack()
    }
}
