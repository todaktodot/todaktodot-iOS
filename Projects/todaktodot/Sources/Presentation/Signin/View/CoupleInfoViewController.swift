//
//  CoupleInfoViewController.swift
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

enum CoupleInfoFlowType {
    case newUser
    case editUser
}

final class CoupleInfoViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    weak var coordinator: SigninCoordinator?
    
    private var coupleInfo: CoupleInfo?
    private var isDone = BehaviorRelay<Bool>(value: false)
    private let isDateSelected = BehaviorRelay<String?>(value: nil)
    private let isRelationSelected = BehaviorRelay<CoupleStage?>(value: nil)
    private let contentsView = UIView()
    private let flowType: CoupleInfoFlowType
    private let backgroundView = UIImageView().then {
        $0.image = UIImage(resource: .connectBackground)
    }
    
    private let scrollView = UIScrollView().then {
        $0.contentInset.bottom = 120
        $0.showsVerticalScrollIndicator = false
    }
    
    private let titleLabel = TDLabel().then {
        $0.text = "지금 우리는?"
        $0.font = .pretenSemiBold(28)
        $0.textColor = .grayScale900
    }
    
    private let dateLabel = TDLabel().then {
        $0.text = "우리가 만난 날"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .grayScale900
    }
    
    private let datePickerView = CoupleDatePickerView()
    
    private let relationshipLabel = TDLabel().then {
        $0.text = "관계 단계"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .grayScale900
    }
    
    private let startButton = UIButton(type: .system).then {
        $0.setTitle("시작하기", for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.white, for: .disabled)
        $0.backgroundColor = .mainPurple
        $0.layer.cornerRadius = 6
        $0.isEnabled = false
    }
    
    private let coupleStepSelectView = CoupleStepSelectView()
    
    init(flowType: CoupleInfoFlowType, info: CoupleInfo? = nil) {
        self.flowType = flowType
        
        if let info, let stage = CoupleStage(rawValue: info.stage) {
            coupleStepSelectView.setSelected(stage: stage)
            datePickerView.setDate(info.firstMetDate)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenBackButton()
        hideKeyboardwhenTappedAround()
        setupViews()
        setupFlexLayout()
        
        if flowType == .newUser {
            AnalyticsService.log(.coupleInfoSetBegin)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentsView)
        view.addSubview(startButton)
    }
    
    private func setupFlexLayout() {
        contentsView.flex.paddingHorizontal(20).define {
            $0.addItem(titleLabel)
                .marginTop(84)
            
            $0.addItem(dateLabel)
                .marginTop(40)
            
            $0.addItem(datePickerView)
                .marginTop(12)
                .height(56)
                .cornerRadius(8)
                .backgroundColor(.white)
            
            $0.addItem(relationshipLabel)
                .marginTop(20)
            
            $0.addItem(coupleStepSelectView)
                .marginTop(12)
        }
    }
    
    private func layoutViews() {
        backgroundView.pin
            .all()

        scrollView.pin
            .all()

        contentsView.pin
            .top()
            .horizontally()

        startButton.pin
            .horizontally(20)
            .bottom(48)
            .height(52)

        contentsView.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = contentsView.frame.size
    }
    
    func bind(reactor: CoupleReactor) {
        reactor.state
            .compactMap { $0.updateCoupleInfo }
            .subscribe(onNext: { [weak self] info in
                guard let self = self else { return }
                
                coordinator?.onCoupleInfoUpdated?(info)
                
                switch self.flowType {
                case .newUser:
                    self.coordinator?.navigateToMain()
                    AnalyticsService.log(.coupleInfoSetCompleted)
                case .editUser:
                    self.coordinator?.navigateBack()
                }
            })
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .compactMap { [weak self] in
                guard let date = self?.isDateSelected.value,
                      let step = self?.isRelationSelected.value else { return nil }
                return CoupleReactor.Action.tapStartButton(date, step.rawValue)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        isDone
            .bind(to: startButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        isDone
            .subscribe(onNext: { [weak self] bool in
                self?.startButton.backgroundColor = bool
                    ? .mainPurple
                    : .grayScale400
            })
            .disposed(by: disposeBag)
        
        datePickerView.isDateSelected
            .subscribe(onNext: { [weak self] text in
                self?.isDateSelected.accept(text)
            })
            .disposed(by: disposeBag)
        
        coupleStepSelectView.isSelected
            .subscribe(onNext: { [weak self] step in
                self?.isRelationSelected.accept(step)
            })
            .disposed(by: disposeBag)
            
        Observable
            .combineLatest(isDateSelected, isRelationSelected)
            .map { ($0 != nil) && ($1 != nil) }
            .bind(to: isDone)
            .disposed(by: disposeBag)
    }
}
