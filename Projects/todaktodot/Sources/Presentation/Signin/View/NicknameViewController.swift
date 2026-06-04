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
    private var flowType = BehaviorRelay<ConnectFlowType?>(value: nil)
    
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
        $0.text = "한글, 영어, 숫자, 이모지 모두 사용 가능해요!"
        $0.font = .pretenMedium(12)
        $0.textColor = .grayScale600
    }
    
    private let nextButton = UIButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.white, for: .disabled)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.backgroundColor = .grayScale400
        $0.layer.cornerRadius = 6
        $0.isEnabled = false
    }
    
    init(flowType: ConnectFlowType? = nil, nickname: String? = nil) {
        self.flowType.accept(flowType)
        if let nickname {
            textFiled.text = nickname
        }
        super.init(nibName: nil, bundle: nil)
        
        if flowType == nil {
            if UserdefaultKey.createdCoupleInfo {
                self.flowType.accept(.join)
            } else {
                self.flowType.accept(.create)
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
        
        if flowType.value == .create || flowType.value == .join {
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
            
            $0.addItem(textFiled)
                .marginTop(40)
                .height(56)
            
            $0.addItem(textFiledDescriptionLabel)
                .marginTop(8)
                .marginLeft(8)
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
        
        reactor.state
            .compactMap { $0.updateNickname }
            .subscribe(onNext: { [weak self] nickname in
                guard let self = self else { return }
                
                coordinator?.onNicknameUpdated?(nickname)
                
                if let type = flowType.value {
                    switch type {
                    case .create:
                        self.coordinator?.showCoupleInfo()
                    case .join:
                        self.coordinator?.navigateToMain()
                    case .edit:
                        self.coordinator?.navigateBack()
                    }
                }
                
                if flowType.value != .edit {
                    UserdefaultKey.createdMyNickname = true
                    AnalyticsService.log(.nicknameSetCompleted)
                }
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .withLatestFrom(textFiled.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .map { CoupleReactor.Action.tapNicknameButton($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        textFiled.rx.text.orEmpty
            .map { !$0.isEmpty }
            .subscribe(onNext: { [weak self] enabled in
                self?.nextButton.isEnabled = enabled
                self?.nextButton.backgroundColor = enabled
                    ? .mainPurple
                    : .grayScale400
            })
            .disposed(by: disposeBag)
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
