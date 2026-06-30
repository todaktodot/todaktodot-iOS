//
//  NicknameViewController.swift
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

enum ConnectFlowType {
    /// 닉네임 -> 기본정보 -> 메인
    case create
    /// 닉네임 -> 메인
    case join
    /// 닉네임 수정
    case edit
}

final class NicknameViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    weak var coordinator: SigninCoordinator?
    
    private var flowType: ConnectFlowType?
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
    
    private let textFiled = UITextField().then {
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
    
    private let birthdayDatePicker = CustomDatePickerView().then {
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
    }
    
    private let checkIcon = UIImageView().then {
        $0.image = UIImage(resource: .nicknameCheckIcon)
    }
    
    private let iconTextSpacingView = UIView()
    
    init(flowType: ConnectFlowType? = nil, nickname: String? = nil) {
        self.flowType = flowType

        if let nickname {
            textFiled.text = nickname
        }
        super.init(nibName: nil, bundle: nil)
        
        birthdayDatePicker.flex.display(.none)
        genderButtonStackVIew.flex.display(.none)
        checkIcon.flex.display(.none)
        
        if flowType == nil {
            if UserdefaultKey.createdCoupleInfo {
                self.flowType = .join
            } else {
                self.flowType = .create
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenBackButton()
        textFiled.delegate = self
        hideKeyboardwhenTappedAround()
        setupViews()
        setupFlexLayout()
        textFiled.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        if flowType == .create || flowType == .join {
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
            
            $0.addItem(birthdayDatePicker)
                .marginTop(24)
                .height(56)
            
            $0.addItem(textFiled)
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
        if flowType == .edit {
            reactor.action.onNext(.isEditingOnly)
        }
        
        reactor.state
            .compactMap { $0.outputNickname }
            .subscribe(onNext: { [weak self] nickname in
                guard let self = self else { return }
                
                coordinator?.onNicknameUpdated?(nickname)
                
                if let type = flowType {
                    switch type {
                    case .create:
                        self.coordinator?.showCoupleInfo()
                    case .join:
                        self.coordinator?.navigateToMain()
                    case .edit:
                        self.coordinator?.navigateBack()
                    }
                }
                
                if flowType != .edit {
                    UserdefaultKey.createdMyNickname = true
                    AnalyticsService.log(.nicknameSetCompleted)
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
                    birthdayDatePicker.flex.display(.flex)

                    UIView.animate(withDuration: 0.2) {
                        self.contentsView.flex.layout()
                    }

                    UIView.animate(
                        withDuration: 0.15,
                        delay: 0.15
                    ) {
                        self.titleLabel.text = "생년월일을 알려주세요"
                        self.birthdayDatePicker.alpha = 1
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
        
        textFiled.rx.text.orEmpty
            .distinctUntilChanged()
            .map(CoupleReactor.Action.nicknameChanged)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            textFiled.rx.text.orEmpty,
            birthdayDatePicker.isDateSelected.map { $0 ?? "" },
            reactor.state.map(\.nicknameViewStep),
            reactor.state.map(\.gender)
        )
        .map { text, birthday, step, gender in
            switch step {
            case .nickname, .edit:
                let isNotEmpty = !text.isEmpty
                self.checkTextField(isNotEmpty: isNotEmpty)
                return isNotEmpty

            case .birthday:
                return !text.isEmpty && !birthday.isEmpty

            case .gender:
                return !text.isEmpty && !birthday.isEmpty && gender != nil
            }
        }
        .distinctUntilChanged()
        .bind(with: self) { owner, enabled in
            owner.nextButtonToggle(isEnabled: enabled)
        }
        .disposed(by: disposeBag)
        
        birthdayDatePicker.isDateSelected
            .subscribe(onNext: { [weak self] date in
                guard let self, let date else { return }
                if let text = textFiled.text, !text.isEmpty {
                    nextButtonToggle(isEnabled: !date.isEmpty)
                } else {
                    nextButtonToggle(isEnabled: false)
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
            .do(onNext: { _ in
                self.nextButtonToggle(isEnabled: false)
            })
            .map { CoupleReactor.Action.tapNext }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func checkTextField(isNotEmpty: Bool) {
        if isNotEmpty {
            iconTextSpacingView.flex.display(.none)
            checkIcon.flex.display(.flex)
        } else {
            iconTextSpacingView.flex.display(.flex)
            checkIcon.flex.display(.none)
        }
        contentsView.flex.layout()
    }
    
    private func nextButtonToggle(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        nextButton.backgroundColor = isEnabled
        ? .mainPurple
        : .grayScale400
    }
    
    private func genderButtonUpdate(isMale: Bool) {
        if let text = textFiled.text, !text.isEmpty {
            nextButtonToggle(isEnabled: true)
        } else {
            nextButtonToggle(isEnabled: false)
        }
        isTappedGenderButton = true
        maleButton.layer.borderColor = isMale ? UIColor.mainPurple.cgColor : UIColor.grayScale200.cgColor
        femaleButton.layer.borderColor = isMale ? UIColor.grayScale200.cgColor : UIColor.mainPurple.cgColor
        reactor?.action.onNext(.genderChanged(isMale ? .male : .female))
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField.markedTextRange != nil {
            return
        }

        guard let text = textField.text else { return }

        if text.count > 10 {
            let index = text.index(text.startIndex, offsetBy: 10)
            textField.text = String(text[..<index])
        }
    }
}

extension NicknameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
