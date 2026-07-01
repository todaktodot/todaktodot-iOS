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
import RxRelay
import UserNotifications
import ReactorKit

enum LogoutType {
    case logout, disconnect, withdrawal, notAdult
}

final class MypageViewController: CustomBackViewController, View {
    var disposeBag = DisposeBag()
    weak var coordinator: MypageCoordinator?
    private var isCouple = PublishRelay<Bool>()
    private var coupleInfo: CoupleInfo?
    private var splitY: CGFloat = 226
    
    private let contentView = UIView()
    
    private let topBackgroundView = UIView().then {
        $0.backgroundColor = .subPurple
    }
    
    private let bottomBackgroundView = UIView().then {
        $0.backgroundColor = .lightPurple
    }
    
    private let topContentBackgroundView = UIView().then {
        $0.backgroundColor = .subPurple
    }
    
    private let bottomContentBackgroundView = UIView().then {
        $0.backgroundColor = .lightPurple
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
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
    
    private let indicatorView = UIActivityIndicatorView(style: .medium).then {
        $0.backgroundColor = .white
        $0.hidesWhenStopped = true
    }
    
    private let profileView = UIView().then {
        $0.flex.display(.none)
    }
    
    private let notYetConnectedView = DashedBorderView()
    private let ourInfoView = OurInfoView()
    private let heatmapContainerView = HeatmapContainerView()
    private let settingSectionView = SettingSectionView()
    
    private let myNicknameLabel = TDLabel().then {
        $0.font = .pretenSemiBold(18)
        $0.textColor = .grayScale900
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let partherNicknameLabel = TDLabel().then {
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
        bindAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateNicknameOrCoupleInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setupViews() {
        view.addSubview(topBackgroundView)
        view.addSubview(bottomBackgroundView)
        view.addSubview(scrollView)
        view.addSubview(indicatorView)
        
        scrollView.addSubview(topContentBackgroundView)
        scrollView.addSubview(bottomContentBackgroundView)
        
        scrollView.addSubview(heartImageView)
        scrollView.addSubview(contentView)
    }
    
    private func setupFlexLayout() {
        let topMargin: CGFloat = 28
        contentView.flex.define {
            $0.addItem(profileView)
            
            $0.addItem(notYetConnectedView)
                .marginTop(topMargin)
                .marginHorizontal(20)
            
            $0.addItem(heatmapContainerView)
                .marginTop(20)
                .marginHorizontal(20)
            
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
        
        profileView.flex.define {
            $0.addItem()
                .marginTop(topMargin)
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
                            $0.addItem(partherNicknameLabel)
                                .marginTop(4)
                        }
                }
            $0.addItem(ourInfoView)
                .marginTop(24)
                .marginHorizontal(20)
        }
    }
    
    private func layoutViews() {
        topBackgroundView.pin
            .top()
            .horizontally()
            .height(50%)
        
        bottomBackgroundView.pin
            .horizontally()
            .bottom()
            .height(50%)
        
        scrollView.pin
            .top(view.pin.safeArea.top)
            .horizontally()
            .bottom()
        
        contentView.pin
            .top()
            .horizontally()
        
        indicatorView.pin
            .all()
        
        heartImageView.pin
            .top(52)
            .hCenter()
            .height(24)
            .width(64)
        
        contentView.flex.layout(mode: .adjustHeight)
        
        updateSplitY()
        topContentBackgroundView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: splitY)
        bottomContentBackgroundView.frame = CGRect(x: 0, y: splitY, width: contentView.bounds.width, height: contentView.bounds.height - splitY)
        
        scrollView.contentSize = contentView.frame.size
    }
    
    func bind(reactor: MyPageReactor) {
        reactor.action.onNext(.fetchInfo)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    self.indicatorView.startAnimating()
                } else {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.indicatorView.alpha = 0
                    }, completion: { _ in
                        self.indicatorView.stopAnimating()
                    })
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.info }
            .take(1)
            .subscribe(onNext: { [weak self] info in
                guard let self = self else { return }
                if info.isCouple {
                    let todayYear = Calendar.current.component(.year, from: Date())
                    fetchHeatmap(year: todayYear, endDate: Date().toYYYYMMDD())
                }
                
                coupleInfo = info.coupleInfo
                setMypageInfo(info)
                isCouple.accept(info.isCouple)
                settingSectionView.infoNotiSwitch.setSwitch(isOn: info.infoAgree)
                settingSectionView.advertiesmentNotiSwitch.setSwitch(isOn: info.advertAgree)
                settingSectionView.marketingNotiSwitch.setSwitch(isOn: info.marketingAgree)
                layoutViews()
                
                if UserdefaultKey.coupleType == .connected && info.myNickname.isEmpty {
                    NotificationCenter.default.post(name: .connectionCompleteAndGoToNickname, object: nil)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.heatmap }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] heatmap in
                guard let self = self else { return }
                heatmapContainerView.configure(heatmap: heatmap)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isLogout }
            .filter { $0 }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                UserdefaultKey.isLoggedIn = false
                UserdefaultKey.resetAuthUserDefaults()
                self.coordinator?.showSigninFlow(alertType: .logout)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isDisconnectCouple }
            .filter { $0 }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                UserdefaultKey.resetUserDefaults()
                self.coordinator?.showSigninFlow(alertType: .disconnect)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isWithdrawal }
            .filter { $0 }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                UserdefaultKey.resetUserDefaults()
                self.coordinator?.showSigninFlow(alertType: .withdrawal)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isInfoNotice }
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] isOn in
                guard let self = self else { return }
                settingSectionView.infoNotiSwitch.setSwitch(isOn: isOn)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isAdvertNoti }
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] isOn in
                guard let self = self else { return }
                showToast(message: "광고성 알림 수신에 \(isOn ? "동의" : "거부")하셨습니다.(\(Date().toDot()))")
                settingSectionView.advertiesmentNotiSwitch.setSwitch(isOn: isOn)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isMarketingNoti }
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] isOn in
                guard let self = self else { return }
                showToast(message: "마케팅 알림 수신에 \(isOn ? "동의" : "거부")하셨습니다.(\(Date().toDot()))")
                settingSectionView.marketingNotiSwitch.setSwitch(isOn: isOn)
            })
            .disposed(by: disposeBag)
        
        isCouple
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if !$0 { heartImageView.removeFromSuperview() }
                profileView.flex.display($0 ? .flex : .none)
                notYetConnectedView.flex.display($0 ? .none : .flex)
                
                if !$0 {
                    [topBackgroundView, bottomBackgroundView, topContentBackgroundView, bottomContentBackgroundView].forEach {
                        $0.removeFromSuperview()
                    }
                    view.backgroundColor = .lightPurple
                }
                
                contentView.flex.layout(mode: .adjustHeight)
                scrollView.contentSize = contentView.frame.size
            })
            .disposed(by: disposeBag)
        
        heatmapContainerView.displayYear
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] year in
                guard let self else { return }
                if year == Calendar.current.component(.year, from: Date()) {
                    fetchHeatmap(year: year, endDate: Date().toYYYYMMDD())
                } else {
                    fetchHeatmap(year: year, startDate: "\(year)-01-01", endDate: "\(year)-12-31")
                }
            })
            .disposed(by: disposeBag)
        
        coupleDisconnectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAlert(icon: UIImage(resource: .warning), title: "정말 커플 연결을 해제하시겠어요?", description: "즉시 연결이 해제되며\n그동안 작성하신 기록은 모두 삭제되어\n되돌릴 수 없으니 신중히 결정해주세요",primaryButtonTitle: "커플 해제", primaryButtonAction: {
                    reactor.action.onNext(.tapDisconnectCouple)
                }, secondaryButtonTitle: "취소")
                
            })
            .disposed(by: disposeBag)
        
        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAlert(icon: UIImage(resource: .warning), title: "로그아웃 시 서비스 사용이\n제한돼요. 그래도 로그아웃할까요?", primaryButtonTitle: "로그아웃", primaryButtonAction: {
                    reactor.action.onNext(.tapLogout)
                }, secondaryButtonTitle: "취소")
                
            })
            .disposed(by: disposeBag)
        
        withdrawalButton.rx.tap
            .subscribe(onNext: { [weak self] in
                
                self?.showAlert(icon: UIImage(resource: .warning), title: "계정 탈퇴 시 서비스 사용이\n제한돼요. 그래도 탈퇴할까요?", primaryButtonTitle: "탈퇴", primaryButtonAction: {
                    reactor.action.onNext(.tapWitdrawal)
                }, secondaryButtonTitle: "취소")
                
            })
            .disposed(by: disposeBag)
        
        notYetConnectedView.connectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showCoupleConnect()
            })
            .disposed(by: disposeBag)
        
        nicknameEditButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showNickname(nickname: self?.myNicknameLabel.text ?? nil)
            })
            .disposed(by: disposeBag)
        
        ourInfoView.settingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showCoupleInfo(info: self?.coupleInfo)
            })
            .disposed(by: disposeBag)
        
        settingSectionView.serviceTermButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showTerms()
            })
            .disposed(by: disposeBag)
        
        settingSectionView.infoNotiSwitch.onTap = { [weak self] isOn in
            guard let self else { return }
            if isOn {
                showAlert(icon: UIImage(resource: .warning), title: "푸시 알림을 끄시겠어요?", description: "•  상대방이 답변해도 바로 알 수 없어요\n•  서로의 답변이 공개되도 알 수 없어요\n•  상대방의 쿡 찌르기를 받을 수 없어요", primaryButtonTitle: "알림 유지하기", primaryButtonAction: {}, secondaryButtonTitle: "알림 끄기", secondaryButtonAction: {
                    reactor.action.onNext(.tapInfoNoti(false))
                })
            } else {
                reactor.action.onNext(.tapInfoNoti(true))
            }
        }
        
        settingSectionView.advertiesmentNotiSwitch.onTap = { [weak self] isOn in
            guard let self else { return }
            if isOn {
                showNotiDisabledAlert {
                    reactor.action.onNext(.tapAdvertNoti(false))
                }
            } else {
                reactor.action.onNext(.tapAdvertNoti(true))
            }
        }
        
        settingSectionView.marketingNotiSwitch.onTap = { [weak self] isOn in
            guard let self else { return }
            if isOn {
                showNotiDisabledAlert {
                    reactor.action.onNext(.tapMarketingNoti(false))
                }
            } else {
                reactor.action.onNext(.tapMarketingNoti(true))
            }
        }
    }
    
    private func bindAction() {
        heatmapContainerView.infoButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                let popup = HeatmapPopupView()
                popup.alpha = 0
                view.addSubview(popup)
                
                popup.flex.layout()
                
                let frame = heatmapContainerView.convert(heatmapContainerView.bounds, to: view)
                
                popup.pin
                    .top(frame.minY)
                    .hCenter()
                
                UIView.animate(withDuration: 0.25) {
                    popup.alpha = 1
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchHeatmap(year: Int, startDate: String? = nil, endDate: String) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let startOfYear = Calendar.current.date(
            from: DateComponents(year: year, month: 1, day: 1)
        )!

        let result = formatter.string(from: startOfYear)

        reactor?.action.onNext(
            .fetchHeatmap(startDate ?? result, endDate)
        )
    }
    
    private func showNotiDisabledAlert(action: @escaping (() -> Void)) {
        showAlert(icon: UIImage(resource: .warning), title: "알림 수신을 중단할까요?", description: "혜택이나 중요한 안내를 놓칠 수 있어요.", primaryButtonTitle: "그대로 둘게요", primaryButtonAction: {}, secondaryButtonTitle: "알림 끄기", secondaryButtonAction: action)
    }
    
    private func setMypageInfo(_ info: MypageInfo) {
        myNicknameLabel.text = info.myNickname
        partherNicknameLabel.text = info.partnerNickname
        ourInfoView.setOurInfo(info: info.coupleInfo)
        
        myNicknameLabel.flex.markDirty()
        partherNicknameLabel.flex.markDirty()
        
        contentView.flex.layout()
    }
    
    private func updateNicknameOrCoupleInfo() {
        coordinator?.onNicknameUpdated = { [weak self] newNickname in
            guard let self = self else { return }
            myNicknameLabel.text = newNickname
            myNicknameLabel.flex.markDirty()
            
            updateSplitY()
            layoutViews()
        }
        
        coordinator?.onCoupleInfoUpdated = { [weak self] info in
            self?.ourInfoView.setOurInfo(info: info)
            self?.coupleInfo = info
        }
        
        contentView.flex.layout()
    }
    
    private func updateSplitY() {
        if let name = myNicknameLabel.text, name.count > 8 {
            splitY = 226 + 28
        } else {
            splitY = 226
        }
    }
}

extension MypageViewController: CustomBackViewControllerDelegate {
    func navigateBack() {
        coordinator?.navigateBack()
    }
}

extension MypageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
