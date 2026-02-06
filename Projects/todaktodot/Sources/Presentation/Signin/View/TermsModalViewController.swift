//
//  TermsModalViewController.swift
//  todaktodot
//
//  Created by 임대진 on 12/14/25.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxSwift
import RxRelay
import ReactorKit

final class TermsModalViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    private var countRelay = PublishRelay<Set<Int>>()
    private var currentSelected = Set<Int>()
    
    private let dimView = UIView().then {
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    }
    
    private let modalView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    private let topToggleView = UIView().then {
        $0.backgroundColor = UIColor(hex: "D9D9D9")
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
    }
    
    private let allCheckButton = CheckButtonView(titleFont: .pretenSemiBold(16)).then {
        $0.configure(isBackground: true, title: "전체 동의")
        $0.setState(isSelected: false)
    }
    
    private let termsButton = CheckButtonView().then {
        $0.configure(isBackground: false, title: "[필수] 이용약관")
        $0.setState(isSelected: false)
    }
    
    private let personalInfoButton = CheckButtonView().then {
        $0.configure(isBackground: false, title: "[필수] 개인 정보 수집 이용")
        $0.setState(isSelected: false)
    }
    
    private let marketingButton = CheckButtonView().then {
        $0.configure(isBackground: false, title: "[선택] 마케팅 수신 및 앱 알림 동의")
        $0.setState(isSelected: false)
    }
    
    private let acceptButton =  UIButton(type: .system).then {
        $0.setTitle("동의하고 시작하기", for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.tintColor = .white
        $0.setTitleColor(.white, for: .disabled)
        $0.backgroundColor = .grayScale400
        $0.layer.cornerRadius = 6
        $0.isEnabled = false
    }
    
    
    private let titleLabel = TDLabel().then {
        $0.text = "서비스 이용을 위해\n약관 동의가 필요합니다"
        $0.font = .pretenSemiBold(20)
        $0.textColor = .grayScale900
        $0.numberOfLines = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupFlexLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.addSubview(dimView)
        view.addSubview(modalView)
    }
    
    private func setupFlexLayout() {
        modalView.flex.paddingHorizontal(20).define {
            $0.addItem(topToggleView)
                .marginTop(16)
            
            $0.addItem(titleLabel)
                .marginTop(22)
            
            $0.addItem(allCheckButton)
                .marginTop(24)
                .height(52)
            
            $0.addItem(termsButton)
                .marginTop(24)
                .height(20)
            
            $0.addItem(personalInfoButton)
                .marginTop(24)
                .height(20)
            
            $0.addItem(marketingButton)
                .marginTop(24)
                .height(20)
            
            $0.addItem(acceptButton)
                .marginTop(40)
                .height(52)
                .marginBottom(14)
        }
    }
    
    private func layoutViews() {
        dimView.pin
            .all()
        
        modalView.pin
            .horizontally()
            .bottom()
            .height(451)
        
        modalView.flex.layout()
    }
    
    func bind(reactor: CoupleReactor) {
        
        allCheckButton.icon.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                if currentSelected.count == 3 {
                    currentSelected = []
                    buttonProcessing(select: false)
                    allCheckButton.setState(isSelected: false)
                } else {
                    currentSelected = [0,1,2]
                    buttonProcessing(select: true)
                    allCheckButton.setState(isSelected: true)
                }
                countRelay.accept(currentSelected)
            })
            .disposed(by: disposeBag)
        
        termsButton.icon.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                if currentSelected.contains(0) {
                    currentSelected.remove(0)
                    termsButton.setState(isSelected: false)
                } else {
                    currentSelected.insert(0)
                    termsButton.setState(isSelected: true)
                }
                countRelay.accept(currentSelected)
            })
            .disposed(by: disposeBag)
        
        personalInfoButton.icon.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                if currentSelected.contains(1) {
                    currentSelected.remove(1)
                    personalInfoButton.setState(isSelected: false)
                } else {
                    currentSelected.insert(1)
                    personalInfoButton.setState(isSelected: true)
                }
                countRelay.accept(currentSelected)
            })
            .disposed(by: disposeBag)
        
        marketingButton.icon.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                if currentSelected.contains(2) {
                    currentSelected.remove(2)
                    marketingButton.setState(isSelected: false)
                } else {
                    currentSelected.insert(2)
                    marketingButton.setState(isSelected: true)
                }
                countRelay.accept(currentSelected)
            })
            .disposed(by: disposeBag)
        
        termsButton.chevronButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                let webVC = WebViewController(url: "https://silver-curve-9aa.notion.site/297562bcddbd8098844cf8c5c8c8e429")
                webVC.modalPresentationStyle = .formSheet
                self.present(webVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        personalInfoButton.chevronButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                let webVC = WebViewController(url: "https://silver-curve-9aa.notion.site/297562bcddbd8018b6a8ffdd3480ab2e?pvs=74")
                webVC.modalPresentationStyle = .formSheet
                self.present(webVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        marketingButton.chevronButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                let webVC = WebViewController(url: "https://silver-curve-9aa.notion.site/297562bcddbd80f0ba3ef3fde36fd816?pvs=74")
                webVC.modalPresentationStyle = .formSheet
                self.present(webVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        acceptButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        countRelay
            .subscribe(onNext: { [weak self] arr in
                guard let self else { return }
                if  arr == [0, 1] {
                    acceptButton.isEnabled = true
                    acceptButton.backgroundColor = .mainPurple
                    allCheckButton.setState(isSelected: false)
                } else if arr.count == 3 {
                    acceptButton.isEnabled = true
                    acceptButton.backgroundColor = .mainPurple
                    allCheckButton.setState(isSelected: true)
                } else {
                    acceptButton.isEnabled = false
                    acceptButton.backgroundColor = .grayScale400
                    allCheckButton.setState(isSelected: false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func buttonProcessing(select: Bool) {
        [termsButton, personalInfoButton, marketingButton].forEach {
            $0.setState(isSelected: select)
        }
    }
}
