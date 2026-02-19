//
//  CoupleConnectViewController.swift
//  todaktodot
//
//  Created by 임대진 on 12/2/25.
//

import UIKit
import Then
import PinLayout
import FlexLayout
import RxSwift
import RxCocoa
import ReactorKit

final class CoupleConnectViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    weak var coordinator: SigninCoordinator?
    
    private let background = UIImageView().then {
        $0.image = UIImage(resource: .connectBackground)
    }
    
    private let scrollview = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
    }
    
    private let contentsView = UIView()
    
    private let codeInputView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .grayScale800.withAlphaComponent(0.95)
    }
    
    private let titleLabel = TDLabel().then {
        $0.text = "상대와 연결하기"
        $0.font = .pretenSemiBold(28)
        $0.textColor = .grayScale900
    }
    
    private let descriptionLabel1 = TDLabel().then {
        $0.text = "내 코드를 복사해서 상대방에게 보내거나\n상대방의 코드를 입력하세요"
        $0.font = .pretenRegular(16)
        $0.textColor = .grayScale800
        $0.numberOfLines = 0
    }
    
    private let descriptionLabel2 = TDLabel().then {
        $0.text = "둘 중 한 명만 상대의 코드를 입력하면 연결돼요 ☺️"
        $0.font = .pretenRegular(14)
        $0.textColor = .grayScale600
        $0.numberOfLines = 0
    }
    
    private let myCodeLabel = TDLabel().then {
        $0.text = "내 코드"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .grayScale800
    }
    
    private let partnerCodeLabel = TDLabel().then {
        $0.text = "상대 코드 입력"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .grayScale800
    }
    
    private let divideTextLabel = TDLabel().then {
        $0.text = "또는"
        $0.textAlignment = .center
        $0.font = .pretenSemiBold(12)
        $0.textColor = .grayScale600
        $0.backgroundColor = .white
    }
    
    private let myCodeTextField = CodeTextFieldView()
    private let partnerCodeTextField = CodeTextFieldView(isPartnerCode: true)
    
    private let copyButton = ImageTextButton(imageSize: 20).then {
        $0.customText.text = "복사하기"
        $0.customText.textColor = .mainPurple
        $0.customText.font = .pretenSemiBold(14)
        
        $0.customImage.image = UIImage(resource: .copy)
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.mainPurple.cgColor
    }
    
    private let connectButton = UIButton(type: .system).then {
        $0.setTitle("연결하기", for: .normal)
        $0.setTitleColor(.white, for: .disabled)

        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.tintColor = .white
        $0.backgroundColor = .grayScale400
        $0.layer.cornerRadius = 6
        $0.isEnabled = false
    }
    
    private let lookAroundButton = UIButton(type: .system).then {
        $0.setTitle("혼자 둘러볼게요", for: .normal)
        $0.titleLabel?.font = .pretenMedium(16)
        $0.tintColor = .grayScale600
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupFlexLayout()
        hideKeyboardwhenTappedAround()
        registerKeyboardNotification()
        
        if UserdefaultKey.couple {
            showConnectAlert()
        } else {
            reactor?.action.onNext(.checkIsJoined)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }

    // MARK: - Setup & Layout

    private func setupViews() {
        view.addSubview(background)
        view.addSubview(scrollview)
        view.addSubview(connectButton)
        view.addSubview(lookAroundButton)
        scrollview.addSubview(contentsView)
    }

    private func setupFlexLayout() {
        contentsView.flex.paddingHorizontal(20).define {
            $0.addItem(titleLabel)
                .marginTop(40)
            
            $0.addItem(descriptionLabel1)
                .marginTop(8)
            
            $0.addItem(descriptionLabel2)
                .marginTop(12)
            
            $0.addItem(codeInputView)
                .marginTop(40)
        }
        
        codeInputView.flex.paddingHorizontal(20).define {
            $0.addItem(myCodeLabel)
                .marginTop(20)
            
            $0.addItem(myCodeTextField)
                .marginTop(12)
            
            $0.addItem(copyButton)
                .marginTop(16)
                .alignSelf(.center)
            
            $0.addItem().define { flex in
                flex.addItem(dividerView)
                    .height(1)
                
                flex.addItem(divideTextLabel)
                    .alignSelf(.center)
                    .width(35)
                    .height(17)
                    .top(-8.5)
            }.marginTop(20)
            
            $0.addItem(partnerCodeLabel)
                .marginTop(20)
            
            $0.addItem(partnerCodeTextField)
                .marginTop(12)
                .marginBottom(24)
        }
    }

    private func layoutViews() {
        background.pin
            .all()
        
        scrollview.pin
            .top(view.pin.safeArea.top)
            .left()
            .right()
            .bottom()
        
        contentsView.pin
            .top()
            .horizontally()
        
        connectButton.pin
            .horizontally(20)
            .bottom(108)
            .height(52)
        
        lookAroundButton.pin
            .horizontally(20)
            .bottom(48)
            .height(52)
        
        contentsView.flex.layout(mode: .adjustHeight)
        
        scrollview.contentSize = contentsView.frame.size
    }
    
    func bind(reactor: CoupleReactor) {
        
        reactor.action.onNext(.issueCoupleCode)
        
        reactor.state
            .compactMap { $0.isAlreadyCouple }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showConnectAlert()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.mycode }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] code in
                guard let self = self else { return }
                self.myCodeTextField.setMyCodeStyle(code)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isJoined }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] joined in
                guard let self = self else { return }
                if !joined {
                    self.coordinator?.showTermsModal()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isCoupleConnectSuccess }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] success in
                guard let self = self else { return }
                if success {
                    showConnectAlert()
                } else {
                    showAlert(icon: UIImage(resource: .heart), title: "앗, 입력하신 코드가 올바르지 않아요", primaryButtonTitle: "다시 입력하기", primaryButtonAction: {})
                }
                     
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isMyCodeIssueFailed }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.coordinator?.navigateBack()
            })
            .disposed(by: disposeBag)
        
        copyButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                if let code = self?.myCodeTextField.getCode() {
                    UIPasteboard.general.string = code.uppercased()
                    self?.showToast(message: "복사가 완료되었습니다")
                }
            })
            .disposed(by: disposeBag)
        
        connectButton.rx.tap
            .map { CoupleReactor.Action.tapConnectButton(self.partnerCodeTextField.getCode().uppercased()) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        partnerCodeTextField.isCodeFull
            .subscribe(onNext: { [weak self] in
                self?.connectButton.backgroundColor = $0 ? .mainPurple : .grayScale400
                self?.connectButton.isEnabled = $0
            })
            .disposed(by: disposeBag)
        
        lookAroundButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.navigateToMain()
            })
            .disposed(by: disposeBag)
    }
    
    func showConnectAlert() {
        UserdefaultKey.couple = true
        
        showAlert(icon: UIImage(resource: .heart), title: "커플 연결 완료!", description: "이제 둘만의 대화를 시작할 수 있어요\n닉네임을 입력하러 가볼까요?", primaryButtonTitle: "확인", primaryButtonAction: {
            self.coordinator?.showNickname()
        })
    }
}

extension CoupleConnectViewController {
    private func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        let bottomInset =
            keyboardFrame.height
            - view.safeAreaInsets.bottom
            + 100
        UIView.animate(withDuration: 0.1) {
            self.scrollview.isScrollEnabled = true
            self.scrollview.contentInset.bottom = bottomInset
            
            self.scrollview.setContentOffset(
                CGPoint(x: 0, y: 60),
                animated: false
            )
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.1) {
            self.scrollview.contentInset.bottom = 0
            self.scrollview.verticalScrollIndicatorInsets.bottom = 0
            
            self.scrollview.setContentOffset(.zero, animated: false)
            self.scrollview.isScrollEnabled = false
        }
    }
}
