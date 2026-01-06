//
//  HistoryCardDetailViewController.swift
//  todaktodot
//
//  Created by daye on 12/16/25.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class HistoryCardDetailViewController: UIViewController {
    
    weak var coordinator: HomeCoordinator?
    
    private let scrollView = UIScrollView()
    private let rootFlexContainer = UIView()
    
    private let mainCardContainer = UIView().then {
        $0.backgroundColor = .subPurple
        $0.layer.cornerRadius = 16
    }

    private let questionLabel = UILabel().then {
        $0.text = "이런 상황에서\n나는 어떻게 행동할까요?"
        $0.font = .pretenSemiBold(24)
        $0.textColor = .grayScale900
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let modeContainer = UIView()
    
    private let situationContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let myAnswerContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let partnerAnswerContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let aiFeedbackContainer = UIView()
    
    private let statusContainer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .lightPurple
        
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
        setupAnswerSections()
        setupAIFeedback()
        
        rootFlexContainer.flex
            .paddingHorizontal(20)
            .paddingTop(10)
            .paddingBottom(120)
            .define { flex in
                flex.addItem(mainCardContainer)
                flex.addItem(myAnswerContainer).marginTop(28)
                flex.addItem(partnerAnswerContainer).marginTop(12)
                flex.addItem(aiFeedbackContainer).marginTop(28)
                flex.addItem(statusContainer).marginTop(12)
            }
        
        mainCardContainer.flex
            .padding(20)
            .define { flex in
                flex.addItem(questionLabel).marginTop(20)
                flex.addItem(modeContainer).marginTop(16)
                flex.addItem(situationContainer).marginTop(20)
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
        return UILabel().then {
            $0.text = text
            $0.font = .pretenMedium(14)
            $0.textColor = UIColor(red: 0.6, green: 0.5, blue: 0.8, alpha: 1.0)
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 18
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor(red: 0.6, green: 0.5, blue: 0.8, alpha: 1.0).cgColor
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(12).paddingVertical(8)
        }
    }
    
    private func setupSituation() {
        let situationTitle = UILabel().then {
            $0.text = "🍽️ 레스토랑 데이트"
            $0.font = .pretenMedium(14)
            $0.textColor = UIColor(red: 0.6, green: 0.5, blue: 0.8, alpha: 1.0)
        }
        
        let situationText = "둘이 처음 가는 고급 레스토랑에서 식사를 마쳤습니다. 계산서가 15만원이 나왔는데, 마침 둘 다 지갑을 꺼내려고 하는 상황이에요!"
        
        let situationLabel = UILabel().then {
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.5
            $0.attributedText = NSAttributedString(
                string: situationText,
                attributes: [.paragraphStyle: paragraphStyle]
            )
        }
        
        situationContainer.flex.padding(20).define { flex in
            flex.addItem(situationTitle)
            flex.addItem(situationLabel).marginTop(8)
        }
    }
    
    private func setupAnswerSections() {
        setupMyAnswer()
        setupPartnerAnswer()
    }
    
    private func setupMyAnswer() {
        let nicknameLabel = UILabel().then {
            $0.text = "내 닉네임"
            $0.font = .pretenSemiBold(16)
            $0.textColor = .mainPurple
        }
        
        let answerLabel = UILabel().then {
            $0.text = "답변"
            $0.font = .pretenMedium(14)
            $0.textColor = .grayScale600
            $0.backgroundColor = .grayScale100
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(10).paddingVertical(2)
        }
        
        let answerText = UILabel().then {
            $0.text = "상대방이 내려고 하면 '고마워, 다음엔 내가 낼게' 한다."
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
        }
        
        let answerRow = UIView()
        answerRow.flex.direction(.row).alignItems(.start).define { flex in
            flex.addItem(answerLabel)
            flex.addItem(answerText).marginLeft(8).grow(1).shrink(1)
        }
        
        let reasonLabel = UILabel().then {
            $0.text = "이유"
            $0.font = .pretenMedium(14)
            $0.textColor = .grayScale600
            $0.backgroundColor = .grayScale100
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(10).paddingVertical(2)
        }
        
        let reasonText = UILabel().then {
            $0.text = "딱 5:5 구분해서 내기보다 한 번은 내가 사고, 한 번은 상대가 사는 방식이 좋아서 계산적으로 하기보다 자연스러운 계산 방식이 좋다고 생각"
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
        }
        
        let reasonRow = UIView()
        reasonRow.flex.direction(.row).alignItems(.start).define { flex in
            flex.addItem(reasonLabel)
            flex.addItem(reasonText).marginLeft(8).grow(1).shrink(1)
        }
        
        myAnswerContainer.flex.padding(20).define { flex in
            flex.addItem(nicknameLabel)
            flex.addItem(answerRow).marginTop(12)
            flex.addItem(reasonRow).marginTop(16)
        }
    }
    
    private func setupPartnerAnswer() {
        let nicknameLabel = UILabel().then {
            $0.text = "연인 닉네임"
            $0.font = .pretenSemiBold(16)
            $0.textColor = .mainPurple
        }
        
        let answerLabel = UILabel().then {
            $0.text = "답변"
            $0.font = .pretenMedium(14)
            $0.textColor = .grayScale600
            $0.backgroundColor = .grayScale100
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(10).paddingVertical(2)
        }
        
        let answerText = UILabel().then {
            $0.text = "상대방이 내려고 하면 '고마워, 다음엔 내가 낼게' 한다."
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0

        }
        
        let answerRow = UIView()
        answerRow.flex.direction(.row).alignItems(.start).define { flex in
            flex.addItem(answerLabel)
            flex.addItem(answerText).marginLeft(8).grow(1).shrink(1)
        }
        
        let reasonLabel = UILabel().then {
            $0.text = "이유"
            $0.font = .pretenMedium(14)
            $0.textColor = .grayScale600
            $0.backgroundColor = .grayScale100
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(10).paddingVertical(2)
        }
        
        // TODO: nil값일떄 처리하도록
        let reasonText = UILabel().then {
            $0.text = "답변하지 않았어요 🥲"
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale600
            $0.numberOfLines = 0
        }
        
        let reasonRow = UIView()
        reasonRow.flex.direction(.row).alignItems(.start).define { flex in
            flex.addItem(reasonLabel)
            flex.addItem(reasonText).marginLeft(8).grow(1).shrink(1)
        }
        
        partnerAnswerContainer.flex.padding(20).define { flex in
            flex.addItem(nicknameLabel)
            flex.addItem(answerRow).marginTop(12)
            flex.addItem(reasonRow).marginTop(16)
        }
    }
    
    private func setupAIFeedback() {
        let bubbleImageView = UIImageView().then {
            $0.image = UIImage(named: "Union")
            $0.contentMode = .scaleToFill
        }
        
        let titleLabel = UILabel().then {
            $0.text = "AI 피드백"
            $0.font = .pretenSemiBold(16)
            $0.textColor = .mainPurple
        }
        
        let feedbackText = UILabel().then {
            $0.text = "차이가 있다는 건 우리가 서로의 세계를 넓힐 수 있다는 뜻이지. 각자 어떤 경험에서 이런 생각을 하게 됐는지 나눠볼까?"
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale900
            $0.numberOfLines = 0
        }
        
        aiFeedbackContainer.addSubview(bubbleImageView)
        aiFeedbackContainer.addSubview(titleLabel)
        aiFeedbackContainer.addSubview(feedbackText)
        bubbleImageView.pin.all()
        aiFeedbackContainer.flex.define { flex in
            flex.addItem().paddingHorizontal(30).paddingVertical(21).paddingBottom(40).define { contentFlex in
                contentFlex.addItem(titleLabel)
                contentFlex.addItem(feedbackText).marginTop(8)
            }
        }
        
        let statusLabel = UILabel().then {
            $0.text = "🔄 답변 공개 완료!"
            $0.font = .pretenMedium(16)
            $0.textColor = .grayScale900
        }
        
        let subtitleLabel = UILabel().then {
            $0.text = "서로의 이유를 더 자세히 들어보고 대화를 이어가보세요."
            $0.font = .pretenRegular(14)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
        }
        
        statusContainer.flex.define { flex in
            flex.addItem(statusLabel)
            flex.addItem(subtitleLabel).marginTop(4)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.pin.all(view.pin.safeArea)
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
        
        if let bubbleImageView = aiFeedbackContainer.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            bubbleImageView.pin.all()
        }
    }
    
    @objc private func backButtonTapped() {
        coordinator?.navigateBack()
    }
}


