//
//  SigninViewController.swift
//  todaktodot
//
//  Created by 임대진 on 12/12/25.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa
import Then
import ReactorKit

final class SigninViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    weak var coordinator: SigninCoordinator?
    
    private let onboardingView = InfiniteSliderView()
    private let buttonContainerView = UIView()
    private let indicatorView = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }
    
    private let kakaoButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: "FAE64D")
        $0.setTitle("카카오 로그인", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        
        $0.layer.cornerRadius = 8
    }
    
    private let googleButton = UIButton().then {
        $0.backgroundColor = .white
        $0.setTitle("구글 로그인", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        
        $0.layer.cornerRadius = 8
    }
    
    private let appleButton = UIButton().then {
        $0.backgroundColor = .grayScale900
        $0.setTitle("Apple로 로그인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        
        $0.layer.cornerRadius = 8
    }
    
    private let appLogo = UIImageView().then {
        $0.image = UIImage(resource: .appLogo)
    }
    private let kakaoLogo = UIImageView().then {
        $0.image = UIImage(resource: .kakaoLogo)
    }
    private let googleLogo = UIImageView().then {
        $0.image = UIImage(resource: .googleLogo)
    }
    private let appleLogo = UIImageView().then {
        $0.image = UIImage(resource: .appleLogo)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        setupFlexLayout()
        bindActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        indicatorView.stopAnimating()
    }
    
    private func setupViews() {
        view.addSubview(onboardingView)
        view.addSubview(appLogo)
        view.addSubview(buttonContainerView)
        view.addSubview(indicatorView)
    }
    
    private func setupFlexLayout() {
        
        kakaoButton.flex.define {
            $0.addItem(kakaoLogo)
                .marginTop(16)
                .marginLeft(20)
                .marginBottom(12)
                .size(24)
        }
        
        googleButton.flex.define {
            $0.addItem(googleLogo)
                .marginLeft(20)
                .marginVertical(14)
                .size(24)
        }
        
        appleButton.flex.define {
            $0.addItem(appleLogo)
                .marginLeft(20)
                .marginVertical(14)
                .size(24)
        }
        
        buttonContainerView.flex.gap(12).define {
            $0.addItem(kakaoButton)
                .height(52)
            
            $0.addItem(googleButton)
                .height(52)
            
            $0.addItem(appleButton)
                .height(52)
        }
    }
    
    private func layoutViews() {
        indicatorView.pin
            .all()
        
        onboardingView.pin
            .all()
        
        appLogo.pin
            .top(56)
            .left(20)
            .width(92)
            .height(32)
        
        buttonContainerView.pin
            .height(180)
            .horizontally(20)
            .bottom(48)
        
        buttonContainerView.flex.layout()
    }
    
    private func bindActions() {
        appleButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                coordinator?.navigateToMain()
            })
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: SigninReactor) {
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                isLoading
                ? self?.indicatorView.startAnimating()
                : self?.indicatorView.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.signinEvent }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .kakaoSuccess, .googleSuccess:
                    self.moveNext()
                    
                case .kakaoFail:
                    break
                    
                case .googleFail:
                    break
                }
                self.reactor?.action.onNext(.clearEvent)
            })
            .disposed(by: disposeBag)
        
        kakaoButton.rx.tap
            .map { SigninReactor.Action.tapKakaoButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        googleButton.rx.tap
            .map { SigninReactor.Action.tapGoogleButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func moveNext() {
//        if UserdefaultKey.couple && UserdefaultKey.joined {
//            coordinator?.navigateToMain()
//        } else {
//            coordinator?.showCoupleConnect()
//        }
        coordinator?.showCoupleConnect() // TODO: 임시 처리
    }
}
