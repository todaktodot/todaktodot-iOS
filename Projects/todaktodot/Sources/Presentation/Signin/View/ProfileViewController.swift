//
//  ProfileViewController.swift
//  todaktodot
//
//  Created by 임대진 on 12/9/25.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxSwift
import RxRelay
import ReactorKit

final class ProfileViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    weak var coordinator: SigninCoordinator?
    
    private var isNicknameEdit: Bool
    private var currentStep: CoupleReactor.NicknameViewStep?
    private var isTappedGenderButton = false
    
    private let contentsView = UIView()
    private let backgroundView = UIImageView().then {
        $0.image = UIImage(resource: .connectBackground)
    }
    
    private let titleLabel = TDLabel().then {
        $0.text = "닉네임을 알려주세요"
        $0.font = .pretenSemiBold(28)
        $0.textColor = .grayScale900
    }
    
    private let nicknameTextField = UITextField().then {
        $0.placeholder = "글자 수는 1~10자까지 입력 가능해요"
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
        $0.backgroundColor = .white
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .always
        
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grayScale200.cgColor
    }
    
    private let textFiledDescriptionLabel = TDLabel().then {
        $0.text = "한글, 영어, 숫자, 이모지 모두 사용 가능해요!(최대 10자)"
        $0.font = .pretenMedium(12)
        $0.textColor = .grayScale600
    }
    
    private let genderButtonStackVIew = UIView().then {
        $0.alpha = 0
    }
    
    private let dateTextFieldView = DateTextFieldView().then {
        $0.alpha = 0
    }
    
    private let maleButton = GenderButton(gender: .male)
    private let femaleButton = GenderButton(gender: .female)
    
    private let nextButton = UIButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.white, for: .disabled)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.backgroundColor = .grayScale400
        $0.layer.cornerRadius = 6
        $0.isEnabled = false
        $0.isHidden = true
    }
    
    private let checkIcon = UIImageView().then {
        $0.image = UIImage(resource: .nicknameCheckIcon)
    }
    
    private let iconTextSpacingView = UIView()
    
    init(isNicknameEdit: Bool, nickname: String? = nil) {
        self.isNicknameEdit = isNicknameEdit

        if let nickname {
            nicknameTextField.text = nickname
        }
        super.init(nibName: nil, bundle: nil)
        
        dateTextFieldView.flex.display(.none)
        genderButtonStackVIew.flex.display(.none)
        checkIcon.flex.display(.none)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenBackButton()
        nicknameTextField.delegate = self
        setupViews()
        setupFlexLayout()
        
        if !isNicknameEdit {
            AnalyticsService.log(.nicknameSetBegin)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !UserdefaultKey.createdMyNickname {
            coordinator?.navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !UserdefaultKey.createdMyNickname {
            UserdefaultKey.createdMyNickname = true
            coordinator?.navigationController.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(contentsView)
        view.addSubview(nextButton)
    }
    
    private func setupFlexLayout() {
        contentsView.flex.paddingHorizontal(20).define {
            $0.addItem(titleLabel)
                .marginTop(84)
                .marginBottom(16)
            
            $0.addItem(genderButtonStackVIew)
                .marginTop(24)
                .height(82)
                .direction(.row)
                .gap(11)
                .define {
                    $0.addItem(maleButton)
                        .grow(1)
                    
                    $0.addItem(femaleButton)
                        .grow(1)
                }
            
            $0.addItem(dateTextFieldView)
                .marginTop(24)
            
            $0.addItem(nicknameTextField)
                .marginTop(24)
                .height(56)
            
            $0.addItem()
                .marginTop(8)
                .direction(.row)
                .define {
                    $0.addItem(checkIcon)
                        .size(18)
                    $0.addItem(iconTextSpacingView)
                        .size(6)
                    $0.addItem(textFiledDescriptionLabel)
                        .marginLeft(2)
                }
        }
    }
    
    private func layoutViews() {
        backgroundView.pin
            .all()
        
        contentsView.pin
            .all()
        
        nextButton.pin
            .horizontally(20)
            .bottom(48)
            .height(52)
        
        contentsView.flex.layout()
    }
    
    func bind(reactor: CoupleReactor) {
        if isNicknameEdit {
            reactor.action.onNext(.isEditingOnly)
            nextButton.isHidden = false
        }
        
        Observable.combineLatest(
            nicknameTextField.rx.text.orEmpty,
            dateTextFieldView.isCorrectDate,
            reactor.state.map(\.nicknameViewStep),
            reactor.state.map(\.gender)
        )
        .map { text, birthday, step, gender in
            switch step {
            case .nickname, .edit:
                return !text.isEmpty

            case .birthday:
                return !text.isEmpty && birthday

            case .gender:
                return !text.isEmpty && birthday && gender != nil
            }
        }
        .distinctUntilChanged()
        .bind(with: self) { owner, enabled in
            owner.nextButtonToggle(isEnabled: enabled)
        }
        .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.info }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] info in
                guard let self = self else { return }
                
                if info.coupleInfo.firstMetDate.isEmpty {
                    self.coordinator?.showCoupleInfo()
                } else {
                    self.coordinator?.navigateToMain()
                }
                
                UserdefaultKey.createdMyNickname = true
                AnalyticsService.log(.nicknameSetCompleted)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.outputNickname }
            .subscribe(onNext: { [weak self] nickname in
                guard let self = self else { return }
                
                coordinator?.onNicknameUpdated?(nickname)
                
                if isNicknameEdit {
                    self.coordinator?.navigateBack()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.nicknameViewStep }
            .subscribe(onNext: { [weak self] step in
                guard let self else { return }
                currentStep = step
                switch step {
                case .birthday:
                    dateTextFieldView.flex.display(.flex)

                    UIView.animate(withDuration: 0.2) {
                        self.contentsView.flex.layout()
                    }

                    UIView.animate(
                        withDuration: 0.15,
                        delay: 0.15
                    ) {
                        self.titleLabel.text = "생년월일을 알려주세요"
                        self.dateTextFieldView.alpha = 1
                    }
                case .gender:
                    genderButtonStackVIew.flex.display(.flex)
                    
                    UIView.animate(withDuration: 0.2) {
                        self.contentsView.flex.layout()
                    }

                    UIView.animate(
                        withDuration: 0.15,
                        delay: 0.15
                    ) {
                        self.titleLabel.text = "성별을 알려주세요"
                        self.genderButtonStackVIew.alpha = 1
                    }
                case .edit, .nickname:
                    return
                }
                
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isDisconnectSuccess }
            .subscribe(onNext: { _ in
                
                UserdefaultKey.isLoggedIn = false
                UserdefaultKey.pendingCoupleDisconnect = false
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeNavigationRootView(animated: true, alertType: .notAdult)
            })
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .map(CoupleReactor.Action.nicknameChanged)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(with: self) { owner, isNotEmpty in
                owner.checkTextField(isNotEmpty: isNotEmpty)
            }
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.controlEvent(.editingChanged)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                let textField = owner.nicknameTextField

                if textField.markedTextRange != nil {
                    return
                }

                guard let text = textField.text, text.count > 10 else { return }

                let index = text.index(text.startIndex, offsetBy: 10)
                textField.text = String(text[..<index])
            })
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                if self.currentStep == .nickname && self.nicknameTextField.hasText {
                    self.reactor?.action.onNext(.tapNext)
                    self.dateTextFieldView.dateTextField.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        dateTextFieldView.isCorrectDate
            .subscribe(onNext: { [weak self] isCorrectDate in
                guard let self else { return }
                
                if self.currentStep == .birthday && isCorrectDate {
                    self.reactor?.action.onNext(.tapNext)
                    self.dateTextFieldView.dateTextField.endEditing(true)
                }
            })
            .disposed(by: disposeBag)
        
        dateTextFieldView.currentDate
            .map(CoupleReactor.Action.birthdayChanged)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        dateTextFieldView.hiddenWarning
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] hiddenWarning in
                guard let self else { return }
                let view = dateTextFieldView
                view.backgroundView.layer.borderColor = hiddenWarning ? UIColor.grayScale200.cgColor : UIColor.redErrorColor.cgColor
                view.warningLabel.flex.display(hiddenWarning ? .none : .flex)
                
                
                if hiddenWarning {
                    UIView.animate(withDuration: 0.2) {
                        view.warningLabel.alpha = 0
                    }
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0.2
                    ) {
                        self.contentsView.flex.layout()
                    }
                } else {
                    UIView.animate(withDuration: 0.2) {
                        self.contentsView.flex.layout()
                    }
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0.2
                    ) {
                        view.warningLabel.alpha = 1
                    }
                }
            })
           .disposed(by: disposeBag)
        
        maleButton.isTap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                genderButtonUpdate(isMale: true)
            })
           .disposed(by: disposeBag)
        
        femaleButton.isTap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                genderButtonUpdate(isMale: false)
            })
           .disposed(by: disposeBag)
                
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                if currentStep == .birthday || currentStep == .gender {
                    guard let birthday = dateTextFieldView.currentDate.value?.toDate(),
                        isOver14YearsOld(birthday)
                    else {
                        showNotAdultAlert()
                        return
                    }
                }

                self.reactor?.action.onNext(.tapNext)
            })
            .disposed(by: disposeBag)
    }
    
    private func isOver14YearsOld(_ birthDate: Date) -> Bool {
        guard let limitDate = Calendar(identifier: .gregorian)
            .date(byAdding: .year, value: 14, to: birthDate) else {
            return false
        }

        return Date() >= limitDate
    }
    
    private func showNotAdultAlert() {
        UserdefaultKey.pendingCoupleDisconnect = true
        showAlert(icon: UIImage(resource: .warning), title: "만 14세 이상만 가입할 수 있어요", description: "커플 해제 후 로그인 페이지로 이동합니다", primaryButtonTitle: "확인했어요", primaryButtonAction: {
            self.reactor?.action.onNext(.disconnectCouple)
        })
    }
    
    private func checkTextField(isNotEmpty: Bool) {
        iconTextSpacingView.flex.display(isNotEmpty ? .none : .flex)
        checkIcon.flex.display(isNotEmpty ? .flex : .none)
        contentsView.flex.layout()
    }
    
    private func nextButtonToggle(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        nextButton.backgroundColor = isEnabled
        ? .mainPurple
        : .grayScale400
    }
    
    private func genderButtonUpdate(isMale: Bool) {
        nextButton.isHidden = false
        isTappedGenderButton = true
        
        maleButton.layer.borderColor = isMale ? UIColor.mainPurple.cgColor : UIColor.grayScale200.cgColor
        maleButton.title.textColor =  isMale ? .mainPurple : .grayScale900
        
        femaleButton.layer.borderColor = isMale ? UIColor.grayScale200.cgColor : UIColor.mainPurple.cgColor
        femaleButton.title.textColor =  isMale ? .grayScale900 : .mainPurple
        
        reactor?.action.onNext(.genderChanged(isMale ? .male : .female))
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.isEmpty { return false }
        
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty { return true }
        
        let allowedPattern = "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9\\p{Emoji}]+$"
        let isValidInput = string.range(of: allowedPattern, options: .regularExpression) != nil
        
        if !isValidInput { return false }
        
        if textField.markedTextRange != nil {
            return true
        }
        
        return true
    }
}
