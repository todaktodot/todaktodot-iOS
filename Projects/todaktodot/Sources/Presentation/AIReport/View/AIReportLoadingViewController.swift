//
//  AIReportLoadingViewController.swift
//  todaktodot
//
//  Created by 임대진 on 1/21/26.
//

import UIKit
import PinLayout
import FlexLayout
import Then
import Lottie

final class AIReportLoadingViewController: UIViewController {
    weak var coordinator: AIReportCoordinator?
    private let background = UIImageView().then {
        $0.image = UIImage(resource: .aiReportLoadingBackground)
    }
    
    private let lottie = LottieAnimationView(name: "loading").then {
        $0.loopMode = .loop
    }
    
    private let label = TDLabel().then {
        $0.text = "우리의 AI 리포트가\n만들어지고 있어요"
        $0.font = .pretenSemiBold(24)
        $0.textColor = .grayScale900
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    private var transitionWorkItem: DispatchWorkItem?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        setupViews()
        setupNavigationBar()
        setupFlexLayout()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.coordinator?.showNext(step: .first, animated: false)
        }
        transitionWorkItem = workItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItem)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(resource: .back),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        navigationController?.navigationBar.isHidden = false
        
        disableGlassStyle()
    }
    
    private func setupViews() {
        view.addSubview(background)
    }
    
    private func setupFlexLayout() {
        background.flex.alignItems(.center).define {
            $0.addItem().grow(1)
            
            $0.addItem(lottie)
                .size(160)
            
            $0.addItem(label)
            
            $0.addItem().grow(1)
        }
        
        lottie.play()
    }
    
    private func layoutViews() {
        background.pin.all()
        
        background.flex.layout()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
