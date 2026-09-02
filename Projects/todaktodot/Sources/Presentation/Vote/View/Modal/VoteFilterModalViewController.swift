//
//  VoteFilterModalViewController.swift
//  todaktodot
//
//  Created by 임대진 on 8/21/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxSwift
import RxRelay
import ReactorKit

final class VoteFilterModalViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    weak var coordinator: VoteCoordinator?
    
    private var category: [CardSubject]?
    private var isClosed: Bool?
    private var isMine: Bool?
    
    private let dimView = UIView().then {
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    }
    
    private let modalView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    private let handleBarView = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "어떤 투표를 찾으시나요?"
        $0.font = .pretenSemiBold(20)
        $0.textColor = .grayScale900
    }

    private let topicLabel = TDLabel().then {
        $0.text = "주제"
        $0.font = .pretenRegular(12)
        $0.textColor = .grayScale800
    }
    
    private let statusLabel = TDLabel().then {
        $0.text = "마감 여부"
        $0.font = .pretenRegular(12)
        $0.textColor = .grayScale800
    }

    private let myVoteLabel = TDLabel().then {
        $0.text = "내가 쓴 글만 보기"
        $0.font = .pretenMedium(15)
        $0.textColor = .grayScale800
    }

    private let myVoteSwitch = UISwitch().then {
        $0.onTintColor = .mainPurple
    }
    
    private let configButton = UIButton().then {
        $0.setTitle("적용하기", for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .mainPurple
        $0.layer.cornerRadius = 6
    }
    
    private let topicAllButton = ChipButton("전체").then {
        $0.isSelected = true
    }
    private let economiButton = ChipButton("💸 경제관")
    private let lifeButton = ChipButton("🏡 생환관")
    private let loveButton = ChipButton("🧑‍❤️‍🧑 연애관")
    private let statusAllButton = ChipButton("전체").then {
        $0.isSelected = true
    }
    private let progressButton = ChipButton("진행중")
    private let closedButton = ChipButton("마감")
    
    private let resetButton = ImageTextButton(horizonPadding: 16, verticalPadding: 15, spacing: 6, imageSize: 20).then {
        $0.customText.text = "초기화"
        $0.customText.font = .pretenSemiBold(16)
        $0.customText.textColor = .grayScale700
        $0.customImage.image = UIImage(resource: .refresh)
        
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grayScale200.cgColor
    }

    init(
        category: [CardSubject]? = nil,
        isClosed: Bool? = nil,
        isMine: Bool? = nil
    ) {
        self.category = category
        self.isClosed = isClosed
        self.isMine = isMine
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupFlexLayout()
        applyInitialFilter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    func bind(reactor: VoteReactor) {
        let topicButtons = [topicAllButton, economiButton, lifeButton, loveButton]
        let statusButtons = [statusAllButton, progressButton, closedButton]

        topicButtons
            .forEach { button in
                button.rx.tap
                    .subscribe(onNext: { [weak self] in
                        guard let self else { return }

                        if button == self.topicAllButton {
                            topicButtons.forEach {
                                $0.isSelected = ($0 == self.topicAllButton)
                            }
                        } else {
                            button.isSelected.toggle()

                            let categoryButtons = [
                                self.economiButton,
                                self.lifeButton,
                                self.loveButton
                            ]

                            self.topicAllButton.isSelected =
                                !categoryButtons.contains(where: { $0.isSelected })
                        }
                    })
                    .disposed(by: disposeBag)
            }
        
        statusButtons
            .forEach { button in
                button.rx.tap
                    .subscribe(onNext: { [weak self] in
                        guard let self else { return }
                        statusButtons
                            .forEach {
                                $0.isSelected = ($0 == button)
                            }
                    })
                    .disposed(by: disposeBag)
            }
        
        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                (topicButtons + statusButtons)
                    .forEach {
                        $0.isSelected = $0 == self.topicAllButton || $0 == self.statusAllButton
                    }
            })
            .disposed(by: disposeBag)
        
        configButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                let topic: [CardSubject]? = {
                    if self.topicAllButton.isSelected {
                        return nil
                    }

                    var categories: [CardSubject] = []

                    if self.economiButton.isSelected {
                        categories.append(.economy)
                    }

                    if self.lifeButton.isSelected {
                        categories.append(.lifestyle)
                    }

                    if self.loveButton.isSelected {
                        categories.append(.love)
                    }

                    return categories.isEmpty ? nil : categories
                }()

                let isClosed: Bool? = {
                    switch true {
                    case self.statusAllButton.isSelected:
                        return nil
                    case self.progressButton.isSelected:
                        return false
                    case self.closedButton.isSelected:
                        return true
                    default:
                        return nil
                    }
                }()

                coordinator?.dismissModal(
                    topic: topic,
                    isClosed: isClosed,
                    onlyMine: self.myVoteSwitch.isOn,
                    updateFilter: true
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func selectButton(_ selectedButton: UIButton, from buttons: [UIButton]) {
        buttons.forEach { $0.isSelected = $0 == selectedButton }
    }
    
    private func applyInitialFilter() {
        let topicButtons = [topicAllButton, economiButton, lifeButton, loveButton]
        let statusButtons = [statusAllButton, progressButton, closedButton]
        let selectedCategories = category ?? []

        if selectedCategories.isEmpty {
            selectButton(topicAllButton, from: topicButtons)
        } else {
            topicAllButton.isSelected = false
            economiButton.isSelected = selectedCategories.contains(.economy)
            lifeButton.isSelected = selectedCategories.contains(.lifestyle)
            loveButton.isSelected = selectedCategories.contains(.love)
        }

        switch isClosed {
        case true:
            selectButton(closedButton, from: statusButtons)
        case false:
            selectButton(progressButton, from: statusButtons)
        case nil:
            selectButton(statusAllButton, from: statusButtons)
        }

        myVoteSwitch.isOn = isMine ?? false
    }
    
    private func setupViews() {
        view.addSubview(dimView)
        view.addSubview(modalView)
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(swipeModal(_:)))
        dimView.addGestureRecognizer(dismiss)
        modalView.addGestureRecognizer(swipe)
    }
    
    private func setupFlexLayout() {
        
        modalView.flex.paddingHorizontal(24).define {
            $0.addItem(handleBarView)
                .marginTop(12)
                .alignSelf(.center)
                .width(52)
                .height(6)
                .cornerRadius(3)
            
            $0.addItem(titleLabel)
                .marginTop(20)
            
            $0.addItem(topicLabel)
                .marginTop(20)
                .height(18)
            
            $0.addItem()
                .marginTop(6)
                .direction(.row)
                .gap(6)
                .alignItems(.center)
                .define {
                    $0.addItem(topicAllButton)
                        .width(49)
                        .height(32)
                    $0.addItem(economiButton)
                        .width(78)
                        .height(32)
                    $0.addItem(lifeButton)
                        .width(78)
                        .height(32)
                    $0.addItem(loveButton)
                        .width(78)
                        .height(32)
                }
            
            $0.addItem(statusLabel)
                .marginTop(12)
                .height(18)
            
            $0.addItem()
                .marginTop(6)
                .direction(.row)
                .gap(6)
                .alignItems(.center)
                .define {
                    $0.addItem(statusAllButton)
                        .width(49)
                        .height(32)
                    $0.addItem(progressButton)
                        .width(61)
                        .height(32)
                    $0.addItem(closedButton)
                        .width(49)
                        .height(32)
                }
            
            $0.addItem()
                .marginTop(20)
                .direction(.row)
                .gap(6)
                .alignItems(.center)
                .define {
                    $0.addItem(myVoteLabel)
                    
                    $0.addItem()
                        .grow(1)
                    
                    $0.addItem(myVoteSwitch)
                }
            
            $0.addItem()
                .marginTop(32)
                .marginBottom(20)
                .direction(.row)
                .gap(12)
                .alignItems(.center)
                .define {
                    $0.addItem(resetButton)
                        .height(52)
                    
                    $0.addItem(configButton)
                        .height(52)
                        .grow(1)
                }
        }
    }
    
    private func layoutViews() {
        dimView.pin
            .all()
        
        modalView.pin
            .horizontally()
            .bottom()
            .height(369)
        
        modalView.flex.layout()
    }
    
    
    @objc func dismissModal() {
        coordinator?.dismissModal()
    }
    
    @objc func swipeModal(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        guard translation.y > 0 else { return }

        switch gesture.state {
        case .changed:
            modalView.transform = CGAffineTransform(
                translationX: 0,
                y: translation.y
            )

        case .ended:
            let velocity = gesture.velocity(in: view)

            if translation.y > 100 || velocity.y > 500 {
                coordinator?.dismissModal()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.modalView.transform = .identity
                }
            }

        default:
            break
        }
    }
}

private final class ChipButton: UIButton {

    init(_ title: String) {
        
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        setTitleColor(.grayScale700, for: .normal)
        setTitleColor(.mainPurple, for: .selected)
        titleLabel?.font = .pretenMedium(14)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayScale200.cgColor
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            updateStyle()
        }
    }
    
    
    private func updateStyle() {
        layer.borderColor = isSelected ? UIColor.mainPurple.cgColor : UIColor.grayScale200.cgColor
        backgroundColor = isSelected ? .lightPurple : .white
    }
}
