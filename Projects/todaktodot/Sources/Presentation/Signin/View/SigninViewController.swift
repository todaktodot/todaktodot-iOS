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

final class SigninViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    private let onboardingView = InfiniteSliderView()
    private let buttonContainerView = UIView()
    
    let kakaoButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: "FAE64D")
        $0.setTitle("카카오 로그인", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        
        $0.layer.cornerRadius = 8
    }
    
    let googleButton = UIButton().then {
        $0.backgroundColor = .white
        $0.setTitle("구글 로그인", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        
        $0.layer.cornerRadius = 8
    }
    
    let appleButton = UIButton().then {
        $0.backgroundColor = .grayScale900
        $0.setTitle("Apple로 로그인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        
        $0.layer.cornerRadius = 8
    }
    
    let appLogo = UIImageView().then {
        $0.image = UIImage(resource: .appLogo)
    }
    let kakaoLogo = UIImageView().then {
        $0.image = UIImage(resource: .kakaoLogo)
    }
    let googleLogo = UIImageView().then {
        $0.image = UIImage(resource: .googleLogo)
    }
    let appleLogo = UIImageView().then {
        $0.image = UIImage(resource: .appleLogo)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        setupFlexLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.addSubview(onboardingView)
        view.addSubview(appLogo)
        view.addSubview(buttonContainerView)
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
        onboardingView.pin
            .all()
        
        appLogo.pin
            .top(view.pin.safeArea.top + 12)
            .left(20)
            .width(92)
            .height(32)
        
        buttonContainerView.pin
            .height(180)
            .horizontally(20)
            .bottom(48)
        
        buttonContainerView.flex.layout()
    }
    
}
