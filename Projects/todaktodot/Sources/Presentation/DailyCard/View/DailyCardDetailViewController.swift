//
//  DailyCardDetailViewController.swift
//  todaktodot
//
//  Created by daye on 12/16/25.
//

import UIKit
import FlexLayout
import PinLayout
import Then

enum CardType {
    case situation
    case balance
}


final class DailyCardDetailViewController: UIViewController {
    
    weak var coordinator: HomeCoordinator?
    private let cardType: CardType
    
    init(cardType: CardType = .situation) {
        self.cardType = cardType
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView = UIScrollView()
    private let rootFlexContainer = UIView()
    
    private let mainCardContainer = UIView().then {
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    
        let gradient = CAGradientLayer()
        let mainPurple = UIColor.mainPurple
        let accentColor1 = UIColor(red: 128/255, green: 74/255, blue: 190/255, alpha: 1.0) // #804ABE
        let accentColor2 = UIColor(red: 152/255, green: 110/255, blue: 153/255, alpha: 1.0) // #986E99
        
        gradient.colors = [accentColor1.cgColor, mainPurple.cgColor, accentColor2.cgColor]
        gradient.locations = [0.0, 0.4, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)  // 왼쪽 위
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)    // 오른쪽 아래
        $0.layer.insertSublayer(gradient, at: 0)
    }
    
    private let headerLabel = TDLabel().then {
        $0.text = "Question"
        $0.font = .pretenSemiBold(12)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let questionLabel = TDLabel().then {
        $0.text = "이런 상황에서\n나는 어떻게 행동할까요?"
        $0.font = .pretenSemiBold(24)
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let modeContainer = UIView()
    private let situationContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let optionsContainer = UIView()
    private let reasonContainer = UIView()
    
    private let reasonTextView = UITextView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grayScale200.cgColor
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        $0.tintColor = .grayScale900
        let placeholderText = "대답을 고른 이유가 궁금해요. 자세히 적을수록\n상대방이 더 잘 이해할 수 있어요"
        
        let attributedString = NSMutableAttributedString(string: placeholderText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.26
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.grayScale400, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font, value: UIFont.pretenMedium(16), range: NSRange(location: 0, length: attributedString.length))
        $0.attributedText = attributedString
    }
    
    private let submitButton = UIButton().then {
        $0.setTitle("답변 완료", for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.backgroundColor = .grayScale400
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 6
        $0.isEnabled = false
    }
    
    private var selectedOptionIndex: Int? = nil
    private var optionButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .lightPurple
        navigationController?.navigationBar.isHidden = false
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .grayScale900
        navigationItem.leftBarButtonItem = backButton
        
        view.addSubview(scrollView)
        scrollView.addSubview(rootFlexContainer)
        
        setupModeIndicators()
        setupSituation()
        setupOptions()
        setupReasonSection()
        
        reasonTextView.delegate = self
        
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        rootFlexContainer.flex
            .paddingHorizontal(20)
            .paddingTop(10)
            .paddingBottom(120)
            .define { flex in
                flex.addItem(mainCardContainer)
                flex.addItem(optionsContainer).marginTop(24)
                flex.addItem(reasonContainer).marginTop(24)
                flex.addItem(submitButton).height(52).marginTop(24)
            }
        
        mainCardContainer.flex
            .padding(20)
            .define { flex in
                flex.addItem(headerLabel)
                flex.addItem(questionLabel).marginTop(4)
                flex.addItem(modeContainer).marginTop(16)
                flex.addItem(situationContainer).marginTop(16)
            }
    }
    
    private func setupModeIndicators() {
        let modes = ["🍰 디저트 모드", "💸 경제관", "🎭 상황극"]
        
        modeContainer.flex
            .direction(.row)
            .wrap(.wrap)
            .justifyContent(.center)
            .define { flex in
                for mode in modes {
                    let label = createModeLabel(mode)
                    flex.addItem(label).marginRight(8).marginBottom(8)
                }
            }
    }
    
    private func createModeLabel(_ text: String) -> UILabel {
        return TDLabel().then {
            $0.text = text
            $0.font = .pretenMedium(14)
            $0.textColor = .white
            $0.backgroundColor = .clear
            $0.layer.cornerRadius = 18
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.cgColor
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(12).paddingVertical(8)
        }
    }
    
    private func setupSituation() {
        let situationTitle = TDLabel().then {
            $0.text = "🍽️ 레스토랑 데이트"
            $0.font = .pretenSemiBold(18)
            $0.textColor = .mainPurple
        }
        
        let situationLabel = TDLabel().then {
            $0.text = "둘이 처음 가는 고급 레스토랑에서 식사를 마쳤습니다. 계산서가 15만원이 나왔는데, 마침 둘 다 지갑을 꺼내려고 하는 상황이에요!"
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
        }
        
        situationContainer.flex.padding(20).define { flex in
            flex.addItem(situationTitle)
            flex.addItem(situationLabel).marginTop(8)
        }
    }
    
    private func setupOptions() {
        if cardType == .balance {
            let balanceOptions = [
                (title: "내가 모두 결제", description: "\"오늘은 내가 낼게!\"라고 말하며 상대방의 지갑을 부드럽게 밀어 넣고 쿨하게 15만 원 전액을 결제한다."),
                (title: "절반씩 정확히 나눠 결제", description: "\"정확히 반반씩 내자\"고 말하며 7만 5천 원을 요청하거나, 각자의 카드로 긁어 나눠 낸다.")
            ]
            
            optionsContainer.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
                for (index, option) in balanceOptions.enumerated() {
                    let button = createBalanceOptionButton(title: option.title, description: option.description, index: index)
                    optionButtons.append(button)
                    flex.addItem(button).width(48%)
                }
            }
        } else {
            let options = [
                "내가 먼저 카드를 내밀며 '내가 낼게'라고 한다",
                "'반반 하자'고 제안한다",
                "상대방이 내려고 하면 '고마워, 다음엔 내가 낼게' 한다",
                "'가위바위보로 정하자'며 재미있게 풀어간다",
                "조용히 기다리며 상대방의 반응을 본다"
            ]
            
            optionsContainer.flex.define { flex in
                for (index, option) in options.enumerated() {
                    let button = createOptionButton(option, index: index)
                    optionButtons.append(button)
                    flex.addItem(button).marginBottom(12)
                }
            }
        }
    }
    
    private func createOptionButton(_ text: String, index: Int) -> UIButton {
        let button = UIButton().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.grayScale200.cgColor
            $0.contentHorizontalAlignment = .left
            $0.tag = index
            $0.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        }
        
        let radioButton = UIImageView().then {
            $0.image = UIImage(systemName: "circle")
            $0.tintColor = .grayScale200
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = false
        }
        
        let textLabel = TDLabel().then {
            $0.text = text
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
            $0.isUserInteractionEnabled = false
        }
        
        button.addSubview(radioButton)
        button.addSubview(textLabel)
        
        // Use flex layout instead of absolute positioning
        button.flex.paddingHorizontal(16).paddingVertical(18).define { flex in
            flex.addItem().direction(.row).alignItems(.start).define { rowFlex in
                rowFlex.addItem(radioButton).size(24)
                rowFlex.addItem(textLabel).marginLeft(12).grow(1).shrink(1)
            }
        }
        
        return button
    }
    
    
    private func setupReasonSection() {
        let titleLabel = TDLabel().then {
            $0.text = "그렇게 생각한 이유가 무엇인가요?(선택)"
            $0.font = .pretenSemiBold(16)
            $0.textColor = .grayScale900
        }
        reasonContainer.flex.define { flex in
            flex.addItem(titleLabel)
            flex.addItem(reasonTextView).height(120).marginTop(12)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.pin.all(view.pin.safeArea)
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
        
        // Update gradient frame
        if let gradientLayer = mainCardContainer.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = mainCardContainer.bounds
        }
    }
    
    private func showSuccessAlert() {
        showAlert(
            icon: UIImage(named: "Check"),
            title: "답변 완료!",
            description: "오늘의 Dot이 만들어졌어요.\n연인도 답변 완료하면\n답변을 같이 볼 수 있어요",
            primaryButtonTitle: "확인",
            primaryButtonAction: { [weak self] in
                self?.coordinator?.navigateToHome()
            }
        )
    }

    private func updateSubmitButton() {
        let hasSelection = selectedOptionIndex != nil
        submitButton.backgroundColor = hasSelection ? .mainPurple : .grayScale400
        submitButton.isEnabled = hasSelection
    }
}

// MARK: - FUNC
extension DailyCardDetailViewController {
    
    @objc private func backButtonTapped() {
        coordinator?.navigateBack()
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        selectedOptionIndex = sender.tag
        
        optionButtons.forEach { button in
            if cardType == .balance {
                let titleLabel = button.subviews.first { $0 is UILabel } as? UILabel
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                    if button.tag == sender.tag {
                        button.layer.borderColor = UIColor.mainPurple.cgColor
                        titleLabel?.textColor = .mainPurple
                    } else {
                        button.layer.borderColor = UIColor.grayScale200.cgColor
                        titleLabel?.textColor = .grayScale900
                    }
                }
            } else {
                let radioButton = button.subviews.first { $0 is UIImageView } as? UIImageView
                let textLabel = button.subviews.first { $0 is UILabel } as? UILabel
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                    if button.tag == sender.tag {
                        button.layer.borderColor = UIColor.mainPurple.cgColor
                        radioButton?.image = UIImage(systemName: "dot.circle")
                        radioButton?.tintColor = .mainPurple
                        textLabel?.textColor = .mainPurple
                    } else {
                        button.layer.borderColor = UIColor.grayScale200.cgColor
                        radioButton?.image = UIImage(systemName: "circle")
                        radioButton?.tintColor = .grayScale200
                        textLabel?.textColor = .grayScale800
                    }
                }
            }
        }
        
        updateSubmitButton()
    }
    
    @objc private func submitButtonTapped() {
        showAlert(
            icon: UIImage(named: "Warning"),
            title: "답변을 완료하시겠어요?",
            description: "답변을 완료하시면",
            tintedDescription: "더 이상 수정이 불가합니다.",
            primaryButtonTitle: "답변 완료",
            primaryButtonAction: { [weak self] in
                self?.showSuccessAlert()
            },
            secondaryButtonTitle: "취소",
            secondaryButtonAction: {}
        )
    }
}

// MARK: - SUB UI
extension DailyCardDetailViewController {
    private func createBalanceOptionButton(title: String, description: String, index: Int) -> UIButton {
        let button = UIButton().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.grayScale200.cgColor
            $0.tag = index
            $0.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        }
        
        let titleLabel = TDLabel().then {
            $0.text = title
            $0.font = .pretenSemiBold(16)
            $0.textColor = .grayScale900
            $0.numberOfLines = 0
            $0.isUserInteractionEnabled = false
        }
        
        let descriptionLabel = TDLabel().then {
            $0.text = description
            $0.font = .pretenRegular(14)
            $0.textColor = .grayScale600
            $0.numberOfLines = 0
            $0.isUserInteractionEnabled = false
        }
        
        button.addSubview(titleLabel)
        button.addSubview(descriptionLabel)
        
        button.flex.padding(16).define { flex in
            flex.addItem(titleLabel)
            flex.addItem(descriptionLabel).marginTop(8)
        }
        
        return button
    }
}

// MARK: - UITextViewDelegate
extension DailyCardDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .grayScale400 {
            textView.text = ""
            textView.textColor = .grayScale900
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "대답을 고른 이유가 궁금해요. 자세히 적을수록\n상대방이 더 잘 이해할 수 있어요"
            textView.textColor = .grayScale400
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.textColor == .grayScale900 && !textView.text.isEmpty {
            textView.text =  textView.text
            textView.textColor = .grayScale900
        }
    }
}
