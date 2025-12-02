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


class CoupleConnectViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let code: String?
    
    private let background = UIImageView().then {
        $0.image = UIImage(resource: .connectBackground)
    }
    
    private let contentsView = UIView()
    
    private let codeInputView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "상대와 연결하기"
        $0.font = .pretenSemiBold(28)
        $0.textColor = .grayScale900
    }
    
    private let descriptionLabel1 = UILabel().then {
        $0.font = .pretenRegular(16)
        $0.textColor = .grayScale800
        $0.numberOfLines = 0
        $0.setTextWithLineHeight(text: "내 코드를 복사해서 상대방에게 보내거나\n상대방의 코드를 입력하세요", multiplier: 1.3)
    }
    
    private let descriptionLabel2 = UILabel().then {
        $0.text = "둘 중 한 명만 상대의 코드를 입력하면 연결돼요 ☺️"
        $0.font = .pretenRegular(14)
        $0.textColor = .grayScale600
        $0.numberOfLines = 0
    }
    
    private let myCodeLabel = UILabel().then {
        $0.text = "내 코드"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .grayScale800
    }
    
    private let partnerCodeLabel = UILabel().then {
        $0.text = "상대 코드 입력"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .grayScale800
    }
    
    private let divideTextLabel = UILabel().then {
        $0.text = "또는"
        $0.textAlignment = .center
        $0.font = .pretenSemiBold(12)
        $0.textColor = .grayScale600
        $0.backgroundColor = .white
    }
    
    private let myCodeTextField: UIView
    
    private let partnerCodeTextField = CodeTextFieldView()
    
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
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.tintColor = .white
        $0.backgroundColor = .grayScale400
        $0.layer.cornerRadius = 6
    }
    
    private let lookAroundButton = UIButton(type: .system).then {
        $0.setTitle("혼자 둘러볼게요", for: .normal)
        $0.titleLabel?.font = .pretenMedium(16)
        $0.tintColor = .grayScale600
    }
    
    init(code: [String]? = nil) {
        self.code = code?.joined()
        myCodeTextField = CodeTextFieldView(code: code)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindActions()
        setupViews()
        setupFlexLayout()
        hideKeyboardwhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }

    // MARK: - Setup & Layout

    private func setupViews() {
        view.addSubview(background)
        view.addSubview(contentsView)
        view.addSubview(connectButton)
        view.addSubview(lookAroundButton)
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
        
        contentsView.pin
            .top(view.pin.safeArea.top)
            .horizontally()
            .bottom()
        
        connectButton.pin
            .horizontally(20)
            .bottom(108)
            .height(52)
        
        lookAroundButton.pin
            .horizontally(20)
            .bottom(48)
            .height(52)
        
        codeInputView.flex.layout(mode: .adjustHeight)
        
        contentsView.flex.layout()
    }
    
    private func bindActions() {
        copyButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                if let code = self?.code {
                    UIPasteboard.general.string = code.uppercased()
                    self?.showToast(message: "복사가 완료되었습니다")
                }
            })
            .disposed(by: disposeBag)
        
        partnerCodeTextField.isCodeFull
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                connectButton.backgroundColor = $0 ? .mainPurple : .grayScale400
            })
            .disposed(by: disposeBag)
            
    }
}
