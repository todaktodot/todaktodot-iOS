//
//  ReportCompleteModalViewController.swift
//  todaktodot
//
//  Created by 임대진 on 8/26/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxSwift
import RxRelay
import ReactorKit

final class ReportCompleteModalViewController: UIViewController {
    var disposeBag = DisposeBag()
    weak var coordinator: VoteCoordinator?
    
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
    
    private let checkImage = UIImageView().then {
        $0.image = UIImage(resource: .lightCheck)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "소중한 의견 감사해요"
        $0.font = .pretenSemiBold(20)
        $0.textColor = .grayScale900
    }
    
    private let descriptionLabel = TDLabel().then {
        $0.text = "해당 투표는 피드에서 숨김처리 됐어요"
        $0.font = .pretenRegular(14)
        $0.textColor = .grayScale600
    }
    
    private let configButton = UIButton().then {
        $0.setTitle("확인", for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .mainPurple
        $0.layer.cornerRadius = 6
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
        
        configButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(swipeModal(_:)))
        dimView.addGestureRecognizer(dismiss)
        modalView.addGestureRecognizer(swipe)
    }
    
    private func setupFlexLayout() {
        
        modalView.flex
            .alignItems(.center)
            .paddingHorizontal(20).define {
                $0.addItem(handleBarView)
                    .marginTop(12)
                    .alignSelf(.center)
                    .width(52)
                    .height(6)
                    .cornerRadius(3)
                
                $0.addItem(checkImage)
                    .marginTop(20)
                
                $0.addItem(titleLabel)
                    .marginTop(8)
                    .height(27)
                
                $0.addItem(descriptionLabel)
                    .marginTop(8)
                    .height(18)
                
                $0.addItem(configButton)
                    .marginTop(24)
                    .height(52)
                    .width(100%)
        }
    }
    
    private func layoutViews() {
        dimView.pin
            .all()
        
        modalView.pin
            .horizontally()
            .bottom()
            .height(271)
        
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
