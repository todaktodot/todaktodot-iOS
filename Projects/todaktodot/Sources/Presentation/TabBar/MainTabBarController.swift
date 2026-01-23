//
//  MainTabBarController.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa

final class MainTabBarController: UIViewController {
    
    private let customTabBar = CustomTabBarView()
    private let containerView = UIView()
    private let rootFlexContainer = UIView()
    private let blurEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterial)
        return UIVisualEffectView(effect: blur)
    }()
    
    private let disposeBag = DisposeBag()
    private var viewControllers: [UIViewController] = []
    private var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        containerView.backgroundColor = .clear
        
        view.addSubview(containerView)
        view.addSubview(blurEffectView)
        view.addSubview(customTabBar)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerView.pin.all()
        
        let shouldHideTabBar = shouldHideCustomTabBar()
        
        if shouldHideTabBar {
            customTabBar.isHidden = true
            blurEffectView.isHidden = true
        } else {
            customTabBar.isHidden = false
            blurEffectView.isHidden = false
            customTabBar.pin.bottom().left().right().height(120)
            blurEffectView.pin.top(to: customTabBar.edge.top).bottom().left().right()
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = blurEffectView.bounds
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.white.cgColor
            ]
            gradientLayer.locations = [0.0, 0.5]
            blurEffectView.layer.mask = gradientLayer
        }
        
        currentViewController?.view.pin.all()
    }
    
    private func shouldHideCustomTabBar() -> Bool {
        guard let navController = currentViewController as? UINavigationController else {
            return false
        }

        return navController.viewControllers.contains { $0.hidesBottomBarWhenPushed }
    }
}

extension MainTabBarController {
    private func setupBindings() {
        customTabBar.selectedTabIndex
            .subscribe(onNext: { [weak self] index in
                self?.showViewController(at: index)
                self?.customTabBar.setSelectedIndex(index, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func setViewControllers(_ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        
        if !viewControllers.isEmpty {
            showViewController(at: 0)
            customTabBar.setSelectedIndex(0, animated: false)
        }
    }
    
    private func showViewController(at index: Int) {
        guard index >= 0 && index < viewControllers.count else { return }
        
        let newViewController = viewControllers[index]
        
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
        
        addChild(newViewController)
        containerView.addSubview(newViewController.view)
        newViewController.view.pin.all()
        newViewController.didMove(toParent: self)
        
        currentViewController = newViewController
        
        // Set up navigation delegate to monitor navigation changes
        if let navController = newViewController as? UINavigationController {
            navController.delegate = self
        }
        
        // Update tab bar visibility
        view.setNeedsLayout()
    }
}

// MARK: - UINavigationControllerDelegate
extension MainTabBarController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        
        let isPushing = navigationController.viewControllers.count > 1
        let shouldHide = viewController.hidesBottomBarWhenPushed || isPushing
        
        if let coordinator = viewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.updateTabBarAppearance(hidden: shouldHide)
            }, completion: nil)
        } else {
            updateTabBarAppearance(hidden: shouldHide)
        }
    }
    
    private func updateTabBarAppearance(hidden: Bool) {
        customTabBar.alpha = hidden ? 0 : 1
        blurEffectView.alpha = hidden ? 0 : 1

        if hidden {
            customTabBar.transform = CGAffineTransform(translationX: 0, y: 150)
        } else {
            customTabBar.transform = .identity
        }
    }
}
