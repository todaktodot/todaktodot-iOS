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
    private var selectedTerms = BehaviorRelay<Set<Int>>(value: [])
    private var isAcceptable = BehaviorRelay<Bool>(value: false)
    
    private let dimView = UIView().then {
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    }
    
    private let modalView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
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
    
    private let AdvertisinggButton = CheckButtonView().then {
        $0.configure(isBackground: false, title: "[선택] 광고성 알림 수신 동의")
        $0.setState(isSelected: false)
    }
    
    private let acceptButton =  UIButton(type: .system).then {
        $0.setTitle("동의하고 시작하기", for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.tintColor = .white
        $0.setTitleColor(.white, for: .disabled)
        $0.backgroundColor = .grayScale400
        $0.layer.cornerRadius = 6
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
            $0.addItem(titleLabel)
                .marginTop(28)
            
            $0.addItem(allCheckButton)
                .marginTop(20)
                .height(52)
            
            $0.addItem(termsButton)
                .marginTop(14)
                .height(40)
            
            $0.addItem(personalInfoButton)
                .marginTop(4)
                .height(40)
            
            $0.addItem(marketingButton)
                .marginTop(4)
                .height(40)
            
            $0.addItem(AdvertisinggButton)
                .marginTop(4)
                .marginLeft(28)
                .height(40)
            
            $0.addItem(acceptButton)
                .marginTop(30)
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
            .height(479)
        
        modalView.flex.layout()
    }
    
    func bind(reactor: CoupleReactor) {
        
        allCheckButton.rx.tap
            .withLatestFrom(selectedTerms)
            .map { selected -> Set<Int> in
                selected.count == 4 ? [] : [0, 1, 2, 3]
            }
            .bind(to: selectedTerms)
            .disposed(by: disposeBag)
    
        termsButton.rx.tap
            .withLatestFrom(selectedTerms)
            .map { selected -> Set<Int> in
                self.setSelectedTerms(selected: selected, termsIndex: 0)
            }
            .bind(to: selectedTerms)
            .disposed(by: disposeBag)
        
        personalInfoButton.rx.tap
            .withLatestFrom(selectedTerms)
            .map { selected -> Set<Int> in
                self.setSelectedTerms(selected: selected, termsIndex: 1)
            }
            .bind(to: selectedTerms)
            .disposed(by: disposeBag)
        
        marketingButton.rx.tap
            .withLatestFrom(selectedTerms)
            .map { selected -> Set<Int> in
                self.setSelectedTerms(selected: selected, termsIndex: 2)
            }
            .bind(to: selectedTerms)
            .disposed(by: disposeBag)
        
        AdvertisinggButton.rx.tap
            .withLatestFrom(selectedTerms)
            .map { selected -> Set<Int> in
                self.setSelectedTerms(selected: selected, termsIndex: 3)
            }
            .bind(to: selectedTerms)
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
        
        AdvertisinggButton.chevronButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                let webVC = WebViewController(url: "https://silver-curve-9aa.notion.site/304562bcddbd8059b8f7ee323b944f4f?pvs=73")
                webVC.modalPresentationStyle = .formSheet
                self.present(webVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        acceptButton.rx.tap
            .withLatestFrom(isAcceptable)
            .subscribe(with: self, onNext: { owner, isAcceptable in
                if isAcceptable {
                    owner.reactor?.action.onNext(.tapTemrsAgreeButton(
                        owner.selectedTerms.value.contains(2), owner.selectedTerms.value.contains(3)
                    ))
                } else {
                    owner.isAcceptable.accept(true)
                    owner.setAllEnable(true)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isTermsAgreeSuccess }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        selectedTerms
            .subscribe(onNext: { [weak self] arr in
                guard let self else { return }

                termsButton.setState(isSelected: arr.contains(0))
                personalInfoButton.setState(isSelected: arr.contains(1))
                marketingButton.setState(isSelected: arr.contains(2))
                AdvertisinggButton.setState(isSelected: arr.contains(3))

                let requiredAccepted = arr.contains(0) && arr.contains(1)
                isAcceptable.accept(requiredAccepted)

                allCheckButton.setState(isSelected: arr.count == 4)
                acceptButton.backgroundColor = requiredAccepted ? .mainPurple : .grayScale400
            })
            .disposed(by: disposeBag)
    }
    
    private func setAllEnable(_ selected: Bool) {
        [termsButton, personalInfoButton, marketingButton, allCheckButton, AdvertisinggButton].forEach {
            $0.setState(isSelected: selected)
        }
        acceptButton.backgroundColor = .mainPurple
    }
    
    private func setSelectedTerms(selected: Set<Int>, termsIndex: Int) -> Set<Int> {
        var next = selected
        if next.contains(termsIndex) {
            next.remove(termsIndex)
        } else {
            next.insert(termsIndex)
        }
        return next
    }
}
