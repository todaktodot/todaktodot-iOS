//
//  MenuModalViewController.swift
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

final class MenuModalViewController: UIViewController {
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
    
    private let reportButton = UIButton().then {
        $0.setTitle("신고", for: .normal)
        $0.setTitleColor(.redErrorColor, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.contentHorizontalAlignment = .left
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
        
        reportButton.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(swipeModal(_:)))
        dimView.addGestureRecognizer(dismiss)
        modalView.addGestureRecognizer(swipe)
    }
    
    private func setupFlexLayout() {
        
        modalView.flex.paddingHorizontal(20).define {
            $0.addItem(handleBarView)
                .marginTop(12)
                .alignSelf(.center)
                .width(52)
                .height(6)
                .cornerRadius(3)
            
            $0.addItem(reportButton)
                .marginTop(20)
                .marginBottom(32)
                .height(40)
                .width(view.bounds.width - 40)
        }
    }
    
    private func layoutViews() {
        dimView.pin
            .all()
        
        modalView.pin
            .horizontally()
            .bottom()
            .height(110)
        
        modalView.flex.layout()
    }
    
    
    @objc func dismissModal() {
        coordinator?.dismissModal()
    }
    
    @objc private func didTapReport() {
        coordinator?.showModal(type: .report)
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
