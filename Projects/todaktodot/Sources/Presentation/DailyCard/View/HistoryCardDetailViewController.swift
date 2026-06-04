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
    private var emojiAddButton: UIView?
    private let emojiPalette = EmojiPaletteView()
    
    private var isCurrentWeek: Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = CardService.shared.getCardSystemDate()
        return calendar.isDate(card.date, equalTo: today, toGranularity: .weekOfYear)
    }
    
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
    private let aiFeedbackStatus = UIView()
    
    private let feedbackLoadingBubble = UIView().then {
        $0.isHidden = true
        $0.layer.shadowColor = UIColor.mainPurple.cgColor
        $0.layer.shadowOffset = CGSize(width: 5, height: 5)
        $0.layer.shadowRadius = 20
        $0.layer.shadowOpacity = 0.2
        $0.layer.masksToBounds = false
    }
    private let feedbackLoadingStatus = UIView().then { $0.isHidden = true }
    
    private let feedbackRetryBubble = UIView().then {
        $0.isHidden = true
        $0.layer.shadowColor = UIColor.mainPurple.cgColor
        $0.layer.shadowOffset = CGSize(width: 5, height: 5)
        $0.layer.shadowRadius = 20
        $0.layer.shadowOpacity = 0.2
        $0.layer.masksToBounds = false
    }
    private let feedbackRetryStatus = UIView().then { $0.isHidden = true }
    
    private let feedbackErrorBubble = UIView().then {
        $0.isHidden = true
        $0.layer.shadowColor = UIColor.mainPurple.cgColor
        $0.layer.shadowOffset = CGSize(width: 5, height: 5)
        $0.layer.shadowRadius = 20
        $0.layer.shadowOpacity = 0.2
        $0.layer.masksToBounds = false
    }
    private let feedbackErrorStatus = UIView().then { $0.isHidden = true }
    
    private let feedbackLockedBubble = UIView().then {
        $0.isHidden = true
        $0.layer.shadowColor = UIColor.mainPurple.cgColor
        $0.layer.shadowOffset = CGSize(width: 5, height: 5)
        $0.layer.shadowRadius = 20
        $0.layer.shadowOpacity = 0.2
        $0.layer.masksToBounds = false
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
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissEmojiPalette))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePartnerEmojiPush), name: .partnerEmojiReceived, object: nil)
    }
    
    @objc private func handlePartnerEmojiPush() {
        reactor?.action.onNext(.refreshPartnerEmoji)
    }
    
    @objc private func dismissEmojiPalette(_ sender: UITapGestureRecognizer) {
        guard !emojiPalette.isHidden else { return }
        let location = sender.location(in: view)
        if !emojiPalette.frame.contains(location) {
            emojiPalette.dismiss()
        }
    }

    private func setupUI() {
        view.backgroundColor = .lightPurple
        
        view.addSubview(scrollView)
        scrollView.addSubview(rootFlexContainer)
        scrollView.delegate = self
        
        setupModeIndicators()
        setupSituation()
        setupMyAnswer()
        setupPartnerAnswer()
        setupAIFeedback()
        setupFeedbackLoadingView()
        setupFeedbackRetryView()
        setupFeedbackErrorView()
        setupFeedbackLockedView()
        
        rootFlexContainer.flex
            .paddingHorizontal(20)
            .paddingTop(10)
            .paddingBottom(70)
            .define { flex in
                flex.addItem(mainCardContainer)
                flex.addItem(myAnswerContainer).marginTop(28)
                flex.addItem(partnerAnswerContainer).marginTop(12)
                flex.addItem(aiFeedbackContainer).marginTop(28)
                flex.addItem(aiFeedbackStatus).marginTop(12)
                flex.addItem(feedbackLoadingBubble).marginTop(28)
                flex.addItem(feedbackLoadingStatus).marginTop(12)
                flex.addItem(feedbackRetryBubble).marginTop(28)
                flex.addItem(feedbackRetryStatus).marginTop(12)
                flex.addItem(feedbackErrorBubble).marginTop(28)
                flex.addItem(feedbackErrorStatus).marginTop(12)
                flex.addItem(feedbackLockedBubble).marginTop(28)
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
        let situationLabel = TDLabel().then {
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.5
            $0.attributedText = NSAttributedString(
                string: card.title,
                attributes: [.paragraphStyle: paragraphStyle]
            )
        }
        situationContainer.flex.padding(20).define { flex in
            flex.addItem(situationTitle)
            flex.addItem(situationLabel).marginTop(8)
        }
    }
    
    private func setupMyAnswer() {
        setupAnswerContainer(
            myAnswerContainer,
            nickname: UserdefaultKey.nicknameInfo?.userNickname,
            answered: card.user1Answered,
            answerText: {
                let optionNo = Int(self.multipleChoice?.user1Answer ?? "0") ?? 0
                return self.multipleChoice?.options.first(where: { $0.id == optionNo })?.text ?? "답변 없음"
            }(),
            reasonText: subjectiveChoice?.user1Answer,
            emoji: multipleChoice?.user1Emoji,
            isPartner: false
        )
    }
    
    private func setupPartnerAnswer() {
        setupAnswerContainer(
            partnerAnswerContainer,
            nickname: UserdefaultKey.nicknameInfo?.anotherUserNickname,
            answered: card.user2Answered,
            answerText: {
                let optionNo = Int(self.multipleChoice?.user2Answer ?? "0") ?? 0
                return self.multipleChoice?.options.first(where: { $0.id == optionNo })?.text ?? "답변 없음"
            }(),
            reasonText: subjectiveChoice?.user2Answer,
            emoji: multipleChoice?.user2Emoji,
            isPartner: true
        )
    }
    
    private func setupAnswerContainer(_ container: UIView, nickname: String?, answered: Bool, answerText: String, reasonText: String?, emoji: EmojiType?, isPartner: Bool) {
        let nicknameLabel = TDLabel().then {
            $0.text = nickname
            $0.font = .pretenSemiBold(16)
            $0.textColor = .mainPurple
        }
        
        let emojiRow = makeEmojiRow(emoji: emoji, isPartner: isPartner)
        if isPartner { emojiRow.tag = 999 }
        let showEmoji = isPartner || emoji != nil || self.isCurrentWeek
        
        container.flex.padding(20).define { flex in
            flex.addItem(nicknameLabel)
            
            if answered {
                let answerRow = makeTagRow(tag: "답변", content: answerText)
                let reasonRow = makeTagRow(tag: "이유", content: reasonText ?? "답변하지 않았어요 🥲", contentColor: reasonText == nil ? .grayScale600 : .grayScale800)
                flex.addItem(answerRow).marginTop(12)
                flex.addItem(reasonRow).marginTop(18)
            } else {
                let notAnsweredLabel = TDLabel().then {
                    $0.text = "답변하지 않았어요 🥲"
                    $0.font = .pretenRegular(16)
                    $0.textColor = .grayScale600
                    $0.numberOfLines = 0
                }
                flex.addItem(notAnsweredLabel).marginTop(12)
            }
            
            if showEmoji {
                flex.addItem(emojiRow).marginTop(12)
            }
        }
    }
    
    private func makeEmojiRow(emoji: EmojiType?, isPartner: Bool) -> UIView {
        let row = UIView()
        row.flex.direction(.row).justifyContent(.end).define { flex in
            if isPartner {
                if let emoji {
                    // 선택된 이모지 표시
                    let emojiContainer = UIView().then {
                        $0.backgroundColor = .lightPurple
                        $0.layer.cornerRadius = 18
                        $0.layer.borderWidth = 1
                        $0.layer.borderColor = UIColor.mainPurple.cgColor
                        $0.isUserInteractionEnabled = true
                    }
                    let emojiImage = UIImageView().then {
                        $0.image = UIImage(named: emoji.imageName)
                        $0.contentMode = .scaleAspectFit
                    }
                    emojiContainer.flex.width(52).height(36).justifyContent(.center).alignItems(.center).define { f in
                        f.addItem(emojiImage).size(36)
                    }
                    
                    if self.isCurrentWeek {
                        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(emojiDeleteTapped))
                        emojiContainer.addGestureRecognizer(deleteTap)
                    }
                    
                    flex.addItem(emojiContainer)
                    
                    if self.isCurrentWeek {
                        // 수정 버튼 (이번주만)
                        let editButton = UIView().then {
                            $0.isUserInteractionEnabled = true
                            let tap = UITapGestureRecognizer(target: self, action: #selector(emojiAddTapped(_:)))
                            $0.addGestureRecognizer(tap)
                        }
                        let editImage = UIImageView().then {
                            $0.image = UIImage(named: "emoji_add")
                            $0.contentMode = .scaleAspectFit
                        }
                        editButton.flex.size(24).justifyContent(.center).alignItems(.center).define { f in
                            f.addItem(editImage).size(24)
                        }
                        self.emojiAddButton = editButton
                        flex.addItem(editButton).marginLeft(10).alignSelf(.center)
                    }
                } else if self.isCurrentWeek {
                    // 미선택 - 추가 버튼 (이번주만)
                    let addContainer = UIView().then {
                        $0.backgroundColor = UIColor(hex: "F5F2F8")
                        $0.layer.cornerRadius = 18
                        $0.isUserInteractionEnabled = true
                        let tap = UITapGestureRecognizer(target: self, action: #selector(emojiAddTapped(_:)))
                        $0.addGestureRecognizer(tap)
                    }
                    let addImage = UIImageView().then {
                        $0.image = UIImage(named: "emoji_add")
                        $0.contentMode = .scaleAspectFit
                    }
                    addContainer.flex.width(52).height(36).justifyContent(.center).alignItems(.center).define { f in
                        f.addItem(addImage).size(28)
                    }
                    self.emojiAddButton = addContainer
                    flex.addItem(addContainer)
                }
            } else {
                // 내 답변 - 상대방이 단 이모지 표시만
                if let emoji {
                    let emojiContainer = UIView().then {
                        $0.backgroundColor = UIColor(hex: "F5F2F8")
                        $0.layer.cornerRadius = 18
                    }
                    let emojiImage = UIImageView().then {
                        $0.image = UIImage(named: emoji.imageName)
                        $0.contentMode = .scaleAspectFit
                    }
                    emojiContainer.flex.width(52).height(36).justifyContent(.center).alignItems(.center).define { f in
                        f.addItem(emojiImage).size(36)
                    }
                    flex.addItem(emojiContainer)
                }
            }
        }
        return row
    }
    
    @objc private func emojiDeleteTapped() {
        reactor?.action.onNext(.deleteEmoji)
    }
    
    @objc private func emojiAddTapped(_ sender: UITapGestureRecognizer) {
        guard let button = sender.view else { return }
        
        if emojiPalette.superview == nil {
            view.addSubview(emojiPalette)
            emojiPalette.isHidden = true
            emojiPalette.onEmojiSelected = { [weak self] type in
                self?.reactor?.action.onNext(.saveEmoji(type))
            }
            emojiPalette.onEmojiDeleted = { [weak self] in
                self?.reactor?.action.onNext(.deleteEmoji)
            }
        }
        
        let buttonFrame = button.convert(button.bounds, to: view)
        let paletteWidth: CGFloat = view.bounds.width - 16
        let paletteHeight: CGFloat = 60
        let spacing: CGFloat = 8
        
        let paletteX: CGFloat = 8
        let belowY = buttonFrame.maxY + spacing
        let aboveY = buttonFrame.minY - paletteHeight - spacing
    
        let paletteY: CGFloat
        if belowY + paletteHeight < view.bounds.height - view.safeAreaInsets.bottom - 80 {
            paletteY = belowY
        } else {
            paletteY = aboveY
        }
        
        emojiPalette.frame = CGRect(x: paletteX, y: paletteY, width: paletteWidth, height: paletteHeight)
        emojiPalette.showWithJumpAnimation(selectedEmoji: reactor?.currentState.myEmoji)
    }
    
    private func makeTagRow(tag: String, content: String, contentColor: UIColor = .grayScale800) -> UIView {
        let tagLabel = TDLabel().then {
            $0.text = tag
            $0.font = .pretenMedium(14)
            $0.textColor = .grayScale600
            $0.backgroundColor = .grayScale100
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.flex.paddingHorizontal(10).paddingVertical(2)
        }
        let contentLabel = TDLabel().then {
            $0.text = content
            $0.font = .pretenRegular(16)
            $0.textColor = contentColor
            $0.numberOfLines = 0
        }
        let row = UIView()
        row.flex.direction(.row).alignItems(.start).define { flex in
            flex.addItem(tagLabel)
            flex.addItem(contentLabel).marginLeft(8).grow(1).shrink(1)
        }
        return row
    }

    private func setupAIFeedback() {
        let bubbleContainer = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.mainPurple.cgColor
            $0.layer.masksToBounds = false
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            $0.accessibilityIdentifier = "bubbleBox"
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
        aiFeedbackContainer.addSubview(tailImageView)
        bubbleContainer.addSubview(contentContainer)
        contentContainer.addSubview(iconImageView)
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(feedbackText)
        
        contentContainer.flex.paddingHorizontal(20).paddingVertical(21).define { contentFlex in
            contentFlex.addItem().direction(.row).alignItems(.center).define { titleFlex in
                titleFlex.addItem(iconImageView).size(28)
                titleFlex.addItem(titleLabel).marginLeft(4)
            }
            contentFlex.addItem(feedbackText).marginTop(24).marginBottom(12)
        }
        
        aiFeedbackContainer.flex.paddingBottom(22).define { flex in
            flex.addItem(bubbleContainer).define { bubbleFlex in
                bubbleFlex.addItem(contentContainer)
            }
        }
        
        populateStatusView(aiFeedbackStatus)
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
        let bubbles = [aiFeedbackContainer, feedbackLoadingBubble, feedbackRetryBubble, feedbackErrorBubble, feedbackLockedBubble]
        for bubble in bubbles {
            guard let tail = bubble.subviews.first(where: { $0.accessibilityIdentifier == "tailImageView" }) else { continue }
            tail.pin.bottom(1).right(0).width(40).height(22)
            bubble.bringSubviewToFront(tail)
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
        
        reactor.pulse(\.$myEmoji)
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] emoji in
                self?.updatePartnerEmojiUI(emoji: emoji)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$partnerEmoji)
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] emoji in
                self?.updateMyAnswerEmojiUI(emoji: emoji)
            })
            .disposed(by: disposeBag)
    }
    
    private func updatePartnerEmojiUI(emoji: EmojiType?) {
        print("🎯 updatePartnerEmojiUI called: \(String(describing: emoji))")
        guard let emojiRow = partnerAnswerContainer.viewWithTag(999) else { return }
        
        // 기존 flex children 제거
        emojiRow.subviews.forEach {
            $0.flex.isIncludedInLayout(false)
            $0.removeFromSuperview()
        }
        
        if let emoji {
            let emojiContainer = UIView().then {
                $0.backgroundColor = .lightPurple
                $0.layer.cornerRadius = 18
                $0.layer.borderWidth = 1
                $0.layer.borderColor = UIColor.mainPurple.cgColor
                $0.isUserInteractionEnabled = true
            }
            let emojiImage = UIImageView().then {
                $0.image = UIImage(named: emoji.imageName)
                $0.contentMode = .scaleAspectFit
            }
            emojiContainer.addSubview(emojiImage)
            emojiContainer.flex.width(52).height(36).justifyContent(.center).alignItems(.center).define { f in
                f.addItem(emojiImage).size(36)
            }
            
            if isCurrentWeek {
                let deleteTap = UITapGestureRecognizer(target: self, action: #selector(self.emojiDeleteTapped))
                emojiContainer.addGestureRecognizer(deleteTap)
            }
            
            let editButton = UIView().then {
                $0.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.emojiAddTapped(_:)))
                $0.addGestureRecognizer(tap)
            }
            let editImage = UIImageView().then {
                $0.image = UIImage(named: "emoji_add")
                $0.contentMode = .scaleAspectFit
            }
            editButton.addSubview(editImage)
            editButton.flex.size(24).justifyContent(.center).alignItems(.center).define { f in
                f.addItem(editImage).size(24)
            }
            self.emojiAddButton = editButton
            
            emojiRow.addSubview(emojiContainer)
            emojiRow.addSubview(editButton)
            emojiRow.flex.direction(.row).justifyContent(.end).alignItems(.center).define { flex in
                flex.addItem(emojiContainer)
                flex.addItem(editButton).marginLeft(10).alignSelf(.center)
            }
        } else {
            let addContainer = UIView().then {
                $0.backgroundColor = UIColor(hex: "F5F2F8")
                $0.layer.cornerRadius = 18
                $0.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.emojiAddTapped(_:)))
                $0.addGestureRecognizer(tap)
            }
            let addImage = UIImageView().then {
                $0.image = UIImage(named: "emoji_add")
                $0.contentMode = .scaleAspectFit
            }
            addContainer.addSubview(addImage)
            addContainer.flex.width(52).height(36).justifyContent(.center).alignItems(.center).define { f in
                f.addItem(addImage).size(28)
            }
            self.emojiAddButton = addContainer
            
            emojiRow.addSubview(addContainer)
            emojiRow.flex.direction(.row).justifyContent(.end).define { flex in
                flex.addItem(addContainer)
            }
        }
        
        emojiRow.flex.markDirty()
        partnerAnswerContainer.flex.layout()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
    }
    
    private func updateMyAnswerEmojiUI(emoji: EmojiType?) {
        // myAnswerContainer에서 tag 998로 이모지 row를 찾아 업데이트
        let existingRow = myAnswerContainer.viewWithTag(998)
        
        if let emoji {
            if let row = existingRow {
                row.subviews.forEach { $0.removeFromSuperview() }
                let emojiContainer = UIView().then {
                    $0.backgroundColor = UIColor(hex: "F5F2F8")
                    $0.layer.cornerRadius = 18
                }
                let emojiImage = UIImageView().then {
                    $0.image = UIImage(named: emoji.imageName)
                    $0.contentMode = .scaleAspectFit
                }
                emojiContainer.addSubview(emojiImage)
                emojiContainer.flex.width(52).height(36).justifyContent(.center).alignItems(.center).define { f in
                    f.addItem(emojiImage).size(36)
                }
                row.addSubview(emojiContainer)
                row.flex.direction(.row).justifyContent(.end).define { flex in
                    flex.addItem(emojiContainer)
                }
                row.flex.markDirty()
            } else {
                let row = UIView()
                row.tag = 998
                let emojiContainer = UIView().then {
                    $0.backgroundColor = UIColor(hex: "F5F2F8")
                    $0.layer.cornerRadius = 18
                }
                let emojiImage = UIImageView().then {
                    $0.image = UIImage(named: emoji.imageName)
                    $0.contentMode = .scaleAspectFit
                }
                emojiContainer.addSubview(emojiImage)
                emojiContainer.flex.width(52).height(36).justifyContent(.center).alignItems(.center).define { f in
                    f.addItem(emojiImage).size(36)
                }
                row.addSubview(emojiContainer)
                row.flex.direction(.row).justifyContent(.end).define { flex in
                    flex.addItem(emojiContainer)
                }
                myAnswerContainer.addSubview(row)
                myAnswerContainer.flex.addItem(row).marginTop(12)
            }
        } else {
            existingRow?.subviews.forEach { $0.removeFromSuperview() }
            existingRow?.flex.isIncludedInLayout(false)
        }
        
        myAnswerContainer.flex.markDirty()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
        
        if let row = myAnswerContainer.viewWithTag(998) {
            row.alpha = 0
            UIView.animate(withDuration: 0.25) {
                row.alpha = 1
            }
        }
    }
    
    private func updateFeedbackUI(state: HistoryCardDetailReactor.FeedbackState) {
        let allBubbles = [aiFeedbackContainer, feedbackLoadingBubble, feedbackRetryBubble, feedbackErrorBubble, feedbackLockedBubble]
        let allStatuses = [aiFeedbackStatus, feedbackLoadingStatus, feedbackRetryStatus, feedbackErrorStatus]
        
        func show(bubble: UIView, status: UIView?, animated: Bool = false) {
            allBubbles.forEach {
                $0.flex.isIncludedInLayout($0 === bubble)
                $0.isHidden = $0 !== bubble
            }
            allStatuses.forEach {
                let visible = $0 === status
                $0.flex.isIncludedInLayout(visible)
                $0.isHidden = !visible
            }
            rootFlexContainer.flex.layout(mode: .adjustHeight)
            scrollView.contentSize = rootFlexContainer.frame.size
            layoutTail()
            
            guard animated else { return }
            bubble.alpha = 0
            bubble.transform = CGAffineTransform(translationX: 0, y: 10)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                bubble.alpha = 1
                bubble.transform = .identity
            }
        }
        
        switch state {
        case .none:
            allBubbles.forEach { $0.flex.isIncludedInLayout(false); $0.isHidden = true }
            allStatuses.forEach { $0.flex.isIncludedInLayout(false); $0.isHidden = true }
            rootFlexContainer.flex.layout(mode: .adjustHeight)
            scrollView.contentSize = rootFlexContainer.frame.size
            
        case .locked:
            show(bubble: feedbackLockedBubble, status: nil)
            
        case .generating:
            didShowLoading = true
            show(bubble: feedbackLoadingBubble, status: feedbackLoadingStatus)
            
        case .loaded(let feedback):
            if let label = feedbackLabel { updateFeedbackLabel(label, with: feedback) }
            show(bubble: aiFeedbackContainer, status: aiFeedbackStatus, animated: didShowLoading)
            
        case .retryable:
            show(bubble: feedbackRetryBubble, status: feedbackRetryStatus, animated: true)
            
        case .error:
            show(bubble: feedbackErrorBubble, status: feedbackErrorStatus, animated: true)
        }
    }
    
    // MARK: - Feedback State Views
    
    private func setupFeedbackLoadingView() {
        let (boxView, tail) = makeFeedbackBubbleBox()
        let header = makeFeedbackHeader()
        let loadingContent = UIView()
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
        
        feedbackLoadingBubble.addSubview(boxView)
        feedbackLoadingBubble.addSubview(tail)
        boxView.addSubview(loadingContent)
        
        loadingContent.flex.alignItems(.center).define { flex in
            flex.addItem(lottie).size(60)
            flex.addItem(loadingLabel).marginTop(4)
        }
        
        feedbackLoadingBubble.flex.paddingBottom(22).define { flex in
            flex.addItem(boxView).paddingHorizontal(20).paddingVertical(21).define { f in
                f.addItem(header)
                f.addItem(loadingContent).marginTop(16).alignSelf(.center)
            }
        }
        populateStatusView(feedbackLoadingStatus)
    }
    
    private func setupFeedbackRetryView() {
        let (boxView, tail) = makeFeedbackBubbleBox()
        let header = makeFeedbackHeader()
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
        let retryButton = UIButton().then {
            var config = UIButton.Configuration.plain()
            config.imagePadding = 6
            config.imagePlacement = .trailing
            config.image = UIImage(systemName: "arrow.clockwise")?.withTintColor(.white, renderingMode: .alwaysOriginal).resized(to: CGSize(width: 24, height: 24))
            config.attributedTitle = AttributedString("다시 불러오기", attributes: AttributeContainer([
                .font: UIFont.pretenSemiBold(16),
                .foregroundColor: UIColor.white
            ]))
            config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
            $0.configuration = config
            $0.backgroundColor = .darkPurple
            $0.layer.cornerRadius = 17
            $0.clipsToBounds = true
        }
        
        feedbackRetryBubble.addSubview(boxView)
        feedbackRetryBubble.addSubview(tail)
        feedbackRetryBubble.flex.paddingBottom(22).define { flex in
            flex.addItem(boxView).paddingHorizontal(20).paddingVertical(21).define { f in
                f.addItem(header)
                f.addItem(emojiImageView).width(38).height(38).alignSelf(.center).marginTop(16)
                f.addItem(errorLabel).marginTop(11).alignSelf(.center)
                f.addItem(retryButton).marginTop(16).alignSelf(.center)
            }
        }
        populateStatusView(feedbackRetryStatus)
        
        retryButton.rx.tap
            .map { HistoryCardDetailReactor.Action.regenerate }
            .bind(to: reactor!.action)
            .disposed(by: disposeBag)
    }
    
    private func setupFeedbackErrorView() {
        let (boxView, tail) = makeFeedbackBubbleBox()
        let header = makeFeedbackHeader()
        let emojiImageView = UIImageView().then {
            $0.image = UIImage(named: "FeedbackUnsmile")
            $0.contentMode = .scaleAspectFit
        }
        let errorLabel = TDLabel().then {
            $0.text = "피드백을 불러올 수 없어요\n잠시 후 다시 시도해 주세요"
            $0.font = .pretenBold(16)
            $0.textColor = .mainPurple
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        feedbackErrorBubble.addSubview(boxView)
        feedbackErrorBubble.addSubview(tail)
        feedbackErrorBubble.flex.paddingBottom(22).define { flex in
            flex.addItem(boxView).paddingHorizontal(20).paddingVertical(21).define { f in
                f.addItem(header)
                f.addItem(emojiImageView).width(38).height(38).alignSelf(.center).marginTop(16)
                f.addItem(errorLabel).marginTop(11).alignSelf(.center)
            }
        }
        populateStatusView(feedbackErrorStatus)
    }
    
    private func setupFeedbackLockedView() {
        let (boxView, tail) = makeFeedbackBubbleBox()
        let header = makeFeedbackHeader()
        let lockedLabel = TDLabel().then {
            $0.text = "🔒 둘 다 답변을 완료해야 AI 피드백이 생성돼요"
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale600
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        feedbackLockedBubble.addSubview(boxView)
        feedbackLockedBubble.addSubview(tail)
        feedbackLockedBubble.flex.paddingBottom(22).define { flex in
            flex.addItem(boxView).paddingHorizontal(20).paddingVertical(21).define { f in
                f.addItem(header)
                f.addItem(lockedLabel).marginTop(16).alignSelf(.center)
            }
        }
    }
    
    private func makeFeedbackBubbleBox() -> (UIView, UIImageView) {
        let box = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.mainPurple.cgColor
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        }
        return (box, makeTailImageView())
    }
    
    private func makeFeedbackHeader() -> UIView {
        let iconImageView = UIImageView().then {
            $0.image = UIImage(named: "book_fill")
            $0.contentMode = .scaleAspectFit
        }
        let titleLabel = TDLabel().then {
            $0.text = "AI 피드백"
            $0.font = .pretenSemiBold(16)
            $0.textColor = .mainPurple
        }
        let header = UIView()
        header.flex.direction(.row).alignItems(.center).define { flex in
            flex.addItem(iconImageView).size(28)
            flex.addItem(titleLabel).marginLeft(4)
        }
        return header
    }
    
    private func makeTailImageView() -> UIImageView {
        UIImageView().then {
            $0.image = UIImage(named: "BoxTail")
            $0.contentMode = .scaleAspectFit
            $0.accessibilityIdentifier = "tailImageView"
        }
    }
    
    private func populateStatusView(_ view: UIView) {
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
        view.flex.paddingTop(12).define { flex in
            flex.addItem(statusLabel)
            flex.addItem(subtitleLabel).marginTop(4)
        }
    }
    
    private func updateFeedbackLabel(_ label: MaskingLabel, with feedback: CardFeedback) {
        let bold = UIFont.pretenBold(16)
        let regular = UIFont.pretenRegular(16)
        let kern: CGFloat = 1.26
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 3.0
        paraStyle.lineBreakMode = .byWordWrapping
        paraStyle.lineBreakStrategy = .hangulWordPriority
        let baseAttrs: [NSAttributedString.Key: Any] = [.kern: kern, .paragraphStyle: paraStyle]
        
        let attr = NSMutableAttributedString(string: "", attributes: baseAttrs)
        let titles = ["요약", "공통점", "차이점", "조언"]
        let bodies = [feedback.summary, feedback.matchPoints, feedback.differences, feedback.tip]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        for (i, title) in titles.enumerated() {
            guard !bodies[i].isEmpty else { continue }
            if attr.length > 0 { attr.append(NSAttributedString(string: "\n\n", attributes: baseAttrs)) }
            var boldAttrs = baseAttrs; boldAttrs[.font] = bold
            var regularAttrs = baseAttrs; regularAttrs[.font] = regular
            attr.append(NSAttributedString(string: title, attributes: boldAttrs))
            attr.append(NSAttributedString(string: "\n" + bodies[i], attributes: regularAttrs))
        }
        label.attributedText = attr
    }
    
    func navigateBack() {
        coordinator?.navigateBack()
    }
}

// MARK: - UIScrollViewDelegate
extension HistoryCardDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !emojiPalette.isHidden {
            emojiPalette.dismiss()
        }
    }
}
