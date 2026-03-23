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
import ReactorKit
import RxSwift
import Lottie

final class HistoryCardDetailViewController: CustomBackViewController, CustomBackViewControllerDelegate, View {
    
    var disposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    private let card: QuestionCard
    private var multipleChoice: Question?
    private var subjectiveChoice: Question?
    private var feedbackLabel: MaskingLabel?
    private var didShowLoading = false
    
    private let scrollView = UIScrollView()
    private let rootFlexContainer = UIView()
    
    private let mainCardContainer = UIView().then {
        $0.backgroundColor = .subPurple
        $0.layer.cornerRadius = 16
    }

    private let questionLabel = TDLabel().then {
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
    
    private let aiFeedbackContainer = UIView().then {
        $0.layer.shadowColor = UIColor.mainPurple.cgColor
        $0.layer.shadowOffset = CGSize(width: 5, height: 5)
        $0.layer.shadowRadius = 20
        $0.layer.shadowOpacity = 0.2
        $0.layer.masksToBounds = false
    }
    
    private let statusContainer = UIView()
    
    // AI 피드백 로딩/에러 UI
    private let feedbackLoadingContainer = UIView().then {
        $0.isHidden = true
    }
    
    private let feedbackErrorContainer = UIView().then {
        $0.isHidden = true
    }
    
    init(card: QuestionCard) {
        self.card = card
        self.multipleChoice = card.questions.first(where: { $0.type == .multipleChoice })
        self.subjectiveChoice = card.questions.first(where: { $0.type == .subjective })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        hidesBottomBarWhenPushed = true
        setupUI()
        reactor?.action.onNext(.checkFeedback)
        AnalyticsService.log(.historyCardDetailBegin(cardId: card.coupleCardId))
        AnalyticsService.log(.historyCardType(status: card.isBothAnswered ? .both : card.user1Answered ? .mineOnly : .partnerOnly))
    }

    private func setupUI() {
        view.backgroundColor = .lightPurple
        
        view.addSubview(scrollView)
        scrollView.addSubview(rootFlexContainer)
        
        setupModeIndicators()
        setupSituation()
        setupAnswerSections()
        if card.user1Answered && card.user2Answered {
            setupAIFeedback()
            setupFeedbackLoadingView()
            setupFeedbackErrorView()
        }
        
        rootFlexContainer.flex
            .paddingHorizontal(20)
            .paddingTop(10)
            .paddingBottom(70)
            .define { flex in
                flex.addItem(mainCardContainer)
                flex.addItem(myAnswerContainer).marginTop(28)
                flex.addItem(partnerAnswerContainer).marginTop(12)
                flex.addItem(aiFeedbackContainer).marginTop(28)
                flex.addItem(feedbackLoadingContainer).marginTop(28)
                flex.addItem(feedbackErrorContainer).marginTop(28)
                flex.addItem(statusContainer).marginTop(4)
            }
        
        mainCardContainer.flex
            .paddingHorizontal(20)
            .paddingBottom(20)
            .define { flex in
                flex.addItem(questionLabel).marginTop(24)
                flex.addItem(modeContainer).marginTop(16)
                flex.addItem(situationContainer).marginTop(20)
            }
    }
    
    private func setupModeIndicators() {
        let modes = [card.mode.emoji + " " + card.mode.displayName,
                     card.subject.emoji + " " + card.subject.displayName,
                     card.type.emoji + " " + card.type.displayName]
        
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
            $0.textColor = .mainPurple
            $0.backgroundColor = .cardPurple
            $0.layer.cornerRadius = 18
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.mainPurple.cgColor
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(12).paddingVertical(8)
        }
    }
    
    private func setupSituation() {
        let situationTitle = TDLabel().then {
            $0.text = card.situation
            $0.font = .pretenMedium(14)
            $0.textColor = .mainPurple
        }
        
        let situationText = card.title
        
        let situationLabel = TDLabel().then {
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
        let nicknameLabel = TDLabel().then {
            $0.text = UserdefaultKey.nicknameInfo?.userNickname
            $0.font = .pretenSemiBold(16)
            $0.textColor = .mainPurple
        }
        
        // user1이 답변하지 않은 경우
        guard card.user1Answered else {
            let notAnsweredLabel = TDLabel().then {
                $0.text = "답변하지 않았어요 🥲"
                $0.font = .pretenRegular(16)
                $0.textColor = .grayScale600
                $0.numberOfLines = 0
            }
            
            myAnswerContainer.flex.padding(20).define { flex in
                flex.addItem(nicknameLabel)
                flex.addItem(notAnsweredLabel).marginTop(12)
            }
            return
        }
        
        let answerLabel = TDLabel().then {
            $0.text = "답변"
            $0.font = .pretenMedium(14)
            $0.textColor = .grayScale600
            $0.backgroundColor = .grayScale100
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(10).paddingVertical(2)
        }
        
        let answerText = TDLabel().then {
            // user1Answer는 옵션 번호 (예: "1")
            let optionNo = Int(multipleChoice?.user1Answer ?? "0") ?? 0
            let optionContent = multipleChoice?.options.first(where: { $0.id == optionNo })?.text ?? "답변 없음"
            $0.text = optionContent
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
        }
        
        let answerRow = UIView()
        answerRow.flex.direction(.row).alignItems(.start).define { flex in
            flex.addItem(answerLabel)
            flex.addItem(answerText).marginLeft(8).grow(1).shrink(1)
        }
        
        let reasonLabel = TDLabel().then {
            $0.text = "이유"
            $0.font = .pretenMedium(14)
            $0.textColor = .grayScale600
            $0.backgroundColor = .grayScale100
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(10).paddingVertical(2)
        }
        
        let reasonText = TDLabel().then {
            $0.text = subjectiveChoice?.user1Answer ?? "답변하지 않았어요 🥲"
            $0.font = .pretenRegular(16)
            $0.baselineAdjustment = .alignCenters
            $0.textColor = subjectiveChoice?.user1Answer == nil ? .grayScale600 : .grayScale800
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
            flex.addItem(reasonRow).marginTop(18)
        }
    }
    
    private func setupPartnerAnswer() {
        let nicknameLabel = TDLabel().then {
            $0.text = UserdefaultKey.nicknameInfo?.anotherUserNickname
            $0.font = .pretenSemiBold(16)
            $0.textColor = .mainPurple
        }

        // user2가 답변하지 않은 경우
        guard card.user2Answered else {
            let notAnsweredLabel = TDLabel().then {
                $0.text = "답변하지 않았어요 🥲"
                $0.font = .pretenRegular(16)
                $0.textColor = .grayScale600
                $0.numberOfLines = 0
            }
            
            partnerAnswerContainer.flex.padding(20).define { flex in
                flex.addItem(nicknameLabel)
                flex.addItem(notAnsweredLabel).marginTop(12)
            }
            return
        }

        let answerLabel = TDLabel().then {
            $0.text = "답변"
            $0.font = .pretenMedium(14)
            $0.textColor = .grayScale600
            $0.backgroundColor = .grayScale100
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(10).paddingVertical(2)
        }
        
        let answerText = TDLabel().then {
            // user2Answer는 옵션 번호 (예: "2")
            let optionNo = Int(multipleChoice?.user2Answer ?? "0") ?? 0
            let optionContent = multipleChoice?.options.first(where: { $0.id == optionNo })?.text ?? "답변 없음"
            $0.text = optionContent
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0

        }
        
        let answerRow = UIView()
        answerRow.flex.direction(.row).alignItems(.start).define { flex in
            flex.addItem(answerLabel)
            flex.addItem(answerText).marginLeft(8).grow(1).shrink(1)
        }
        
        let reasonLabel = TDLabel().then {
            $0.text = "이유"
            $0.font = .pretenMedium(14)
            $0.textColor = .grayScale600
            $0.backgroundColor = .grayScale100
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(10).paddingVertical(2)
        }
        
        let reasonText = TDLabel().then {
            $0.text = subjectiveChoice?.user2Answer ?? "답변하지 않았어요 🥲"
            $0.font = .pretenRegular(16)
            $0.textColor = subjectiveChoice?.user2Answer == nil ? .grayScale600 : .grayScale800
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
            flex.addItem(reasonRow).marginTop(18)
        }
    }

    private func setupAIFeedback() {
        let bubbleContainer = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.mainPurple.cgColor
            $0.layer.masksToBounds = false
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        }
        
        let tailImageView = UIImageView().then {
            $0.image = UIImage(named: "BoxTail")
            $0.contentMode = .scaleAspectFit
            $0.accessibilityIdentifier = "tailImageView"
        }
        
        let contentContainer = UIView()
        
        let iconImageView = UIImageView().then {
            $0.image = UIImage(named: "book_fill")
            $0.contentMode = .scaleAspectFit
        }
        
        let titleLabel = TDLabel().then {
            $0.text = "AI 피드백"
            $0.font = .pretenSemiBold(16)
            $0.textColor = .mainPurple
        }

        let feedbackText = MaskingLabel(textColor: .grayScale900).then {
            $0.numberOfLines = 0
        }
        self.feedbackLabel = feedbackText
        let feedback = card.feedback ?? HistoryCardDetailReactor.cachedFeedback(for: card.coupleCardId)
        if let feedback {
            updateFeedbackLabel(feedbackText, with: feedback)
        }
        
        aiFeedbackContainer.addSubview(bubbleContainer)
        bubbleContainer.addSubview(contentContainer)
        contentContainer.addSubview(iconImageView)
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(feedbackText)
        
        // tail을 마지막에 추가해서 z-index 최상위로
        aiFeedbackContainer.addSubview(tailImageView)
        
        contentContainer.flex.paddingHorizontal(20).paddingVertical(21).define { contentFlex in
            contentFlex.addItem().direction(.row).alignItems(.center).define { titleFlex in
                titleFlex.addItem(iconImageView).size(28)
                titleFlex.addItem(titleLabel).marginLeft(4)
            }
            contentFlex.addItem(feedbackText).marginTop(8)
        }
        
        aiFeedbackContainer.flex.paddingBottom(21).define { flex in
            flex.addItem(bubbleContainer).define { bubbleFlex in
                bubbleFlex.addItem(contentContainer)
            }
        }
        
        let statusLabel = TDLabel().then {
            $0.text = "답변 공개 완료!"
            $0.font = .pretenMedium(16)
            $0.textColor = .grayScale900
        }
        
        let subtitleLabel = TDLabel().then {
            $0.text = "서로의 이유를 더 자세히 들어보고 대화를 이어가보세요."
            $0.font = .pretenRegular(14)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
        }
        
        statusContainer.flex.paddingTop(12).define { flex in
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
        layoutTail()
    }
    
    private func layoutTail() {
        for container in [aiFeedbackContainer, feedbackLoadingContainer, feedbackErrorContainer] {
            if let tailImageView = container.subviews.first(where: { $0.accessibilityIdentifier == "tailImageView" }) {
                tailImageView.pin.bottom(0).right(0).width(40).height(22)
                container.bringSubviewToFront(tailImageView)
            }
        }
    }
    
    // MARK: - Reactor Binding
    
    func bind(reactor: HistoryCardDetailReactor) {
        reactor.pulse(\.$feedbackState)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.updateFeedbackUI(state: state)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateFeedbackUI(state: HistoryCardDetailReactor.FeedbackState) {
        switch state {
        case .none:
            aiFeedbackContainer.flex.isIncludedInLayout(false)
            feedbackLoadingContainer.flex.isIncludedInLayout(false)
            feedbackErrorContainer.flex.isIncludedInLayout(false)
            statusContainer.flex.isIncludedInLayout(false)
            aiFeedbackContainer.isHidden = true
            feedbackLoadingContainer.isHidden = true
            feedbackErrorContainer.isHidden = true
            statusContainer.isHidden = true
            rootFlexContainer.flex.layout(mode: .adjustHeight)
            scrollView.contentSize = rootFlexContainer.frame.size
            
        case .generating:
            didShowLoading = true
            aiFeedbackContainer.flex.isIncludedInLayout(false)
            aiFeedbackContainer.isHidden = true
            feedbackErrorContainer.flex.isIncludedInLayout(false)
            feedbackErrorContainer.isHidden = true
            feedbackLoadingContainer.flex.isIncludedInLayout(true)
            feedbackLoadingContainer.isHidden = false
            statusContainer.flex.isIncludedInLayout(true)
            statusContainer.isHidden = false
            rootFlexContainer.flex.layout(mode: .adjustHeight)
            scrollView.contentSize = rootFlexContainer.frame.size
            
        case .loaded(let feedback):
            if let label = feedbackLabel {
                updateFeedbackLabel(label, with: feedback)
            }
            feedbackLoadingContainer.flex.isIncludedInLayout(false)
            feedbackLoadingContainer.isHidden = true
            feedbackErrorContainer.flex.isIncludedInLayout(false)
            feedbackErrorContainer.isHidden = true
            statusContainer.flex.isIncludedInLayout(true)
            statusContainer.isHidden = false
            
            aiFeedbackContainer.flex.isIncludedInLayout(true)
            aiFeedbackContainer.isHidden = false
            
            rootFlexContainer.flex.layout(mode: .adjustHeight)
            scrollView.contentSize = rootFlexContainer.frame.size
            layoutTail()
            
            guard didShowLoading else { return }
            
            // 상단 기준으로 아래로 펼쳐지는 애니메이션
            aiFeedbackContainer.alpha = 0
            let originalBounds = aiFeedbackContainer.bounds
            aiFeedbackContainer.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            aiFeedbackContainer.layer.position.y -= originalBounds.height / 2
            aiFeedbackContainer.transform = CGAffineTransform(scaleX: 1, y: 0.01)
            
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.aiFeedbackContainer.alpha = 1
                self.aiFeedbackContainer.transform = .identity
            } completion: { _ in
                self.aiFeedbackContainer.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                self.aiFeedbackContainer.layer.position.y += originalBounds.height / 2
            }
            return
            
        case .error:
            aiFeedbackContainer.flex.isIncludedInLayout(false)
            aiFeedbackContainer.isHidden = true
            feedbackLoadingContainer.flex.isIncludedInLayout(false)
            feedbackLoadingContainer.isHidden = true
            statusContainer.flex.isIncludedInLayout(false)
            statusContainer.isHidden = true
            feedbackErrorContainer.flex.isIncludedInLayout(true)
            feedbackErrorContainer.isHidden = false
            rootFlexContainer.flex.layout(mode: .adjustHeight)
            scrollView.contentSize = rootFlexContainer.frame.size
        }
    }
    
    // MARK: - Feedback Loading / Error Views
    
    private func setupFeedbackLoadingView() {
        let boxView = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.mainPurple.cgColor
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        }
        let lottie = LottieAnimationView(name: "loading2").then {
            $0.loopMode = .loop
            $0.play()
        }
        let loadingLabel = TDLabel().then {
            $0.text = "로딩중..."
            $0.font = .pretenBold(16)
            $0.textColor = .mainPurple
            $0.textAlignment = .center
        }
        let tailImageView = UIImageView().then {
            $0.image = UIImage(named: "BoxTail")
            $0.contentMode = .scaleAspectFit
            $0.accessibilityIdentifier = "tailImageView"
        }
        
        feedbackLoadingContainer.flex.paddingBottom(21).define { flex in
            flex.addItem(boxView).padding(20).alignItems(.center).define { boxFlex in
                boxFlex.addItem(lottie).size(60)
                boxFlex.addItem(loadingLabel).marginTop(4)
            }
        }
        feedbackLoadingContainer.addSubview(tailImageView)
    }
    
    private func setupFeedbackErrorView() {
        let boxView = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.grayScale300.cgColor
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        }
        let emojiImageView = UIImageView().then {
            $0.image = UIImage(named: "FeedbackUnsmile")
            $0.contentMode = .scaleAspectFit
        }
        let errorLabel = TDLabel().then {
            $0.text = "피드백을 가져오지 못했어요"
            $0.font = .pretenBold(16)
            $0.textColor = .mainPurple
            $0.textAlignment = .center
        }
        let tailImageView = UIImageView().then {
            $0.image = UIImage(named: "BoxTail")
            $0.contentMode = .scaleAspectFit
            $0.accessibilityIdentifier = "tailImageView"
        }
        
        feedbackErrorContainer.flex.paddingBottom(21).define { flex in
            flex.addItem(boxView).padding(20).alignItems(.center).define { boxFlex in
                boxFlex.addItem(emojiImageView).width(38).height(38)
                boxFlex.addItem(errorLabel).marginTop(11)
            }
        }
        feedbackErrorContainer.addSubview(tailImageView)
    }
    
    private func updateFeedbackLabel(_ label: MaskingLabel, with feedback: CardFeedback) {
        let bold = UIFont.pretenBold(16)
        let regular = UIFont.pretenRegular(16)
        let kern: CGFloat = 1.26
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 3.0
        paraStyle.lineBreakMode = .byCharWrapping
        let baseAttrs: [NSAttributedString.Key: Any] = [.kern: kern, .paragraphStyle: paraStyle]
        
        let attr = NSMutableAttributedString(string: "\n", attributes: baseAttrs)
        let titles = ["요약", "공통점", "차이점", "조언"]
        let bodies = [feedback.summary, feedback.matchPoints, feedback.differences, feedback.tip]
        for (i, title) in titles.enumerated() {
            guard !bodies[i].isEmpty else { continue }
            if attr.length > 1 { attr.append(NSAttributedString(string: "\n\n", attributes: baseAttrs)) }
            var boldAttrs = baseAttrs; boldAttrs[.font] = bold
            var regularAttrs = baseAttrs; regularAttrs[.font] = regular
            attr.append(NSAttributedString(string: title, attributes: boldAttrs))
            attr.append(NSAttributedString(string: "\n" + bodies[i], attributes: regularAttrs))
        }
        attr.append(NSAttributedString(string: "\n", attributes: baseAttrs))
        label.attributedText = attr
    }
    
    func navigateBack() {
        coordinator?.navigateBack()
    }
}


