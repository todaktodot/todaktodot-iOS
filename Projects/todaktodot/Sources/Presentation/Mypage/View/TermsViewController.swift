//
//  TermsViewController.swift
//  todaktodot
//
//  Created by 임대진 on 1/27/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxSwift

final class TermsViewController: CustomBackViewController {
    weak var coordinator: MypageCoordinator?
    
    private var disposeBag = DisposeBag()
    private let contentView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let backgroundView = UIImageView().then {
        $0.image = UIImage(resource: .mypageSubBackground)
    }
    private let personalTermButton = ModalButton().then {
        $0.setTitle(title: "개인정보 수집 및 이용")
    }
    
    private let usedTermButton = ModalButton().then {
        $0.setTitle(title: "이용 약관")
    }
    
    private let divider = UIView().then {
        $0.backgroundColor = UIColor.grayScale200
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        title = "서비스 이용약관"
        
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
        view.addSubview(contentView)
    }
    
    private func setupFlexLayout() {
        contentView.flex
            .marginTop(28)
            .marginHorizontal(20)
            .paddingHorizontal(20)
            .paddingVertical(16)
            .gap(16)
            .define {
                $0.addItem(personalTermButton)
                
                $0.addItem(divider)
                    .height(1)
                    .marginHorizontal(-20)
                
                $0.addItem(usedTermButton)
            }
    }
    
    private func layoutViews() {
        backgroundView.pin
            .all()
        
        contentView.pin
            .top(view.pin.safeArea)
            .horizontally()
        
        contentView.flex.layout(mode: .adjustHeight)
    }
    
    private func bindActions() {
        personalTermButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showDetailPersonalTerms()
            })
            .disposed(by: disposeBag)
        
        usedTermButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showDetailTerms()
            })
            .disposed(by: disposeBag)
    }
}

extension TermsViewController: CustomBackViewControllerDelegate {
    func navigateBack() {
        coordinator?.navigateBack()
    }
}
