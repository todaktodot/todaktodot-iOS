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

final class CoupleInfoViewController: UIViewController {
    weak var coordinator: SigninCoordinator?
    
    private var isDone = BehaviorRelay<Bool>(value: false)
    private let isDateSelected = BehaviorRelay<Bool>(value: false)
    private let isRelationSelected = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    private let contentsView = UIView()
    private let backgroundView = UIImageView().then {
        $0.image = UIImage(resource: .connectBackground)
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
    
    private let buttonsView = SelectedButtonView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardwhenTappedAround()
        setupViews()
        setupFlexLayout()
        bindActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(contentsView)
        view.addSubview(startButton)
    }
    
    private func setupFlexLayout() {
        contentsView.flex.paddingHorizontal(20).define {
            $0.addItem(titleLabel)
                .marginTop(40)
            
            $0.addItem(dateLabel)
                .marginTop(40)
            
            $0.addItem(datePickerView)
                .marginTop(12)
                .height(56)
                .cornerRadius(8)
                .backgroundColor(.white)
            
            $0.addItem(relationshipLabel)
                .marginTop(20)
            
            $0.addItem(buttonsView)
                .marginTop(12)
        }
    }
    
    private func layoutViews() {
        backgroundView.pin
            .all()
        
        contentsView.pin
            .top(view.pin.safeArea.top)
            .horizontally()
            .bottom()
        
        startButton.pin
            .horizontally(20)
            .bottom(48)
            .height(52)
        
        contentsView.flex.layout()
    }
    
    private func bindActions() {
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
            .subscribe(onNext: { [weak self] bool in
                self?.isDateSelected.accept(bool)
            })
            .disposed(by: disposeBag)
        
        buttonsView.isSelected
            .subscribe(onNext: { [weak self] bool in
                self?.isRelationSelected.accept(bool)
            })
            .disposed(by: disposeBag)
            
        Observable
            .combineLatest(isDateSelected, isRelationSelected)
            .map { $0 && $1 }
            .bind(to: isDone)
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.navigateToMain()
            })
            .disposed(by: disposeBag)
    }
}
