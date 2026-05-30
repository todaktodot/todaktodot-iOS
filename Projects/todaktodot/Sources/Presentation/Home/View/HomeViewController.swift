//
//  HomeViewController.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift
import RxCocoa
import UserNotifications
import Then

final class HomeViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    private let gradientLayer = CAGradientLayer()
    private let rootFlexContainer = UIView()
    private let scrollView = UIScrollView()
    private let contentContainer = UIView()
    private var firstAnimation = true
    private var currentAnswerStatus: AnswerStatus?
    private var hasShownCardTypeTooltip = false
    private var liftedCardView: UIView?
    private var skeletonShownAt: CFTimeInterval = 0
    private var isHidingSkeleton = false
    private let mainCard = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.05
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 8
    }
    
    private let mainCardSkeleton = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.05
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 8
        $0.isHidden = true
    }
    
    private let skeletonShimmerLayer = CAGradientLayer()
    
    private let retryFetchButton = UIButton().then {
        $0.isHidden = true
        var config = UIButton.Configuration.plain()
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.image = UIImage(named: "retry")?.resizedWithBetterQuality(to: CGSize(width: 28, height: 28))
        config.attributedTitle = AttributedString("질문 불러오기", attributes: AttributeContainer([
            .font: UIFont.pretenSemiBold(16),
            .foregroundColor: UIColor.mainPurple
        ]))
        config.background.backgroundColor = .white
        config.background.strokeColor = .mainPurple
        config.background.strokeWidth = 1
        config.background.cornerRadius = 6
        config.cornerStyle = .fixed
        $0.configuration = config
    }
    private let chipRow = UIView()
    
    private let yearLabel = TDLabel().then {
        $0.text = "2025년 9월 14일 일요일"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale600
    }
    private let questionIcon = UIImageView().then {
        $0.image = UIImage(systemName: "questionmark.circle")
        $0.tintColor = .grayScale600
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
    }
    private let titleLabel = TDLabel().then {
        $0.font = .pretenSemiBold(24)
        $0.numberOfLines = 0
        $0.textColor = .grayScale900
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        $0.attributedText = NSAttributedString(
            string: "오늘의 질문이 도착했어요\n먼저 답해볼까요?",
            attributes: [.paragraphStyle: paragraphStyle]
        )
    }
    private let chip1 = ChipView(title: "🍰 디저트모드")
    private let chip2 = ChipView(title: "💸 경제관")
    private lazy var chip3 = ChipView(title: "⚖️ 밸런스게임").then {
        $0.isHidden = true
    }
    
    private let cardTypeTooltipContainer = UIView().then {
        $0.isHidden = true
        $0.layer.zPosition = 100
    }
    private let cardTypeTooltipImageView = UIImageView().then {
        $0.image = UIImage(named: "cardtypeTooltip")
        $0.contentMode = .scaleToFill
    }
    private let cardTypeTooltipLabel = TDLabel().then {
        $0.text = "연인이 먼저 선택한 유형이에요"
        $0.font = .pretenMedium(12)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let arrowButton = UIButton().then {
        $0.backgroundColor = TodotColors.Button.purpleButton1
        $0.layer.cornerRadius = 24
        let arrowConfig = UIImage.SymbolConfiguration(weight: .semibold)
        $0.setImage(UIImage(systemName: "arrow.right", withConfiguration: arrowConfig), for: .normal)
        $0.tintColor = .white
        $0.isUserInteractionEnabled = true
        $0.layer.zPosition = 100
    }
    private let pokeButton = UIButton().then {
        $0.setTitle("콕 찌르기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(14)
        $0.backgroundColor = TodotColors.Button.purpleButton1
        $0.layer.cornerRadius = 6
        $0.isHidden = true
    }
    private let descriptionCard = UIView().then {
        $0.backgroundColor = .grayScale100
        $0.layer.cornerRadius = 12
    }
    
    private let descriptionTitle = TDLabel().then {
        $0.text = "하루에 딱 1개의 질문만 주어져요!"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale800
        $0.numberOfLines = 0
    }
    
    private let descriptionLabel = TDLabel().then {
        $0.font = .pretenRegular(14)
        $0.textColor = .grayScale600
        $0.numberOfLines = 0
    }
    
    private let timezoneNoticeLabel = TDLabel().then {
        $0.numberOfLines = 0
        $0.isHidden = NSTimeZone.system.identifier == "Asia/Seoul"
        let text = "* 모든 시간은 한국 시간을 기준으로 안내돼요"
        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.pretenRegular(12),
            .foregroundColor: UIColor.grayScale600
        ])
        attr.addAttribute(.font, value: UIFont.pretenBold(12), range: (text as NSString).range(of: "한국 시간을 기준"))
        $0.attributedText = attr
    }
    
    private let tooltipContainer = TouchPassthroughView().then {
        $0.isHidden = true
        $0.clipsToBounds = false
    }
    
    private let tooltipImageView = UIImageView().then {
        $0.image = UIImage(named: "tooltip")
        $0.contentMode = .scaleToFill
    }
    
    private let tooltipLabel = TDLabel().then {
        $0.text = "방금 완성된 오늘의 대화예요!\n눌러서 확인해보세요 🙂"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale800
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let weekCardsContainer = UIView()
    var historyCards: [QuestionCard] = []
    private var isLoadingHistoryCards = true
    private let shimmerLayer = CAGradientLayer()
    
    init(reactor: HomeReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 테스트용 배치
        // reactor?.action.onNext(.assignCards)
        setupUI()
        showMainCardSkeleton()
        reactor?.action.onNext(.initialLoad)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCardAnswerStatusChanged),
            name: .cardAnswerStatusChanged,
            object: nil
        )
    }
    
    private func fetchAllCards() {
        let savedTodayCards = CardService.shared.getTodayCards()
        
        if let lastWeeklyDate = UserdefaultKey.lastWeeklyCardDate,
           lastWeeklyDate >= Date(),
           !savedTodayCards.isEmpty {
            print("✅ 주간 카드 저장됨")
            reactor?.action.onNext(.loadTodayCards)
        } else {
            print("📥 주간 카드 백그라운드 패치 시작")
            fetchWeeklyCards()
        }
    }
    
    private var hasAppeared = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.checkCoupleConnection)
        if let status = currentAnswerStatus {
            updateMainCard(for: status)
        }
        if hasAppeared {
            fetchHistoryCards()
        }
        hasAppeared = true
    }    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tooltipContainer.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserdefaultKey.isInitialLogin == true {
            showNotificationAlert()
            UserdefaultKey.isInitialLogin = false
        }
        
        PushRouter.shared.consumePending()
    }
    
    func bind(reactor: HomeReactor) {
        reactor.state.map { $0.historyCards }
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] historyCards in
                guard let self = self else { return }
                self.historyCards = historyCards
                self.isLoadingHistoryCards = false
                
                // loading 중이면 데이터만 저장, UI는 updateCardLoadState에서 처리
                guard self.reactor?.currentState.cardLoadState == .loaded else { return }
                
                self.updateWeekCards()
                self.updateMainCardFromHistory(historyCards)
                self.refreshAnswerStatus()
                if firstAnimation {
                    cardAmimation()
                    firstAnimation = false
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.shouldShowTooltip }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldShow in
                guard let self = self else { return }
                
                if shouldShow {
                    self.tooltipContainer.alpha = 0
                    self.tooltipContainer.isHidden = false
                    self.tooltipContainer.transform = CGAffineTransform(translationX: 0, y: -10)
                    
                    UIView.animate(
                        withDuration: 0.5,
                        delay: 0.3,
                        usingSpringWithDamping: 0.7,
                        initialSpringVelocity: 0.5,
                        options: .curveEaseOut
                    ) {
                        self.tooltipContainer.alpha = 1
                        self.tooltipContainer.transform = .identity
                    }
                } else {
                    // 이미 애니메이션 중이거나 보이는 상태면 숨기지 않음
                    if self.tooltipContainer.alpha == 0 {
                        self.tooltipContainer.isHidden = true
                    }
                }
            })
            .disposed(by: disposeBag)
        
        let answerStatusStream = reactor.state.map { $0.answerStatus }.distinctUntilChanged()
        let coupleConnectedStream = reactor.state.map { $0.isCoupleConnected }.distinctUntilChanged()
        
        answerStatusStream
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                guard self?.reactor?.currentState.cardLoadState == .loaded else { return }
                self?.updateMainCard(for: status)
            })
            .disposed(by: disposeBag)
        
        let isPokedStream = reactor.state.map { $0.isPoked }.distinctUntilChanged().share(replay: 1)
        
        isPokedStream
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isPoked in
                self?.updatePokeButton(isPoked: isPoked)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$didPokeSuccess)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showPokeAlert()
                self?.reactor?.action.onNext(.dismissPokeSuccess)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(answerStatusStream, coupleConnectedStream)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status, isCoupleConnected in
                guard self?.reactor?.currentState.cardLoadState == .loaded else { return }
                self?.updateMainCard(for: status)
                self?.updateButtonForMyAnswered(status: status, isCoupleConnected: isCoupleConnected)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.shouldShowNotificationAlert }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] show in
                if show {
                    self?.showNotificationAlert()
                }
            })
            .disposed(by: disposeBag)
        
        pokeButton.rx.tap
            .withLatestFrom(reactor.state.map { ($0.answerStatus, $0.isCoupleConnected, $0.historyCards) })
            .subscribe(onNext: { [weak self] status, isCoupleConnected, historyCards in
                if status == .myAnswered && !isCoupleConnected {
                    self?.coordinator?.tabBarCoordinator?.showCoupleConnect()
                } else {
                    let cardSystemDate = CardService.shared.getCardSystemDate()
                    let todayCard = historyCards.first { Calendar.current.isDate($0.date, inSameDayAs: cardSystemDate) }
                    
                    if let coupleCardId = todayCard?.coupleCardId {
                        reactor.action.onNext(.tapPokeButton(coupleCardId: coupleCardId))
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.shouldShowPokeError }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, let reactor = self.reactor else { return }
                self.showPokeErrorAlert()
                reactor.action.onNext(.dismissPokeError)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.weeklyCardsFetchFailed }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showWeeklyCardsFetchFailedAlert()
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$cardLoadState)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.updateCardLoadState(state)
            })
            .disposed(by: disposeBag)
        
        retryFetchButton.rx.tap
            .map { HomeReactor.Action.retryFetchCards }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        arrowButton.rx.tap
            .do(onNext: { print("🔘 Arrow button tap detected!") })
            .withLatestFrom(reactor.state.map { $0.answerStatus })
            .subscribe(onNext: { [weak self] status in
                guard let self = self else { return }
                
                if self.isAnswerSubmissionUnavailable(for: status) {
                    self.updateMainCard(for: status)
                    self.showAnswerUnavailableAlert()
                    self.fetchHistoryCards()
                    return
                }
                
                reactor.action.onNext(.checkPartnerSelection)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$partnerSelectedCard)
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] card in
                guard let self else { return }
                if let card {
                    switch card.type {
                    case .roleplay:
                        self.coordinator?.showDailyCardDetail(card: card)
                    case .balance:
                        self.coordinator?.showBalanceCardDetail(card: card)
                    case .none:
                        let todayCards = CardService.shared.getTodayCards()
                        self.coordinator?.showDailyCard(todayCards: todayCards, selectedType: .none)
                    }
                } else {
                    let todayCards = CardService.shared.getTodayCards()
                    self.coordinator?.showDailyCard(todayCards: todayCards, selectedType: .none)
                }
            })
            .disposed(by: disposeBag)
    }
    private func setupUI() {
        gradientLayer.colors = [
            UIColor(hex: "F9F2EE").cgColor,
            UIColor(hex: "F1EBF5").cgColor,
            UIColor(hex: "FCFAFE").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentContainer)
        
        setupMainCard()
        
        tooltipContainer.addSubview(tooltipImageView)
        tooltipContainer.flex.define { flex in
            flex.addItem(tooltipLabel)
        }
        
        contentContainer.flex
            .paddingHorizontal(20)
            .paddingBottom(150)
            .define { flex in
                flex.addItem(mainCard).marginTop(20)
                flex.addItem(mainCardSkeleton).marginVertical(20).position(.absolute).top(0).left(20).right(20)
                flex.addItem().marginTop(36).width(100%).define { wrapperFlex in
                    wrapperFlex.view?.clipsToBounds = false
                    wrapperFlex.addItem(weekCardsContainer)
                    
                    wrapperFlex.addItem(tooltipContainer)
                        .paddingLeft(40)
                        .paddingRight(50)
                        .paddingTop(30)
                        .paddingBottom(45)
                        .top(-35)
                        .right(-20)
                        .position(.absolute)
                }
            }
    }
    
    private func updateWeekCards() {
        setupHistoryCards()
        view.setNeedsLayout()
    }
    
    private func refreshAnswerStatus() {
        let cardSystemDate = CardService.shared.getCardSystemDate()
        guard let card = historyCards.first(where: { Calendar.current.isDate($0.date, inSameDayAs: cardSystemDate) }) else {
            print("⚠️ refreshAnswerStatus: 오늘 카드 못 찾음, historyCards count: \(historyCards.count)")
            return
        }
        let status: AnswerStatus
        if card.user1Answered && card.user2Answered {
            status = .bothAnswered
        } else if card.user1Answered {
            status = .myAnswered
        } else if card.user2Answered {
            status = .partnerAnswered
        } else {
            status = .bothUnanswered
        }
        print("✅ refreshAnswerStatus: \(status), user1: \(card.user1Answered), user2: \(card.user2Answered)")
        updateMainCard(for: status)
    }
    
    private func fetchHistoryCards() {
        /// 월요일부터 오늘까지 (8시 기준)
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let today = CardService.shared.getCardSystemDate()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        guard let startOfWeek = calendar.date(from: components) else { return }
        
        let startDate = startOfWeek.toYYYYMMDD()
        let endDate = today.toYYYYMMDD()
        
        print("📅 조회 범위: \(startDate) ~ \(endDate)")
        reactor?.action.onNext(.fetchHistoryCards(startDate: startDate, endDate: endDate))
    }
    
    
    private func fetchWeeklyCards() {
        /// 오늘부터 다음 일요일까지 (8시 기준)
        let calendar = Calendar.current
        let today = CardService.shared.getCardSystemDate()
        
        guard let nextSunday = calendar.nextDate(after: today, matching: DateComponents(weekday: 1), matchingPolicy: .nextTime) else {
            return
        }
        
        let startDate = today.toYYYYMMDD()
        let endDate = nextSunday.toYYYYMMDD()
        reactor?.action.onNext(.fetchWeeklyCards(startDate: startDate, endDate: endDate))
    }
    
    @objc private func showInfoPopup() {
        let popupView = InfoPopupView()
        popupView.show(in: view, alignedWith: mainCard)
        AnalyticsService.log(.guideClick)
    }
    
    @objc private func appWillEnterForeground() {
        if let status = currentAnswerStatus {
            updateMainCard(for: status)
        }
        fetchHistoryCards()
    }
    
    @objc private func handleCardAnswerStatusChanged() {
        fetchHistoryCards()
    }
    
    private func updatePokeButton(isPoked: Bool) {
        if isPoked {
            pokeButton.setTitle("찌르기 완료", for: .normal)
            pokeButton.backgroundColor = .grayScale300
            pokeButton.isEnabled = false
        } else {
            pokeButton.setTitle("콕 찌르기", for: .normal)
            pokeButton.backgroundColor = TodotColors.Button.purpleButton1
            pokeButton.isEnabled = true
        }
    }
    
    private func isAnswerSubmissionUnavailable(for status: AnswerStatus) -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        let isClosedHours = hour >= 4 && hour < 8
        let hasNotAnswered = status == .bothUnanswered || status == .partnerAnswered
        return isClosedHours && hasNotAnswered
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = view.bounds
        
        scrollView.pin.all(view.pin.safeArea)
        contentContainer.pin.top().left().right()
        
        let previousHeight = contentContainer.frame.height
        contentContainer.flex.layout(mode: .adjustHeight)
        
        tooltipContainer.flex.layout(mode: .adjustHeight)
        tooltipImageView.frame = tooltipContainer.bounds
        
        if previousHeight != contentContainer.frame.height {
            scrollView.contentSize = contentContainer.frame.size
        }
    }
}

// MARK: - MainCard UI
extension HomeViewController {
    
    private func setupMainCard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showInfoPopup))
        questionIcon.addGestureRecognizer(tapGesture)
        
        let descParagraphStyle = NSMutableParagraphStyle()
        descParagraphStyle.lineHeightMultiple = 1.3
        descriptionLabel.attributedText = NSAttributedString(
            string: "매일 08시 업데이트· 다음날 04시 작성 마감\n04시~ 08시 사이에는 답변할 수 없어요",
            attributes: [.paragraphStyle: descParagraphStyle]
        )
        
        [yearLabel, questionIcon, titleLabel, chip1, chip2, chip3, arrowButton, descriptionCard, pokeButton, retryFetchButton]
            .forEach {mainCard.addSubview($0)}
        [descriptionTitle, descriptionLabel].forEach {descriptionCard.addSubview($0)}
        
        cardTypeTooltipContainer.addSubview(cardTypeTooltipImageView)
        cardTypeTooltipContainer.addSubview(cardTypeTooltipLabel)
        
        mainCard.flex
            .padding(24)
            .define { flex in
                flex.addItem(questionIcon).position(.absolute).top(20).right(20).size(24)
                flex.addItem(yearLabel)
                flex.addItem(titleLabel).marginTop(8)
                flex.addItem(chipRow).direction(.row).justifyContent(.spaceBetween).alignItems(.start).marginTop(16).define { rowFlex in
                    rowFlex.addItem().direction(.column).define { chipContainer in
                        chipContainer.addItem().direction(.row).define { firstRow in
                            firstRow.addItem(chip1).height(37).width(chip1.intrinsicContentSize.width)
                            firstRow.addItem(chip2).height(37).width(chip2.intrinsicContentSize.width).marginLeft(4)
                        }
                        chipContainer.addItem(chip3).height(37).width(chip3.intrinsicContentSize.width).marginTop(9).isIncludedInLayout(false)
                    }
                    rowFlex.addItem(arrowButton).size(48).marginLeft(16)
                }
                flex.addItem(descriptionCard).direction(.column).marginTop(20).define { descFlex in
                    descFlex.addItem(descriptionTitle).marginTop(16).marginLeft(16)
                    let showNotice = NSTimeZone.system.identifier != "Asia/Seoul"
                    descFlex.addItem(descriptionLabel).marginTop(4).marginLeft(16).marginBottom(showNotice ? 0 : 16)
                    descFlex.addItem(timezoneNoticeLabel).marginTop(8).marginLeft(16).marginBottom(16).isIncludedInLayout(showNotice)
                }
                flex.addItem(retryFetchButton).height(48).marginTop(20)
                flex.addItem(pokeButton).height(48).marginTop(16)
            }
        
        setupMainCardSkeleton()
        mainCard.addSubview(cardTypeTooltipContainer)
        cardTypeTooltipContainer.flex.isIncludedInLayout(false)
    }
    
    private func setupMainCardSkeleton() {
        let skeletonBoxes = (0..<5).map { _ in
            UIView().then {
                $0.backgroundColor = .grayScale200
                $0.layer.cornerRadius = 4
            }
        }
        
        skeletonBoxes.forEach { mainCardSkeleton.addSubview($0) }
        
        mainCardSkeleton.flex
            .padding(24)
            .define { flex in
                flex.addItem(skeletonBoxes[0]).height(20).width(180)
                flex.addItem(skeletonBoxes[1]).height(70).marginTop(8)
                flex.addItem(skeletonBoxes[2]).height(37).width(240).marginTop(16)
                flex.addItem(skeletonBoxes[3]).height(90).marginTop(20)
                flex.addItem(skeletonBoxes[4]).height(48).marginTop(16)
            }
        
        skeletonBoxes.forEach { addWaveToBox($0) }
    }
    
    private func addWaveToBox(_ box: UIView) {
        let overlay = UIView()
        overlay.backgroundColor = .white
        overlay.layer.cornerRadius = 4
        overlay.alpha = 0
        
        box.addSubview(overlay)
        overlay.frame = box.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let waveAnimation = CAKeyframeAnimation(keyPath: "opacity")
        waveAnimation.values = [0.0, 0.3, 0.6, 0.3, 0.0]
        waveAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        waveAnimation.duration = 1.5
        waveAnimation.repeatCount = .infinity
        waveAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        overlay.layer.add(waveAnimation, forKey: "wave")
    }
    
    private func showMainCardSkeleton() {
        skeletonShownAt = CACurrentMediaTime()
        mainCard.alpha = 0
        mainCard.isHidden = true
        mainCardSkeleton.isHidden = false
    }
    
    private func showCardTypeTooltip(_ show: Bool) {
        guard show else {
            cardTypeTooltipContainer.isHidden = true
            return
        }
        
        cardTypeTooltipLabel.sizeToFit()
        let tooltipSize = CGSize(
            width: cardTypeTooltipLabel.frame.width + 16,
            height: cardTypeTooltipLabel.frame.height + 16
        )
        
        let chip3Frame = chip3.convert(chip3.bounds, to: mainCard)
        cardTypeTooltipContainer.frame = CGRect(
            x: chip3Frame.minX + 11,
            y: chip3Frame.maxY - 7,
            width: tooltipSize.width,
            height: tooltipSize.height
        )
        cardTypeTooltipImageView.frame = cardTypeTooltipContainer.bounds
        cardTypeTooltipLabel.center = CGPoint(x: tooltipSize.width / 2, y: tooltipSize.height / 2 + 2)
        
        if hasShownCardTypeTooltip {
            cardTypeTooltipContainer.alpha = 1
            cardTypeTooltipContainer.isHidden = false
            return
        }
        hasShownCardTypeTooltip = true
        
        cardTypeTooltipContainer.alpha = 0
        cardTypeTooltipContainer.isHidden = false
        cardTypeTooltipContainer.transform = CGAffineTransform(translationX: 0, y: -8)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.cardTypeTooltipContainer.alpha = 1
            self.cardTypeTooltipContainer.transform = .identity
        }
    }
    
    private func hideMainCardSkeleton() {
        guard !isHidingSkeleton else { return }
        isHidingSkeleton = true
        mainCard.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.mainCardSkeleton.alpha = 0
            self.mainCard.alpha = 1
        }) { _ in
            self.isHidingSkeleton = false
            self.mainCardSkeleton.isHidden = true
            self.mainCardSkeleton.alpha = 1
        }
    }
    
    private func updateCardLoadState(_ state: CardLoadState) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        
        switch state {
        case .loading:
            weekCardsContainer.isHidden = true
            showMainCardSkeleton()
            return
            
        case .loaded:
            // 히스토리카드 렌더링
            updateWeekCards()
            weekCardsContainer.isHidden = false
            
            // 메인카드 렌더링
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE"
            yearLabel.text = dateFormatter.string(from: CardService.shared.getCardSystemDate())
            chipRow.isHidden = false
            chipRow.flex.isIncludedInLayout(true)
            descriptionCard.isHidden = false
            descriptionCard.flex.isIncludedInLayout(true)
            retryFetchButton.isHidden = true
            retryFetchButton.flex.isIncludedInLayout(false)
            mainCard.flex.paddingBottom(24)
            
            // 내부 상태값 반영 (answerStatus, 칩, 날짜 등)
            let cards = reactor?.currentState.historyCards ?? []
            self.historyCards = cards
            let cardSystemDate = CardService.shared.getCardSystemDate()
            let todayHistoryCard = cards.first { Calendar.current.isDate($0.date, inSameDayAs: cardSystemDate) }
            if let card = todayHistoryCard {
                let status: AnswerStatus
                if card.user1Answered && card.user2Answered {
                    status = .bothAnswered
                } else if card.user1Answered {
                    status = .myAnswered
                } else if card.user2Answered {
                    status = .partnerAnswered
                } else {
                    status = .bothUnanswered
                }
                updateMainCard(for: status)
            } else if let status = reactor?.currentState.answerStatus {
                updateMainCard(for: status)
            }
            updateMainCardFromHistory(cards)
            
            // 모든 요소 세팅 완료 후 한 번에 스켈레톤 페이드아웃
            hideMainCardSkeleton()
            
            // 히스토리 기반 답변 상태 최종 반영
            refreshAnswerStatus()
            
            if firstAnimation {
                cardAmimation()
                firstAnimation = false
            }
            return
            
        case .retryable:
            yearLabel.text = "데일리카드 생성 오류"
            titleLabel.attributedText = NSAttributedString(
                string: "오늘의 질문을\n가져오지 못했어요",
                attributes: [.paragraphStyle: paragraphStyle]
            )
            retryFetchButton.isHidden = false
            retryFetchButton.flex.isIncludedInLayout(true).height(44).marginTop(20).marginHorizontal(-4)
            
        case .error:
            yearLabel.text = "데일리카드 생성 오류"
            titleLabel.attributedText = NSAttributedString(
                string: "질문 불러오기에 실패했어요\n잠시 후 다시 시도해 주세요",
                attributes: [.paragraphStyle: paragraphStyle]
            )
            retryFetchButton.isHidden = true
            retryFetchButton.flex.isIncludedInLayout(false)
        }
        
        chipRow.isHidden = true
        chipRow.flex.isIncludedInLayout(false)
        descriptionCard.isHidden = true
        descriptionCard.flex.isIncludedInLayout(false)
        arrowButton.isHidden = true
        pokeButton.isHidden = true
        pokeButton.flex.isIncludedInLayout(false)
        cardTypeTooltipContainer.isHidden = true
        
        titleLabel.flex.markDirty()
        mainCard.flex.paddingBottom(32).markDirty()
        hideMainCardSkeleton()
        contentContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = contentContainer.frame.size
    }
    
    private func updateMainCard(for status: AnswerStatus, caller: String = #function) {
        // 이미 답변 상태가 확인된 후에 bothUnanswered로 되돌리지 않음
        if status == .bothUnanswered && currentAnswerStatus != nil && currentAnswerStatus != .bothUnanswered {
            return
        }
        let isFirstSet = currentAnswerStatus == nil
        let previousStatus = currentAnswerStatus
        currentAnswerStatus = status
        let shouldAnimatePokeButton = !isFirstSet && previousStatus != .myAnswered && status == .myAnswered
        
        let applyUpdate = { [self] in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.5
            let isAnswerUnavailable = isAnswerSubmissionUnavailable(for: status)
            
            pokeButton.flex.isIncludedInLayout(false)
            
            switch status {
            case .bothUnanswered:
                titleLabel.attributedText = NSAttributedString(
                    string: isAnswerUnavailable
                    ? "지금은 답변할 수 없어요\n오전 8시에 새 질문이 도착해요"
                    : "오늘의 질문이 도착했어요\n먼저 답해볼까요?",
                    attributes: [.paragraphStyle: paragraphStyle]
                )
                pokeButton.isHidden = true
                arrowButton.isHidden = isAnswerUnavailable
                
            case .partnerAnswered:
                titleLabel.attributedText = NSAttributedString(
                    string: isAnswerUnavailable
                    ? "답변할 수 없어요\n오전 8시에 새 질문이 도착해요"
                    : "연인이 벌써 답했어요!\n내가 답하면 바로\n확인할 수 있어요",
                    attributes: [.paragraphStyle: paragraphStyle]
                )
                pokeButton.isHidden = true
                arrowButton.isHidden = isAnswerUnavailable
                
            case .myAnswered:
                let isCoupleConnected = reactor?.currentState.isCoupleConnected ?? false
                titleLabel.attributedText = NSAttributedString(
                    string: isCoupleConnected
                    ? "답변 완료!\n연인이 답하기 전까지\n확인할 수 없어요"
                    : "답변 완료!\n연인과 연결되지 않아\n확인할 수 없어요",
                    attributes: [.paragraphStyle: paragraphStyle]
                )
                pokeButton.isHidden = false
                pokeButton.flex.isIncludedInLayout(true).height(48).marginTop(16)
                arrowButton.isHidden = true
                
            case .bothAnswered:
                titleLabel.attributedText = NSAttributedString(
                    string: "두 사람 모두 답변 완료!\n아래 카드에서 내용을\n확인해보세요",
                    attributes: [.paragraphStyle: paragraphStyle]
                )
                pokeButton.isHidden = true
                arrowButton.isHidden = true
            }
            
            titleLabel.flex.markDirty()
            mainCard.flex.markDirty()
            contentContainer.flex.layout(mode: .adjustHeight)
            mainCard.layoutIfNeeded()
            scrollView.contentSize = contentContainer.frame.size
        }
        
        if !isFirstSet && previousStatus != status {
            UIView.transition(with: titleLabel, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
        }
        
        applyUpdate()
        
        guard shouldAnimatePokeButton else { return }
        
        pokeButton.alpha = 0
        pokeButton.transform = CGAffineTransform(translationX: 0, y: 8)
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            self.pokeButton.alpha = 1
            self.pokeButton.transform = .identity
        }
    }
    
    private func updateTodayCardUI(_ cards: [QuestionCard]) {
        guard let firstCard = cards.first else {
            print("⚠️ 표시 가능한 오늘 카드 없음")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE"
        yearLabel.text = dateFormatter.string(from: firstCard.date)
        
        chip1.updateTitle("\(firstCard.mode.emoji)" + " " + "\(firstCard.mode.displayName)")
        chip2.updateTitle("\(firstCard.subject.emoji)" + " " + "\(firstCard.subject.displayName)")
        //        firstCard.type.
        chip1.flex.width(chip1.intrinsicContentSize.width)
        chip2.flex.width(chip2.intrinsicContentSize.width)
        chip1.superview?.flex.layout(mode: .adjustWidth)
    }
    
    private func updateMainCardFromHistory(_ cards: [QuestionCard]) {
        // cardLoadState가 loaded가 아니면 메인카드 업데이트하지 않음
        guard reactor?.currentState.cardLoadState == .loaded else { return }
        
        // 히스토리에서 오늘 카드 찾기 (8시 기준)
        let cardSystemDate = CardService.shared.getCardSystemDate()
        let todayCard = cards.first { Calendar.current.isDate($0.date, inSameDayAs: cardSystemDate) }
        
        guard let card = todayCard else {
            print("⚠️ 오늘 카드 없음")
            return
        }
        
        // 날짜와 칩만 업데이트 (answerStatus는 Reactor에서 자동 처리)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE"
        yearLabel.text = dateFormatter.string(from: card.date)
        
        chip1.updateTitle("\(card.mode.emoji) \(card.mode.displayName)")
        chip2.updateTitle("\(card.subject.emoji) \(card.subject.displayName)")
        
        // chip3는 type이 .none이 아닐 때만 표시
        let isSelectedByPartner: Bool = {
            guard let selectedBy = card.selectedByUserId,
                  let myId = UserdefaultKey.userId else { return false }
            return selectedBy != myId
        }()
        
        if card.type != .none {
            chip3.updateTitle("\(card.type.emoji) \(card.type.displayName)")
            chip3.isHidden = false
            chip3.flex.isIncludedInLayout(true)
            chip3.flex.width(chip3.intrinsicContentSize.width)
        } else {
            chip3.isHidden = true
            chip3.flex.isIncludedInLayout(false)
        }
        
        chip1.flex.width(chip1.intrinsicContentSize.width)
        chip2.flex.width(chip2.intrinsicContentSize.width)
        
        mainCard.flex.layout(mode: .adjustHeight)
        mainCard.layoutIfNeeded()
        
        chip3.setHighlighted(isSelectedByPartner)
        showCardTypeTooltip(isSelectedByPartner)
    }
    
    private func updateButtonForMyAnswered(status: AnswerStatus, isCoupleConnected: Bool) {
        guard status == .myAnswered else { return }
        
        if isCoupleConnected {
            pokeButton.setTitle("콕 찌르기", for: .normal)
            pokeButton.setImage(nil, for: .normal)
            pokeButton.imageEdgeInsets = .zero
            pokeButton.titleEdgeInsets = .zero
        } else {
            pokeButton.setTitle("커플 연결하기", for: .normal)
            if let heartLinkImage = UIImage(named: "heart_link") {
                let resizedImage = heartLinkImage.resizedWithBetterQuality(to: CGSize(width: 28, height: 28))
                pokeButton.setImage(resizedImage, for: .normal)
                pokeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
                pokeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            }
        }
    }
}

// MARK: - HistoryCard UI
extension HomeViewController {
    
    private func createEmptyWeekView() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.layer.cornerRadius = 16
        
        let dashedBorder = CAShapeLayer()
        dashedBorder.strokeColor = UIColor(hex: "E0D3F1").cgColor
        dashedBorder.lineDashPattern = [4, 4]
        dashedBorder.fillColor = UIColor.clear.cgColor
        dashedBorder.lineWidth = 1
        container.layer.addSublayer(dashedBorder)
        
        let gloomyImageView = UIImageView().then {
            $0.image = UIImage(named: "gloomy")
            $0.contentMode = .scaleAspectFit
        }
        
        let emptyLabel = TDLabel().then {
            $0.text = "이번 주에 작성된 카드가 없어요"
            $0.font = .pretenMedium(14)
            $0.textColor = .grayScale600
            $0.textAlignment = .center
        }
        
        container.addSubview(gloomyImageView)
        container.addSubview(emptyLabel)
        
        container.flex
            .paddingHorizontal(20)
            .paddingVertical(16)
            .alignItems(.center)
            .define { flex in
                flex.addItem(gloomyImageView).size(36).marginTop(16)
                flex.addItem(emptyLabel).marginTop(4).marginBottom(16)
            }
        
        container.layoutIfNeeded()
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: container.bounds, cornerRadius: 16)
            dashedBorder.path = path.cgPath
            dashedBorder.frame = container.bounds
        }
        
        return container
    }
    
    @objc private func weekCardTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view,
              let card = historyCards.first(where: { $0.id == tappedView.tag }) else {
            return
        }
        let isToday = Calendar.current.isDate(card.date, inSameDayAs: CardService.shared.getCardSystemDate())
        if isToday {
            if card.user1Answered && card.user2Answered {
                coordinator?.showHistoryCardDetail(card: card)
            } else {
                showNonAnsweredAlert()
            }
        } else {
            if !card.user1Answered && !card.user2Answered {
                showNonAnsweredAlert()
            } else {
                coordinator?.showHistoryCardDetail(card: card)
            }
        }
    }
    
    private func setupHistoryCards() {
        
        weekCardsContainer.subviews.forEach { $0.removeFromSuperview() }
        weekCardsContainer.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        if isLoadingHistoryCards {
            showSkeletonCard()
            return
        }
        
        weekCardsContainer.flex.define { flex in
            let cardSystemDate = CardService.shared.getCardSystemDate()
            let calendar = Calendar.current
            let filteredCards = historyCards.filter { card in
                let isToday = calendar.isDate(card.date, inSameDayAs: cardSystemDate)
                if isToday {
                    return card.user1Answered && card.user2Answered
                }
                return true
            }
            
            if UserdefaultKey.coupleType == .solo || filteredCards.isEmpty {
                let emptyView = createEmptyWeekView()
                flex.addItem(emptyView)
            } else {
                let sortedCards = filteredCards.sorted { $0.date > $1.date }
                sortedCards.enumerated().forEach { index, card in
                    let cardView = createWeekCard(card: card, index: index)
                    let isLast = index == sortedCards.count - 1
                    flex.addItem(cardView)
                        .height(isLast ? 83 : 83 + 60)
                        .marginTop(index == 0 ? 0 : -60)
                }
            }
        }
        
        weekCardsContainer.flex.layout()
        weekCardsContainer.pin.width(view.frame.width - 40)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleCardLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        weekCardsContainer.addGestureRecognizer(longPress)
    }
    
    private func weekCardTapped(from view: UIView) {
        guard let card = historyCards.first(where: { $0.id == view.tag }) else { return }
        let isToday = Calendar.current.isDate(card.date, inSameDayAs: CardService.shared.getCardSystemDate())
        if isToday {
            if card.user1Answered && card.user2Answered {
                coordinator?.showHistoryCardDetail(card: card)
            } else {
                showNonAnsweredAlert()
            }
        } else {
            if !card.user1Answered && !card.user2Answered {
                showNonAnsweredAlert()
            } else {
                coordinator?.showHistoryCardDetail(card: card)
            }
        }
    }
    
    func cardAmimation() {
        guard !weekCardsContainer.subviews.isEmpty else { return }
        weekCardsContainer.subviews.enumerated().forEach { index, view in
            view.transform = CGAffineTransform(translationX: 0, y: -50)
            view.alpha = 0
            
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.3,
                options: .curveEaseOut,
                animations: {
                    view.transform = .identity
                    view.alpha = 1
                }
            )
        }
    }
    
    private func createWeekCard(card: QuestionCard, index: Int) -> UIView {
        let cardView = UIView()
        
        let calendar = Calendar.current
        let cardSystemDate = CardService.shared.getCardSystemDate()
        let isToday = calendar.isDate(card.date, inSameDayAs: cardSystemDate)
        
        if isToday {
            cardView.backgroundColor = UIColor.mainPurple
        } else {
            let weekday = calendar.component(.weekday, from: card.date)
            if weekday == 1 || weekday == 2 || weekday == 4 || weekday == 6 {
                cardView.backgroundColor = UIColor.cardPurple
            } else {
                cardView.backgroundColor = UIColor.lightCardPurple
            }
        }
        
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor(hex: "774F92").cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: -8)
        cardView.layer.shadowRadius = 15
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        let dateString = dateFormatter.string(from: card.date)
        
        dateFormatter.dateFormat = "E"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let weekday = dateFormatter.string(from: card.date)
        
        let dayLabel = TDLabel()
        dayLabel.text = "\(weekday) \(dateString)"
        dayLabel.font = .pretenSemiBold(16)
        dayLabel.textColor = isToday ? .white : .grayScale900
        
        let topicLabel = TDLabel()
        let topicText = card.type != .none
        ? "\(card.mode.displayName) · \(card.subject.displayName) · \(card.type.displayName)"
        : "\(card.mode.displayName) · \(card.subject.displayName)"
        topicLabel.text = topicText
        topicLabel.font = .pretenRegular(14)
        topicLabel.textColor = isToday ? .white : .grayScale800
        
        let arrowIcon = UIImageView()
        arrowIcon.image = UIImage(systemName: "chevron.right")
        arrowIcon.tintColor = isToday ? .white : .grayScale800
        arrowIcon.contentMode = .scaleAspectFit
        
        cardView.addSubview(dayLabel)
        cardView.addSubview(topicLabel)
        cardView.addSubview(arrowIcon)
        
        cardView.flex
            .paddingHorizontal(20)
            .paddingTop(16)
            .paddingBottom(18)
            .define { flex in
                flex.addItem(arrowIcon).position(.absolute).right(20).top(33.5).size(16)
                flex.addItem(dayLabel)
                flex.addItem(topicLabel).marginTop(8)
            }
        
        cardView.tag = card.id
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(weekCardTapped(_:)))
        cardView.addGestureRecognizer(tapGesture)
        
        return cardView
    }
    
    private func showSkeletonCard() {
        let skeletonCard = createBlurredSkeletonCard()
        
        weekCardsContainer.flex.define { flex in
            flex.addItem(skeletonCard).height(83)
        }
        
        weekCardsContainer.flex.layout()
        weekCardsContainer.pin.width(view.frame.width - 40)
        
        DispatchQueue.main.async {
            self.addShimmerToCard(skeletonCard)
        }
    }
    
    private func createBlurredSkeletonCard() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.lightCardPurple
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor(hex: "774F92").cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: -8)
        cardView.layer.shadowRadius = 15
        
        return cardView
    }
    
    private func addShimmerToCard(_ cardView: UIView) {
        let overlay = UIView()
        overlay.backgroundColor = .white
        overlay.layer.cornerRadius = 20
        overlay.frame = cardView.bounds
        overlay.alpha = 0
        
        cardView.addSubview(overlay)
        
        let waveAnimation = CAKeyframeAnimation(keyPath: "opacity")
        waveAnimation.values = [0.0, 0.25, 0.5, 0.25, 0.0]
        waveAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        waveAnimation.duration = 2.0
        waveAnimation.repeatCount = .infinity
        waveAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        overlay.layer.add(waveAnimation, forKey: "wave")
    }
}

// MARK: - Alert
extension HomeViewController {
    private func showConnectCoupleAlert() {
        showAlert(
            icon: UIImage(named: "heart_link"),
            title: "커플 연결 요청을 보냈어요\n상대방이 수락하면 연결돼요",
            description: nil,
            primaryButtonTitle: "확인",
            primaryButtonAction: {}
        )
    }
    
    private func showPokeAlert() {
        showAlert(
            icon: UIImage(resource: .poke),
            title: "콕! 상대방에게 알림을 보냈어요\n곧 답변할 거예요",
            description: nil,
            primaryButtonTitle: "확인",
            primaryButtonAction: {}
        )
    }
    
    private func showPokeErrorAlert() {
        showAlert(
            icon: UIImage(resource: .unsmile),
            title: "콕찌르기 실패\n잠시 후 다시 시도해주세요",
            description: nil,
            primaryButtonTitle: "확인",
            primaryButtonAction: {}
        )
    }
    
    private func showNonAnsweredAlert() {
        showAlert(
            icon: UIImage(resource: .unsmile),
            title: "답변 내용이 없어 확인할 수 없어요",
            description: nil,
            primaryButtonTitle: "확인",
            primaryButtonAction: {}
        )
    }
    
    private func showAnswerUnavailableAlert() {
        showAlert(
            icon: UIImage(resource: .unsmile),
            title: "지금은 답변할 수 없어요\n오전 8시에 새 질문이 도착해요",
            description: nil,
            primaryButtonTitle: "확인",
            primaryButtonAction: {}
        )
    }
    
    private func showWeeklyCardsFetchFailedAlert() {
        showAlert(
            icon: UIImage(resource: .unsmile),
            title: "데일리카드 가져오기에 실패했어요.\n다시 시도해보세요.",
            description: nil,
            primaryButtonTitle: "다시 시도",
            primaryButtonAction: { [weak self] in
                self?.fetchWeeklyCards()
            }
        )
    }
    
    private func showNotificationAlert() {
        showAlert(
            icon:  UIImage(resource: .bell),
            title: "알림을 켜고 우리만의 대화를 시작해요!",
            description: "• 상대방이 답변하면 바로 알 수 있어요\n• 서로의 답변이 공개되면 알림을 받아요\n• 상대방의 쿡 찌르기를 받을 수 있어요",
            primaryButtonTitle: "알림켜기",
            primaryButtonAction: { [weak self] in
                self?.reactor?.action.onNext(.notiAgree)
                self?.requestAuthorization()
            },
            secondaryButtonTitle: "나중에 할게요",
            secondaryButtonAction: { [weak self] in
                self?.reactor?.action.onNext(.dismissNotificationAlert)
                self?.requestAuthorization()
            }
        )
    }
    
    private func requestAuthorization() {
        let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOption,
            completionHandler: {_, _ in })
    }
}

extension HomeViewController: BaseViewControllerDelegate {
    func navigateToMyPage() {
        coordinator?.navigateToMyPage(self.navigationController, tabBarCoordinator: coordinator?.tabBarCoordinator)
    }
}

extension HomeViewController {
    @objc private func handleCardLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: weekCardsContainer)
        
        switch gesture.state {
        case .began, .changed:
            let target = weekCardsContainer.subviews.reversed().first { view in
                let touchRect = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: 83)
                return touchRect.contains(location)
            }
            
            if target !== liftedCardView {
                if let prev = liftedCardView {
                    UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3) {
                        prev.transform = .identity
                        prev.layer.shadowOpacity = 0.08
                    }
                }
                liftedCardView = target
                if let card = target {
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                        card.transform = CGAffineTransform(translationX: 0, y: -12).scaledBy(x: 1.02, y: 1.02)
                        card.layer.shadowOpacity = 0.18
                    }
                }
            }
            
        case .ended, .cancelled:
            if let card = liftedCardView {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3) {
                    card.transform = .identity
                    card.layer.shadowOpacity = 0.08
                }
                if gesture.state == .ended, let tapped = liftedCardView {
                    weekCardTapped(from: tapped)
                }
            }
            liftedCardView = nil
            
        default:
            break
        }
    }
}
