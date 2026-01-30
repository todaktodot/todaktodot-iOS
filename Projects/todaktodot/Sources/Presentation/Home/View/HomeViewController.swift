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

    private let mainCard = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.05
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 8
    }
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
//    private let chipContainer = UIView()
    private let chip1 = ChipView(title: "🍰 디저트모드")
    private let chip2 = ChipView(title: "💸 경제관")
    private let arrowButton = UIButton().then {
        $0.backgroundColor = TodotColors.Button.purpleButton1
        $0.layer.cornerRadius = 24
        let arrowConfig = UIImage.SymbolConfiguration(weight: .semibold)
        $0.setImage(UIImage(systemName: "arrow.right", withConfiguration: arrowConfig), for: .normal)
        $0.tintColor = .white
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
    
    private let weekCardsContainer = UIView()
    private let weekdays = ["토", "금", "목", "수", "화", "월"]
    private var hasWeekCards = true // TODO: 임시 설정. 카드 존재여부 확인
    
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
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNotificationAlert()
    }
    
    func bind(reactor: HomeReactor) {
        reactor.state.map { $0.answerStatus }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                self?.updateMainCard(for: status)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isPoked }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isPoked in
                self?.updatePokeButton(isPoked: isPoked)
            })
            .disposed(by: disposeBag)
        
        let answerStatusStream = reactor.state.map { $0.answerStatus }.distinctUntilChanged()
        let coupleConnectedStream = reactor.state.map { $0.isCoupleConnected }.distinctUntilChanged()
        
        Observable.combineLatest(answerStatusStream, coupleConnectedStream)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status, isCoupleConnected in
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
            .withLatestFrom(reactor.state.map { ($0.answerStatus, $0.isCoupleConnected) })
            .subscribe(onNext: { [weak self] status, isCoupleConnected in
                if status == .myAnswered && !isCoupleConnected {
                    self?.coordinator?.tabBarCoordinator?.showCoupleConnect()
                } else {
                    self?.showPokeAlert()
                    reactor.action.onNext(.tapPokeButton)
                }
            })
            .disposed(by: disposeBag)
        
        arrowButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showDailyCard()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        // TODO: 그라데이션 정의?
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
        setupWeekCards()
        
        contentContainer.flex
            .paddingHorizontal(20)
            .paddingBottom(150)
            .define { flex in
                flex.addItem(mainCard).marginVertical(20)
                flex.addItem(weekCardsContainer).marginTop(hasWeekCards ? 36 : 28)
            }
    }
    
    private func setupMainCard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showInfoPopup))
        questionIcon.addGestureRecognizer(tapGesture)
        
        let descParagraphStyle = NSMutableParagraphStyle()
        descParagraphStyle.lineHeightMultiple = 1.5
        descriptionLabel.attributedText = NSAttributedString(
            string: "오전 8시 기준으로 질문이 바뀌니 8시가 지나기\n전에 답해보세요.",
            attributes: [.paragraphStyle: descParagraphStyle]
        )
        
        [yearLabel, questionIcon, titleLabel, chip1, chip2, arrowButton, descriptionCard, pokeButton]
            .forEach {mainCard.addSubview($0)}
        [descriptionTitle, descriptionLabel].forEach {descriptionCard.addSubview($0)}
        
        mainCard.flex
            .padding(24)
            .define { flex in
                flex.addItem(questionIcon).position(.absolute).top(20).right(20).size(24)
                flex.addItem(yearLabel)
                flex.addItem(titleLabel).marginTop(8)
                flex.addItem().direction(.row).justifyContent(.spaceBetween).alignItems(.end).marginTop(16).marginRight(22).define { rowFlex in
                    rowFlex.addItem().direction(.row).define { chipFlex in
                        chipFlex.addItem(chip1).height(37)
                        chipFlex.addItem(chip2).height(37).marginLeft(4)
                    }
                    rowFlex.addItem(arrowButton).marginLeft(47).size(48)
                }
                flex.addItem(descriptionCard).direction(.column).marginTop(20).define { descFlex in
                    descFlex.addItem(descriptionTitle).marginTop(16).marginLeft(16)
                    descFlex.addItem(descriptionLabel).marginTop(4).marginLeft(16).marginBottom(16)
                }
                flex.addItem(pokeButton).height(48).marginTop(16)
            }
    }
    
    private func updateMainCard(for status: AnswerStatus) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        
        pokeButton.flex.isIncludedInLayout(false)
        
        switch status {
        case .bothUnanswered:
            titleLabel.attributedText = NSAttributedString(
                string: "오늘의 질문이 도착했어요\n먼저 답해볼까요?",
                attributes: [.paragraphStyle: paragraphStyle]
            )
            pokeButton.isHidden = true
            
        case .partnerAnswered:
            titleLabel.attributedText = NSAttributedString(
                string: "연인이 벌써 답했어요! 내가 답하면 바로\n확인할 수 있어요",
                attributes: [.paragraphStyle: paragraphStyle]
            )
            pokeButton.isHidden = true
            
        case .myAnswered:
            titleLabel.attributedText = NSAttributedString(
                string: "답변 완료!\n연인이 답하기 전까지\n확인할 수 없어요",
                attributes: [.paragraphStyle: paragraphStyle]
            )
            pokeButton.isHidden = false
            pokeButton.flex.isIncludedInLayout(true).height(48).marginTop(16)
            
        case .bothAnswered:
            titleLabel.attributedText = NSAttributedString(
                string: "두 사람 모두 답변 완료!\n아래 카드에서 내용을\n확인해보세요",
                attributes: [.paragraphStyle: paragraphStyle]
            )
            pokeButton.isHidden = true
        }
        
        mainCard.flex.layout(mode: .adjustHeight)
        contentContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = contentContainer.frame.size
    }
    
    private func setupWeekCards() {
        weekCardsContainer.flex.define { flex in
            if hasWeekCards {
                weekdays.enumerated().forEach { index, day in
                    let card = createWeekCard(day: day, date: "\(27-index)", index: index)
                    let isLast = index == weekdays.count - 1
                    flex.addItem(card)
                        .height(isLast ? 83 : 83 + 60)
                        .marginTop(index == 0 ? 0 : -60)
                }
            } else {
                let emptyView = createEmptyWeekView()
                flex.addItem(emptyView)
            }
        }
    }
    
    private func createWeekCard(day: String, date: String, index: Int) -> UIView {
        let card = UIView()
        
        if index % 2 == 0 {
            card.backgroundColor = UIColor.lightCardPurple
        } else {
            card.backgroundColor = UIColor.cardPurple
        }
        
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor(hex: "774F92").cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: -8)
        card.layer.shadowRadius = 15
        
        let dayLabel = TDLabel()
        dayLabel.text = "\(day) 9/\(date)"
        dayLabel.font = .pretenSemiBold(16)
        dayLabel.textColor = .grayScale900
        
        let topicLabel = TDLabel()
        topicLabel.text = "모드 · 대주제 ·소주제"
        topicLabel.font = .pretenRegular(14)
        topicLabel.textColor = .grayScale800
        
        let arrowIcon = UIImageView()
        arrowIcon.image = UIImage(systemName: "chevron.right")
        arrowIcon.tintColor = .grayScale800
        arrowIcon.contentMode = .scaleAspectFit
        
        card.addSubview(dayLabel)
        card.addSubview(topicLabel)
        card.addSubview(arrowIcon)
        
        card.flex
            .padding(20)
            .define { flex in
                flex.addItem(arrowIcon).position(.absolute).right(20).top(33.5).size(16)
                flex.addItem(dayLabel)
                flex.addItem(topicLabel).marginTop(8)
            }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(weekCardTapped))
        card.addGestureRecognizer(tapGesture)
        
        return card
    }
    
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
    
    @objc private func weekCardTapped() {
        coordinator?.showHistoryCardDetail()
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
    
    private func showNotificationAlert() {
        showAlert(
            icon:  UIImage(resource: .bell),
            title: "알림을 켜고 우리만의 대화를 시작해요!",
            description: "• 상대방이 답변하면 바로 알 수 있어요\n• 서로의 답변이 공개되면 알림을 받아요\n• 상대방의 쿡 찌르기를 받을 수 있어요",
            primaryButtonTitle: "알림켜기",
            primaryButtonAction: { [weak self] in
                self?.openAppSettings()
            },
            secondaryButtonTitle: "나중에 할게요",
            secondaryButtonAction: { [weak self] in
                self?.reactor?.action.onNext(.dismissNotificationAlert)
            }
        )
    }
    
    private func openAppSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
    
    @objc private func showInfoPopup() {
        let popupView = InfoPopupView()
        popupView.show(in: view, alignedWith: mainCard)
    }
    
    private func updatePokeButton(isPoked: Bool) {
        if isPoked {
            pokeButton.backgroundColor = .grayScale300
            pokeButton.isEnabled = false
        } else {
            pokeButton.backgroundColor = TodotColors.Button.purpleButton1
            pokeButton.isEnabled = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = view.bounds
        
        scrollView.pin.all(view.pin.safeArea)
        contentContainer.pin.top().left().right()
        
        contentContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = contentContainer.frame.size
    }
}

private final class ChipView: UIView {
    
    private let label = TDLabel()
    private var calculatedWidth: CGFloat = 0
    
    init(title: String) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayScale200.cgColor
        layer.cornerRadius = 20
        
        label.text = title
        label.font = .pretenMedium(14)
        label.textColor = .grayScale800
        label.sizeToFit()
        
        calculatedWidth = label.frame.width + 28
        
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.pin.center()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: calculatedWidth, height: 37)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: calculatedWidth, height: 37)
    }
}

extension HomeViewController: BaseViewControllerDelegate {
    func navigateToMyPage() {
        coordinator?.navigateToMyPage(self.navigationController, tabBarCoordinator: coordinator?.tabBarCoordinator)
    }
}
