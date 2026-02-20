//
//  DailyCardViewController.swift
//  todaktodot
//
//  Created by daye on 12/16/25.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift
import RxCocoa
import Then

final class DailyCardViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    private let rootFlexContainer = UIView()
    private let titleLabel = TDLabel().then {
        $0.text = "상황극과 밸런스게임 중\n원하는 스타일을 선택해서 답해보세요!"
        $0.font = .pretenSemiBold(20)
        $0.textColor = .grayScale900
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }
    private let situationButton = UIButton()
    private let balanceButton = UIButton()
    
    init(reactor: DailyCardReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func bind(reactor: DailyCardReactor) {
        // 초기 선택 상태 반영 (레이아웃 완료 후)
        reactor.state.map { $0.historySelectedType }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] historyType in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    // historySelectedType에 따라 버튼 스타일 적용
                    self.updateButtonStyle(self.situationButton, isSelected: historyType == .roleplay)
                    self.updateButtonStyle(self.balanceButton, isSelected: historyType == .balance)
                }
            })
            .disposed(by: disposeBag)
        
        situationButton.rx.tap
            .withLatestFrom(reactor.state.map { $0.historySelectedType })
            .subscribe(onNext: { [weak self] historyType in
                // historyType이 .balance면 알림
                if historyType == .balance {
                    self?.showNotificationAlert()
                } else {
                    // .none 또는 .roleplay면 이동
                    reactor.action.onNext(.tapSituationButton)
                }
            })
            .disposed(by: disposeBag)
        
        balanceButton.rx.tap
            .withLatestFrom(reactor.state.map { $0.historySelectedType })
            .subscribe(onNext: { [weak self] historyType in
                // historyType이 .roleplay면 알림
                if historyType == .roleplay {
                    self?.showNotificationAlert()
                } else {
                    // .none 또는 .balance면 이동
                    reactor.action.onNext(.tapBalanceButton)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedCard }
            .compactMap { $0 }
            .skip(1)
            .distinctUntilChanged { $0.id == $1.id }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] card in
                guard let self = self else { return }
                
                // 버튼 스타일 업데이트 제거 - historySelectedType만 기준으로 함
                
                switch card.type {
                case .roleplay:
                    self.coordinator?.showDailyCardDetail(card: card)
                case .balance:
                    self.coordinator?.showBalanceCardDetail(card: card)
                case .none:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .lightPurple
        navigationController?.navigationBar.isHidden = false
        setupBackbutton()
       
        view.addSubview(rootFlexContainer)
        
        setupMainButton(situationButton, title: "상황극", caption: "상황 속 주인공이 되어 생각해보는 몰입형 토크", iconName: "🎭")
        setupMainButton(balanceButton, title: "밸런스게임", caption: "둘 중 하나, 무조건 골라야 하는 선택의 순간", iconName: "⚖️")
        
        rootFlexContainer.flex
            .paddingHorizontal(20)
            .paddingTop(10)
            .define { flex in
                flex.addItem(titleLabel)
                flex.addItem(situationButton).height(144).marginTop(36)
                flex.addItem(balanceButton).height(144).marginTop(12)
            }
    }
    
    private func setupBackbutton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .grayScale900
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.all(view.pin.safeArea)
        rootFlexContainer.flex.layout()
    }
    
    private func showNotificationAlert() {
        guard let reactor = reactor else { return }
        let historyType = reactor.currentState.historySelectedType
        
        // historySelectedType에 해당하는 카드 찾기
        guard let card = reactor.currentState.selectedCard ?? 
              (historyType == .roleplay ? 
                CardStorageService.shared.getTodayCards().first(where: { $0.type == .roleplay }) :
                CardStorageService.shared.getTodayCards().first(where: { $0.type == .balance })) else {
            return
        }
        
        showAlert(
            icon: UIImage(resource: .warning),
            title: "연인이 이미 유형을 선택했어요!",
            description: "다음에는 먼저 질문에 답변하여\n 유형을 선정해보세요.",
            primaryButtonTitle: "카드 작성하러 가기",
            primaryButtonAction: { [weak self] in
                switch historyType {
                case .roleplay:
                    self?.coordinator?.showDailyCardDetail(card: card)
                case .balance:
                    self?.coordinator?.showBalanceCardDetail(card: card)
                case .none:
                    break
                }
            }
        )
    }
}

// MARK: - FUNC
extension DailyCardViewController {
    @objc private func backButtonTapped() {
        coordinator?.navigateBack()
    }
    
    private func updateButtonStyle(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.mainPurple.cgColor
            button.layer.shadowColor = UIColor.mainPurple.withAlphaComponent(0.2).cgColor
            button.layer.shadowOpacity = 1
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 8
        } else {
            button.layer.borderWidth = 0
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.05
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 8
        }
    }
}

// MARK: - SUB UI
extension DailyCardViewController {
    private func setupMainButton(_ button: UIButton, title: String, caption: String, iconName: String) {
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.05
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 8
        
        let iconLabel = TDLabel().then {
            $0.text = iconName
            $0.font = .systemFont(ofSize: 40)
            $0.textAlignment = .center
        }
        
        let titleLabel = TDLabel().then {
            $0.text = title
            $0.font = .pretenSemiBold(20)
            $0.textColor = .grayScale900
        }
        
        let captionLabel = TDLabel().then {
            $0.text = caption
            $0.font = .pretenRegular(16)
            $0.textColor = .grayScale800
            $0.numberOfLines = 0
        }
        
        button.addSubview(iconLabel)
        button.addSubview(titleLabel)
        button.addSubview(captionLabel)
        
        iconLabel.flex.size(40).position(.absolute).top(20).right(20)
        titleLabel.flex.position(.absolute).bottom(56).left(20)
        captionLabel.flex.position(.absolute).bottom(20).left(20)
    }
}
